function SpawnVehicle(vehicleModel)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    RequestModel(vehicleModel)
    local timeout = 0
    while not HasModelLoaded(vehicleModel) and timeout < 5000 do
        Wait(100)
        timeout = timeout + 100
    end
    
    if not HasModelLoaded(vehicleModel) then
        lib.notify({
            title = 'ToolsTraillers',
            description = 'Modèle de véhicule introuvable',
            type = 'error'
        })
        return nil
    end
    
    local spawnCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 3.0, 0.0)
    local vehicle = CreateVehicle(vehicleModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, true, true)
    SetVehicleOnGroundProperly(vehicle)
    SetModelAsNoLongerNeeded(vehicleModel)
    
    return vehicle
end

function SpawnPed(pedModel)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    RequestModel(pedModel)
    local timeout = 0
    while not HasModelLoaded(pedModel) and timeout < 5000 do
        Wait(100)
        timeout = timeout + 100
    end
    
    if not HasModelLoaded(pedModel) then
        lib.notify({
            title = 'ToolsTraillers',
            description = 'Modèle de PNJ introuvable',
            type = 'error'
        })
        return nil
    end
    
    local spawnCoords = GetOffsetFromEntityInWorldCoords(playerPed, 2.0, 0.0, 0.0)
    local ped = CreatePed(4, pedModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, true, true)
    SetPedOnGroundProperly(ped)
    SetModelAsNoLongerNeeded(pedModel)
    
    return ped
end

function ToggleInvisibility()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        local isVisible = IsEntityVisible(vehicle)
        SetEntityVisible(vehicle, not isVisible, false)
        SetEntityVisible(ped, not isVisible, false)
    else
        local isVisible = IsEntityVisible(ped)
        SetEntityVisible(ped, not isVisible, false)
    end
end

function GetInvisibilityState()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        return not IsEntityVisible(vehicle)
    else
        return not IsEntityVisible(ped)
    end
end

currentTimeScale = 1.0

function SetSlowMotion(speed)
    if speed < 0.1 then speed = 0.1 end
    if speed > 1.0 then speed = 1.0 end
    currentTimeScale = speed
    SetTimeScale(speed)
end

function GetSlowMotionState()
    return currentTimeScale ~= 1.0
end

function ToggleSlowMotion()
    if currentTimeScale == 1.0 then
        SetSlowMotion(0.5)
    else
        SetSlowMotion(1.0)
    end
end

function RepairVehicle()
    local vehicle = get_nearby_vehicle(true, false)
    
    if vehicle then
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, true, false)
        
        lib.notify({
            title = 'ToolsTraillers',
            description = 'Véhicule réparé',
            type = 'success'
        })
        
        return true
    end
    
    return false
end

function DeleteSelectedVehicle()
    local vehicle = get_nearby_vehicle(true, false)
    
    if vehicle then
        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteEntity(vehicle)
        
        lib.notify({
            title = 'ToolsTraillers',
            description = 'Véhicule supprimé',
            type = 'success'
        })
        
        return true
    end
    
    return false
end

function TeleportToCoords(x, y, z)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        SetEntityCoords(vehicle, x, y, z, false, false, false, false)
    else
        SetEntityCoords(ped, x, y, z, false, false, false, false)
    end
    
    lib.notify({
        title = 'ToolsTraillers',
        description = 'Téléportation réussie',
        type = 'success'
    })
end

function TeleportToWaypoint()
    local waypoint = GetFirstBlipInfoId(8)
    
    if waypoint == 0 then
        lib.notify({
            title = 'ToolsTraillers',
            description = 'Aucun waypoint défini',
            type = 'error'
        })
        return false
    end
    
    local coords = GetBlipInfoIdCoord(waypoint)
    TeleportToCoords(coords.x, coords.y, coords.z)
    return true
end

function TeleportToPlayer(playerId)
    if not playerId then
        return false
    end
    
    local targetPed = GetPlayerPed(playerId)
    
    if not DoesEntityExist(targetPed) then
        lib.notify({
            title = 'ToolsTraillers',
            description = 'Joueur introuvable',
            type = 'error'
        })
        return false
    end
    
    local coords = GetEntityCoords(targetPed)
    TeleportToCoords(coords.x, coords.y, coords.z)
    return true
end

function PlayAnimation(dict, anim, duration)
    local ped = PlayerPedId()
    
    RequestAnimDict(dict)
    local timeout = 0
    while not HasAnimDictLoaded(dict) and timeout < 5000 do
        Wait(100)
        timeout = timeout + 100
    end
    
    if not HasAnimDictLoaded(dict) then
        lib.notify({
            title = 'ToolsTraillers',
            description = 'Animation introuvable: ' .. dict,
            type = 'error'
        })
        return false
    end
    
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, duration or -1, 1, 0, false, false, false)
    SetModelAsNoLongerNeeded(dict)
    
    lib.notify({
        title = 'ToolsTraillers',
        description = 'Animation lancée: ' .. anim,
        type = 'success'
    })
    
    return true
end

function StopAnimation()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    
    lib.notify({
        title = 'ToolsTraillers',
        description = 'Animation arrêtée',
        type = 'info'
    })
end

function PlayAnimationFromConfig(animData)
    if not animData or not animData.dict or not animData.anim then
        lib.notify({
            title = 'ToolsTraillers',
            description = 'Données d\'animation invalides',
            type = 'error'
        })
        return false
    end
    
    PlayAnimation(animData.dict, animData.anim, animData.duration)
    return true
end

function SetWeather(weatherType)
    SetWeatherTypePersist(weatherType)
    SetWeatherTypeNow(weatherType)
    SetWeatherTypeNowPersist(weatherType)
    
    lib.notify({
        title = 'ToolsTraillers',
        description = 'Météo changée: ' .. weatherType,
        type = 'success'
    })
end

function SetTime(hour, minute)
    NetworkOverrideClockTime(hour, minute, 0)
    
    lib.notify({
        title = 'ToolsTraillers',
        description = 'Heure changée: ' .. hour .. ':' .. (minute < 10 and '0' or '') .. minute,
        type = 'success'
    })
end

function SetGravity(gravity)
    SetGravityLevel(gravity)
    
    lib.notify({
        title = 'ToolsTraillers',
        description = 'Gravité changée: ' .. gravity,
        type = 'success'
    })
end

function BringPlayer(targetId)
    TriggerServerEvent('toolstraillers:bringPlayer', targetId)
end

function GotoPlayer(targetId)
    TriggerServerEvent('toolstraillers:gotoPlayer', targetId)
end

RegisterNetEvent('toolstraillers:teleportPlayer')
AddEventHandler('toolstraillers:teleportPlayer', function(x, y, z)
    TeleportToCoords(x, y, z)
end)