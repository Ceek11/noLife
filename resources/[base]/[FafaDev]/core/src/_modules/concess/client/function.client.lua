current_preview_vehicle = nil
current_vehicle_data = nil
current_concess_data = nil
preview_spawn_coords = nil

is_testing_vehicle = false
test_vehicle = nil
return_coords = nil
test_zone_center = nil
test_zone_radius = 0

search_filter = ""
price_min_filter = 0
price_max_filter = 999999999
sort_type = "price_asc"
selected_category = nil

function DeletePreviewVehicle()
    if current_preview_vehicle and DoesEntityExist(current_preview_vehicle) then
        DeleteEntity(current_preview_vehicle)
        current_preview_vehicle = nil
    end
end

function GetVehicleSeats(vehicleModel)
    local modelHash = GetHashKey(vehicleModel)
    return GetVehicleModelNumberOfSeats(modelHash)
end

function FilterVehicles(vehicles)
    local filtered = {}
    
    for _, vehicle in pairs(vehicles) do
        local passFilter = true
        
        if search_filter ~= "" then
            if not string.find(string.lower(vehicle.name), string.lower(search_filter)) then
                passFilter = false
            end
        end
        
        if vehicle.price < price_min_filter or vehicle.price > price_max_filter then
            passFilter = false
        end
        
        if passFilter then
            table.insert(filtered, vehicle)
        end
    end
    
    return filtered
end

function SortVehicles(vehicles)
    if sort_type == "price_asc" then
        table.sort(vehicles, function(a, b) return a.price < b.price end)
    elseif sort_type == "price_desc" then
        table.sort(vehicles, function(a, b) return a.price > b.price end)
    elseif sort_type == "name_asc" then
        table.sort(vehicles, function(a, b) return a.name < b.name end)
    elseif sort_type == "name_desc" then
        table.sort(vehicles, function(a, b) return a.name > b.name end)
    end
    
    return vehicles
end

function CreatePreviewVehicle(vehicleModel)
    DeletePreviewVehicle()
    
    if not preview_spawn_coords then return end
    
    local modelHash = GetHashKey(vehicleModel)
    RequestModel(modelHash)
    
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end
    
    if not HasModelLoaded(modelHash) then return end
    
    current_preview_vehicle = CreateVehicle(modelHash, preview_spawn_coords.x, preview_spawn_coords.y, preview_spawn_coords.z, preview_spawn_coords.heading or 0.0, false, false)
    
    SetEntityAlpha(current_preview_vehicle, 200, false)
    SetEntityCollision(current_preview_vehicle, false, false)
    FreezeEntityPosition(current_preview_vehicle, true)
    SetVehicleDoorsLocked(current_preview_vehicle, 2)
    SetVehicleEngineOn(current_preview_vehicle, false, true, true)
    SetModelAsNoLongerNeeded(modelHash)
end

function EndVehicleTest()
    if not is_testing_vehicle then return end
    
    is_testing_vehicle = false
    
    if test_vehicle and DoesEntityExist(test_vehicle) then
        DeleteEntity(test_vehicle)
        test_vehicle = nil
    end
    
    if return_coords then
        local playerPed = PlayerPedId()
        SetEntityCoords(playerPed, return_coords.x, return_coords.y, return_coords.z)
        SetEntityHeading(playerPed, return_coords.heading)
        return_coords = nil
    end
    
    test_zone_center = nil
    test_zone_radius = 0
end

function MonitorTestZone()
    CreateThread(function()
        while is_testing_vehicle do
            if test_zone_center and test_zone_radius > 0 then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local distance = #(playerCoords - vector3(test_zone_center.x, test_zone_center.y, test_zone_center.z))
                
                if distance > test_zone_radius then
                    if test_vehicle and DoesEntityExist(test_vehicle) then
                        SetEntityCoords(test_vehicle, test_zone_center.x, test_zone_center.y, test_zone_center.z)
                        SetEntityHeading(test_vehicle, test_zone_center.heading or 0.0)
                    end
                end
            end
            
            ESX.ShowHelpNotification("Appuyez sur ~INPUT_DETONATE~ pour arrêter le test")
            
            if IsControlJustPressed(0, 47) then
                EndVehicleTest()
            end
            
            Wait(0)
        end
    end)
end

function SpawnTestVehicle(vehicleModel)
    if not current_concess_data or not current_concess_data.testPoint then return end
    
    local testPoint = current_concess_data.testPoint
    local playerPed = PlayerPedId()
    
    return_coords = {
        x = GetEntityCoords(playerPed).x,
        y = GetEntityCoords(playerPed).y,
        z = GetEntityCoords(playerPed).z,
        heading = GetEntityHeading(playerPed)
    }
    
    local modelHash = GetHashKey(vehicleModel)
    RequestModel(modelHash)
    
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end
    
    if not HasModelLoaded(modelHash) then return end
    
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(10) end
    
    test_vehicle = CreateVehicle(modelHash, testPoint.x, testPoint.y, testPoint.z, testPoint.heading or 0.0, true, true)
    
    SetVehicleOnGroundProperly(test_vehicle)
    SetVehicleHasBeenOwnedByPlayer(test_vehicle, true)
    SetVehicleNeedsToBeHotwired(test_vehicle, false)
    SetVehRadioStation(test_vehicle, 'OFF')
    SetVehicleNumberPlateText(test_vehicle, "TEST" .. math.random(1000, 9999))
    SetModelAsNoLongerNeeded(modelHash)
    
    SetEntityCoords(playerPed, testPoint.x, testPoint.y, testPoint.z)
    SetPedIntoVehicle(playerPed, test_vehicle, -1)
    
    test_zone_center = testPoint
    test_zone_radius = current_concess_data.testZoneRadius or 500.0
    is_testing_vehicle = true
    
    DoScreenFadeIn(500)
    
    RageUI.CloseAll()
    DeletePreviewVehicle()
    
    MonitorTestZone()
end

function StartVehicleSale()
    if not current_vehicle_data or not current_concess_data then return end
    
    local targetPlayer = CORE.get_nearby_player(false, true)
    if not targetPlayer then
        return
    end
    
    local targetServerId = GetPlayerServerId(targetPlayer)
    
    CORE.trigger_server_event("fafadev:to_server:request_vehicle_purchase", targetServerId, current_vehicle_data, current_concess_data)
    ESX.ShowNotification("Proposition de vente envoyée")
end

RegisterNetEvent("fafadev:to_client:show_vehicle_purchase_request")
AddEventHandler("fafadev:to_client:show_vehicle_purchase_request", function(sellerServerId, vehicleData, concessData)
    CreateThread(function()
        local saleActive = true
        
        while saleActive do
            ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour payer par carte | ~INPUT_DETONATE~ pour payer en liquide | ~INPUT_VEH_DUCK~ pour refuser")
            
            if IsControlJustPressed(0, 38) then
                CORE.trigger_server_event("fafadev:to_server:buy_vehicle", vehicleData, "card", sellerServerId)
                saleActive = false
            elseif IsControlJustPressed(0, 47) then
                CORE.trigger_server_event("fafadev:to_server:buy_vehicle", vehicleData, "cash", sellerServerId)
                saleActive = false
            elseif IsControlJustPressed(0, 73) then
                CORE.trigger_server_event("fafadev:to_server:cancel_vehicle_purchase", sellerServerId)
                ESX.ShowNotification("Achat refusé")
                saleActive = false
            end
            Wait(0)
        end
    end)
end)

function IsSpawnPointOccupied(x, y, z, radius)
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        local vehCoords = GetEntityCoords(vehicle)
        local distance = #(vector3(x, y, z) - vehCoords)
        if distance < (radius or 3.0) then
            return true
        end
    end
    return false
end

function FindFreeSpawnPoint(spawnPositions)
    for _, spawnPos in ipairs(spawnPositions) do
        if not IsSpawnPointOccupied(spawnPos.x, spawnPos.y, spawnPos.z) then
            return spawnPos
        end
    end
    return nil
end

function GenerateRandomPlate()
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local plate = ""
    for i = 1, 8 do
        local rand = math.random(1, #charset)
        plate = plate .. string.sub(charset, rand, rand)
    end
    return plate
end

RegisterNetEvent("fafadev:to_client:prepare_vehicle_spawn")
AddEventHandler("fafadev:to_client:prepare_vehicle_spawn", function(vehicleModel, buyerId, ownerIdentifier)
    local modelHash = GetHashKey(vehicleModel)
    RequestModel(modelHash)
    
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end
    
    if not HasModelLoaded(modelHash) then
        ESX.ShowNotification("Erreur: Impossible de charger le véhicule")
        return
    end
    
    local tempVehicle = CreateVehicle(modelHash, 0.0, 0.0, -100.0, 0.0, false, false)
    
    Wait(100)
    
    local plate = GenerateRandomPlate()
    SetVehicleNumberPlateText(tempVehicle, plate)
    
    Wait(100)
    
    local vehicleProperties = ESX.Game.GetVehicleProperties(tempVehicle)
    
    DeleteEntity(tempVehicle)
    SetModelAsNoLongerNeeded(modelHash)
    
    CORE.trigger_server_event("fafadev:to_server:save_vehicle_to_db", vehicleProperties, buyerId, ownerIdentifier)
end)

RegisterNetEvent("fafadev:to_client:spawn_purchased_vehicle_final")
AddEventHandler("fafadev:to_client:spawn_purchased_vehicle_final", function(vehicleProperties)
    SpawnPurchasedVehicleWithProperties(vehicleProperties)
end)

function SpawnPurchasedVehicleWithProperties(vehicleProperties)
    if not current_concess_data or not current_concess_data.spawnPositions or #current_concess_data.spawnPositions == 0 then
        ESX.ShowNotification("Erreur: Position de spawn non définie")
        return
    end
    
    local spawnPos = FindFreeSpawnPoint(current_concess_data.spawnPositions)
    
    if not spawnPos then
        ESX.ShowNotification("Erreur: Aucune position de spawn disponible")
        return
    end
    
    local modelHash = vehicleProperties.model
    RequestModel(modelHash)
    
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end
    
    if not HasModelLoaded(modelHash) then
        ESX.ShowNotification("Erreur: Impossible de charger le véhicule")
        return
    end
    
    local vehicle = CreateVehicle(modelHash, spawnPos.x, spawnPos.y, spawnPos.z, spawnPos.heading or 0.0, true, true)
    
    Wait(100)
    
    ESX.Game.SetVehicleProperties(vehicle, vehicleProperties)
    
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetModelAsNoLongerNeeded(modelHash)
    
    ESX.ShowNotification("Véhicule livré avec succès")
end