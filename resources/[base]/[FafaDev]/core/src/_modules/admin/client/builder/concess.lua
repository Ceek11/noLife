-- Variables pour les sous-menus des concessionnaires
local concess_submenus = {}

-- Fonction pour nettoyer les sous-menus obsolètes
local function CleanupObsoleteConcessSubmenus(current_concess)
    local current_keys = {}
    
    -- Collecter les clés actuelles
    if current_concess then
        if current_concess.sell then
            for _, sell in pairs(current_concess.sell) do
                table.insert(current_keys, "concess_sell_" .. sell.name)
            end
        end
        if current_concess.preview then
            for _, preview in pairs(current_concess.preview) do
                table.insert(current_keys, "concess_preview_" .. preview.name)
            end
        end
    end
    
    -- Supprimer les sous-menus qui n'existent plus
    for key, submenu in pairs(concess_submenus) do
        local exists = false
        for _, current_key in pairs(current_keys) do
            if key == current_key then
                exists = true
                break
            end
        end
        if not exists then
            concess_submenus[key] = nil
        end
    end
end

function concess_builder(concessData)
    local TBL_CONCESS_BUILDER = concessData or {}
    
    -- Nettoyer les sous-menus obsolètes
    CleanupObsoleteConcessSubmenus(TBL_CONCESS_BUILDER)
    
    RageUI.IsVisible(sub_menus_admin["concess"], function()
        RageUI.Button("Créer un point de vente", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un point de vente", {
                    {type = 'input', label = 'Nom du concessionnaire', description = 'Nom unique du concessionnaire', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Message d\'interaction', description = 'Message affiché au joueur', required = true, default = 'Appuyez sur ~INPUT_CONTEXT~ pour vendre un véhicule'},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: -63.501,-1106.249,26.250)', required = true, icon = 'map-marker-alt'},
                    {type = 'input', label = 'Positions de spawn', description = 'Format: x,y,z,heading|x2,y2,z2,heading2 (ex: -70.679,-1105.808,26.082,0.0)', required = true, icon = 'car'},
                    {type = 'input', label = 'Jobs autorisés', description = 'Liste des jobs séparés par des virgules (ex: cardealer,admin)', required = true, icon = 'briefcase'},
                    {type = 'input', label = 'Catégories de véhicules', description = 'Liste des catégories séparées par des virgules (ex: super,sports,compacts)', required = true, icon = 'list'},
                    {type = 'checkbox', label = 'Afficher le marqueur', description = 'Afficher le marqueur sur la carte', checked = true}
                })
                if input then
                    local coordsList = string.split(input[3], "|")
                    local coordsArray = {}
                    for i, coordString in pairs(coordsList) do
                        local coordsData = string.split(coordString, ",")
                        if #coordsData ~= 3 then
                            ESX.ShowNotification('Format de coordonnées invalide à la position ' .. i .. '. Utilisez: x,y,z')
                            return
                        end
                        local x, y, z = tonumber(coordsData[1]), tonumber(coordsData[2]), tonumber(coordsData[3])
                        if not x or not y or not z then
                            ESX.ShowNotification('Coordonnées invalides à la position ' .. i)
                            return
                        end
                        table.insert(coordsArray, {x = x, y = y, z = z})
                    end
                    
                    local spawnsList = string.split(input[4], "|")
                    local spawnsArray = {}
                    for i, spawnString in pairs(spawnsList) do
                        local spawnData = string.split(spawnString, ",")
                        if #spawnData ~= 4 then
                            ESX.ShowNotification('Format de spawn invalide à la position ' .. i .. '. Utilisez: x,y,z,heading')
                            return
                        end
                        local x, y, z, heading = tonumber(spawnData[1]), tonumber(spawnData[2]), tonumber(spawnData[3]), tonumber(spawnData[4])
                        if not x or not y or not z or not heading then
                            ESX.ShowNotification('Position de spawn invalide à la position ' .. i)
                            return
                        end
                        table.insert(spawnsArray, {x = x, y = y, z = z, heading = heading})
                    end
                    
                    local jobs = {}
                    if input[5] and input[5] ~= "" then
                        jobs = string.split(input[5], ",")
                        for i, job in ipairs(jobs) do
                            jobs[i] = job:match("^%s*(.-)%s*$")
                        end
                    end
                    
                    local categories = {}
                    if input[6] and input[6] ~= "" then
                        categories = string.split(input[6], ",")
                        for i, cat in ipairs(categories) do
                            categories[i] = cat:match("^%s*(.-)%s*$")
                        end
                    end
                    
                    local sellData = {
                        name = input[1],
                        message = input[2],
                        coords = coordsArray,
                        spawnPositions = spawnsArray,
                        jobAccess = jobs,
                        categories = categories,
                        drawmarker = input[7]
                    }
                    
                    CORE.trigger_server_callback("fafadev:to_server:create_concess_sell", function(success)
                        if success then
                            ESX.ShowNotification('Point de vente créé avec succès !')
                            CORE.trigger_server_callback("fafadev:to_server:get_concess", function(concess)
                                TBL_CONCESS_BUILDER = concess
                            end)
                        else
                            ESX.ShowNotification('Erreur lors de la création du point de vente')
                        end
                    end, sellData)
                end
            end
        })
        
        RageUI.Button("Créer un point de prévisualisation", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un point de prévisualisation", {
                    {type = 'input', label = 'Nom du concessionnaire', description = 'Nom unique du concessionnaire', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Message d\'interaction', description = 'Message affiché au joueur', required = true, default = 'Appuyez sur ~INPUT_CONTEXT~ pour prévisualiser les véhicules'},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: -65.79,-1096.63,25.42)', required = true, icon = 'map-marker-alt'},
                    {type = 'input', label = 'Positions de spawn', description = 'Format: x,y,z,heading|x2,y2,z2,heading2 (ex: -50.0,-1100.0,25.0,0.0)', required = true, icon = 'car'},
                    {type = 'input', label = 'Point de test', description = 'Format: x,y,z,heading (ex: -1032.0,-2730.0,13.75,330.0)', required = true, icon = 'map-pin'},
                    {type = 'number', label = 'Rayon de la zone de test', description = 'Rayon en mètres', default = 500, min = 100, max = 2000},
                    {type = 'input', label = 'Catégories de véhicules', description = 'Liste des catégories séparées par des virgules (ex: super,sports,compacts)', required = true, icon = 'list'},
                    {type = 'checkbox', label = 'Afficher le marqueur', description = 'Afficher le marqueur sur la carte', checked = true}
                })
                if input then
                    local coordsList = string.split(input[3], "|")
                    local coordsArray = {}
                    for i, coordString in pairs(coordsList) do
                        local coordsData = string.split(coordString, ",")
                        if #coordsData ~= 3 then
                            ESX.ShowNotification('Format de coordonnées invalide à la position ' .. i .. '. Utilisez: x,y,z')
                            return
                        end
                        local x, y, z = tonumber(coordsData[1]), tonumber(coordsData[2]), tonumber(coordsData[3])
                        if not x or not y or not z then
                            ESX.ShowNotification('Coordonnées invalides à la position ' .. i)
                            return
                        end
                        table.insert(coordsArray, {x = x, y = y, z = z})
                    end
                    
                    local spawnsList = string.split(input[4], "|")
                    local spawnsArray = {}
                    for i, spawnString in pairs(spawnsList) do
                        local spawnData = string.split(spawnString, ",")
                        if #spawnData ~= 4 then
                            ESX.ShowNotification('Format de spawn invalide à la position ' .. i .. '. Utilisez: x,y,z,heading')
                            return
                        end
                        local x, y, z, heading = tonumber(spawnData[1]), tonumber(spawnData[2]), tonumber(spawnData[3]), tonumber(spawnData[4])
                        if not x or not y or not z or not heading then
                            ESX.ShowNotification('Position de spawn invalide à la position ' .. i)
                            return
                        end
                        table.insert(spawnsArray, {x = x, y = y, z = z, heading = heading})
                    end
                    
                    local testPointData = string.split(input[5], ",")
                    if #testPointData ~= 4 then
                        ESX.ShowNotification('Format du point de test invalide. Utilisez: x,y,z,heading')
                        return
                    end
                    local tx, ty, tz, th = tonumber(testPointData[1]), tonumber(testPointData[2]), tonumber(testPointData[3]), tonumber(testPointData[4])
                    if not tx or not ty or not tz or not th then
                        ESX.ShowNotification('Point de test invalide')
                        return
                    end
                    local testPoint = {x = tx, y = ty, z = tz, heading = th}
                    
                    local categories = {}
                    if input[7] and input[7] ~= "" then
                        categories = string.split(input[7], ",")
                        for i, cat in ipairs(categories) do
                            categories[i] = cat:match("^%s*(.-)%s*$")
                        end
                    end
                    
                    local previewData = {
                        name = input[1],
                        message = input[2],
                        coords = coordsArray,
                        spawnPositions = spawnsArray,
                        testPoint = testPoint,
                        testZoneRadius = input[6] or 500,
                        categories = categories,
                        drawmarker = input[8]
                    }
                    
                    CORE.trigger_server_callback("fafadev:to_server:create_concess_preview", function(success)
                        if success then
                            ESX.ShowNotification('Point de prévisualisation créé avec succès !')
                            CORE.trigger_server_callback("fafadev:to_server:get_concess", function(concess)
                                TBL_CONCESS_BUILDER = concess
                            end)
                        else
                            ESX.ShowNotification('Erreur lors de la création du point de prévisualisation')
                        end
                    end, previewData)
                end
            end
        })
        
        RageUI.Line()
        
        -- Affichage des points de vente avec sous-menus
        RageUI.Separator("~b~Points de vente")
        if TBL_CONCESS_BUILDER and TBL_CONCESS_BUILDER.sell then
            for _, sell in pairs(TBL_CONCESS_BUILDER.sell) do
                local jobsText = sell.jobAccess and #sell.jobAccess > 0 and table.concat(sell.jobAccess, ",") or "Aucun"
                local categoriesText = sell.categories and #sell.categories > 0 and table.concat(sell.categories, ",") or "Aucune"
                local info = "Jobs: " .. jobsText .. " | Catégories: " .. categoriesText
                local submenu_key = "concess_sell_" .. sell.name
                
                -- Créer le sous-menu s'il n'existe pas
                if not concess_submenus[submenu_key] then
                    concess_submenus[submenu_key] = RageUI.CreateSubMenu(sub_menus_admin["concess"], sell.name, "Gestion du point de vente")
                else
                    -- Mettre à jour le titre du sous-menu si le nom a changé
                    concess_submenus[submenu_key].Title = sell.name
                end
                
                RageUI.Button(sell.name, info, {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        -- Pas besoin d'action, le sous-menu s'ouvre automatiquement
                    end
                }, concess_submenus[submenu_key])
            end
        end
        
        -- Affichage des points de prévisualisation avec sous-menus
        RageUI.Separator("~b~Points de prévisualisation")
        if TBL_CONCESS_BUILDER and TBL_CONCESS_BUILDER.preview then
            for _, preview in pairs(TBL_CONCESS_BUILDER.preview) do
                local categoriesText = preview.categories and #preview.categories > 0 and table.concat(preview.categories, ",") or "Aucune"
                local info = "Catégories: " .. categoriesText
                local submenu_key = "concess_preview_" .. preview.name
                
                -- Créer le sous-menu s'il n'existe pas
                if not concess_submenus[submenu_key] then
                    concess_submenus[submenu_key] = RageUI.CreateSubMenu(sub_menus_admin["concess"], preview.name, "Gestion du point de prévisualisation")
                else
                    -- Mettre à jour le titre du sous-menu si le nom a changé
                    concess_submenus[submenu_key].Title = preview.name
                end
                
                RageUI.Button(preview.name, info, {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        -- Pas besoin d'action, le sous-menu s'ouvre automatiquement
                    end
                }, concess_submenus[submenu_key])
            end
        end
    end)
    
    -- Gestion des sous-menus individuels des concessionnaires
    for submenu_key, submenu in pairs(concess_submenus) do
        RageUI.IsVisible(submenu, function()
            local is_sell = string.find(submenu_key, "concess_sell_")
            local concess_name = string.gsub(submenu_key, "concess_sell_", "")
            if not is_sell then
                concess_name = string.gsub(submenu_key, "concess_preview_", "")
            end
            
            local concess_data = nil
            if is_sell and TBL_CONCESS_BUILDER and TBL_CONCESS_BUILDER.sell then
                for _, sell in pairs(TBL_CONCESS_BUILDER.sell) do
                    if sell.name == concess_name then
                        concess_data = sell
                        break
                    end
                end
            elseif not is_sell and TBL_CONCESS_BUILDER and TBL_CONCESS_BUILDER.preview then
                for _, preview in pairs(TBL_CONCESS_BUILDER.preview) do
                    if preview.name == concess_name then
                        concess_data = preview
                        break
                    end
                end
            end
            
            if concess_data then
                RageUI.Separator("~b~" .. concess_name .. "~s~")
                
                -- Téléportation
                RageUI.Button("Se téléporter au concessionnaire", "Se téléporter aux coordonnées du concessionnaire", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        if concess_data.coords and #concess_data.coords > 0 then
                            local coords = concess_data.coords[1] -- Prendre la première coordonnée
                            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
                            ESX.ShowNotification('Téléportation effectuée !')
                        else
                            ESX.ShowNotification('Aucune coordonnée trouvée pour ce concessionnaire')
                        end
                    end
                })
                
                -- Modification
                RageUI.Button("Modifier les informations", "Modifier les paramètres du concessionnaire", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        local coordsString = ""
                        if concess_data.coords then
                            local coordsList = {}
                            for _, coord in pairs(concess_data.coords) do
                                table.insert(coordsList, string.format("%.2f,%.2f,%.2f", coord.x, coord.y, coord.z))
                            end
                            coordsString = table.concat(coordsList, "|")
                        end
                        
                        local spawnsString = ""
                        if concess_data.spawnPositions then
                            local spawnsList = {}
                            for _, spawn in pairs(concess_data.spawnPositions) do
                                table.insert(spawnsList, string.format("%.2f,%.2f,%.2f,%.2f", spawn.x, spawn.y, spawn.z, spawn.heading))
                            end
                            spawnsString = table.concat(spawnsList, "|")
                        end
                        
                        if is_sell then
                            -- Modification point de vente
                            local input = lib.inputDialog("Modifier le point de vente", {
                                {type = 'input', label = 'Nom du concessionnaire', description = 'Nom unique du concessionnaire', required = true, min = 2, max = 50, default = concess_data.name or ""},
                                {type = 'input', label = 'Message d\'interaction', description = 'Message affiché au joueur', required = true, default = concess_data.message or ""},
                                {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2', required = true, icon = 'map-marker-alt', default = coordsString},
                                {type = 'input', label = 'Positions de spawn', description = 'Format: x,y,z,heading|x2,y2,z2,heading2', required = true, icon = 'car', default = spawnsString},
                                {type = 'input', label = 'Jobs autorisés', description = 'Liste des jobs séparés par des virgules', icon = 'briefcase', default = table.concat(concess_data.jobAccess or {}, ",")},
                                {type = 'input', label = 'Catégories de véhicules', description = 'Liste des catégories séparées par des virgules', icon = 'list', default = table.concat(concess_data.categories or {}, ",")},
                                {type = 'checkbox', label = 'Afficher le marqueur', description = 'Afficher le marqueur sur la carte', checked = concess_data.drawmarker or false}
                            })
                            if input then
                                local coordsList = string.split(input[3], "|")
                                local coordsArray = {}
                                for i, coordString in pairs(coordsList) do
                                    local coordsData = string.split(coordString, ",")
                                    if #coordsData ~= 3 then
                                        ESX.ShowNotification('Format de coordonnées invalide à la position ' .. i .. '. Utilisez: x,y,z')
                                        return
                                    end
                                    local x, y, z = tonumber(coordsData[1]), tonumber(coordsData[2]), tonumber(coordsData[3])
                                    if not x or not y or not z then
                                        ESX.ShowNotification('Coordonnées invalides à la position ' .. i)
                                        return
                                    end
                                    table.insert(coordsArray, {x = x, y = y, z = z})
                                end
                                
                                local spawnsList = string.split(input[4], "|")
                                local spawnsArray = {}
                                for i, spawnString in pairs(spawnsList) do
                                    local spawnData = string.split(spawnString, ",")
                                    if #spawnData ~= 4 then
                                        ESX.ShowNotification('Format de spawn invalide à la position ' .. i .. '. Utilisez: x,y,z,heading')
                                        return
                                    end
                                    local x, y, z, heading = tonumber(spawnData[1]), tonumber(spawnData[2]), tonumber(spawnData[3]), tonumber(spawnData[4])
                                    if not x or not y or not z or not heading then
                                        ESX.ShowNotification('Position de spawn invalide à la position ' .. i)
                                        return
                                    end
                                    table.insert(spawnsArray, {x = x, y = y, z = z, heading = heading})
                                end
                                
                                local jobs = {}
                                if input[5] and input[5] ~= "" then
                                    jobs = string.split(input[5], ",")
                                    for i, job in ipairs(jobs) do
                                        jobs[i] = job:match("^%s*(.-)%s*$")
                                    end
                                end
                                
                                local categories = {}
                                if input[6] and input[6] ~= "" then
                                    categories = string.split(input[6], ",")
                                    for i, cat in ipairs(categories) do
                                        categories[i] = cat:match("^%s*(.-)%s*$")
                                    end
                                end
                                
                                local sellData = {
                                    old_name = concess_name,
                                    name = input[1],
                                    message = input[2],
                                    coords = coordsArray,
                                    spawnPositions = spawnsArray,
                                    jobAccess = jobs,
                                    categories = categories,
                                    drawmarker = input[7]
                                }
                                
                                CORE.trigger_server_callback("fafadev:to_server:update_concess_sell", function(success)
                                    if success then
                                        ESX.ShowNotification('Point de vente modifié avec succès !')
                                        CORE.trigger_server_callback("fafadev:to_server:get_concess", function(concess)
                                            TBL_CONCESS_BUILDER = concess
                                            -- Mettre à jour le titre du sous-menu
                                            if concess_submenus[submenu_key] then
                                                concess_submenus[submenu_key].Title = input[1]
                                            end
                                        end)
                                    else
                                        ESX.ShowNotification('Erreur lors de la modification du point de vente')
                                    end
                                end, sellData)
                            end
                        else
                            -- Modification point de prévisualisation
                            local testPointString = ""
                            if concess_data.testPoint then
                                testPointString = string.format("%.2f,%.2f,%.2f,%.2f", concess_data.testPoint.x, concess_data.testPoint.y, concess_data.testPoint.z, concess_data.testPoint.heading)
                            end
                            
                            local input = lib.inputDialog("Modifier le point de prévisualisation", {
                                {type = 'input', label = 'Nom du concessionnaire', description = 'Nom unique du concessionnaire', required = true, min = 2, max = 50, default = concess_data.name or ""},
                                {type = 'input', label = 'Message d\'interaction', description = 'Message affiché au joueur', required = true, default = concess_data.message or ""},
                                {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2', required = true, icon = 'map-marker-alt', default = coordsString},
                                {type = 'input', label = 'Positions de spawn', description = 'Format: x,y,z,heading|x2,y2,z2,heading2', required = true, icon = 'car', default = spawnsString},
                                {type = 'input', label = 'Point de test', description = 'Format: x,y,z,heading', required = true, icon = 'map-pin', default = testPointString},
                                {type = 'number', label = 'Rayon de la zone de test', description = 'Rayon en mètres', default = concess_data.testZoneRadius or 500, min = 100, max = 2000},
                                {type = 'input', label = 'Catégories de véhicules', description = 'Liste des catégories séparées par des virgules', icon = 'list', default = table.concat(concess_data.categories or {}, ",")},
                                {type = 'checkbox', label = 'Afficher le marqueur', description = 'Afficher le marqueur sur la carte', checked = concess_data.drawmarker or false}
                            })
                            if input then
                                local coordsList = string.split(input[3], "|")
                                local coordsArray = {}
                                for i, coordString in pairs(coordsList) do
                                    local coordsData = string.split(coordString, ",")
                                    if #coordsData ~= 3 then
                                        ESX.ShowNotification('Format de coordonnées invalide à la position ' .. i .. '. Utilisez: x,y,z')
                                        return
                                    end
                                    local x, y, z = tonumber(coordsData[1]), tonumber(coordsData[2]), tonumber(coordsData[3])
                                    if not x or not y or not z then
                                        ESX.ShowNotification('Coordonnées invalides à la position ' .. i)
                                        return
                                    end
                                    table.insert(coordsArray, {x = x, y = y, z = z})
                                end
                                
                                local spawnsList = string.split(input[4], "|")
                                local spawnsArray = {}
                                for i, spawnString in pairs(spawnsList) do
                                    local spawnData = string.split(spawnString, ",")
                                    if #spawnData ~= 4 then
                                        ESX.ShowNotification('Format de spawn invalide à la position ' .. i .. '. Utilisez: x,y,z,heading')
                                        return
                                    end
                                    local x, y, z, heading = tonumber(spawnData[1]), tonumber(spawnData[2]), tonumber(spawnData[3]), tonumber(spawnData[4])
                                    if not x or not y or not z or not heading then
                                        ESX.ShowNotification('Position de spawn invalide à la position ' .. i)
                                        return
                                    end
                                    table.insert(spawnsArray, {x = x, y = y, z = z, heading = heading})
                                end
                                
                                local testPointData = string.split(input[5], ",")
                                if #testPointData ~= 4 then
                                    ESX.ShowNotification('Format du point de test invalide. Utilisez: x,y,z,heading')
                                    return
                                end
                                local tx, ty, tz, th = tonumber(testPointData[1]), tonumber(testPointData[2]), tonumber(testPointData[3]), tonumber(testPointData[4])
                                if not tx or not ty or not tz or not th then
                                    ESX.ShowNotification('Point de test invalide')
                                    return
                                end
                                local testPoint = {x = tx, y = ty, z = tz, heading = th}
                                
                                local categories = {}
                                if input[7] and input[7] ~= "" then
                                    categories = string.split(input[7], ",")
                                    for i, cat in ipairs(categories) do
                                        categories[i] = cat:match("^%s*(.-)%s*$")
                                    end
                                end
                                
                                local previewData = {
                                    old_name = concess_name,
                                    name = input[1],
                                    message = input[2],
                                    coords = coordsArray,
                                    spawnPositions = spawnsArray,
                                    testPoint = testPoint,
                                    testZoneRadius = input[6] or 500,
                                    categories = categories,
                                    drawmarker = input[8]
                                }
                                
                                CORE.trigger_server_callback("fafadev:to_server:update_concess_preview", function(success)
                                    if success then
                                        ESX.ShowNotification('Point de prévisualisation modifié avec succès !')
                                        CORE.trigger_server_callback("fafadev:to_server:get_concess", function(concess)
                                            TBL_CONCESS_BUILDER = concess
                                            -- Mettre à jour le titre du sous-menu
                                            if concess_submenus[submenu_key] then
                                                concess_submenus[submenu_key].Title = input[1]
                                            end
                                        end)
                                    else
                                        ESX.ShowNotification('Erreur lors de la modification du point de prévisualisation')
                                    end
                                end, previewData)
                            end
                        end
                    end
                })
                
                -- Suppression
                RageUI.Button("Supprimer le concessionnaire", "Supprimer définitivement ce concessionnaire", {RightLabel = "~r~Supprimer~s~"}, true, {
                    onSelected = function()
                        local confirm = lib.alertDialog({
                            header = 'Confirmation',
                            content = 'Êtes-vous sûr de vouloir supprimer le concessionnaire "' .. concess_name .. '" ?',
                            centered = true,
                            cancel = true
                        })
                        if confirm == 'confirm' then
                            if is_sell then
                                CORE.trigger_server_callback("fafadev:to_server:delete_concess_sell", function(success)
                                    if success then
                                        ESX.ShowNotification('Point de vente supprimé avec succès !')
                                        CORE.trigger_server_callback("fafadev:to_server:get_concess", function(concess)
                                            TBL_CONCESS_BUILDER = concess
                                        end)
                                    else
                                        ESX.ShowNotification('Erreur lors de la suppression du point de vente')
                                    end
                                end, concess_name)
                            else
                                CORE.trigger_server_callback("fafadev:to_server:delete_concess_preview", function(success)
                                    if success then
                                        ESX.ShowNotification('Point de prévisualisation supprimé avec succès !')
                                        CORE.trigger_server_callback("fafadev:to_server:get_concess", function(concess)
                                            TBL_CONCESS_BUILDER = concess
                                        end)
                                    else
                                        ESX.ShowNotification('Erreur lors de la suppression du point de prévisualisation')
                                    end
                                end, concess_name)
                            end
                        end
                    end
                })
            end
        end)
    end
end

return concess_builder
