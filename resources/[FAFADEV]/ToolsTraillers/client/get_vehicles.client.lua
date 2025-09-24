function get_vehicles_pool()
    local vehicles = {}
    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(vehicle) then
            table.insert(vehicles, vehicle)
        end
    end
    return vehicles
end

function get_nearby_vehicles(distance)
    local ped = GetPlayerPed(-1)
    local playerPos = GetEntityCoords(ped)
    local nearbyVehicles = {}
    local vehicles = get_vehicles_pool()
    
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

local wait = false
local xWait = false

function get_nearby_vehicle(solo, other)
    if wait then
        xWait = true
        while wait do
            Citizen.Wait(5)
        end
    end

    xWait = false
    local cTimer = GetGameTimer() + 10000
    local oVehicle = get_nearby_vehicles(10)

    if solo then
        local playerVehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
        if playerVehicle ~= 0 then
            oVehicle[#oVehicle + 1] = playerVehicle
        end
    end

    if #oVehicle == 0 then
        lib.notify({
            title = 'ToolsTraillers',
            description = 'Aucun véhicule aux alentours',
            type = 'error'
        })
        return false
    end

    if #oVehicle == 1 and other then
        return oVehicle[1]
    end

    lib.notify({
        title = 'ToolsTraillers',
        description = 'E: Valider | A: Changer | X: Annuler',
        type = 'info'
    })
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
            lib.notify({
                title = 'ToolsTraillers',
                description = 'Action annulée',
                type = 'error'
            })
            break
        elseif IsDisabledControlJustPressed(0, 44) then
            cBase = (cBase == #oVehicle) and 1 or (cBase + 1)
        end
        local cCoords = GetEntityCoords(oVehicle[cBase])
        DrawMarker(0, cCoords.x, cCoords.y, cCoords.z + 1.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.1, 0.1, 0.1, 0, 180, 10, 30, true, true, 0, 0, 0, 0, 0)
    end
    wait = false
    return false
end