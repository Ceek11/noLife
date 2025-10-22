TBL_CHESTS = {}

function FUN_LOAD_CHESTS()
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), 'data/chests.json')
    tbl_chests = json.decode(str_file_content)
    for _, chest in pairs(tbl_chests) do
        TBL_CHESTS[chest.name] = chest
        exports.ox_inventory:RegisterStash(chest.name, chest.label, 100, chest.options.max_weight or 2000, false)
    end
end

CORE.register_server_callback("fafadev:to_server:get_chests", function(source, cb)
    cb(TBL_CHESTS)
end)

CORE.register_server_callback("fafadev:to_server:create_chest", function(source, cb, chestData)
    if not chestData or not chestData.name or not chestData.label or not chestData.coords then
        cb(false)
        return
    end
    
    if TBL_CHESTS[chestData.name] then
        cb(false)
        return
    end
    
    -- Ajouter le coffre à la table
    TBL_CHESTS[chestData.name] = chestData
    
    -- Enregistrer le coffre dans ox_inventory
    exports.ox_inventory:RegisterStash(chestData.name, chestData.label, 100, chestData.options.max_weight or 2000, false)
    
    -- Sauvegarder dans le fichier JSON
    local chestsArray = {}
    for _, chest in pairs(TBL_CHESTS) do
        table.insert(chestsArray, chest)
    end
    
    local success = SaveResourceFile(GetCurrentResourceName(), 'data/chests.json', json.encode(chestsArray, {indent = true}), -1)
    if success then
        -- Rafraîchir automatiquement les coffres pour tous les joueurs
        CORE.trigger_client_callback("fafadev:to_client:refresh_chests", -1, function() end, TBL_CHESTS)
        cb(true)
    else
        -- Annuler les changements en cas d'erreur
        TBL_CHESTS[chestData.name] = nil
        cb(false)
    end
end)

CORE.register_server_callback("fafadev:to_server:delete_chest", function(source, cb, chestName)
    if not chestName or not TBL_CHESTS[chestName] then
        cb(false)
        return
    end
    
    -- Supprimer le coffre de la table
    TBL_CHESTS[chestName] = nil
    
    -- Sauvegarder dans le fichier JSON
    local chestsArray = {}
    for _, chest in pairs(TBL_CHESTS) do
        table.insert(chestsArray, chest)
    end
    
    local success = SaveResourceFile(GetCurrentResourceName(), 'data/chests.json', json.encode(chestsArray, {indent = true}), -1)
    if success then
        -- Rafraîchir automatiquement les coffres pour tous les joueurs
        CORE.trigger_client_callback("fafadev:to_client:refresh_chests", -1, function() end, TBL_CHESTS)
    end
    cb(success)
end)