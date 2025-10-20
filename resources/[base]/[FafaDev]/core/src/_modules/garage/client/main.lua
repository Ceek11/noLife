function getVehiclesPersonnel(typeGarage)
    CORE.trigger_server_callback('fCore:getVehiclesPersonnel', function(data)
        vehiclesPersonnel = data or {}
    end, typeGarage)
end

function getVehiclesFourriere(typeGarage)
    CORE.trigger_server_callback('fCore:getVehiclesFourriere', function(data)
        PersonnelFourriere = data or {}
    end, typeGarage)
end

function getVehiclesJob(typeGarage, jobName)
    CORE.trigger_server_callback('fCore:getVehiclesJob', function(data)
        vehiclesJob = data or {}
    end, typeGarage, jobName)
end

function getVehiclesJobFourriere(typeGarage, jobName)
    CORE.trigger_server_callback('fCore:getVehiclesJobFourriere', function(data)
        JobFourriere = data or {}
    end, typeGarage, jobName)
end

function spawnVehicle(vehicleData, plate, spawnVehPositions)
    if not vehicleData or not vehicleData.model then
        ESX.ShowNotification("~r~Erreur : Modèle de véhicule invalide")
        return
    end
    
    RequestModel(vehicleData.model)
    while not HasModelLoaded(vehicleData.model) do Wait(10) end

    for i = 1, #spawnVehPositions do
        local pos = spawnVehPositions[i]
        if not IsAnyVehicleNearPoint(pos.x, pos.y, pos.z, 3.0) then
            CORE.trigger_server_event("fCore:updateStatuVehicle", plate)
            local veh = CreateVehicle(vehicleData.model, pos.x, pos.y, pos.z, pos.w, true, false)
            if not DoesEntityExist(veh) then
                ESX.ShowNotification("~r~Erreur : Impossible de créer le véhicule")
                return
            end
            
            Wait(100)
            SetVehicleOnGroundProperly(veh)
            ESX.Game.SetVehicleProperties(veh, vehicleData)
            SetVehicleNumberPlateText(veh, plate)
            SetEntityAsMissionEntity(veh, true, true)
            SetVehicleHasBeenOwnedByPlayer(veh, true)
            SetVehicleNeedsToBeHotwired(veh, false)
            SetVehicleEngineOn(veh, true, true, false)
            SetModelAsNoLongerNeeded(vehicleData.model)
            ESX.ShowNotification("~g~Véhicule sorti avec succès")
            return
        end
    end
    ESX.ShowNotification("~o~Toutes les places de spawn sont occupées.")
end

function GetVehiculeDamageStatus(veh)
    local damage = {windows = {}, doors = {}, wheel = {}, tires = {}, deformations = {}}
    for i = 0, 7 do damage.windows[i] = not IsVehicleWindowIntact(veh, i) end
    for i = 0, 5 do damage.doors[i] = not IsVehicleDoorDamaged(veh, i) end
    for i = 0, 7 do damage.tires[i] = not IsVehicleTyreBurst(veh, i, false) end
    
    local points = {{x = 0.0, y = 1.0, z = 0.5}, {x = 0.0, y = -1.0, z = 0.5}, {x = 1.0, y = 0.0, z = 0.5}, {x = -1.0, y = 0.0, z = 0.5}}
    for i, offset in pairs(points) do
        local worldPos = GetWorldPositionOfEntityBone(veh, offset.x, offset.y, offset.z)
        local deformation = GetVehicleDeformationAtPos(veh, worldPos.x, worldPos.y, worldPos.z)
        damage.deformations[i] = {x = deformation.x, y = deformation.y, z = deformation.z}
    end
    return damage
end

function deleteGarage(typeGarage, garageName, spawnVehPositions)
    local vehicles = GetGamePool("CVehicle")
    for _, veh in pairs(vehicles) do
        local vehiclePos = GetEntityCoords(veh)
        for i = 1, #spawnVehPositions do
            local pos = spawnVehPositions[i]
            if #(vehiclePos - vector3(pos.x, pos.y, pos.z)) < 3.0 then
                local vehicleProps = ESX.Game.GetVehicleProperties(veh)
                vehicleProps.damage = GetVehiculeDamageStatus(veh)
                CORE.trigger_server_event("fCore:deleteGarage", typeGarage, garageName, vehicleProps, NetworkGetNetworkIdFromEntity(veh))
                return
            end
        end
    end
    ESX.ShowNotification("Tu n'as pas de véhicule dans la zone")
end

function deleteVehicleDirect(garageName, typeGarage, spawnVehPositions)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicles = GetGamePool("CVehicle")
    
    -- Chercher le véhicule le plus proche du joueur
    local closestVehicle = nil
    local closestDistance = 5.0 -- Distance maximale de 5 mètres
    
    for _, veh in pairs(vehicles) do
        local vehiclePos = GetEntityCoords(veh)
        local distance = #(playerCoords - vehiclePos)
        
        if distance < closestDistance then
            closestVehicle = veh
            closestDistance = distance
        end
    end
    
    if closestVehicle then
        local vehicleProps = ESX.Game.GetVehicleProperties(closestVehicle)
        vehicleProps.damage = GetVehiculeDamageStatus(closestVehicle)
        CORE.trigger_server_event("fCore:deleteVehicleDirect", typeGarage, garageName, vehicleProps, NetworkGetNetworkIdFromEntity(closestVehicle))
    else
        ESX.ShowNotification("~r~Aucun véhicule à proximité")
    end
end

RegisterNetEvent("fCore:deleteVehicle", function(netId)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if veh ~= 0 and DoesEntityExist(veh) then DeleteEntity(veh) end
end)

RegisterNetEvent("fCore:spawnVehicle", function(vehicle, plate, spawnVehPositions)
    spawnVehicle(vehicle, plate, spawnVehPositions)
end)

CORE.register_client_callback("fafadev:to_client:refresh_garages", function(handler, garages)
    TBL_GARAGES = garages
    handler()
end)