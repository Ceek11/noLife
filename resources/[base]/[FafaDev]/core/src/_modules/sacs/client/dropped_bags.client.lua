local droppedBags = {}
local currentOpenBagId = nil


CORE.register_client_callback('fafadev:client:sync_dropped_bags', function(handler, allDroppedBags)
    local newDroppedBags = allDroppedBags or {}

    for bagId, bag in pairs(droppedBags) do
        if not newDroppedBags[bagId] and bag.prop and DoesEntityExist(bag.prop) then
            SetEntityAsMissionEntity(bag.prop, false, true)
            DeleteObject(bag.prop)
            bag.prop = nil
        end
    end

    for bagId, bagData in pairs(newDroppedBags) do
        if not droppedBags[bagId] then
            local prop = createBagProp(bagId, bagData)
            if prop then
                newDroppedBags[bagId].prop = prop
            end
        end
    end

    droppedBags = newDroppedBags

    FUN_HANDLE_DROPPED_BAGS(droppedBags)
    handler(true)
end)

function createBagProp(bagId, bagData)
    local propModel = "prop_cs_heist_bag_02"
    
    for _, config in pairs(CONFIG_SACS.bags) do
        if config.bags_1 == bagData.bagType then
            propModel = config.prop
            break
        end
    end
    
    RequestModel(GetHashKey(propModel))
    while not HasModelLoaded(GetHashKey(propModel)) do
        Citizen.Wait(0)
    end
    
    local spawnCoords = vector3(bagData.coords.x, bagData.coords.y, bagData.coords.z - 1.0)
    local prop = CreateObject(GetHashKey(propModel), spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, true)
    
    if prop and prop ~= 0 then
        SetEntityHeading(prop, bagData.heading)
        FreezeEntityPosition(prop, true)
        SetEntityAsMissionEntity(prop, true, true)
        
        SetEntityCollision(prop, false, false)
        SetEntityCompletelyDisableCollision(prop, true, false)
        
        return prop
    else
        return nil
    end
end

function FUN_HANDLE_DROPPED_BAGS(bags)
    AddTickHandler("dropped_bags", 0, function()
        local playerCoords = GetEntityCoords(PlayerPedId())
        local markerNear = false

        for bagId, bagData in pairs(bags) do
            if bagData.coords then
                local distance = #(playerCoords - bagData.coords)

                if distance < 2.0 then
                    markerNear = true
                    ESX.ShowHelpNotification("~INPUT_CONTEXT~ Ouvrir le sac\n~INPUT_DETONATE~ Ramasser le sac")

                    if IsControlJustPressed(0, 38) then
                        currentOpenBagId = bagId
                        CORE.trigger_server_event('fafadev:to_server:open_dropped_bag', bagId)
                    elseif IsControlJustPressed(0, 246) then
                        CORE.trigger_server_event('fafadev:to_server:pickup_dropped_bag', bagId)
                    end
                end
            end
        end

        if not markerNear then
            SetIntervalEnabled(false, "dropped_bags")
        else
            SetIntervalEnabled(true, "dropped_bags")
        end
    end)
end

AddEventHandler('ox_inventory:closed', function()
    if currentOpenBagId then
        CORE.trigger_server_event('fafadev:to_server:save_dropped_bag_items', currentOpenBagId)
        currentOpenBagId = nil
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, bag in pairs(droppedBags) do
            if bag.prop and DoesEntityExist(bag.prop) then
                SetEntityAsMissionEntity(bag.prop, false, true)
                DeleteObject(bag.prop)
            end
        end
        droppedBags = {}
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Citizen.Wait(2000)
        CORE.trigger_server_event('fafadev:to_server:request_dropped_bags_sync')
    end
end)
