local CONFIG_TRASH_DATA = {}

local function getRandomItem()
    local random = math.random(100)
    local cumulative = 0
    
    for category, chance in pairs(CONFIG_TRASH.chances) do
        cumulative = cumulative + chance
        if random <= cumulative then
            if category == "rien" then
                return nil
            end
            
            local items = CONFIG_TRASH.items[category]
            if items and #items > 0 then
                local item = items[math.random(#items)]
                if math.random(100) <= item.chance then
                    local count = math.random(item.min_count, item.max_count)
                    return {
                        name = item.name,
                        label = item.label,
                        count = count
                    }
                end
            end
        end
    end
    
    return nil
end


CORE.register_server_event("fafadev:to_server:search_trash_bin", function(source, bin_id)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        return 
    end
    
    if CONFIG_TRASH_DATA[bin_id] then
        CORE.trigger_client_event("fafadev:to_client:trash_search_result", source, "already_searched", "Cette poubelle a déjà été fouillée", 0, 0)
        return
    end
    
    CONFIG_TRASH_DATA[bin_id] = GetGameTimer()
    
    local item = getRandomItem()
    
    if item then
        if item.name == "money" then
            xPlayer.addMoney(item.count)
            CORE.trigger_client_event("fafadev:to_client:trash_search_result", source, "money", "Argent", item.count, item.count)
        else
            xPlayer.addInventoryItem(item.name, item.count)
            CORE.trigger_client_event("fafadev:to_client:trash_search_result", source, item.name, item.label, item.count, 0)
        end
    else
        CORE.trigger_client_event("fafadev:to_client:trash_search_result", source, nil, nil, 0, 0)
    end
    
    CORE.trigger_client_event("fafadev:to_client:sync_trash_data", -1, CONFIG_TRASH_DATA)
end)
