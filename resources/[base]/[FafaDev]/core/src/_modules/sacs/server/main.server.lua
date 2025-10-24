local TBL_PLAYER_BAGS = {}
local TBL_DROPPED_BAGS = {}

local function hasItemsInBag(bagName)
    local inventory = exports.ox_inventory:GetInventory(bagName, false)
    return inventory and inventory.weight and inventory.weight > 0
end

CORE.register_server_event('fafadev:to_server:equip_bag', function(source, bagName)
    local bagConfig = CONFIG_SACS.bags[bagName]
    if not bagConfig then return end
    
    local bagName_full = bagName .. "_" .. source
    exports.ox_inventory:RegisterStash(bagName_full, bagName, bagConfig.capacity, 100000, false)
    
    TBL_PLAYER_BAGS[source] = {
        bagName = bagName_full,
        bag = bagConfig
    }
    
    CORE.trigger_client_callback('fafadev:client:sync_bags', -1, function() end, TBL_PLAYER_BAGS)
end)

CORE.register_server_event('fafadev:to_server:remove_bag', function(source)
    if not TBL_PLAYER_BAGS[source] then return end
    
    local bagName = TBL_PLAYER_BAGS[source].bagName
    
    if hasItemsInBag(bagName) then
        TriggerClientEvent('esx:showNotification', source, '~r~Impossible de retirer le sac : il contient encore des objets')
        CORE.trigger_client_callback('fafadev:client:sync_bags', source, function() end, TBL_PLAYER_BAGS)
        return
    end
    
    TBL_PLAYER_BAGS[source] = nil
    TriggerClientEvent('fafadev:client:remove_bag_visual', source)
    CORE.trigger_client_callback('fafadev:client:sync_bags', -1, function() end, TBL_PLAYER_BAGS)
    TriggerClientEvent('esx:showNotification', source, 'Sac retiré avec succès')
end)

CORE.register_server_event('fafadev:to_server:drop_bag', function(source)
    if not TBL_PLAYER_BAGS[source] then return end
    
    
    local bagData = TBL_PLAYER_BAGS[source]
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local playerHeading = GetEntityHeading(GetPlayerPed(source))
    
    local bagItems = exports.ox_inventory:GetInventoryItems(bagData.bagName, false)
    local itemsJson = json.encode(bagItems or {})
    
    MySQL.Async.insert('INSERT INTO dropped_bags (bag_name, bag_type, owner_identifier, x, y, z, heading, items) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        bagData.bagName,
        bagData.bag.bags_1,
        GetPlayerIdentifier(source, 0),
        playerCoords.x,
        playerCoords.y,
        playerCoords.z,
        playerHeading,
        itemsJson
    }, function(insertId)
        if insertId then
            TBL_DROPPED_BAGS[insertId] = {
                id = insertId,
                bagName = bagData.bagName,
                bagType = bagData.bag.bags_1,
                owner = GetPlayerIdentifier(source, 0),
                coords = vector3(playerCoords.x, playerCoords.y, playerCoords.z),
                heading = playerHeading,
                items = bagItems or {}
            }
            
            CORE.trigger_client_callback('fafadev:client:sync_dropped_bags', -1, function() end, TBL_DROPPED_BAGS)
        end
    end)
    
    TBL_PLAYER_BAGS[source] = nil
    TriggerClientEvent('fafadev:client:remove_bag_visual', source)
    TriggerClientEvent('fafadev:client:play_drop_animation', source)
    CORE.trigger_client_callback('fafadev:client:sync_bags', -1, function() end, TBL_PLAYER_BAGS)
    TriggerClientEvent('esx:showNotification', source, 'Sac posé au sol')
end)

CORE.register_server_event('fafadev:to_server:open_bag_inventory', function(source)
    if not TBL_PLAYER_BAGS[source] then 
        TriggerClientEvent('esx:showNotification', source, "Vous n'avez pas de sac équipé")
        return 
    end
    
    TriggerClientEvent('ox_inventory:openInventory', source, 'stash', {
        id = TBL_PLAYER_BAGS[source].bagName,
        owner = false
    })
end)

CORE.register_server_event('fafadev:to_server:request_bag_sync', function(source)
    CORE.trigger_client_callback('fafadev:client:sync_bags', source, function() end, TBL_PLAYER_BAGS)
end)

CORE.register_server_event('fafadev:to_server:request_dropped_bags_sync', function(source)
    CORE.trigger_client_callback('fafadev:client:sync_dropped_bags', source, function() end, TBL_DROPPED_BAGS)
end)

Citizen.CreateThread(function()
    MySQL.Async.fetchAll('SELECT * FROM dropped_bags', {}, function(results)
        for _, bag in pairs(results) do
            local items = {}
            if bag.items then
                items = json.decode(bag.items) or {}
            end
            
            TBL_DROPPED_BAGS[bag.id] = {
                id = bag.id,
                bagName = bag.bag_name,
                bagType = bag.bag_type,
                owner = bag.owner_identifier,
                coords = vector3(tonumber(bag.x), tonumber(bag.y), tonumber(bag.z)),
                heading = tonumber(bag.heading),
                items = items
            }
        end
        CORE.trigger_client_callback('fafadev:client:sync_dropped_bags', -1, function() end, TBL_DROPPED_BAGS)
    end)
end)

CORE.register_server_event('fafadev:to_server:open_dropped_bag', function(source, bagId)
    if not TBL_DROPPED_BAGS[bagId] then return end
    
    local bagData = TBL_DROPPED_BAGS[bagId]
    local tempStashName = "dropped_bag_" .. bagId
    
    exports.ox_inventory:RegisterStash(tempStashName, "Sac au sol", 60, 100000, false)
    
    for slot, item in pairs(bagData.items) do
        if item and item.name then
            exports.ox_inventory:AddItem(tempStashName, item.name, item.count, item.metadata, slot)
        end
    end
    
    TriggerClientEvent('ox_inventory:openInventory', source, 'stash', {
        id = tempStashName,
        owner = false
    })
    
    MySQL.Async.execute('UPDATE dropped_bags SET last_accessed = NOW() WHERE id = ?', {bagId})
end)

CORE.register_server_event('fafadev:to_server:save_dropped_bag_items', function(source, bagId)
    if not TBL_DROPPED_BAGS[bagId] then return end
    
    local tempStashName = "dropped_bag_" .. bagId
    local updatedItems = exports.ox_inventory:GetInventoryItems(tempStashName, false)
    local itemsJson = json.encode(updatedItems or {})
    
    MySQL.Async.execute('UPDATE dropped_bags SET items = ? WHERE id = ?', {itemsJson, bagId}, function(affectedRows)
        if affectedRows > 0 then
            TBL_DROPPED_BAGS[bagId].items = updatedItems or {}
        end
    end)
    
    exports.ox_inventory:ClearInventory(tempStashName)
end)

CORE.register_server_event('fafadev:to_server:pickup_dropped_bag', function(source, bagId)
    if not TBL_DROPPED_BAGS[bagId] then return end
    
    local bagData = TBL_DROPPED_BAGS[bagId]
    
    if TBL_PLAYER_BAGS[source] then
        TriggerClientEvent('esx:showNotification', source, '~r~Vous avez déjà un sac équipé')
        return
    end
    
    local hasItems = false
    for slot, item in pairs(bagData.items) do
        if item and item.name and item.count and item.count > 0 then
            hasItems = true
            break
        end
    end
    
    if hasItems then
        TriggerClientEvent('esx:showNotification', source, '~y~Attention : Le sac contient des objets ! Ils seront perdus.')
    end
    
    local bagItemName = nil
    local bagTypeNumber = tonumber(bagData.bagType)
    for itemName, config in pairs(CONFIG_SACS.bags) do
        if config.bags_1 == bagTypeNumber then
            bagItemName = itemName
            break
        end
    end
    if bagItemName then
        local newBagName = bagItemName .. "_" .. source
        local bagConfig = CONFIG_SACS.bags[bagItemName]
        
        exports.ox_inventory:RegisterStash(newBagName, bagItemName, bagConfig.capacity, 100000, false)
        
        local existingItems = exports.ox_inventory:GetInventoryItems(newBagName, false)
        if not existingItems or next(existingItems) == nil then
            for slot, item in pairs(bagData.items) do
                if item and item.name then
                    exports.ox_inventory:AddItem(newBagName, item.name, item.count, item.metadata, slot)
                end
            end
        end
        
        TBL_PLAYER_BAGS[source] = {
            bagName = newBagName,
            bag = bagConfig
        }
        
        CORE.trigger_client_callback('fafadev:client:sync_bags', -1, function() end, TBL_PLAYER_BAGS)
        
        TriggerClientEvent('fafadev:client:apply_bag_visual', source, bagConfig)
        TriggerClientEvent('esx:showNotification', source, 'Sac équipé !')
        
        Citizen.SetTimeout(100, function()
            TBL_DROPPED_BAGS[bagId] = nil
            CORE.trigger_client_callback('fafadev:client:sync_dropped_bags', -1, function() end, TBL_DROPPED_BAGS)
            
            MySQL.Async.execute('DELETE FROM dropped_bags WHERE id = ?', {bagId}, function(affectedRows)
            end)
        end)
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    if TBL_PLAYER_BAGS[source] then
        TBL_PLAYER_BAGS[source] = nil
        CORE.trigger_client_callback('fafadev:client:sync_bags', -1, function() end, TBL_PLAYER_BAGS)
    end
end)