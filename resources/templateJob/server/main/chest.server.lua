local function getOrCreateChest(jobName, callback)
    MySQL.Async.fetchAll(
        "SELECT * FROM fafa_chest WHERE job_name = ?",
        {jobName},
        function(result)
            if #result > 0 then
                callback(result[1])
            else
                MySQL.Async.execute(
                    "INSERT INTO fafa_chest (job_name, items, max_weight) VALUES (?, ?, ?)",
                    {jobName, "{}", 100.00},
                    function(affectedRows)
                        if affectedRows > 0 then
                            MySQL.Async.fetchAll(
                                "SELECT * FROM fafa_chest WHERE job_name = ?",
                                {jobName},
                                function(newResult)
                                    if #newResult > 0 then
                                        callback(newResult[1])
                                    else
                                        callback(nil)
                                    end
                                end
                            )
                        else
                            callback(nil)
                        end
                    end
                )
            end
        end
    )
end

local function calculateCurrentWeight(chestItems, xPlayer, callback)
    local totalWeight = 0
    for itemKey, itemData in pairs(chestItems) do
        local itemWeight = 0
        if itemData.type == "weapon" then
            itemWeight = 0.1
        else
            local item = xPlayer.getInventoryItem(itemData.name)
            if item and item.weight then
                itemWeight = item.weight
            else
                itemWeight = 0.1
            end
        end
        totalWeight = totalWeight + (itemWeight * itemData.quantity)
    end
    callback(totalWeight)
end

local function getItemWeight(itemName, itemType, xPlayer, callback)
    if itemType == "weapon" then
        callback(0.1)
    else
        local item = xPlayer.getInventoryItem(itemName)
        if item and item.weight then
            callback(item.weight)
        else
            callback(0.1)
        end
    end
end

RegisterServerEventWithLog("templatejobto_server:deposit_item", function(item, quantity)
    local _source = source
    if not check_source(_source) then return end
    
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not check_xplayer(xPlayer) then return end
    if not check_job(xPlayer, CONFIG_INFOS_JOB.job_name) then return end
    
    local playerItem = nil
    local itemType = "item"
    
    if item.type == "weapon" then
        playerItem = xPlayer.getWeapon(item.name)
        itemType = "weapon"
        if not playerItem or playerItem.ammo < quantity then
            xPlayer.showNotification(T("chest_error_not_enough_ammo"))
            return
        end
    else
        playerItem = xPlayer.getInventoryItem(item.name)
        if not playerItem or playerItem.count < quantity then
            xPlayer.showNotification(T("chest_error_not_enough_item"))
            return
        end
    end
    
    getOrCreateChest(CONFIG_INFOS_JOB.job_name, function(chestEntry)
        if not chestEntry then
            xPlayer.showNotification(T("chest_error_access"))
            return
        end
        
        local chestItems = json.decode(chestEntry.items) or {}
        local itemKey = item.name .. "_" .. itemType
        
        getItemWeight(item.name, itemType, xPlayer, function(itemWeight)
            calculateCurrentWeight(chestItems, xPlayer, function(currentWeight)
                local newWeight = tonumber(currentWeight) + (tonumber(itemWeight) * quantity)
                local maxWeight = tonumber(chestEntry.max_weight)
                
                if newWeight > maxWeight then
                    xPlayer.showNotification(T("chest_error_too_heavy", newWeight, maxWeight))
                    return
                end
                
                if chestItems[itemKey] then
                    chestItems[itemKey].quantity = chestItems[itemKey].quantity + quantity
                else
                    chestItems[itemKey] = {
                        name = item.name,
                        label = item.label,
                        type = itemType,
                        quantity = quantity,
                        metadata = item.metadata
                    }
                end
                
                local itemsJson = json.encode(chestItems)
                MySQL.Async.execute(
                    "UPDATE fafa_chest SET items = ? WHERE id = ?",
                    {itemsJson, chestEntry.id},
                    function(affectedRows)
                        if affectedRows > 0 then
                            if itemType == "weapon" then
                                xPlayer.removeWeaponAmmo(item.name, quantity)
                            else
                                xPlayer.removeInventoryItem(item.name, quantity)
                            end
                            xPlayer.showNotification(T("chest_success_deposited", quantity, item.label, newWeight, maxWeight))
                            -- Webhook Discord
                            local discordMessage = T("discord_chest_deposit", quantity, item.label) .. "\n" .. T("discord_chest_weight", newWeight, maxWeight)
                            send_discord_message(_source, "chest", "chest", T("discord_title_chest_deposit"), discordMessage, xPlayer.getName())
                        else
                            xPlayer.showNotification(T("chest_error_deposit"))
                        end
                    end
                )
            end)
        end)
    end)
end)

RegisterServerEventWithLog("templatejobto_server:withdraw_item", function(item, quantity)
    local _source = source
    if not check_source(_source) then return end
    
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not check_xplayer(xPlayer) then return end
    if not check_job(xPlayer, CONFIG_INFOS_JOB.job_name) then return end
    
    getOrCreateChest(CONFIG_INFOS_JOB.job_name, function(chestEntry)
        if not chestEntry then
            xPlayer.showNotification(T("chest_error_access"))
            return
        end
        
        local chestItems = json.decode(chestEntry.items) or {}
        local itemKey = item.name .. "_" .. item.type
        
        if not chestItems[itemKey] then
            xPlayer.showNotification(T("chest_error_item_not_found"))
            return
        end
        
        local chestItem = chestItems[itemKey]
        if chestItem.quantity < quantity then
            xPlayer.showNotification(T("chest_error_not_enough_items"))
            return
        end
        
        if item.type == "weapon" then
            xPlayer.addWeaponAmmo(item.name, quantity)
        else
            local canCarry = xPlayer.canCarryItem(item.name, quantity)
            if not canCarry then
                xPlayer.showNotification(T("chest_error_cannot_carry"))
                return
            end
            xPlayer.addInventoryItem(item.name, quantity)
        end
        
        local newQuantity = chestItem.quantity - quantity
        if newQuantity <= 0 then
            chestItems[itemKey] = nil
        else
            chestItems[itemKey].quantity = newQuantity
        end
        
        local itemsJson = json.encode(chestItems)
        
        calculateCurrentWeight(chestItems, xPlayer, function(newWeight)
            local maxWeight = tonumber(chestEntry.max_weight)
            MySQL.Async.execute(
                "UPDATE fafa_chest SET items = ? WHERE id = ?",
                {itemsJson, chestEntry.id},
                function(affectedRows)
                    if affectedRows > 0 then
                        xPlayer.showNotification(T("chest_success_withdrawn", quantity, item.label, newWeight, maxWeight))
                        -- Webhook Discord
                        local discordMessage = T("discord_chest_withdraw", quantity, item.label) .. "\n" .. T("discord_chest_weight", newWeight, maxWeight)
                        send_discord_message(_source, "chest", "chest", T("discord_title_chest_withdraw"), discordMessage, xPlayer.getName())
                    end
                end
            )
        end)
    end)
end)

RegisterServerCallbackWithLog("templatejobto_server:get_chest_items", function(source, cb)
    local _source = source
    if not check_source(_source) then return end
    
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not check_xplayer(xPlayer) then return end
    if not check_job(xPlayer, CONFIG_INFOS_JOB.job_name) then return end
    
    getOrCreateChest(CONFIG_INFOS_JOB.job_name, function(chestEntry)
        if not chestEntry then
            cb({})
            return
        end
        
        local chestItems = json.decode(chestEntry.items) or {}
        local itemsList = {}
        
        for itemKey, itemData in pairs(chestItems) do
            table.insert(itemsList, {
                id = itemKey,
                name = itemData.name,
                label = itemData.label,
                type = itemData.type,
                quantity = itemData.quantity,
                metadata = itemData.metadata
            })
        end
        
        table.sort(itemsList, function(a, b)
            if a.type ~= b.type then
                return a.type < b.type
            end
            return a.label < b.label
        end)
        
        cb(itemsList)
    end)
end)

RegisterServerCallbackWithLog("templatejobto_server:get_chest_info", function(source, cb)
    local _source = source
    if not check_source(_source) then return end
    
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not check_xplayer(xPlayer) then return end
    if not check_job(xPlayer, CONFIG_INFOS_JOB.job_name) then return end
    
    getOrCreateChest(CONFIG_INFOS_JOB.job_name, function(chestEntry)
        if not chestEntry then
            cb({current_weight = 0, max_weight = 100})
            return
        end
        
        local chestItems = json.decode(chestEntry.items) or {}
        
        calculateCurrentWeight(chestItems, xPlayer, function(currentWeight)
            cb({
                current_weight = tonumber(currentWeight) or 0,
                max_weight = tonumber(chestEntry.max_weight) or 100
            })
        end)
    end)
end)