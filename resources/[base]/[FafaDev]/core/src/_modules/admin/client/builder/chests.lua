-- Variables pour les sous-menus des coffres
local chest_submenus = {}

-- Fonction pour nettoyer les sous-menus obsolètes
local function CleanupObsoleteChestSubmenus(current_chests)
    local current_keys = {}
    
    -- Collecter les clés actuelles
    if current_chests then
        for name, _ in pairs(current_chests) do
            table.insert(current_keys, "chest_" .. name)
        end
    end
    
    -- Supprimer les sous-menus qui n'existent plus
    for key, submenu in pairs(chest_submenus) do
        local exists = false
        for _, current_key in pairs(current_keys) do
            if key == current_key then
                exists = true
                break
            end
        end
        if not exists then
            chest_submenus[key] = nil
        end
    end
end

function chests_builder(chestsData)
    local TBL_CHESTS = chestsData or {}
    
    -- Nettoyer les sous-menus obsolètes
    CleanupObsoleteChestSubmenus(TBL_CHESTS)
    
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
        
        -- Affichage des coffres avec sous-menus
        for name, chest in pairs(TBL_CHESTS) do 
            local label = chest.label or name
            local info = string.format("Job: %s | Poids: %dkg", chest.job or "Tous", chest.options and chest.options.max_weight or 2000)
            local submenu_key = "chest_" .. name
            
            -- Créer le sous-menu s'il n'existe pas
            if not chest_submenus[submenu_key] then
                chest_submenus[submenu_key] = RageUI.CreateSubMenu(sub_menus_admin["chests"], label, "Gestion du coffre")
            else
                -- Mettre à jour le titre du sous-menu si le label a changé
                chest_submenus[submenu_key].Title = label
            end
            
            RageUI.Button(label, info, {RightLabel = "→→→"}, true, {
                onSelected = function()
                    -- Pas besoin d'action, le sous-menu s'ouvre automatiquement
                end
            }, chest_submenus[submenu_key])
        end
    end)
    
    -- Gestion des sous-menus individuels des coffres
    for submenu_key, submenu in pairs(chest_submenus) do
        RageUI.IsVisible(submenu, function()
            local chest_name = string.gsub(submenu_key, "chest_", "")
            local chest_data = TBL_CHESTS[chest_name]
            
            if chest_data then
                local chest_label = chest_data.label or chest_name
                
                RageUI.Separator("~b~" .. chest_label .. "~s~")
                
                -- Téléportation
                RageUI.Button("Se téléporter au coffre", "Se téléporter aux coordonnées du coffre", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        if chest_data.coords and #chest_data.coords > 0 then
                            local coords = chest_data.coords[1] -- Prendre la première coordonnée
                            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
                            ESX.ShowNotification('Téléportation effectuée !')
                        else
                            ESX.ShowNotification('Aucune coordonnée trouvée pour ce coffre')
                        end
                    end
                })
                
                -- Modification
                RageUI.Button("Modifier les informations", "Modifier les paramètres du coffre", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        local coordsString = ""
                        if chest_data.coords then
                            local coordsList = {}
                            for _, coord in pairs(chest_data.coords) do
                                table.insert(coordsList, string.format("%.2f,%.2f,%.2f", coord.x, coord.y, coord.z))
                            end
                            coordsString = table.concat(coordsList, "|")
                        end
                        
                        local input = lib.inputDialog("Modifier le coffre", {
                            {type = 'input', label = 'Nom du coffre', description = 'Entrez le nom du coffre (unique)', required = true, min = 2, max = 50, default = chest_name},
                            {type = 'input', label = 'Label du coffre', description = 'Nom affiché du coffre', required = true, min = 2, max = 50, default = chest_data.label or ""},
                            {type = 'input', label = 'Job requis', description = 'Job nécessaire pour accéder au coffre (optionnel)', icon = 'briefcase', default = chest_data.job or ""},
                            {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir le coffre', required = true, default = chest_data.message or 'Appuyer sur ~INPUT_CONTEXT~ pour accéder au coffre'},
                            {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: 32.586411,-743.623474,44.238464|100.0,200.0,30.0)', required = true, icon = 'map-marker-alt', default = coordsString},
                            {type = 'number', label = 'Poids maximum', description = 'Poids maximum du coffre (défaut: 2000)', default = chest_data.options and chest_data.options.max_weight or 2000, min = 100, max = 10000},
                            {type = 'checkbox', label = 'Afficher le marqueur', description = 'Afficher le marqueur sur la carte', default = chest_data.drawmarker or false}
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
                                old_name = chest_name,
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
                            
                            CORE.trigger_server_callback("fafadev:to_server:update_chest", function(success)
                                if success then
                                    ESX.ShowNotification('Coffre modifié avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_chests", function(chests)
                                        TBL_CHESTS = chests
                                        -- Mettre à jour le titre du sous-menu
                                        if chest_submenus[submenu_key] then
                                            chest_submenus[submenu_key].Title = input[2]
                                        end
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la modification du coffre')
                                end
                            end, chestData)
                        end
                    end
                })
                
                -- Suppression
                RageUI.Button("Supprimer le coffre", "Supprimer définitivement ce coffre", {RightLabel = "~r~Supprimer~s~"}, true, {
                    onSelected = function()
                        local confirm = lib.alertDialog({
                            header = 'Confirmation',
                            content = 'Êtes-vous sûr de vouloir supprimer le coffre "' .. chest_label .. '" ?',
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
                            end, chest_name)
                        end
                    end
                })
            end
        end)
    end
end

return chests_builder
