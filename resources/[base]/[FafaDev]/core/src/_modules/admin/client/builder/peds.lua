-- Variables pour les sous-menus des peds
local ped_submenus = {}

-- Fonction pour nettoyer les sous-menus obsolètes
local function CleanupObsoletePedSubmenus(current_peds)
    local current_keys = {}
    
    -- Collecter les clés actuelles
    if current_peds then
        for index, _ in pairs(current_peds) do
            table.insert(current_keys, "ped_" .. index)
        end
    end
    
    -- Supprimer les sous-menus qui n'existent plus
    for key, submenu in pairs(ped_submenus) do
        local exists = false
        for _, current_key in pairs(current_keys) do
            if key == current_key then
                exists = true
                break
            end
        end
        if not exists then
            ped_submenus[key] = nil
        end
    end
end

function peds_builder(pedsData)
    local TBL_PEDS = pedsData or {}
    local CONFIG_PEDS = {
        scenario_list = {"WORLD_HUMAN_SMOKING", "WORLD_HUMAN_STAND_MOBILE", "WORLD_HUMAN_GUARD_STAND"},
        anim_list = {
            idle = "idle",
            smoking = "WORLD_HUMAN_SMOKING",
            mobile = "WORLD_HUMAN_STAND_MOBILE"
        },
        behavior_list = {
            {id = "guard", label = "Garde", description = "Comportement de garde"},
            {id = "civilian", label = "Civil", description = "Comportement civil"},
            {id = "worker", label = "Travailleur", description = "Comportement de travailleur"}
        }
    }
    
    -- Nettoyer les sous-menus obsolètes
    CleanupObsoletePedSubmenus(TBL_PEDS)
    
    RageUI.IsVisible(sub_menus_admin["peds"], function()
        RageUI.Button("Créer un ped", nil, {}, true, {
            onSelected = function()
                local playerPed = PlayerPedId()
                local coords = GetEntityCoords(playerPed)
                local heading = GetEntityHeading(playerPed)
                
                local scenarioOptions = {{value = 'none', label = 'Aucun (aléatoire)'}}
                if CONFIG_PEDS.scenario_list then
                    for _, scenario in ipairs(CONFIG_PEDS.scenario_list) do
                        table.insert(scenarioOptions, {value = scenario, label = scenario})
                    end
                end
                
                local animOptions = {{value = 'none', label = 'Aucune'}}
                if CONFIG_PEDS.anim_list then
                    for key, anim in pairs(CONFIG_PEDS.anim_list) do
                        table.insert(animOptions, {value = key, label = key:gsub("_", " "):gsub("^%l", string.upper)})
                    end
                end
                
                local behaviorOptions = {{value = 'default', label = 'Par défaut'}}
                if CONFIG_PEDS.behavior_list then
                    for _, behavior in ipairs(CONFIG_PEDS.behavior_list) do
                        table.insert(behaviorOptions, {value = behavior.id, label = behavior.label, description = behavior.description})
                    end
                end
                
                local input = lib.inputDialog("Créer un ped", {
                    {type = 'input', label = 'Modèle du ped', description = 'Nom du modèle (ex: s_m_m_doctor_01, a_m_m_business_01)', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z,w|x2,y2,z2,w2 (laisser vide pour pos actuelle)', icon = 'map-marker-alt', default = string.format("%.2f,%.2f,%.2f,%.2f", coords.x, coords.y, coords.z, heading)},
                    {type = 'select', label = 'Scénario', description = 'Scénario à appliquer au ped', options = scenarioOptions, default = 'none'},
                    {type = 'select', label = 'Animation prédefinie', description = 'Animation de la config (optionnel)', options = animOptions, default = 'none'},
                    {type = 'select', label = 'Comportement', description = 'Comportement du ped', options = behaviorOptions, default = 'default'}
                })
                
                if input then
                    local coordsList = string.split(input[2], "|")
                    local coordsArray = {}
                    for i, coordString in pairs(coordsList) do
                        local coordsData = string.split(coordString, ",")
                        if #coordsData ~= 4 then
                            ESX.ShowNotification(string.format('Format de coordonnées invalide à la position %s. Utilisez: x,y,z,w', i))
                            return
                        end
                        local x, y, z, w = tonumber(coordsData[1]), tonumber(coordsData[2]), tonumber(coordsData[3]), tonumber(coordsData[4])
                        if not x or not y or not z or not w then
                            ESX.ShowNotification(string.format('Coordonnées invalides à la position %s. Les valeurs doivent être des nombres', i))
                            return
                        end
                        table.insert(coordsArray, {x = x, y = y, z = z, w = w})
                    end
                    
                    local pedData = {
                        ped_model = input[1],
                        ped_coords = coordsArray
                    }
                    
                    if input[3] and input[3] ~= 'none' then
                        pedData.scenario = input[3]
                    end
                    
                    if input[4] and input[4] ~= 'none' then
                        pedData.animation = input[4]
                    end
                    
                    if input[5] and input[5] ~= 'default' then
                        pedData.behavior = input[5]
                    end
                    
                    CORE.trigger_server_callback("fafadev:to_server:create_ped", function(success)
                        if success then
                            ESX.ShowNotification('Ped créé avec succès !')
                            CORE.trigger_server_callback("fafadev:to_server:get_peds", function(peds)
                                TBL_PEDS = peds
                                FUN_HANDLE_PEDS(peds)
                            end)
                        else
                            ESX.ShowNotification('Erreur lors de la création du ped')
                        end
                    end, pedData)
                end
            end
        })
        RageUI.Line()
        
        -- Affichage des peds avec sous-menus
        for index, ped in pairs(TBL_PEDS) do 
            local label = string.format("%s (%d positions)", ped.ped_model, #ped.ped_coords)
            local behaviorLabel = ped.behavior or "Défaut"
            if ped.behavior and CONFIG_PEDS.behavior_list then
                for _, behavior in ipairs(CONFIG_PEDS.behavior_list) do
                    if behavior.id == ped.behavior then
                        behaviorLabel = behavior.label
                        break
                    end
                end
            end
            local info = string.format("Scénario: %s | Comportement: %s", ped.scenario or "Aléatoire", behaviorLabel)
            local submenu_key = "ped_" .. index
            
            -- Créer le sous-menu s'il n'existe pas
            if not ped_submenus[submenu_key] then
                ped_submenus[submenu_key] = RageUI.CreateSubMenu(sub_menus_admin["peds"], label, "Gestion du ped")
            else
                -- Mettre à jour le titre du sous-menu si le label a changé
                ped_submenus[submenu_key].Title = label
            end
            
            RageUI.Button(label, info, {RightLabel = "→→→"}, true, {
                onSelected = function()
                    -- Pas besoin d'action, le sous-menu s'ouvre automatiquement
                end
            }, ped_submenus[submenu_key])
        end
    end)
    
    -- Gestion des sous-menus individuels des peds
    for submenu_key, submenu in pairs(ped_submenus) do
        RageUI.IsVisible(submenu, function()
            local ped_index_str = string.gsub(submenu_key, "ped_", "")
            local ped_index = tonumber(ped_index_str)
            if not ped_index then
                return -- Ignorer si l'index n'est pas valide
            end
            local ped_data = TBL_PEDS[ped_index]
            
            if ped_data then
                local ped_label = string.format("%s (%d positions)", ped_data.ped_model, #ped_data.ped_coords)
                
                RageUI.Separator("~b~" .. ped_label .. "~s~")
                
                -- Téléportation
                RageUI.Button("Se téléporter au ped", "Se téléporter aux coordonnées du ped", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        if ped_data.ped_coords and #ped_data.ped_coords > 0 then
                            local coords = ped_data.ped_coords[1] -- Prendre la première coordonnée
                            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
                            ESX.ShowNotification('Téléportation effectuée !')
                        else
                            ESX.ShowNotification('Aucune coordonnée trouvée pour ce ped')
                        end
                    end
                })
                
                -- Modification
                RageUI.Button("Modifier les informations", "Modifier les paramètres du ped", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        local coordsString = ""
                        if ped_data.ped_coords then
                            local coordsList = {}
                            for _, coord in pairs(ped_data.ped_coords) do
                                table.insert(coordsList, string.format("%.2f,%.2f,%.2f,%.2f", coord.x, coord.y, coord.z, coord.w))
                            end
                            coordsString = table.concat(coordsList, "|")
                        end
                        
                        local scenarioOptions = {{value = 'none', label = 'Aucun (aléatoire)'}}
                        if CONFIG_PEDS.scenario_list then
                            for _, scenario in ipairs(CONFIG_PEDS.scenario_list) do
                                table.insert(scenarioOptions, {value = scenario, label = scenario})
                            end
                        end
                        
                        local animOptions = {{value = 'none', label = 'Aucune'}}
                        if CONFIG_PEDS.anim_list then
                            for key, anim in pairs(CONFIG_PEDS.anim_list) do
                                table.insert(animOptions, {value = key, label = key:gsub("_", " "):gsub("^%l", string.upper)})
                            end
                        end
                        
                        local behaviorOptions = {{value = 'default', label = 'Par défaut'}}
                        if CONFIG_PEDS.behavior_list then
                            for _, behavior in ipairs(CONFIG_PEDS.behavior_list) do
                                table.insert(behaviorOptions, {value = behavior.id, label = behavior.label, description = behavior.description})
                            end
                        end
                        
                        local input = lib.inputDialog("Modifier le ped", {
                            {type = 'input', label = 'Modèle du ped', description = 'Nom du modèle (ex: s_m_m_doctor_01, a_m_m_business_01)', required = true, min = 2, max = 50, default = ped_data.ped_model or ""},
                            {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z,w|x2,y2,z2,w2', icon = 'map-marker-alt', default = coordsString},
                            {type = 'select', label = 'Scénario', description = 'Scénario à appliquer au ped', options = scenarioOptions, default = ped_data.scenario or 'none'},
                            {type = 'select', label = 'Animation prédefinie', description = 'Animation de la config (optionnel)', options = animOptions, default = ped_data.animation or 'none'},
                            {type = 'select', label = 'Comportement', description = 'Comportement du ped', options = behaviorOptions, default = ped_data.behavior or 'default'}
                        })
                        if input then
                            local coordsList = string.split(input[2], "|")
                            local coordsArray = {}
                            for i, coordString in pairs(coordsList) do
                                local coordsData = string.split(coordString, ",")
                                if #coordsData ~= 4 then
                                    ESX.ShowNotification(string.format('Format de coordonnées invalide à la position %s. Utilisez: x,y,z,w', i))
                                    return
                                end
                                local x, y, z, w = tonumber(coordsData[1]), tonumber(coordsData[2]), tonumber(coordsData[3]), tonumber(coordsData[4])
                                if not x or not y or not z or not w then
                                    ESX.ShowNotification(string.format('Coordonnées invalides à la position %s. Les valeurs doivent être des nombres', i))
                                    return
                                end
                                table.insert(coordsArray, {x = x, y = y, z = z, w = w})
                            end
                            
                            local pedData = {
                                ped_model = input[1],
                                ped_coords = coordsArray
                            }
                            
                            if input[3] and input[3] ~= 'none' then
                                pedData.scenario = input[3]
                            end
                            
                            if input[4] and input[4] ~= 'none' then
                                pedData.animation = input[4]
                            end
                            
                            if input[5] and input[5] ~= 'default' then
                                pedData.behavior = input[5]
                            end
                            
                            CORE.trigger_server_callback("fafadev:to_server:update_ped", function(success)
                                if success then
                                    ESX.ShowNotification('Ped modifié avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_peds", function(peds)
                                        TBL_PEDS = peds
                                        FUN_HANDLE_PEDS(peds)
                                        -- Mettre à jour le titre du sous-menu
                                        if ped_submenus[submenu_key] then
                                            ped_submenus[submenu_key].Title = string.format("%s (%d positions)", pedData.ped_model, #pedData.ped_coords)
                                        end
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la modification du ped')
                                end
                            end, ped_index, pedData)
                        end
                    end
                })
                
                -- Suppression
                RageUI.Button("Supprimer le ped", "Supprimer définitivement ce ped", {RightLabel = "~r~Supprimer~s~"}, true, {
                    onSelected = function()
                        local confirm = lib.alertDialog({
                            header = 'Confirmation',
                            content = string.format('Êtes-vous sûr de vouloir supprimer le ped "%s" ?', ped_data.ped_model),
                            centered = true,
                            cancel = true
                        })
                        if confirm == 'confirm' then
                            CORE.trigger_server_callback("fafadev:to_server:delete_ped", function(success)
                                if success then
                                    ESX.ShowNotification('Ped supprimé avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_peds", function(peds)
                                        TBL_PEDS = peds
                                        FUN_HANDLE_PEDS(peds)
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la suppression du ped')
                                end
                            end, ped_index)
                        end
                    end
                })
            end
        end)
    end
end

return peds_builder
