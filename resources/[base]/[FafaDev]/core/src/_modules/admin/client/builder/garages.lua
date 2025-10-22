function garages_builder(garagesData)
    local TBL_GARAGES = garagesData or {}
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
        for name, garage in pairs(TBL_GARAGES) do 
            RageUI.Button(garage.name or name, nil, {RightLabel = "~r~Supprimer~s~"}, true, {
                onSelected = function()
                    local confirm = lib.alertDialog({
                        header = 'Confirmation',
                        content = string.format('Êtes-vous sûr de vouloir supprimer le garage "%s" ?', garage.name or name),
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
                        end, name)
                    end
                end
            })
        end
    end)
end

return garages_builder
