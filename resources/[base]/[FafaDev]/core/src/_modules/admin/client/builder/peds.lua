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
            local description = string.format("Scénario: %s | Comportement: %s", ped.scenario or "Aléatoire", behaviorLabel)
            RageUI.Button(label, description, {RightLabel = "~r~Supprimer~s~"}, true, {
                onSelected = function()
                    local confirm = lib.alertDialog({
                        header = 'Confirmation',
                        content = string.format('Êtes-vous sûr de vouloir supprimer le ped "%s" ?', ped.ped_model),
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
                        end, index)
                    end
                end
            })
        end
    end)
end

return peds_builder
