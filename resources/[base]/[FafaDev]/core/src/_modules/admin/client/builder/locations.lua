-- Variables pour les sous-menus des locations
local location_submenus = {}

-- Fonction pour nettoyer les sous-menus obsolètes
local function CleanupObsoleteLocationSubmenus(current_locations)
    local current_keys = {}
    
    -- Collecter les clés actuelles
    if current_locations then
        for name, _ in pairs(current_locations) do
            table.insert(current_keys, "location_" .. name)
        end
    end
    
    -- Supprimer les sous-menus qui n'existent plus
    for key, submenu in pairs(location_submenus) do
        local exists = false
        for _, current_key in pairs(current_keys) do
            if key == current_key then
                exists = true
                break
            end
        end
        if not exists then
            location_submenus[key] = nil
        end
    end
end

function locations_builder(locationsData)
    local TBL_LOCATIONS = locationsData or {}
    
    -- Nettoyer les sous-menus obsolètes
    CleanupObsoleteLocationSubmenus(TBL_LOCATIONS)
    
    RageUI.IsVisible(sub_menus_admin["locations"], function()
        RageUI.Button("Créer une location", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer une location", {
                    {type = 'input', label = 'Nom de la location', description = 'Entrez le nom de la location (unique)', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Label de la location', description = 'Nom affiché de la location', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir la location', required = true, default = 'Appuyer sur ~INPUT_CONTEXT~ pour accéder à la location'},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: 32.586,-743.623,44.238|100.0,200.0,30.0)', required = true, icon = 'map-marker-alt'},
                    {type = 'input', label = 'Positions de spawn', description = 'Format: x,y,z,w|x2,y2,z2,w2 (ex: 32.586,-743.623,44.238,90.0|100.0,200.0,30.0,180.0)', required = true, icon = 'car'},
                    {type = 'input', label = 'Véhicules', description = 'Format: model,label,price,deposit|model2,label2,price2,deposit2 (ex: adder,Adder,500,1000|zentorno,Zentorno,450,900)', required = true, icon = 'list'},
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
                    
                    local vehiclesList = string.split(input[6], "|")
                    local vehiclesArray = {}
                    for i, vehicleString in pairs(vehiclesList) do
                        local vehicleData = string.split(vehicleString, ",")
                        if #vehicleData ~= 4 then
                            ESX.ShowNotification(string.format('Format de véhicule invalide à la position %s. Utilisez: model,label,price,deposit', i))
                            return
                        end
                        local price = tonumber(vehicleData[3])
                        local deposit = tonumber(vehicleData[4])
                        if not price or not deposit then
                            ESX.ShowNotification(string.format('Prix ou caution invalide à la position %s. Les valeurs doivent être des nombres', i))
                            return
                        end
                        table.insert(vehiclesArray, {
                            model = vehicleData[1],
                            label = vehicleData[2],
                            price = price,
                            deposit = deposit
                        })
                    end
                    
                    local locationData = {
                        name = input[1],
                        label = input[2],
                        message = input[3],
                        coords = coordsArray,
                        spawn_positions = spawnsArray,
                        vehicles_list = vehiclesArray,
                        drawmarker = input[7]
                    }
                    
                    CORE.trigger_server_callback("fafadev:to_server:create_location", function(success)
                        if success then
                            ESX.ShowNotification('Location créée avec succès !')
                            CORE.trigger_server_callback("fafadev:to_server:get_locations", function(locations)
                                TBL_LOCATIONS = locations
                            end)
                        else
                            ESX.ShowNotification('Erreur lors de la création de la location')
                        end
                    end, locationData)
                end
            end
        })
        
        RageUI.Line()
        
        -- Affichage des locations avec sous-menus
        for name, location in pairs(TBL_LOCATIONS) do
            local label = location.label or name
            local vehiclesCount = location.vehicles_list and #location.vehicles_list or 0
            local info = string.format("Véhicules: %d | Spawns: %d", vehiclesCount, location.spawn_positions and #location.spawn_positions or 0)
            local submenu_key = "location_" .. name
            
            -- Créer le sous-menu s'il n'existe pas
            if not location_submenus[submenu_key] then
                location_submenus[submenu_key] = RageUI.CreateSubMenu(sub_menus_admin["locations"], label, "Gestion de la location")
            else
                -- Mettre à jour le titre du sous-menu si le label a changé
                location_submenus[submenu_key].Title = label
            end
            
            RageUI.Button(label, info, {RightLabel = "→→→"}, true, {
                onSelected = function()
                    -- Pas besoin d'action, le sous-menu s'ouvre automatiquement
                end
            }, location_submenus[submenu_key])
        end
    end)
    
    -- Gestion des sous-menus individuels des locations
    for submenu_key, submenu in pairs(location_submenus) do
        RageUI.IsVisible(submenu, function()
            local location_name = string.match(submenu_key, "location_(.+)")
            local location_data = TBL_LOCATIONS[location_name]
            
            if location_data then
                local location_label = location_data.label or location_name
                
                RageUI.Separator("~b~" .. location_label .. "~s~")
                
                -- Téléportation
                RageUI.Button("Se téléporter à la location", "Se téléporter aux coordonnées de la location", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        if location_data.coords and #location_data.coords > 0 then
                            local coords = location_data.coords[1]
                            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
                            ESX.ShowNotification('Téléportation effectuée !')
                        end
                    end
                })
                
                -- Modification
                RageUI.Button("Modifier les informations", "Modifier les paramètres de la location", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        local coordsString = ""
                        if location_data.coords then
                            local coordsList = {}
                            for _, coord in pairs(location_data.coords) do
                                table.insert(coordsList, string.format("%.2f,%.2f,%.2f", coord.x, coord.y, coord.z))
                            end
                            coordsString = table.concat(coordsList, "|")
                        end
                        
                        local spawnsString = ""
                        if location_data.spawn_positions then
                            local spawnsList = {}
                            for _, spawn in pairs(location_data.spawn_positions) do
                                table.insert(spawnsList, string.format("%.2f,%.2f,%.2f,%.2f", spawn.x, spawn.y, spawn.z, spawn.w))
                            end
                            spawnsString = table.concat(spawnsList, "|")
                        end
                        
                        local vehiclesString = ""
                        if location_data.vehicles_list then
                            local vehiclesList = {}
                            for _, vehicle in pairs(location_data.vehicles_list) do
                                table.insert(vehiclesList, string.format("%s,%s,%d,%d", vehicle.model, vehicle.label, vehicle.price, vehicle.deposit))
                            end
                            vehiclesString = table.concat(vehiclesList, "|")
                        end
                        
                        local input = lib.inputDialog("Modifier la location", {
                            {type = 'input', label = 'Nom de la location', description = 'Entrez le nom de la location (unique)', required = true, min = 2, max = 50, default = location_data.name or ""},
                            {type = 'input', label = 'Label de la location', description = 'Nom affiché de la location', required = true, min = 2, max = 50, default = location_data.label or ""},
                            {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir la location', required = true, default = location_data.message or ""},
                            {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2', required = true, icon = 'map-marker-alt', default = coordsString},
                            {type = 'input', label = 'Positions de spawn', description = 'Format: x,y,z,w|x2,y2,z2,w2', required = true, icon = 'car', default = spawnsString},
                            {type = 'input', label = 'Véhicules', description = 'Format: model,label,price,deposit|model2,label2,price2,deposit2', required = true, icon = 'list', default = vehiclesString},
                            {type = 'checkbox', label = 'Afficher le marqueur', description = 'Afficher le marqueur sur la carte', checked = location_data.drawmarker or false}
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
                            
                            local vehiclesList = string.split(input[6], "|")
                            local vehiclesArray = {}
                            for i, vehicleString in pairs(vehiclesList) do
                                local vehicleData = string.split(vehicleString, ",")
                                if #vehicleData ~= 4 then
                                    ESX.ShowNotification(string.format('Format de véhicule invalide à la position %s. Utilisez: model,label,price,deposit', i))
                                    return
                                end
                                local price = tonumber(vehicleData[3])
                                local deposit = tonumber(vehicleData[4])
                                if not price or not deposit then
                                    ESX.ShowNotification(string.format('Prix ou caution invalide à la position %s. Les valeurs doivent être des nombres', i))
                                    return
                                end
                                table.insert(vehiclesArray, {
                                    model = vehicleData[1],
                                    label = vehicleData[2],
                                    price = price,
                                    deposit = deposit
                                })
                            end
                            
                            local locationData = {
                                name = input[1],
                                label = input[2],
                                message = input[3],
                                coords = coordsArray,
                                spawn_positions = spawnsArray,
                                vehicles_list = vehiclesArray,
                                drawmarker = input[7]
                            }
                            
                            CORE.trigger_server_callback("fafadev:to_server:update_location", function(success)
                                if success then
                                    ESX.ShowNotification('Location modifiée avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_locations", function(locations)
                                        TBL_LOCATIONS = locations
                                        -- Mettre à jour le titre du sous-menu
                                        if location_submenus[submenu_key] then
                                            location_submenus[submenu_key].Title = input[2]
                                        end
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la modification de la location')
                                end
                            end, location_name, locationData)
                        end
                    end
                })
                
                -- Suppression
                RageUI.Button("Supprimer la location", "Supprimer définitivement cette location", {RightLabel = "~r~Supprimer~s~"}, true, {
                    onSelected = function()
                        local confirm = lib.alertDialog({
                            header = 'Confirmation',
                            content = 'Êtes-vous sûr de vouloir supprimer la location "' .. location_label .. '" ?',
                            centered = true,
                            cancel = true
                        })
                        if confirm == 'confirm' then
                            CORE.trigger_server_callback("fafadev:to_server:delete_location", function(success)
                                if success then
                                    ESX.ShowNotification('Location supprimée avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_locations", function(locations)
                                        TBL_LOCATIONS = locations
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la suppression de la location')
                                end
                            end, location_name)
                        end
                    end
                })
            end
        end)
    end
end

return locations_builder
