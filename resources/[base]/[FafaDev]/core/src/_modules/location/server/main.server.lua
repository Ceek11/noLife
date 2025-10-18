local str_file_location = 'data/location.json'
TBL_LOCATIONS = {}
TBL_RENTED_VEHICLES = {}

function FUN_LOAD_LOCATIONS()
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), str_file_location)
    tbl_locations = json.decode(str_file_content)
    for _, location in pairs(tbl_locations) do
        TBL_LOCATIONS[location.name] = location
    end
end

CORE.register_server_callback("fafadev:to_server:get_locations", function(source, cb)
    cb(TBL_LOCATIONS)
end)

CORE.register_server_callback("fafadev:to_server:check_spawn_free", function(source, cb, spawnPos)
    local coords = vector3(spawnPos.x, spawnPos.y, spawnPos.z)
    local vehicles = GetAllVehicles()
    for _, vehicle in ipairs(vehicles) do
        if DoesEntityExist(vehicle) then
            local vehCoords = GetEntityCoords(vehicle)
            if #(coords - vehCoords) < 3.0 then
                cb(false)
                return
            end
        end
    end
    cb(true)
end)

local function GetFreeSpawnPosition(spawn_positions)
    for _, spawnPos in pairs(spawn_positions) do
        local coords = vector3(spawnPos.x, spawnPos.y, spawnPos.z)
        local isFree = true
        local vehicles = GetAllVehicles()
        for _, vehicle in ipairs(vehicles) do
            if DoesEntityExist(vehicle) then
                local vehCoords = GetEntityCoords(vehicle)
                if #(coords - vehCoords) < 3.0 then
                    isFree = false
                    break
                end
            end
        end
        if isFree then
            return spawnPos
        end
    end
    return nil
end

CORE.register_server_callback("fafadev:to_server:rent_vehicle", function(source, cb, locationName, vehicleModel, vehiclePrice, vehicleDeposit)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb({success = false, message = "Joueur introuvable"})
        return
    end
    if TBL_RENTED_VEHICLES[source] then
        cb({success = false, message = "Vous avez déjà un véhicule loué"})
        return
    end
    local totalPrice = vehiclePrice + vehicleDeposit
    if xPlayer.getMoney() < totalPrice then
        cb({success = false, message = "Vous n'avez pas assez d'argent (Location: " .. vehiclePrice .. "$ + Caution: " .. vehicleDeposit .. "$)"})
        return
    end
    local location = TBL_LOCATIONS[locationName]
    if not location then
        cb({success = false, message = "Location introuvable"})
        return
    end
    local spawnPos = GetFreeSpawnPosition(location.spawn_positions)
    if not spawnPos then
        cb({success = false, message = "Aucune place de parking disponible"})
        return
    end
    xPlayer.removeMoney(totalPrice, "Vehicle Rental + Deposit")
    local vehicleHash = GetHashKey(vehicleModel)
    local vehicle = CreateVehicle(vehicleHash, spawnPos.x, spawnPos.y, spawnPos.z, spawnPos.w or 0.0, true, true)
    while not DoesEntityExist(vehicle) do
        Wait(10)
    end
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local vehPlate = GetVehicleNumberPlateText(vehicle)
    SetVehicleNumberPlateText(vehicle, "LOC" .. source)
    TBL_RENTED_VEHICLES[source] = {
        netId = netId,
        vehicle = vehicle,
        deposit = vehicleDeposit,
        spawnPos = vector3(spawnPos.x, spawnPos.y, spawnPos.z)
    }
    cb({success = true, netId = netId, deposit = vehicleDeposit})
end)

RegisterNetEvent("fafadev:to_server:return_vehicle", function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local rentedVeh = TBL_RENTED_VEHICLES[source]
    if rentedVeh then
        if DoesEntityExist(rentedVeh.vehicle) then
            DeleteEntity(rentedVeh.vehicle)
        end
        if xPlayer and rentedVeh.deposit then
            xPlayer.addMoney(rentedVeh.deposit, "Vehicle Rental Deposit Return")
        end
        TBL_RENTED_VEHICLES[source] = nil
    end
end)

local function SaveLocationsToFile()
    local locationsArray = {}
    for _, location in pairs(TBL_LOCATIONS) do
        table.insert(locationsArray, location)
    end
    local jsonData = json.encode(locationsArray, {indent = true})
    SaveResourceFile(GetCurrentResourceName(), str_file_location, jsonData, -1)
end

CORE.register_server_callback("fafadev:to_server:create_location", function(source, cb, locationData)
    if not locationData or not locationData.name or not locationData.coords or not locationData.spawn_positions or not locationData.vehicles_list then
        cb(false)
        return
    end
    if TBL_LOCATIONS[locationData.name] then
        cb(false)
        return
    end
    TBL_LOCATIONS[locationData.name] = locationData
    SaveLocationsToFile()
    CORE.trigger_client_callback("fafadev:to_client:refresh_locations", -1, function() end, TBL_LOCATIONS)
    cb(true)
end)

CORE.register_server_callback("fafadev:to_server:delete_location", function(source, cb, locationName)
    if not locationName or not TBL_LOCATIONS[locationName] then
        cb(false)
        return
    end
    TBL_LOCATIONS[locationName] = nil
    SaveLocationsToFile()
    CORE.trigger_client_callback("fafadev:to_client:refresh_locations", -1, function() end, TBL_LOCATIONS)
    cb(true)
end)

AddEventHandler("playerDropped", function()
    local source = source
    local rentedVeh = TBL_RENTED_VEHICLES[source]
    if rentedVeh then
        if DoesEntityExist(rentedVeh.vehicle) then
            DeleteEntity(rentedVeh.vehicle)
        end
        TBL_RENTED_VEHICLES[source] = nil
    end
end)
