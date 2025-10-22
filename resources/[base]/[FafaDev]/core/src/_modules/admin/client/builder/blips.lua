function blips_builder(blipsData)
    local TBL_BLIPS = blipsData or {}
    RageUI.IsVisible(sub_menus_admin["blips"], function()
        RageUI.Button("Créer un blip classique", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un blip classique", {
                    {type = 'input', label = 'Label du blip', description = 'Nom affiché sur le blip', required = true, min = 2, max = 50},
                    {type = 'number', label = 'Sprite', description = 'Icône du blip (60=Police, 61=Hôpital, 108=Banque)', required = true, default = 1, min = 0, max = 826},
                    {type = 'number', label = 'Couleur', description = 'Couleur du blip (0-85)', required = true, default = 1, min = 0, max = 85},
                    {type = 'input', label = 'Taille', description = 'Taille du blip (0.5 - 2.0)', required = true, default = '0.8'},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z (ex: 425.13,-979.55,30.71)', required = true, icon = 'map-marker-alt'},
                    {type = 'input', label = 'Job requis', description = 'Job requis (ALL pour tous)', required = true, default = 'ALL'},
                    {type = 'input', label = 'Job2 requis', description = 'Job2 requis (ALL pour tous)', required = true, default = 'ALL'},
                    {type = 'checkbox', label = 'Activer la zone', description = 'Afficher une zone autour du blip'},
                    {type = 'input', label = 'Rayon de la zone', description = 'Rayon en mètres (si zone activée)', default = '50.0'},
                    {type = 'number', label = 'Couleur zone', description = 'Couleur de la zone (0-85)', default = 0, min = 0, max = 85}
                })
                if input then
                    local coordsData = string.split(input[5], ",")
                    if #coordsData ~= 3 then
                        ESX.ShowNotification('Format de coordonnées invalide. Utilisez: x,y,z')
                        return
                    end
                    
                    local x, y, z = tonumber(coordsData[1]), tonumber(coordsData[2]), tonumber(coordsData[3])
                    if not x or not y or not z then
                        ESX.ShowNotification('Coordonnées invalides. Les valeurs doivent être des nombres')
                        return
                    end
                    
                    local blipData = {
                        type = "classic",
                        data = {
                            Label = input[1],
                            Id = tonumber(input[2]) or 1,
                            BColor = tonumber(input[3]) or 1,
                            BSize = tonumber(input[4]) or 0.8,
                            X = x,
                            Y = y,
                            Z = z,
                            Job = input[6],
                            Job2 = input[7],
                            Area = input[8],
                            ASize = input[8] and (tonumber(input[9]) or 50.0) or 0.0,
                            AColor = input[8] and (tonumber(input[10]) or 0) or 0
                        }
                    }
                    
                    CORE.trigger_server_callback("fafadev:to_server:create_blip", function(success)
                        if success then
                            ESX.ShowNotification('Blip créé avec succès !')
                            CORE.trigger_server_callback("fafadev:to_server:get_blips", function(blips)
                                TBL_BLIPS = blips
                            end)
                        else
                            ESX.ShowNotification('Erreur lors de la création du blip')
                        end
                    end, blipData)
                end
            end
        })
        
        RageUI.Button("Créer un blip d'entreprise", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un blip d'entreprise", {
                    {type = 'input', label = 'Nom du blip', description = 'Nom affiché sur le blip', required = true, min = 2, max = 50},
                    {type = 'number', label = 'Sprite', description = 'Icône du blip', required = true, default = 1, min = 0, max = 826},
                    {type = 'number', label = 'Couleur', description = 'Couleur du blip (0-85)', required = true, default = 1, min = 0, max = 85},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z (ex: 425.13,-979.55,30.71)', required = true, icon = 'map-marker-alt'},
                    {type = 'input', label = 'Job requis', description = 'Job requis pour voir le blip', required = true}
                })
                if input then
                    local coordsData = string.split(input[4], ",")
                    if #coordsData ~= 3 then
                        ESX.ShowNotification('Format de coordonnées invalide. Utilisez: x,y,z')
                        return
                    end
                    
                    local x, y, z = tonumber(coordsData[1]), tonumber(coordsData[2]), tonumber(coordsData[3])
                    if not x or not y or not z then
                        ESX.ShowNotification('Coordonnées invalides. Les valeurs doivent être des nombres')
                        return
                    end
                    
                    local blipData = {
                        type = "entreprise",
                        data = {
                            name = input[1],
                            id = tonumber(input[2]) or 1,
                            color = tonumber(input[3]) or 1,
                            pos = {x = x, y = y, z = z},
                            job = input[5]
                        }
                    }
                    
                    CORE.trigger_server_callback("fafadev:to_server:create_blip", function(success)
                        if success then
                            ESX.ShowNotification('Blip d\'entreprise créé avec succès !')
                            CORE.trigger_server_callback("fafadev:to_server:get_blips", function(blips)
                                TBL_BLIPS = blips
                            end)
                        else
                            ESX.ShowNotification('Erreur lors de la création du blip d\'entreprise')
                        end
                    end, blipData)
                end
            end
        })
        
        RageUI.Line()
        
        -- Affichage des blips classiques
        if TBL_BLIPS and TBL_BLIPS.ClassicBlips then
            for i, blip in pairs(TBL_BLIPS.ClassicBlips) do
                local label = blip.Label or ("Blip #" .. i)
                local info = string.format("Sprite: %d | Couleur: %d | Job: %s", blip.Id, blip.BColor, blip.Job)
                RageUI.Button(label, info, {RightLabel = "~r~Supprimer~s~"}, true, {
                    onSelected = function()
                        local confirm = lib.alertDialog({
                            header = 'Confirmation',
                            content = 'Êtes-vous sûr de vouloir supprimer le blip "' .. label .. '" ?',
                            centered = true,
                            cancel = true
                        })
                        if confirm == 'confirm' then
                            CORE.trigger_server_callback("fafadev:to_server:delete_blip", function(success)
                                if success then
                                    ESX.ShowNotification('Blip supprimé avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_blips", function(blips)
                                        TBL_BLIPS = blips
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la suppression du blip')
                                end
                            end, "classic", i)
                        end
                    end
                })
            end
        end
        
        -- Affichage des blips d'entreprise
        if TBL_BLIPS and TBL_BLIPS.Blips and TBL_BLIPS.Blips.Entreprise then
            for i, blip in pairs(TBL_BLIPS.Blips.Entreprise) do
                local label = blip.name or ("Blip Entreprise #" .. i)
                local info = string.format("Sprite: %d | Couleur: %d | Job: %s", blip.id, blip.color, blip.job)
                RageUI.Button(label, info, {RightLabel = "~r~Supprimer~s~"}, true, {
                    onSelected = function()
                        local confirm = lib.alertDialog({
                            header = 'Confirmation',
                            content = 'Êtes-vous sûr de vouloir supprimer le blip "' .. label .. '" ?',
                            centered = true,
                            cancel = true
                        })
                        if confirm == 'confirm' then
                            CORE.trigger_server_callback("fafadev:to_server:delete_blip", function(success)
                                if success then
                                    ESX.ShowNotification('Blip supprimé avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_blips", function(blips)
                                        TBL_BLIPS = blips
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la suppression du blip')
                                end
                            end, "entreprise", i)
                        end
                    end
                })
            end
        end
    end)
end

return blips_builder