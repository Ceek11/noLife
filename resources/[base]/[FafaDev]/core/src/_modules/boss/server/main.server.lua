TBL_BOSS_MENUS = {}

function FUN_LOAD_BOSS_MENUS()
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), 'data/boss.json')
    if str_file_content then
        local tbl_boss_menus = json.decode(str_file_content)
        for _, boss_menu in pairs(tbl_boss_menus) do
            TBL_BOSS_MENUS[boss_menu.name] = boss_menu
        end
    end
end

CORE.register_server_callback("fafadev:to_server:get_boss", function(source, cb)
    cb(TBL_BOSS_MENUS)
end)

CORE.register_server_callback("fafadev:to_server:create_boss", function(source, cb, bossData)
    if not bossData or not bossData.name or not bossData.coords or not bossData.job then
        cb(false)
        return
    end
    
    if TBL_BOSS_MENUS[bossData.name] then
        cb(false)
        return
    end
    
    TBL_BOSS_MENUS[bossData.name] = bossData
    
    -- Sauvegarder dans le fichier JSON
    local bossMenusArray = {}
    for _, boss_menu in pairs(TBL_BOSS_MENUS) do
        table.insert(bossMenusArray, boss_menu)
    end
    
    local success = SaveResourceFile(GetCurrentResourceName(), 'data/boss.json', json.encode(bossMenusArray, {indent = true}), -1)
    if success then
        -- Rafraîchir automatiquement les menus boss pour tous les joueurs
        CORE.trigger_client_callback("fafadev:to_client:refresh_boss", -1, function() end, TBL_BOSS_MENUS)
        cb(true)
    else
        TBL_BOSS_MENUS[bossData.name] = nil
        cb(false)
    end
end)

CORE.register_server_callback("fafadev:to_server:update_boss", function(source, cb, bossName, bossData)
    if not bossName or not bossData or not TBL_BOSS_MENUS[bossName] then
        cb(false)
        return
    end
    
    -- Mettre à jour les données du menu boss
    TBL_BOSS_MENUS[bossName] = bossData
    
    -- Sauvegarder dans le fichier JSON
    local bossMenusArray = {}
    for _, boss_menu in pairs(TBL_BOSS_MENUS) do
        table.insert(bossMenusArray, boss_menu)
    end
    
    local success = SaveResourceFile(GetCurrentResourceName(), 'data/boss.json', json.encode(bossMenusArray, {indent = true}), -1)
    if success then
        -- Rafraîchir automatiquement les menus boss pour tous les joueurs
        CORE.trigger_client_callback("fafadev:to_client:refresh_boss", -1, function() end, TBL_BOSS_MENUS)
        cb(true)
    else
        cb(false)
    end
end)

CORE.register_server_callback("fafadev:to_server:delete_boss", function(source, cb, bossName)
    if not bossName or not TBL_BOSS_MENUS[bossName] then
        cb(false)
        return
    end
    
    TBL_BOSS_MENUS[bossName] = nil
    
    -- Sauvegarder dans le fichier JSON
    local bossMenusArray = {}
    for _, boss_menu in pairs(TBL_BOSS_MENUS) do
        table.insert(bossMenusArray, boss_menu)
    end
    
    local success = SaveResourceFile(GetCurrentResourceName(), 'data/boss.json', json.encode(bossMenusArray, {indent = true}), -1)
    if success then
        -- Rafraîchir automatiquement les menus boss pour tous les joueurs
        CORE.trigger_client_callback("fafadev:to_client:refresh_boss", -1, function() end, TBL_BOSS_MENUS)
    end
    cb(success)
end)
