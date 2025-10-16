function CORE.get_vehicles_pool() -- Get Les véhicules
    local vehicles = {}

    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(vehicle) then
            table.insert(vehicles, vehicle)
        end
    end

    return vehicles
end

-- Fonction utilitaire pour vérifier si une valeur est dans une table
function CORE.is_in_table(tbl, val)
    if type(tbl) ~= "table" then return false end
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

function CORE.get_nearby_vehicles(distance) -- Get des véhicules dans la zone
    local ped = GetPlayerPed(-1)
    local playerPos = GetEntityCoords(ped)
    local nearbyVehicles = {}

    local vehicles = CORE.get_vehicles_pool()
    if vehicles then
        for _, vehicle in ipairs(vehicles) do
            local vehiclePos = GetEntityCoords(vehicle)

            if vehiclePos and #(vehiclePos - playerPos) <= (distance or 6) then
                nearbyVehicles[#nearbyVehicles + 1] = vehicle
            end
        end
    end
    return nearbyVehicles
end

local wait = false;
local xWait = false

function CORE.get_nearby_vehicle(solo, other)
    if wait then
        xWait = true
        while wait do
            Citizen.Wait(5)
        end
    end

    xWait = false
    local cTimer = GetGameTimer() + 10000;
    local oVehicle = CORE.get_nearby_vehicles(2)

    if solo then
        local playerVehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
        if playerVehicle ~= 0 then
            oVehicle[#oVehicle + 1] = playerVehicle
        end
    end

    if #oVehicle == 0 then
        ESX.ShowNotification("Il y a ~r~aucun~s~ véhicule ~r~alentours~s~ de vous.")
        return false
    end

    if #oVehicle == 1 and other then
        return oVehicle[1]
    end

    ESX.ShowNotification(
        "Appuyer sur ~g~E~s~ pour valider~n~Appuyer sur ~b~A~s~ pour changer de cible~n~Appuyer sur ~r~X~s~ pour annuler")
    Citizen.Wait(100)
    local cBase = 1
    wait = true
    while GetGameTimer() <= cTimer and not xWait do
        Citizen.Wait(0)
        DisableControlAction(0, 38, true)
        DisableControlAction(0, 73, true)
        DisableControlAction(0, 44, true)
        if IsDisabledControlJustPressed(0, 38) then
            wait = false
            return oVehicle[cBase]
        elseif IsDisabledControlJustPressed(0, 73) then
            ESX.ShowNotification("Vous avez ~r~annulé~s~ cette ~r~action~s~")
            break
        elseif IsDisabledControlJustPressed(0, 44) then
            cBase = (cBase == #oVehicle) and 1 or (cBase + 1)
        end
        local cCoords = GetEntityCoords(oVehicle[cBase])
        DrawMarker(0, cCoords.x, cCoords.y, cCoords.z + 1.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.1, 0.1, 0.1, 0, 180, 10,
            30, true, true, 0, 0, 0, 0, 0)
    end
    wait = false
    return false
end
