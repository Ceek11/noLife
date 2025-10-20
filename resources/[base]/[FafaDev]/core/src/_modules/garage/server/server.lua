CORE.register_server_callback('fCore:getVehiclesPersonnel', function(source, cb, typeGarage)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = ? AND type = ?", {xPlayer.identifier, typeGarage}, function(result)
        local vehiclesPersonnel = {}
        if result then
            for _, v in pairs(result) do
                table.insert(vehiclesPersonnel, {
                    plate = v.plate,
                    vehicle = json.decode(v.vehicle),
                    stored = v.stored,
                    label = v.label,
                    pound = v.pound,
                    parking = v.parking
                })
            end
        end
        cb(vehiclesPersonnel)
    end)
end)

CORE.register_server_callback('fCore:getVehiclesFourriere', function(source, cb, typeGarage)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE pound = 1 AND owner = ? AND type = ?", {xPlayer.identifier, typeGarage}, function(result)
        local vehiclesPersonnelFourriere = {}
        if result then
            for _, v in pairs(result) do
                table.insert(vehiclesPersonnelFourriere, {
                    plate = v.plate,
                    vehicle = json.decode(v.vehicle),
                    label = v.label
                })
            end
        end
        cb(vehiclesPersonnelFourriere)
    end)
end)

CORE.register_server_callback('fCore:getVehiclesJob', function(source, cb, typeGarage, jobName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE (job = ? OR job = ?) AND type = ?", {jobName, '"' .. jobName .. '"', typeGarage}, function(result)
        local vehiclesJob = {}
        if result then
            for _, v in pairs(result) do
                table.insert(vehiclesJob, {
                    plate = v.plate,
                    vehicle = json.decode(v.vehicle),
                    stored = v.stored,
                    label = v.label,
                    pound = v.pound,
                    parking = v.parking
                })
            end
        end
        cb(vehiclesJob)
    end)
end)

CORE.register_server_callback('fCore:getVehiclesJobFourriere', function(source, cb, typeGarage, jobName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE pound = 1 AND (job = ? OR job = ?) AND type = ?", {jobName, '"' .. jobName .. '"', typeGarage}, function(result)
        local vehiclesJobFourriere = {}
        if result then
            for _, v in pairs(result) do
                table.insert(vehiclesJobFourriere, {
                    plate = v.plate,
                    vehicle = json.decode(v.vehicle),
                    label = v.label
                })
            end
        end
        cb(vehiclesJobFourriere)
    end)
end)

CORE.register_server_event("fCore:renameVehicle", function(_src, plate, newLabel)
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not xPlayer then return end
    
    MySQL.Async.fetchAll("SELECT owner FROM owned_vehicles WHERE plate = ?", {plate}, function(result)
        if result and result[1] and result[1].owner == xPlayer.identifier then
            MySQL.Async.execute("UPDATE owned_vehicles SET label = ? WHERE plate = ?", {newLabel, plate}, function(rowsChanged)
                if rowsChanged > 0 then
                    TriggerClientEvent("esx:showNotification", _src, "Véhicule renommé avec succès")
                end
            end)
        end
    end)
end)

CORE.register_server_event("fCore:transferVehicleToJob", function(_src, plate, jobName)
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not xPlayer then return end
    
    MySQL.Async.fetchAll("SELECT owner FROM owned_vehicles WHERE plate = ?", {plate}, function(result)
        if result and result[1] and result[1].owner == xPlayer.identifier then
            MySQL.Async.execute("UPDATE owned_vehicles SET job = ? WHERE plate = ?", {jobName, plate}, function(rowsChanged)
                if rowsChanged > 0 then
                    TriggerClientEvent("esx:showNotification", _src, "~g~Véhicule transféré à l'entreprise")
                else
                    TriggerClientEvent("esx:showNotification", _src, "~r~Erreur lors du transfert")
                end
            end)
        else
            TriggerClientEvent("esx:showNotification", _src, "~r~Vous n'êtes pas propriétaire de ce véhicule")
        end
    end)
end)

CORE.register_server_event("fCore:transferVehicleToPersonal", function(_src, plate)
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not xPlayer then return end
    
    MySQL.Async.execute("UPDATE owned_vehicles SET job = NULL WHERE plate = ?", {plate}, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent("esx:showNotification", _src, "~g~Véhicule transféré en personnel")
        else
            TriggerClientEvent("esx:showNotification", _src, "~r~Erreur lors du transfert")
        end
    end)
end)

CORE.register_server_event("fCore:updateStatuVehicle", function(_src, plate)
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not xPlayer then return end
    
    MySQL.Async.execute("UPDATE owned_vehicles SET stored = 0, pound = 0 WHERE plate = ? AND owner = ?", {plate, xPlayer.identifier})
end)

CORE.register_server_event("fCore:takeVehicleFromFourriere", function(_src, plate, spawnVehPositions, vehicle, price)
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not xPlayer then return end
    
    local getMoney = xPlayer.getAccount('bank').money
    if getMoney < price then
        TriggerClientEvent("esx:showNotification", _src, "Vous n'avez pas assez d'argent")
        return
    end
    
    xPlayer.removeAccountMoney('bank', price)
    MySQL.Async.execute("UPDATE owned_vehicles SET stored = 0, pound = 0 WHERE plate = ? AND owner = ?", {plate, xPlayer.identifier}, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent("fCore:spawnVehicle", _src, vehicle, plate, spawnVehPositions)
        else
            TriggerClientEvent("esx:showNotification", _src, "~r~Erreur lors de la sortie du véhicule")
            xPlayer.addAccountMoney('bank', price)
        end
    end)
end)

CORE.register_server_event("fCore:deleteGarage", function(_src, type, garageName, vehicleProps, netId)
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not xPlayer then return end
    if not vehicleProps or not vehicleProps.plate then
        TriggerClientEvent("esx:showNotification", _src, "~r~Propriétés du véhicule invalides.")
        return
    end

    local row = MySQL.single.await('SELECT * FROM owned_vehicles WHERE plate = ?', {vehicleProps.plate})
    if not row then
        TriggerClientEvent("esx:showNotification", _src, "~r~Aucun véhicule trouvé avec cette plaque.")
        return
    end
    if row.type ~= type then
        TriggerClientEvent("esx:showNotification", _src, "~r~Vous n'avez pas le droit de ranger ce véhicule dans ce garage.")
        return
    end
    if row.owner ~= xPlayer.identifier then
        TriggerClientEvent("esx:showNotification", _src, "~r~Le véhicule ne vous appartient pas.")
        return
    end
    
    MySQL.Async.execute("UPDATE owned_vehicles SET stored = 1, pound = 0, parking = ?, vehicle = ? WHERE plate = ?", {garageName, json.encode(vehicleProps), vehicleProps.plate}, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent("esx:showNotification", _src, "~g~Véhicule rangé avec succès")
            TriggerClientEvent("fCore:deleteVehicle", _src, netId)
        else
            TriggerClientEvent("esx:showNotification", _src, "~r~Erreur lors du rangement")
        end
    end)
end)

CORE.register_server_event("fCore:deleteVehicleDirect", function(_src, type, garageName, vehicleProps, netId)
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not xPlayer then return end
    if not vehicleProps or not vehicleProps.plate then
        TriggerClientEvent("esx:showNotification", _src, "~r~Propriétés du véhicule invalides.")
        return
    end

    local row = MySQL.single.await('SELECT * FROM owned_vehicles WHERE plate = ?', {vehicleProps.plate})
    if not row then
        TriggerClientEvent("esx:showNotification", _src, "~r~Aucun véhicule trouvé avec cette plaque.")
        return
    end
    if row.type ~= type then
        TriggerClientEvent("esx:showNotification", _src, "~r~Vous n'avez pas le droit de ranger ce véhicule dans ce garage.")
        return
    end
    if row.owner ~= xPlayer.identifier then
        TriggerClientEvent("esx:showNotification", _src, "~r~Le véhicule ne vous appartient pas.")
        return
    end
    
    MySQL.Async.execute("UPDATE owned_vehicles SET stored = 1, pound = 0, parking = ?, vehicle = ? WHERE plate = ?", {garageName, json.encode(vehicleProps), vehicleProps.plate}, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent("esx:showNotification", _src, "~g~Véhicule rangé avec succès")
            TriggerClientEvent("fCore:deleteVehicle", _src, netId)
        else
            TriggerClientEvent("esx:showNotification", _src, "~r~Erreur lors du rangement")
        end
    end)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    MySQL.Async.execute("UPDATE owned_vehicles SET pound = 1 WHERE stored = 0 AND pound = 0")
end)