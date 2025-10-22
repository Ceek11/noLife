-- Variables pour les sous-menus des garages
local garage_submenus = {}

-- Fonction pour nettoyer les sous-menus obsolètes
local function CleanupObsoleteGarageSubmenus(current_garages)
    local current_keys = {}
    
    -- Collecter les clés actuelles
    if current_garages then
        for name, _ in pairs(current_garages) do
            table.insert(current_keys, "garage_" .. name)
        end
    end
    
    -- Supprimer les sous-menus qui n'existent plus
    for key, submenu in pairs(garage_submenus) do
        local exists = false
        for _, current_key in pairs(current_keys) do
            if key == current_key then
                exists = true
                break
            end
        end
        if not exists then
            garage_submenus[key] = nil
        end
    end
end

function garages_builder(garagesData)
    local TBL_GARAGES = garagesData or {}
    
    -- Nettoyer les sous-menus obsolètes
    CleanupObsoleteGarageSubmenus(TBL_GARAGES)
    
    RageUI.IsVisible(sub_menus_admin["garages"], function()
        RageUI.Button("Créer un garage", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un garage", {
                    {type = 'input', label = 'Nom du garage', description = 'Entrez le nom du garage (unique)', required = true, min = 2, max = 50},
                    {type = 'select', label = 'Type de garage', description = 'Type de véhicules acceptés', required = true, options = {
                        {value = 'car', label = 'Voitures'},
                        {value = 'bike', label = 'Motos'},
                        {value = 'boat', label = 'Bateaux'},
                        {value = 'heli', label = 'Hélicoptères'},
                        {value = 'plane', label = 'Avions'}
                    }},
                    {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir le garage', required = true, default = 'Appuyer sur ~INPUT_CONTEXT~ pour ouvrir le garage'},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: 32.586,-743.623,44.238|100.0,200.0,30.0)', required = true, icon = 'map-marker-alt'},
                    {type = 'input', label = 'Positions de spawn', description = 'Format: x,y,z,w|x2,y2,z2,w2 (ex: 32.586,-743.623,44.238,90.0|100.0,200.0,30.0,180.0)', required = true, icon = 'car'},
                    {type = 'input', label = 'Jobs autorisés', description = 'Liste des jobs séparés par des virgules (vide=tous)', icon = 'briefcase'},
                    {type = 'input', label = 'Points de suppression', description = 'Format: x,y,z,message|x2,y2,z2,message2 (optionnel)', icon = 'trash'},
                    {type = 'checkbox', label = 'Fourrière', description = 'Marquer comme fourrière (marqueur rouge)', checked = false},
                    {type = 'checkbox', label = 'Afficher le marqueur', description = 'Afficher le marqueur sur la carte', checked = true}
                })
                if input then
                    local coordsList = string.split(input[4], "|")
                    local coordsArray = {}
                    for i, coordString in pairs(coordsList) do
                        local coordsData = string.split(coordString, ",")
                        if #coordsData ~= 3 then
                            ESX.ShowNotification(string.format('Format de coordonnées invalide à la position %s. Utilisez: x,y,z', i))
                            return
                        end
                        local x, y, z = tonumber(coordsData[1]), tonumber(coordsData[2]), tonumber(coordsData[3])
                        if not x or not y or not z then
                            ESX.ShowNotification(string.format('Coordonnées invalides à la position %s. Les valeurs doivent être des nombres', i))
                            return
                        end
                        table.insert(coordsArray, {x = x, y = y, z = z})
                    end
                    
                    local spawnsList = string.split(input[5], "|")
                    local spawnsArray = {}
                    for i, spawnString in pairs(spawnsList) do
                        local spawnData = string.split(spawnString, ",")
                        if #spawnData ~= 4 then
                            ESX.ShowNotification(string.format('Format de spawn invalide à la position %s. Utilisez: x,y,z,w', i))
                            return
                        end
                        local x, y, z, w = tonumber(spawnData[1]), tonumber(spawnData[2]), tonumber(spawnData[3]), tonumber(spawnData[4])
                        if not x or not y or not z or not w then
                            ESX.ShowNotification(string.format('Position de spawn invalide à la position %s. Les valeurs doivent être des nombres', i))
                            return
                        end
                        table.insert(spawnsArray, {x = x, y = y, z = z, w = w})
                    end
                    
                    local jobAccess = {}
                    if input[6] and input[6] ~= "" then
                        jobAccess = string.split(input[6], ",")
                        for i, job in ipairs(jobAccess) do
                            jobAccess[i] = job:match("^%s*(.-)%s*$")
                        end
                    end
                    
                    local deletePoints = {}
                    if input[7] and input[7] ~= "" then
                        local deleteList = string.split(input[7], "|")
                        for i, deleteString in pairs(deleteList) do
                            local deleteData = string.split(deleteString, ",")
                            if #deleteData ~= 4 then
                                ESX.ShowNotification(string.format('Format de point de suppression invalide à la position %s. Utilisez: x,y,z,message', i))
                                return
                            end
                            local x, y, z = tonumber(deleteData[1]), tonumber(deleteData[2]), tonumber(deleteData[3])
                            if not x or not y or not z then
                                ESX.ShowNotification(string.format('Coordonnées de suppression invalides à la position %s. Les valeurs doivent être des nombres', i))
                                return
                            end
                            table.insert(deletePoints, {
                                x = x,
                                y = y,
                                z = z,
                                message = deleteData[4]
                            })
                        end
                    end
                    
                    local garageData = {
                        name = input[1],
                        type = input[2],
                        message = input[3],
                        coords = coordsArray,
                        spawnPositions = spawnsArray,
                        jobAccess = jobAccess,
                        deletePoints = deletePoints,
                        isImpound = input[8],
                        drawmarker = input[9]
                    }
                    
                    CORE.trigger_server_callback("fafadev:to_server:create_garage", function(success)
                        if success then
                            ESX.ShowNotification('Garage créé avec succès !')
                            CORE.trigger_server_callback("fafadev:to_server:get_garages", function(garages)
                                TBL_GARAGES = garages
                            end)
                        else
                            ESX.ShowNotification('Erreur lors de la création du garage')
                        end
                    end, garageData)
                end
            end
        })
        
        RageUI.Line()
        
        -- Affichage des garages avec sous-menus
        for name, garage in pairs(TBL_GARAGES) do
            local label = garage.name or name
            local info = string.format("Type: %s | Jobs: %s", garage.type or "car", table.concat(garage.jobAccess or {}, ", ") or "Tous")
            local submenu_key = "garage_" .. name
            
            -- Créer le sous-menu s'il n'existe pas
            if not garage_submenus[submenu_key] then
                garage_submenus[submenu_key] = RageUI.CreateSubMenu(sub_menus_admin["garages"], label, "Gestion du garage")
            else
                -- Mettre à jour le titre du sous-menu si le label a changé
                garage_submenus[submenu_key].Title = label
            end
            
            RageUI.Button(label, info, {RightLabel = "→→→"}, true, {
                onSelected = function()
                    -- Pas besoin d'action, le sous-menu s'ouvre automatiquement
                end
            }, garage_submenus[submenu_key])
        end
    end)
    
    -- Gestion des sous-menus individuels des garages
    for submenu_key, submenu in pairs(garage_submenus) do
        RageUI.IsVisible(submenu, function()
            local garage_name = string.match(submenu_key, "garage_(.+)")
            local garage_data = TBL_GARAGES[garage_name]
            
            if garage_data then
                local garage_label = garage_data.name or garage_name
                
                RageUI.Separator("~b~" .. garage_label .. "~s~")
                
                -- Téléportation
                RageUI.Button("Se téléporter au garage", "Se téléporter aux coordonnées du garage", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        if garage_data.coords and #garage_data.coords > 0 then
                            local coords = garage_data.coords[1]
                            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
                            ESX.ShowNotification('Téléportation effectuée !')
                        end
                    end
                })
                
                -- Modification
                RageUI.Button("Modifier les informations", "Modifier les paramètres du garage", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        local coordsString = ""
                        if garage_data.coords then
                            local coordsList = {}
                            for _, coord in pairs(garage_data.coords) do
                                table.insert(coordsList, string.format("%.2f,%.2f,%.2f", coord.x, coord.y, coord.z))
                            end
                            coordsString = table.concat(coordsList, "|")
                        end
                        
                        local spawnsString = ""
                        if garage_data.spawnPositions then
                            local spawnsList = {}
                            for _, spawn in pairs(garage_data.spawnPositions) do
                                table.insert(spawnsList, string.format("%.2f,%.2f,%.2f,%.2f", spawn.x, spawn.y, spawn.z, spawn.w))
                            end
                            spawnsString = table.concat(spawnsList, "|")
                        end
                        
                        local deleteString = ""
                        if garage_data.deletePoints then
                            local deleteList = {}
                            for _, delete in pairs(garage_data.deletePoints) do
                                table.insert(deleteList, string.format("%.2f,%.2f,%.2f,%s", delete.x, delete.y, delete.z, delete.message))
                            end
                            deleteString = table.concat(deleteList, "|")
                        end
                        
                        local input = lib.inputDialog("Modifier le garage", {
                            {type = 'input', label = 'Nom du garage', description = 'Entrez le nom du garage (unique)', required = true, min = 2, max = 50, default = garage_data.name or ""},
                            {type = 'select', label = 'Type de garage', description = 'Type de véhicules acceptés', required = true, options = {
                                {value = 'car', label = 'Voitures'},
                                {value = 'bike', label = 'Motos'},
                                {value = 'boat', label = 'Bateaux'},
                                {value = 'heli', label = 'Hélicoptères'},
                                {value = 'plane', label = 'Avions'}
                            }, default = garage_data.type or 'car'},
                            {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir le garage', required = true, default = garage_data.message or ""},
                            {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2', required = true, icon = 'map-marker-alt', default = coordsString},
                            {type = 'input', label = 'Positions de spawn', description = 'Format: x,y,z,w|x2,y2,z2,w2', required = true, icon = 'car', default = spawnsString},
                            {type = 'input', label = 'Jobs autorisés', description = 'Liste des jobs séparés par des virgules (vide=tous)', icon = 'briefcase', default = table.concat(garage_data.jobAccess or {}, ",")},
                            {type = 'input', label = 'Points de suppression', description = 'Format: x,y,z,message|x2,y2,z2,message2 (optionnel)', icon = 'trash', default = deleteString},
                            {type = 'checkbox', label = 'Fourrière', description = 'Marquer comme fourrière (marqueur rouge)', checked = garage_data.isImpound or false},
                            {type = 'checkbox', label = 'Afficher le marqueur', description = 'Afficher le marqueur sur la carte', checked = garage_data.drawmarker or false}
                        })
                        if input then
                            local coordsList = string.split(input[4], "|")
                            local coordsArray = {}
                            for i, coordString in pairs(coordsList) do
                                local coordsData = string.split(coordString, ",")
                                if #coordsData ~= 3 then
                                    ESX.ShowNotification(string.format('Format de coordonnées invalide à la position %s. Utilisez: x,y,z', i))
                                    return
                                end
                                local x, y, z = tonumber(coordsData[1]), tonumber(coordsData[2]), tonumber(coordsData[3])
                                if not x or not y or not z then
                                    ESX.ShowNotification(string.format('Coordonnées invalides à la position %s. Les valeurs doivent être des nombres', i))
                                    return
                                end
                                table.insert(coordsArray, {x = x, y = y, z = z})
                            end
                            
                            local spawnsList = string.split(input[5], "|")
                            local spawnsArray = {}
                            for i, spawnString in pairs(spawnsList) do
                                local spawnData = string.split(spawnString, ",")
                                if #spawnData ~= 4 then
                                    ESX.ShowNotification(string.format('Format de spawn invalide à la position %s. Utilisez: x,y,z,w', i))
                                    return
                                end
                                local x, y, z, w = tonumber(spawnData[1]), tonumber(spawnData[2]), tonumber(spawnData[3]), tonumber(spawnData[4])
                                if not x or not y or not z or not w then
                                    ESX.ShowNotification(string.format('Position de spawn invalide à la position %s. Les valeurs doivent être des nombres', i))
                                    return
                                end
                                table.insert(spawnsArray, {x = x, y = y, z = z, w = w})
                            end
                            
                            local jobAccess = {}
                            if input[6] and input[6] ~= "" then
                                jobAccess = string.split(input[6], ",")
                                for i, job in ipairs(jobAccess) do
                                    jobAccess[i] = job:match("^%s*(.-)%s*$")
                                end
                            end
                            
                            local deletePoints = {}
                            if input[7] and input[7] ~= "" then
                                local deleteList = string.split(input[7], "|")
                                for i, deleteString in pairs(deleteList) do
                                    local deleteData = string.split(deleteString, ",")
                                    if #deleteData ~= 4 then
                                        ESX.ShowNotification(string.format('Format de point de suppression invalide à la position %s. Utilisez: x,y,z,message', i))
                                        return
                                    end
                                    local x, y, z = tonumber(deleteData[1]), tonumber(deleteData[2]), tonumber(deleteData[3])
                                    if not x or not y or not z then
                                        ESX.ShowNotification(string.format('Coordonnées de suppression invalides à la position %s. Les valeurs doivent être des nombres', i))
                                        return
                                    end
                                    table.insert(deletePoints, {
                                        x = x,
                                        y = y,
                                        z = z,
                                        message = deleteData[4]
                                    })
                                end
                            end
                            
                            local garageData = {
                                name = input[1],
                                type = input[2],
                                message = input[3],
                                coords = coordsArray,
                                spawnPositions = spawnsArray,
                                jobAccess = jobAccess,
                                deletePoints = deletePoints,
                                isImpound = input[8],
                                drawmarker = input[9]
                            }
                            
                            CORE.trigger_server_callback("fafadev:to_server:update_garage", function(success)
                                if success then
                                    ESX.ShowNotification('Garage modifié avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_garages", function(garages)
                                        TBL_GARAGES = garages
                                        -- Mettre à jour le titre du sous-menu
                                        if garage_submenus[submenu_key] then
                                            garage_submenus[submenu_key].Title = input[1]
                                        end
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la modification du garage')
                                end
                            end, garage_name, garageData)
                        end
                    end
                })
                
                -- Suppression
                RageUI.Button("Supprimer le garage", "Supprimer définitivement ce garage", {RightLabel = "~r~Supprimer~s~"}, true, {
                    onSelected = function()
                        local confirm = lib.alertDialog({
                            header = 'Confirmation',
                            content = 'Êtes-vous sûr de vouloir supprimer le garage "' .. garage_label .. '" ?',
                            centered = true,
                            cancel = true
                        })
                        if confirm == 'confirm' then
                            CORE.trigger_server_callback("fafadev:to_server:delete_garage", function(success)
                                if success then
                                    ESX.ShowNotification('Garage supprimé avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_garages", function(garages)
                                        TBL_GARAGES = garages
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la suppression du garage')
                                end
                            end, garage_name)
                        end
                    end
                })
            end
        end)
    end
end

return garages_builder
