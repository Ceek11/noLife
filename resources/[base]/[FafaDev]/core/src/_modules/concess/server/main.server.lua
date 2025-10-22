TBL_CATEGORIE = {}
TBL_VEHICLE = {}
TBL_CONCESS = {}

function FUN_LOAD_CONCESS()
    local concess = LoadResourceFile(GetCurrentResourceName(), "data/concess.json")
    if concess then
        TBL_CONCESS = json.decode(concess) or {}
    end
    
    Wait(100)
    local vehicles = MySQL.query.await('SELECT * FROM vehicles')
    for _, vehicle in ipairs(vehicles or {}) do
        TBL_VEHICLE[vehicle.name] = vehicle
    end

    local categories = MySQL.query.await('SELECT * FROM vehicle_categories')
    for _, category in ipairs(categories or {}) do
        TBL_CATEGORIE[category.name] = category
    end
end

CORE.register_server_callback("fafadev:to_server:get_concess", function(source, cb)
    cb(TBL_CONCESS)
end)

CORE.register_server_callback("fafadev:to_server:get_categories", function(source, cb)
    cb(TBL_CATEGORIE)
end)

CORE.register_server_callback("fafadev:to_server:get_vehicles", function(source, cb, category)
    if category then
        local filteredVehicles = {}
        for name, vehicle in pairs(TBL_VEHICLE) do
            if vehicle.category == category then
                filteredVehicles[name] = vehicle
            end
        end
        cb(filteredVehicles)
    else
        cb(TBL_VEHICLE)
    end
end)

CORE.register_server_callback("fafadev:to_server:get_vehicles_by_categories", function(source, cb, categories)
    if categories and type(categories) == "table" then
        local filteredVehicles = {}
        for name, vehicle in pairs(TBL_VEHICLE) do
            for _, categoryName in pairs(categories) do
                if vehicle.category == categoryName then
                    filteredVehicles[name] = vehicle
                    break
                end
            end
        end
        cb(filteredVehicles)
    else
        cb(TBL_VEHICLE)
    end
end)

CORE.register_server_event("fafadev:to_server:request_vehicle_purchase", function(source, targetId, vehicleData, concessData)
    TriggerClientEvent("fafadev:to_client:show_vehicle_purchase_request", targetId, source, vehicleData, concessData)
end)

CORE.register_server_event("fafadev:to_server:cancel_vehicle_purchase", function(source, sellerServerId)
    TriggerClientEvent('esx:showNotification', sellerServerId, "Le client a refusé l'achat")
end)

CORE.register_server_event("fafadev:to_server:buy_vehicle", function(source, vehicleData, paymentMethod, sellerServerId)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        return
    end
    
    local price = vehicleData.price or 0
    local hasMoney = false
    
    if paymentMethod == "card" then
        if xPlayer.getAccount('bank').money >= price then
            xPlayer.removeAccountMoney('bank', price)
            hasMoney = true
        end
    elseif paymentMethod == "cash" then
        if xPlayer.getMoney() >= price then
            xPlayer.removeMoney(price)
            hasMoney = true
        end
    end
    
    if hasMoney then
        TriggerClientEvent('esx:showNotification', sellerServerId, string.format("Vente de ~g~%s~s~ réussie pour ~g~%s$", vehicleData.name, price))
        TriggerClientEvent('esx:showNotification', source, string.format("Vous avez acheté ~g~%s~s~", vehicleData.name))
        TriggerClientEvent("fafadev:to_client:prepare_vehicle_spawn", sellerServerId, vehicleData.model, source, xPlayer.identifier)
    else
        TriggerClientEvent('esx:showNotification', source, "Vous n'avez pas assez d'argent")
        TriggerClientEvent('esx:showNotification', sellerServerId, "Le client n'a pas assez d'argent")
    end
end)

CORE.register_server_event("fafadev:to_server:save_vehicle_to_db", function(source, vehicleProperties, buyerId, ownerIdentifier)
    MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {
        ownerIdentifier,
        vehicleProperties.plate,
        json.encode(vehicleProperties)
    }, function(insertId)
        if insertId then
            TriggerClientEvent("fafadev:to_client:spawn_purchased_vehicle_final", source, vehicleProperties)
            TriggerClientEvent('esx:showNotification', buyerId, "Votre véhicule est prêt !")
        else
            TriggerClientEvent('esx:showNotification', source, "Erreur lors de l'enregistrement en base de données")
            TriggerClientEvent('esx:showNotification', buyerId, "Erreur lors de l'enregistrement en base de données")
        end
    end)
end)

local function SaveConcessToFile()
    local jsonData = json.encode(TBL_CONCESS, {indent = true})
    SaveResourceFile(GetCurrentResourceName(), "data/concess.json", jsonData, -1)
end

CORE.register_server_callback("fafadev:to_server:create_concess_sell", function(source, cb, sellData)
    if not sellData or not sellData.name then
        cb(false)
        return
    end
    
    if not TBL_CONCESS.sell then
        TBL_CONCESS.sell = {}
    end
    
    for _, sell in pairs(TBL_CONCESS.sell) do
        if sell.name == sellData.name then
            cb(false)
            return
        end
    end
    
    table.insert(TBL_CONCESS.sell, sellData)
    SaveConcessToFile()
    -- Rafraîchir automatiquement les concess pour tous les joueurs
    CORE.trigger_client_callback("fafadev:to_client:refresh_concess", -1, function() end, TBL_CONCESS)
    cb(true)
end)

CORE.register_server_callback("fafadev:to_server:create_concess_preview", function(source, cb, previewData)
    if not previewData or not previewData.name then
        cb(false)
        return
    end
    
    if not TBL_CONCESS.preview then
        TBL_CONCESS.preview = {}
    end
    
    for _, preview in pairs(TBL_CONCESS.preview) do
        if preview.name == previewData.name then
            cb(false)
            return
        end
    end
    
    table.insert(TBL_CONCESS.preview, previewData)
    SaveConcessToFile()
    -- Rafraîchir automatiquement les concess pour tous les joueurs
    CORE.trigger_client_callback("fafadev:to_client:refresh_concess", -1, function() end, TBL_CONCESS)
    cb(true)
end)

CORE.register_server_callback("fafadev:to_server:delete_concess_sell", function(source, cb, sellName)
    if not sellName or not TBL_CONCESS.sell then
        cb(false)
        return
    end
    
    for i, sell in ipairs(TBL_CONCESS.sell) do
        if sell.name == sellName then
            table.remove(TBL_CONCESS.sell, i)
            SaveConcessToFile()
            -- Rafraîchir automatiquement les concess pour tous les joueurs
            CORE.trigger_client_callback("fafadev:to_client:refresh_concess", -1, function() end, TBL_CONCESS)
            cb(true)
            return
        end
    end
    
    cb(false)
end)

CORE.register_server_callback("fafadev:to_server:delete_concess_preview", function(source, cb, previewName)
    if not previewName or not TBL_CONCESS.preview then
        cb(false)
        return
    end
    
    for i, preview in ipairs(TBL_CONCESS.preview) do
        if preview.name == previewName then
            table.remove(TBL_CONCESS.preview, i)
            SaveConcessToFile()
            -- Rafraîchir automatiquement les concess pour tous les joueurs
            CORE.trigger_client_callback("fafadev:to_client:refresh_concess", -1, function() end, TBL_CONCESS)
            cb(true)
            return
        end
    end
    
    cb(false)
end)