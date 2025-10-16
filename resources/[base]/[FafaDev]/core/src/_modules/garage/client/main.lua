function getVehiclesPersonnel(typeGarage, callback)
    vehiclesPersonnel = {}
    CORE.trigger_server_callback('fCore:getVehiclesPersonnel', function(data)
        vehiclesPersonnel = data or {}
        if callback then
            callback(typeGarage)
        end
    end, typeGarage)
end

function getVehiclesFourriere(typeGarage, callback)
    CORE.trigger_server_callback('fCore:getVehiclesFourriere', function(vehiclesPersonnelFourriere)
        PersonnelFourriere = vehiclesPersonnelFourriere or {}
        if callback then
            callback(typeGarage)
        end
    end, typeGarage)
end


local function ClassToType(class)
    if class >= 0 and class <= 7 then
        return "automobile"
    elseif class == 8 then
        return "bike"
    elseif class == 14 then
        return "boat"
    elseif class == 15 then
        return "heli"
    elseif class == 16 then
        return "plane"
    elseif class == 21 then
        return "train"
    elseif class == 22 or class == 23 then
        return "trailer"
    else
        return "automobile"
    end
end

function spawnVehicle(vehicleData, plate, spawnVehPositions, action, previousPosition)

    RequestModel(vehicleData.model)
    while not HasModelLoaded(vehicleData.model) do 
        Wait(10) 
    end

    local class = GetVehicleClassFromName(vehicleData.model)
    local detectedType = ClassToType(class)

    local foundPosition = false
    for i = 1, #spawnVehPositions do
        local pos = spawnVehPositions[i]
        
        if not IsAnyVehicleNearPoint(pos.x, pos.y, pos.z, 3.0) then 
            TriggerServerEvent("fCore:updateStatuVehicle", plate, action)
            local veh = CreateVehicle(vehicleData.model, pos.x, pos.y, pos.z + 0.1, pos.w, true, false)
            local netId = NetworkGetNetworkIdFromEntity(veh)
            TriggerEvent("fCore:ConfigureVehicleProperties", netId, vehicleData, plate, pos) 
            foundPosition = true
            break
        end
    end

    if not foundPosition then
        ESX.ShowNotification("Toutes les places de spawn sont occupées.")
    end
end


function GetVehiculeDamageStatus(veh)
    local damage = {
        windows = {},
        doors = {},
        wheel = {},
        tires = {},
        deformations = {}
    }
    
    for i = 0, 7 do 
        damage.windows[i] = not IsVehicleWindowIntact(veh, i)
    end

    for i = 0, 5 do 
        damage.doors[i] = not IsVehicleDoorDamaged(veh, i)
    end

    for i = 0, 7 do 
        damage.tires[i] = not IsVehicleTyreBurst(veh, i, false)
    end

    local points = {
        {x = 0.0, y = 1.0, z = 0.5}, 
        {x = 0.0, y = -1.0, z = 0.5},  
        {x = 1.0, y = 0.0, z = 0.5},  
        {x = -1.0, y = 0.0, z = 0.5}, 
    } 
    
    for i, offset in pairs(points) do
        local worldPos = GetWorldPositionOfEntityBone(veh, offset.x, offset.y, offset.z)
        local deformation = GetVehicleDeformationAtPos(veh, worldPos.x, worldPos.y, worldPos.z)
        damage.deformations[i] = {
            x = deformation.x,
            y = deformation.y,
            z = deformation.z
        }
    end
    return damage
end


function deleteGarage(typeGarage, garageName, spawnVehPositions)
    local vehicles = GetGamePool("CVehicle")
    local founds = false
    
    
    for _, veh in pairs(vehicles) do
        local vehiclePos = GetEntityCoords(veh)  
        for i = 1, #spawnVehPositions do
            local pos = spawnVehPositions[i].xyz
            local dist = #(vehiclePos - pos)
           
            if dist < 3.0 then
                local vehicleProps = ESX.Game.GetVehicleProperties(veh)
                local damage = GetVehiculeDamageStatus(veh)
                vehicleProps.damage = damage
                local netId = NetworkGetNetworkIdFromEntity(veh)
                TriggerServerEvent("fCore:deleteGarage", typeGarage, garageName, vehicleProps, netId)
                founds = true
                break
            end
            
        end
    end

    if not founds then
        ESX.ShowNotification("Tu n'a pas de véhicule dans la zone")
    end
end



RegisterNetEvent("fCore:deleteVehicle", function(netId)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if veh ~= 0 and DoesEntityExist(veh) then
        DeleteEntity(veh)
    end
end)

RegisterNetEvent("fCore:spawnVehicle", function(vehicle, plate, spawnVehPositions, previousPosition)
    spawnVehicle(vehicle, plate, spawnVehPositions, "fourriere", previousPosition)
end)

RegisterNetEvent("fCore:ConfigureVehicleProperties", function(netId, vehicleData, plate, pos)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if veh ~= 0 and DoesEntityExist(veh) then
        ESX.Game.SetVehicleProperties(veh, vehicleData)
        SetVehicleNumberPlateText(veh, plate)
        SetEntityAsMissionEntity(veh, true, true)
        SetVehicleHasBeenOwnedByPlayer(veh, true)
        SetVehicleNeedsToBeHotwired(veh, false)
        SetModelAsNoLongerNeeded(vehicleData.model)
        SetVehicleOnGroundProperly(veh)
        SetVehicleEngineOn(veh, true, true, false)
    end
end)