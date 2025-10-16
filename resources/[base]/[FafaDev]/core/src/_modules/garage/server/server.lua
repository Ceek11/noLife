CORE.register_server_callback('fCore:getVehiclesPersonnel', function(source, cb, typeGarage)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not checkSource(_src) or not checkXPlayer(xPlayer) then 
        return
    end
    local vehiclesPersonnel = {}
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = ? AND type = ?", {xPlayer.identifier, typeGarage}, function(result)
        for _, v in pairs(result) do
            table.insert(vehiclesPersonnel, {
                owner = v.owner,
                plate = v.plate,
                vehicle = json.decode(v.vehicle),
                type = v.type,
                job = v.job,
                job2 = v.job2,
                stored = v.stored,
                label = v.label,
                pound = v.pound,
                parking = v.parking
            })
        end
        cb(vehiclesPersonnel)
    end)
end)


CORE.register_server_callback('fCore:getVehiclesFourriere', function(source, cb, typeGarage)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not checkSource(_src) or not checkXPlayer(xPlayer) then 
        return
    end

    local vehiclesPersonnelFourriere = {}

    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE pound = 1 AND owner = ? AND type = ?", {
        xPlayer.identifier,
        typeGarage
    }, function(result)
        for _, v in pairs(result) do
            table.insert(vehiclesPersonnelFourriere, {
                owner = v.owner,
                plate = v.plate,
                vehicle = json.decode(v.vehicle),
                label = v.label,
            })
        end
        cb(vehiclesPersonnelFourriere)
    end)
end)


CORE.register_server_event("fCore:renameVehicle", function(plate, label)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not checkSource(_src) or not checkXPlayer(xPlayer) then 
        return
    end
    MySQL.Async.fetchAll("UPDATE owned_vehicles SET label = ? WHERE plate = ?", {label, plate}, function(result) end)
end)





CORE.register_server_event("fCore:takeVehicleFromFourriere", function(plate, spawnVehPositions, vehicle, price, previousPosition)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not checkSource(_src) or not checkXPlayer(xPlayer) then 
        return
    end
    local getMoney = xPlayer.getAccount('bank').money
    if getMoney < price then
        TriggerClientEvent("esx:showNotification", _src, "Vous n'avez pas assez d'argent")
        return
    end
    TriggerClientEvent("fCore:spawnVehicle", _src, vehicle, plate, spawnVehPositions, previousPosition)
end)

CORE.register_server_event("fCore:deleteGarage", function(type, garageName, vehicleProps, netId)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not checkSource(_src) or not checkXPlayer(xPlayer) then
        return
    end

    if not vehicleProps or not vehicleProps.plate then
        TriggerClientEvent("esx:showNotification", _src, "Propriétés du véhicule invalides.")
        return
    end

    local row = MySQL.single.await('SELECT * FROM owned_vehicles WHERE plate = ?', {
        vehicleProps.plate
    })

    if not row then
        TriggerClientEvent("esx:showNotification", _src, "Aucun véhicule trouvé avec cette plaque.")
        return
    end

    if row.type ~= type then
        TriggerClientEvent("esx:showNotification", _src, "Vous n'avez pas le droit de ranger ce véhicule dans ce garage.")
        return
    end

    if row.owner ~= xPlayer.identifier and garageName ~= row.parking then
        TriggerClientEvent("esx:showNotification", _src, "Le véhicule ne vous appartient pas.")
        return
    end

    MySQL.Async.execute("UPDATE owned_vehicles SET stored = 1, parking = ?, vehicle = ? WHERE plate = ?", {
        garageName,
        json.encode(vehicleProps),
        vehicleProps.plate
    }, function()
        TriggerClientEvent("esx:showNotification", _src, "Vous avez rangé votre véhicule.")
        TriggerClientEvent("fCore:deleteVehicle", _src, netId)
    end)
end)

-- Événement qui s'exécute au démarrage du serveur
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    
    -- Mise à jour des véhicules qui sont en dehors du garage et pas en fourrière
    MySQL.Async.execute("UPDATE owned_vehicles SET pound = 1 WHERE stored = 0 AND pound = 0", {}, function(rowsChanged) end)
end)



