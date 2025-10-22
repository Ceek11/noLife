function chests_builder(chestsData)
    local TBL_CHESTS = chestsData or {}
    RageUI.IsVisible(sub_menus_admin["chests"], function()
        RageUI.Button("Créer un coffre", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un coffre", {
                    {type = 'input', label = 'Nom du coffre', description = 'Entrez le nom du coffre (unique)', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Label du coffre', description = 'Nom affiché du coffre', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Job requis', description = 'Job nécessaire pour accéder au coffre (optionnel)', icon = 'briefcase'},
                    {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir le coffre', required = true, default = 'Appuyer sur ~INPUT_CONTEXT~ pour accéder au coffre'},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: 32.586411,-743.623474,44.238464|100.0,200.0,30.0)', required = true, icon = 'map-marker-alt'},
                    {type = 'number', label = 'Poids maximum', description = 'Poids maximum du coffre (défaut: 2000)', default = 2000, min = 100, max = 10000},
                    {type = 'checkbox', label = 'Afficher le marqueur', description = 'Afficher le marqueur sur la carte', checked = true}
                })
                if input then
                    local coordsList = string.split(input[5], "|")
                    local coordsArray = {}
                    for i, coordString in pairs(coordsList) do
                        local coordsData = string.split(coordString, ",")
                        if #coordsData ~= 3 then
                            ESX.ShowNotification('Format de coordonnées invalide à la position ' .. i .. '. Utilisez: x,y,z')
                            return
                        end
                        
                        local x, y, z = tonumber(coordsData[1]), tonumber(coordsData[2]), tonumber(coordsData[3])
                        if not x or not y or not z then
                            ESX.ShowNotification('Coordonnées invalides à la position ' .. i .. '. Les valeurs doivent être des nombres')
                            return
                        end
                        
                        table.insert(coordsArray, {x = x, y = y, z = z})
                    end
                    
                    local chestData = {
                        name = input[1],
                        label = input[2],
                        job = input[3] and input[3] ~= "" and input[3] or nil,
                        message = input[4],
                        coords = coordsArray,
                        drawmarker = input[7],
                        options = {
                            max_weight = input[6] or 2000
                        }
                    }
                    
                    CORE.trigger_server_callback("fafadev:to_server:create_chest", function(success)
                        if success then
                            ESX.ShowNotification('Coffre créé avec succès !')
                            CORE.trigger_server_callback("fafadev:to_server:get_chests", function(chests)
                                TBL_CHESTS = chests
                            end)
                        else
                            ESX.ShowNotification('Erreur lors de la création du coffre')
                        end
                    end, chestData)
                end
            end
        })
        RageUI.Line()
        for name, chest in pairs(TBL_CHESTS) do 
            RageUI.Button(chest.label or name, nil, {RightLabel = "~r~Supprimer~s~"}, true, {
                onSelected = function()
                    local confirm = lib.alertDialog({
                        header = 'Confirmation',
                        content = 'Êtes-vous sûr de vouloir supprimer le coffre "' .. (chest.label or name) .. '" ?',
                        centered = true,
                        cancel = true
                    })
                    if confirm == 'confirm' then
                        CORE.trigger_server_callback("fafadev:to_server:delete_chest", function(success)
                            if success then
                                ESX.ShowNotification('Coffre supprimé avec succès !')
                                CORE.trigger_server_callback("fafadev:to_server:get_chests", function(chests)
                                    TBL_CHESTS = chests
                                end)
                            else
                                ESX.ShowNotification('Erreur lors de la suppression du coffre')
                            end
                        end, name)
                    end
                end
            })
        end
    end)
end

return chests_builder
