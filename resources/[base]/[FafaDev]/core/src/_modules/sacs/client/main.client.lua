local currentBag = nil

local function FUN_APPLY_BAG_VISUAL(playerId, bagData)
    if not bagData then return end
    local playerPed = GetPlayerPed(playerId)
    if not playerPed or playerPed == 0 then return end
    SetPedComponentVariation(playerPed, 5, bagData.bags_1, bagData.variation, 0)
end

local function FUN_REMOVE_BAG_VISUAL(playerId)
    local playerPed = GetPlayerPed(playerId)
    if not playerPed or playerPed == 0 then return end
    SetPedComponentVariation(playerPed, 5, 0, 0, 0)
end

RegisterNetEvent('fafadev:client:remove_bag_visual')
AddEventHandler('fafadev:client:remove_bag_visual', function()
    FUN_REMOVE_BAG_VISUAL(PlayerId())
    currentBag = nil
    TriggerEvent('fafadev:client:update_current_bag', nil)
end)

RegisterNetEvent('fafadev:useBag')
AddEventHandler('fafadev:useBag', function(data, slot)
    local itemName = data.name
    local bagConfig = CONFIG_SACS.bags[itemName]
    if not bagConfig then return end
    CORE.trigger_server_event('fafadev:to_server:equip_bag', itemName)
    
    currentBag = {
        bagName = itemName .. "_" .. GetPlayerServerId(PlayerId()),
        bag = bagConfig
    }
    
    FUN_APPLY_BAG_VISUAL(PlayerId(), bagConfig)
    
    TriggerEvent('fafadev:client:update_current_bag', currentBag)
    
    ESX.ShowNotification('Sac équipé !')
end)

CORE.register_client_callback('fafadev:client:sync_bags', function(handler, allPlayerBags)
    for playerId, bagData in pairs(allPlayerBags or {}) do
        FUN_APPLY_BAG_VISUAL(playerId, bagData.bag)
    end
    
    local playerId = GetPlayerServerId(PlayerId())
    
    if allPlayerBags and allPlayerBags[playerId] then
        currentBag = {
            bagName = allPlayerBags[playerId].bagName,
            bag = allPlayerBags[playerId].bag
        }
        TriggerEvent('fafadev:client:update_current_bag', currentBag)
    else
        currentBag = nil
        TriggerEvent('fafadev:client:update_current_bag', nil)
    end
    
    handler(true)
end)

RegisterNetEvent('fafadev:client:apply_bag_visual')
AddEventHandler('fafadev:client:apply_bag_visual', function(bagConfig)
    FUN_APPLY_BAG_VISUAL(PlayerId(), bagConfig)
end)

RegisterNetEvent('fafadev:client:play_drop_animation')
AddEventHandler('fafadev:client:play_drop_animation', function()
    local playerPed = PlayerPedId()
    local animConfig = CONFIG_SACS.animations.drop
    
    RequestAnimDict(animConfig.dict)
    while not HasAnimDictLoaded(animConfig.dict) do
        Citizen.Wait(0)
    end
    
    TaskPlayAnim(playerPed, animConfig.dict, animConfig.name, 8.0, -8.0, -1, 0, 0, false, false, false)
    
    Citizen.SetTimeout(animConfig.duration, function()
        ClearPedTasks(playerPed)
    end)
end)

AddEventHandler('esx:playerLoaded', function()
    CORE.trigger_server_event('fafadev:to_server:request_bag_sync')
end)
