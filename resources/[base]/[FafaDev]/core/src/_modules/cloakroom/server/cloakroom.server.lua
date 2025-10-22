local function validate_boss_permission(source, job_name)
    local xPlayer = ESX.GetPlayerFromId(source)
    local result = xPlayer and xPlayer.job and xPlayer.job.grade_name == "boss" and xPlayer.job.name == job_name
    return result
end

local function notify_clients_update(society_name)
    CORE.trigger_client_event("templatejob:to_client:cloakroom_updated", -1, society_name)
end


CORE.register_server_callback("templatejob:to_server:get_cloakroom_data", function(source, cb, society_name)       
    if source <= 0 then return end 
    
    MySQL.Async.fetchAll('SELECT * FROM cloakroom WHERE society_name = ?', { society_name }, function(result)
        if result and #result > 0 then
            for i = 1, #result do
                if result[i].info_outfit then
                    result[i].info_outfit = json.decode(result[i].info_outfit)
                end
                if result[i].outfit then
                    result[i].outfit = json.decode(result[i].outfit)
                end
            end
            cb(result)
        else
            cb({})
        end
    end)
end)

CORE.register_server_event("templatejob:to_server:add_cloakroom", function(source, society_name, info_outfit, outfit)    
    if not validate_boss_permission(source, society_name) then
        TriggerClientEvent("esx:showNotification", source, "Vous n'avez pas les permissions nécessaires")
        return
    end
    
    if not society_name or not info_outfit or not outfit or not outfit.model then
        TriggerClientEvent("esx:showNotification", source, "Données manquantes")
        return
    end
    
    local grade = tonumber(info_outfit.grade)
    if not grade or grade < 0 or not info_outfit.label then
        TriggerClientEvent("esx:showNotification", source, "Grade invalide")
        return
    end
    
    local outfit_data = {}
    for k, v in pairs(outfit) do
        outfit_data[k] = v
    end
    
    local info_data = {
        label = info_outfit.label,
        grade = grade
    }
    
    MySQL.Async.insert('INSERT INTO cloakroom (society_name, info_outfit, outfit) VALUES (?, ?, ?)', 
        { society_name, json.encode(info_data), json.encode(outfit_data)}, 
        function(insertId)
            if insertId then
                notify_clients_update(society_name)
                TriggerClientEvent("esx:showNotification", source, "Tenue créée avec succès")
            else
                TriggerClientEvent("esx:showNotification", source, "Échec de la création de la tenue")
            end
        end)
end)

CORE.register_server_event("templatejob:to_server:update_outfit_info", function(source, outfit_id, field, value)
    if not outfit_id or not field or not value then
        TriggerClientEvent("esx:showNotification", source, "Données manquantes")
        return
    end
    
    if field == "grade" then
        value = tonumber(value)
        if not value or value < 0 then
            TriggerClientEvent("esx:showNotification", source, "Grade invalide")
            return
        end
    end
    
    MySQL.Async.fetchAll('SELECT society_name, info_outfit FROM cloakroom WHERE id = ?', { outfit_id }, function(result)
        if result and #result > 0 then
            local current_data = result[1]
            
            -- Vérifier les permissions maintenant qu'on a le society_name
            if not validate_boss_permission(source, current_data.society_name) then
                TriggerClientEvent("esx:showNotification", source, "Vous n'avez pas les permissions nécessaires")
                return
            end
            
            local success, info_outfit = pcall(json.decode, current_data.info_outfit)
            
            if not success then
                TriggerClientEvent("esx:showNotification", source, "Erreur lors de la lecture des données")
                return
            end
            
            info_outfit[field] = value
            
            MySQL.Async.execute('UPDATE cloakroom SET info_outfit = ? WHERE id = ?', 
                { json.encode(info_outfit), outfit_id }, 
                function(affectedRows)
                    if affectedRows and affectedRows > 0 then
                        notify_clients_update(current_data.society_name)
                        TriggerClientEvent("esx:showNotification", source, "Champ mis à jour avec succès")
                    else
                        TriggerClientEvent("esx:showNotification", source, "Échec de la mise à jour")
                    end
                end)
        else
            TriggerClientEvent("esx:showNotification", source, "Tenue introuvable")
        end
    end)
end)

CORE.register_server_event("templatejob:to_server:update_outfit_clothes", function(source, outfit_id, outfit_data)
    MySQL.Async.fetchAll('SELECT society_name FROM cloakroom WHERE id = ?', { outfit_id }, function(result)
        if result and #result > 0 then
            local society_name = result[1].society_name
            
            -- Vérifier les permissions
            if not validate_boss_permission(source, society_name) then
                TriggerClientEvent("esx:showNotification", source, "Vous n'avez pas les permissions nécessaires")
                return
            end
            
            MySQL.Async.execute('UPDATE cloakroom SET outfit = ? WHERE id = ?', { json.encode(outfit_data), outfit_id }, function(affectedRows)
                if affectedRows and affectedRows > 0 then
                    notify_clients_update(society_name)
                    TriggerClientEvent("esx:showNotification", source, "Tenue mise à jour avec succès")
                else
                    TriggerClientEvent("esx:showNotification", source, "Échec de la mise à jour")
                end
            end)
        else
            TriggerClientEvent("esx:showNotification", source, "Tenue introuvable")
        end
    end)
end)

CORE.register_server_event("templatejob:to_server:remove_cloakroom", function(source, society_name, outfit_id)
    if not validate_boss_permission(source, society_name) then
        TriggerClientEvent("esx:showNotification", source, "Vous n'avez pas les permissions nécessaires")
        return
    end
    
    MySQL.Async.execute('DELETE FROM cloakroom WHERE id = ? AND society_name = ?', { outfit_id, society_name }, function(affectedRows)
        if affectedRows and affectedRows > 0 then
            notify_clients_update(society_name)
            TriggerClientEvent("esx:showNotification", source, "Tenue supprimée avec succès")
        end
    end)
end)
