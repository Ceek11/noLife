local str_file_location = 'data/clookroom.json'
TBL_CLOAKROOMS = {}

-- Callback pour récupérer les données de skin du joueur
CORE.register_server_callback("esx_skin:getPlayerSkin", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb(nil)
        return
    end
    
    -- Récupérer les données de skin depuis la base de données
    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = ?', {xPlayer.identifier}, function(result)
        if result and #result > 0 then
            local userData = result[1]
            local skin = json.decode(userData.skin or '{}')
            
            -- Ajouter le modèle du joueur
            local playerPed = GetPlayerPed(source)
            if playerPed and playerPed ~= 0 then
                local model = GetEntityModel(playerPed)
                local modelString = (model == GetHashKey("mp_m_freemode_01") and "mp_m_freemode_01") or 
                                   (model == GetHashKey("mp_f_freemode_01") and "mp_f_freemode_01") or 
                                   "mp_m_freemode_01"
                skin.model = modelString
            else
                skin.model = "mp_m_freemode_01"
            end
            
            cb(skin)
        else
            cb(nil)
        end
    end)
end)

function FUN_LOAD_CLOAKROOMS()
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), str_file_location)
    if str_file_content then
        local tbl_cloakrooms = json.decode(str_file_content)
        for _, cloakroom in pairs(tbl_cloakrooms) do
            TBL_CLOAKROOMS[cloakroom.name] = cloakroom
        end
    end
end

CORE.register_server_callback("fafadev:to_server:get_cloakrooms", function(source, cb)
    cb(TBL_CLOAKROOMS)
end)

CORE.register_server_callback("fafadev:to_server:create_cloakroom", function(source, cb, cloakroomData)
    if not cloakroomData or not cloakroomData.name or not cloakroomData.coords or not cloakroomData.job then
        cb(false)
        return
    end
    
    if TBL_CLOAKROOMS[cloakroomData.name] then
        cb(false)
        return
    end
    
    TBL_CLOAKROOMS[cloakroomData.name] = cloakroomData
    
    -- Sauvegarder dans le fichier JSON
    local cloakroomsArray = {}
    for _, cloakroom in pairs(TBL_CLOAKROOMS) do
        table.insert(cloakroomsArray, cloakroom)
    end
    
    local success = SaveResourceFile(GetCurrentResourceName(), str_file_location, json.encode(cloakroomsArray, {indent = true}), -1)
    if success then
        -- Rafraîchir automatiquement les vestiaires pour tous les joueurs
        CORE.trigger_client_callback("fafadev:to_client:refresh_cloakrooms", -1, function() end, TBL_CLOAKROOMS)
        cb(true)
    else
        TBL_CLOAKROOMS[cloakroomData.name] = nil
        cb(false)
    end
end)

CORE.register_server_callback("fafadev:to_server:update_cloakroom", function(source, cb, cloakroomData)
    if not cloakroomData or not cloakroomData.old_name or not cloakroomData.name or not cloakroomData.coords or not cloakroomData.job then
        cb(false)
        return
    end
    
    -- Vérifier que l'ancien vestiaire existe
    if not TBL_CLOAKROOMS[cloakroomData.old_name] then
        cb(false)
        return
    end
    
    -- Si le nom a changé, vérifier que le nouveau nom n'existe pas déjà
    if cloakroomData.old_name ~= cloakroomData.name and TBL_CLOAKROOMS[cloakroomData.name] then
        cb(false)
        return
    end
    
    -- Supprimer l'ancien vestiaire s'il a changé de nom
    if cloakroomData.old_name ~= cloakroomData.name then
        TBL_CLOAKROOMS[cloakroomData.old_name] = nil
    end
    
    -- Mettre à jour le vestiaire dans la table
    TBL_CLOAKROOMS[cloakroomData.name] = cloakroomData
    
    -- Sauvegarder dans le fichier JSON
    local cloakroomsArray = {}
    for _, cloakroom in pairs(TBL_CLOAKROOMS) do
        table.insert(cloakroomsArray, cloakroom)
    end
    
    local success = SaveResourceFile(GetCurrentResourceName(), str_file_location, json.encode(cloakroomsArray, {indent = true}), -1)
    if success then
        -- Rafraîchir automatiquement les vestiaires pour tous les joueurs
        CORE.trigger_client_callback("fafadev:to_client:refresh_cloakrooms", -1, function() end, TBL_CLOAKROOMS)
        cb(true)
    else
        -- Annuler les changements en cas d'erreur
        if cloakroomData.old_name ~= cloakroomData.name then
            TBL_CLOAKROOMS[cloakroomData.old_name] = TBL_CLOAKROOMS[cloakroomData.name]
            TBL_CLOAKROOMS[cloakroomData.name] = nil
        end
        cb(false)
    end
end)

CORE.register_server_callback("fafadev:to_server:delete_cloakroom", function(source, cb, cloakroomName)
    if not cloakroomName or not TBL_CLOAKROOMS[cloakroomName] then
        cb(false)
        return
    end
    
    TBL_CLOAKROOMS[cloakroomName] = nil
    
    -- Sauvegarder dans le fichier JSON
    local cloakroomsArray = {}
    for _, cloakroom in pairs(TBL_CLOAKROOMS) do
        table.insert(cloakroomsArray, cloakroom)
    end
    
    local success = SaveResourceFile(GetCurrentResourceName(), str_file_location, json.encode(cloakroomsArray, {indent = true}), -1)
    if success then
        -- Rafraîchir automatiquement les vestiaires pour tous les joueurs
        CORE.trigger_client_callback("fafadev:to_client:refresh_cloakrooms", -1, function() end, TBL_CLOAKROOMS)
    end
    cb(success)
end)
