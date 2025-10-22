function locations_builder(locationsData)
    local TBL_LOCATIONS = locationsData or {}
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
        for name, location in pairs(TBL_LOCATIONS) do 
            RageUI.Button(location.label or name, nil, {RightLabel = "~r~Supprimer~s~"}, true, {
                onSelected = function()
                    local confirm = lib.alertDialog({
                        header = 'Confirmation',
                        content = string.format('Êtes-vous sûr de vouloir supprimer la location "%s" ?', location.label or name),
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
                        end, name)
                    end
                end
            })
        end
    end)
end

return locations_builder
