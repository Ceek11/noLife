function cloakrooms_builder(cloakroomsData)
    local TBL_CLOAKROOMS = cloakroomsData or {}
    RageUI.IsVisible(sub_menus_admin["cloakrooms"], function()
        RageUI.Button("Créer un vestiaire", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un vestiaire", {
                    {type = 'input', label = 'Nom du vestiaire', description = 'Entrez le nom du vestiaire (unique)', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Label du vestiaire', description = 'Nom affiché du vestiaire', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Job requis', description = 'Job nécessaire pour accéder au vestiaire', required = true, icon = 'briefcase'},
                    {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir le vestiaire', required = true, default = 'Appuyer sur ~INPUT_CONTEXT~ pour accéder au vestiaire'},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: 32.586411,-743.623474,44.238464|100.0,200.0,30.0)', required = true, icon = 'map-marker-alt'}
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
                    
                    local cloakroomData = {
                        name = input[1],
                        label = input[2],
                        job = input[3],
                        message = input[4],
                        coords = coordsArray
                    }
                    
                    CORE.trigger_server_callback("fafadev:to_server:create_cloakroom", function(success)
                        if success then
                            ESX.ShowNotification('Vestiaire créé avec succès !')
                            CORE.trigger_server_callback("fafadev:to_server:get_cloakrooms", function(cloakrooms)
                                TBL_CLOAKROOMS = cloakrooms
                            end)
                        else
                            ESX.ShowNotification('Erreur lors de la création du vestiaire')
                        end
                    end, cloakroomData)
                end
            end
        })
        RageUI.Line()
        for name, cloakroom in pairs(TBL_CLOAKROOMS) do 
            RageUI.Button(cloakroom.label or name, nil, {RightLabel = "~r~Supprimer~s~"}, true, {
                onSelected = function()
                    local confirm = lib.alertDialog({
                        header = 'Confirmation',
                        content = 'Êtes-vous sûr de vouloir supprimer le vestiaire "' .. (cloakroom.label or name) .. '" ?',
                        centered = true,
                        cancel = true
                    })
                    if confirm == 'confirm' then
                        CORE.trigger_server_callback("fafadev:to_server:delete_cloakroom", function(success)
                            if success then
                                ESX.ShowNotification('Vestiaire supprimé avec succès !')
                                CORE.trigger_server_callback("fafadev:to_server:get_cloakrooms", function(cloakrooms)
                                    TBL_CLOAKROOMS = cloakrooms
                                end)
                            else
                                ESX.ShowNotification('Erreur lors de la suppression du vestiaire')
                            end
                        end, name)
                    end
                end
            })
        end
    end)
end

return cloakrooms_builder
