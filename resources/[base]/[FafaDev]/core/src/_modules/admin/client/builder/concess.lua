function concess_builder(concessData)
    local TBL_CONCESS_BUILDER = concessData or {}
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
        RageUI.Separator("~b~Points de vente")
        if TBL_CONCESS_BUILDER and TBL_CONCESS_BUILDER.sell then
            for _, sell in pairs(TBL_CONCESS_BUILDER.sell) do
                local jobsText = sell.jobAccess and #sell.jobAccess > 0 and table.concat(sell.jobAccess, ",") or "Aucun"
                local categoriesText = sell.categories and #sell.categories > 0 and table.concat(sell.categories, ",") or "Aucune"
                RageUI.Button(sell.name, "Jobs: " .. jobsText .. " | Catégories: " .. categoriesText, {RightLabel = "~r~Supprimer~s~"}, true, {
                    onSelected = function()
                        local confirm = lib.alertDialog({
                            header = 'Confirmation',
                            content = 'Êtes-vous sûr de vouloir supprimer le point de vente "' .. sell.name .. '" ?',
                            centered = true,
                            cancel = true
                        })
                        if confirm == 'confirm' then
                            CORE.trigger_server_callback("fafadev:to_server:delete_concess_sell", function(success)
                                if success then
                                    ESX.ShowNotification('Point de vente supprimé avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_concess", function(concess)
                                        TBL_CONCESS_BUILDER = concess
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la suppression du point de vente')
                                end
                            end, sell.name)
                        end
                    end
                })
            end
        end
        
        RageUI.Separator("~b~Points de prévisualisation")
        if TBL_CONCESS_BUILDER and TBL_CONCESS_BUILDER.preview then
            for _, preview in pairs(TBL_CONCESS_BUILDER.preview) do
                local categoriesText = preview.categories and #preview.categories > 0 and table.concat(preview.categories, ",") or "Aucune"
                RageUI.Button(preview.name, "Catégories: " .. categoriesText, {RightLabel = "~r~Supprimer~s~"}, true, {
                    onSelected = function()
                        local confirm = lib.alertDialog({
                            header = 'Confirmation',
                            content = 'Êtes-vous sûr de vouloir supprimer le point de prévisualisation "' .. preview.name .. '" ?',
                            centered = true,
                            cancel = true
                        })
                        if confirm == 'confirm' then
                            CORE.trigger_server_callback("fafadev:to_server:delete_concess_preview", function(success)
                                if success then
                                    ESX.ShowNotification('Point de prévisualisation supprimé avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_concess", function(concess)
                                        TBL_CONCESS_BUILDER = concess
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la suppression du point de prévisualisation')
                                end
                            end, preview.name)
                        end
                    end
                })
            end
        end
    end)
end

return concess_builder
