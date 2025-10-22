-- Variables pour les sous-menus des cloakrooms
local cloakroom_submenus = {}

-- Fonction pour nettoyer les sous-menus obsolètes
local function CleanupObsoleteCloakroomSubmenus(current_cloakrooms)
    local current_keys = {}
    
    -- Collecter les clés actuelles
    if current_cloakrooms then
        for name, _ in pairs(current_cloakrooms) do
            table.insert(current_keys, "cloakroom_" .. name)
        end
    end
    
    -- Supprimer les sous-menus qui n'existent plus
    for key, submenu in pairs(cloakroom_submenus) do
        local exists = false
        for _, current_key in pairs(current_keys) do
            if key == current_key then
                exists = true
                break
            end
        end
        if not exists then
            cloakroom_submenus[key] = nil
        end
    end
end

function cloakrooms_builder(cloakroomsData)
    local TBL_CLOAKROOMS = cloakroomsData or {}
    
    -- Nettoyer les sous-menus obsolètes
    CleanupObsoleteCloakroomSubmenus(TBL_CLOAKROOMS)
    
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
        
        -- Affichage des cloakrooms avec sous-menus
        for name, cloakroom in pairs(TBL_CLOAKROOMS) do 
            local label = cloakroom.label or name
            local info = string.format("Job: %s", cloakroom.job or "N/A")
            local submenu_key = "cloakroom_" .. name
            
            -- Créer le sous-menu s'il n'existe pas
            if not cloakroom_submenus[submenu_key] then
                cloakroom_submenus[submenu_key] = RageUI.CreateSubMenu(sub_menus_admin["cloakrooms"], label, "Gestion du vestiaire")
            else
                -- Mettre à jour le titre du sous-menu si le label a changé
                cloakroom_submenus[submenu_key].Title = label
            end
            
            RageUI.Button(label, info, {RightLabel = "→→→"}, true, {
                onSelected = function()
                    -- Pas besoin d'action, le sous-menu s'ouvre automatiquement
                end
            }, cloakroom_submenus[submenu_key])
        end
    end)
    
    -- Gestion des sous-menus individuels des cloakrooms
    for submenu_key, submenu in pairs(cloakroom_submenus) do
        RageUI.IsVisible(submenu, function()
            local cloakroom_name = string.gsub(submenu_key, "cloakroom_", "")
            local cloakroom_data = TBL_CLOAKROOMS[cloakroom_name]
            
            if cloakroom_data then
                local cloakroom_label = cloakroom_data.label or cloakroom_name
                
                RageUI.Separator("~b~" .. cloakroom_label .. "~s~")
                
                -- Téléportation
                RageUI.Button("Se téléporter au vestiaire", "Se téléporter aux coordonnées du vestiaire", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        if cloakroom_data.coords and #cloakroom_data.coords > 0 then
                            local coords = cloakroom_data.coords[1] -- Prendre la première coordonnée
                            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
                            ESX.ShowNotification('Téléportation effectuée !')
                        else
                            ESX.ShowNotification('Aucune coordonnée trouvée pour ce vestiaire')
                        end
                    end
                })
                
                -- Modification
                RageUI.Button("Modifier les informations", "Modifier les paramètres du vestiaire", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        local coordsString = ""
                        if cloakroom_data.coords then
                            local coordsList = {}
                            for _, coord in pairs(cloakroom_data.coords) do
                                table.insert(coordsList, string.format("%.2f,%.2f,%.2f", coord.x, coord.y, coord.z))
                            end
                            coordsString = table.concat(coordsList, "|")
                        end
                        
                        local input = lib.inputDialog("Modifier le vestiaire", {
                            {type = 'input', label = 'Nom du vestiaire', description = 'Entrez le nom du vestiaire (unique)', required = true, min = 2, max = 50, default = cloakroom_name},
                            {type = 'input', label = 'Label du vestiaire', description = 'Nom affiché du vestiaire', required = true, min = 2, max = 50, default = cloakroom_data.label or ""},
                            {type = 'input', label = 'Job requis', description = 'Job nécessaire pour accéder au vestiaire', required = true, icon = 'briefcase', default = cloakroom_data.job or ""},
                            {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir le vestiaire', required = true, default = cloakroom_data.message or 'Appuyer sur ~INPUT_CONTEXT~ pour accéder au vestiaire'},
                            {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: 32.586411,-743.623474,44.238464|100.0,200.0,30.0)', required = true, icon = 'map-marker-alt', default = coordsString}
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
                                old_name = cloakroom_name,
                                name = input[1],
                                label = input[2],
                                job = input[3],
                                message = input[4],
                                coords = coordsArray
                            }
                            
                            CORE.trigger_server_callback("fafadev:to_server:update_cloakroom", function(success)
                                if success then
                                    ESX.ShowNotification('Vestiaire modifié avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_cloakrooms", function(cloakrooms)
                                        TBL_CLOAKROOMS = cloakrooms
                                        -- Mettre à jour le titre du sous-menu
                                        if cloakroom_submenus[submenu_key] then
                                            cloakroom_submenus[submenu_key].Title = input[2]
                                        end
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la modification du vestiaire')
                                end
                            end, cloakroomData)
                        end
                    end
                })
                
                -- Suppression
                RageUI.Button("Supprimer le vestiaire", "Supprimer définitivement ce vestiaire", {RightLabel = "~r~Supprimer~s~"}, true, {
                    onSelected = function()
                        local confirm = lib.alertDialog({
                            header = 'Confirmation',
                            content = 'Êtes-vous sûr de vouloir supprimer le vestiaire "' .. cloakroom_label .. '" ?',
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
                            end, cloakroom_name)
                        end
                    end
                })
            end
        end)
    end
end

return cloakrooms_builder
