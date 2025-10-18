RegisterNetEvent("fafadev:playerLoaded")
AddEventHandler("fafadev:playerLoaded", function()
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    
    if xPlayer then
        MySQL.Async.fetchAll("SELECT * FROM incapacity WHERE identifier = ? AND time > ?", {
            xPlayer.identifier, os.time()
        }, function(result)
            if result and result[1] then
                TriggerClientEvent("fafadev:checkIncapacity", _src, result[1])
            end
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000*5)
        
        MySQL.Async.fetchAll("SELECT * FROM incapacity WHERE time <= ?", {
            os.time()
        }, function(results)
            if results then
                for _, incapacity in ipairs(results) do
                    local xPlayer = ESX.GetPlayerFromIdentifier(incapacity.identifier)
                    if xPlayer then
                        -- Suppression de l'incapacité expirée
                        MySQL.Async.execute("DELETE FROM incapacity WHERE identifier = ?", {
                            incapacity.identifier
                        }, function()
                            TriggerClientEvent("fafadev:incapacity", xPlayer.source, 5) -- 5 = delete
                        end)
                    end
                end
            end
        end)
    end
end)

RegisterNetEvent("fafadev:addIncapacity", function(durationInMinutes, lvl)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not xPlayer then return end
    
    -- Vérifier que le niveau d'incapacité existe
    if not CONFIG_INCAPACITY[lvl] then
        print("^1[ERREUR] Niveau d'incapacité invalide: " .. tostring(lvl))
        return
    end
    
    local time = os.time() + (tonumber(durationInMinutes) * 60)
    
    MySQL.Async.execute("DELETE FROM incapacity WHERE identifier = ?", {
        xPlayer.identifier
    }, function()
        MySQL.Async.execute("INSERT INTO incapacity (identifier, lvl, time) VALUES (?,?,?)", {
            xPlayer.identifier, lvl, time
        }, function(insertId)
            if insertId then
                print("^2[INFO] Incapacité ajoutée pour " .. xPlayer.getName() .. " (Niveau " .. lvl .. ", " .. durationInMinutes .. " minutes)")
            end
        end)
    end)
end)

RegisterNetEvent("fafadev:registerIncapacity", function(target, lvl)
    TriggerClientEvent("fafadev:incapacity", target, lvl)
end)

RegisterNetEvent("fafadev:removeIncapacity", function(target, lvl)
    local xTarget = ESX.GetPlayerFromId(target)
    if not xTarget then return end
    
    MySQL.Async.execute("DELETE FROM incapacity WHERE identifier = ?", {
        xTarget.identifier
    }, function(affectedRows)
        if affectedRows > 0 then
            print("^2[INFO] Incapacité supprimée pour " .. xTarget.getName())
        end
        TriggerClientEvent("fafadev:incapacity", target, lvl)
    end)
end)

-- Événement pour vérifier l'incapacité d'un joueur
RegisterNetEvent("fafadev:checkPlayerIncapacity")
AddEventHandler("fafadev:checkPlayerIncapacity", function()
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    
    if xPlayer then
        MySQL.Async.fetchAll("SELECT * FROM incapacity WHERE identifier = ? AND time > ?", {
            xPlayer.identifier, os.time()
        }, function(result)
            if result and result[1] then
                TriggerClientEvent("fafadev:checkIncapacity", _src, result[1])
            end
        end)
    end
end)
