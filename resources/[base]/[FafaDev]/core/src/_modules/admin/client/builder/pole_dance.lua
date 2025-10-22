function pole_dance_builder(poleDanceData)
    local TBL_POLE_DANCE = poleDanceData or {}
    local TBL_POLE_DANCE_ANIMATIONS = {
        {id = "dance1", label = "Danse 1", description = "Animation de danse basique"},
        {id = "dance2", label = "Danse 2", description = "Animation de danse avancée"},
        {id = "pole1", label = "Pole 1", description = "Animation de pole dance basique"},
        {id = "pole2", label = "Pole 2", description = "Animation de pole dance avancée"}
    }
    
    RageUI.IsVisible(sub_menus_admin["pole_dance"], function()
        RageUI.Button("Créer un pole dance", nil, {}, true, {
            onSelected = function()
                -- Créer les options d'animations depuis la config
                local animationOptions = {}
                if TBL_POLE_DANCE_ANIMATIONS then
                    for _, anim in ipairs(TBL_POLE_DANCE_ANIMATIONS) do
                        table.insert(animationOptions, {
                            value = anim.id,
                            label = anim.label,
                            description = anim.description
                        })
                    end
                end
                
                local input = lib.inputDialog("Créer un pole dance", {
                    {type = 'input', label = 'Label du pole dance', description = 'Nom affiché du pole dance', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour accéder au pole dance', required = true, default = 'Appuyez sur ~INPUT_CONTEXT~ pour accéder au pole dance'},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: 127.830,-1284.796,29.280|100.0,200.0,30.0)', required = true, icon = 'map-marker-alt'},
                    {type = 'multi-select', label = 'Animations disponibles', description = 'Sélectionnez les animations disponibles', options = animationOptions, required = true},
                    {type = 'input', label = 'Jobs autorisés', description = 'Liste des jobs séparés par des virgules (vide=tous)', icon = 'briefcase'},
                    {type = 'input', label = 'Grades autorisés', description = 'Liste des grades séparés par des virgules (vide=tous)', icon = 'star'},
                    {type = 'checkbox', label = 'Afficher le marqueur', description = 'Afficher le marqueur sur la carte', checked = true}
                })
                if input then
                    local coordsList = string.split(input[3], "|")
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
                    
                    -- Récupération des animations sélectionnées (multi-select retourne directement un tableau)
                    local animations = input[4] or {}
                    
                    -- Parsing des jobs
                    local jobAccess = {}
                    if input[5] and input[5] ~= "" then
                        jobAccess = string.split(input[5], ",")
                        for i, job in ipairs(jobAccess) do
                            jobAccess[i] = job:match("^%s*(.-)%s*$")
                        end
                    end
                    
                    -- Parsing des grades
                    local gradeAccess = {}
                    if input[6] and input[6] ~= "" then
                        local gradesList = string.split(input[6], ",")
                        for _, gradeStr in pairs(gradesList) do
                            local grade = tonumber(gradeStr:match("^%s*(.-)%s*$"))
                            if grade then
                                table.insert(gradeAccess, grade)
                            end
                        end
                    end
                    
                    local poleDanceData = {
                        label = input[1],
                        message = input[2],
                        coords = coordsArray,
                        animations = animations,
                        jobAccess = jobAccess,
                        gradeAccess = gradeAccess,
                        drawmarker = input[7]
                    }
                    
                    CORE.trigger_server_callback("fafadev:to_server:create_pole_dance", function(success)
                        if success then
                            ESX.ShowNotification('Pole dance créé avec succès !')
                            CORE.trigger_server_callback("fafadev:to_server:get_pole_dance", function(pole_dance)
                                TBL_POLE_DANCE = pole_dance
                            end)
                        else
                            ESX.ShowNotification('Erreur lors de la création du pole dance')
                        end
                    end, poleDanceData)
                end
            end
        })
        RageUI.Line()
        for name, poleDance in pairs(TBL_POLE_DANCE) do 
            local animationsText = ""
            if poleDance.animations and #poleDance.animations > 0 then
                local animationNames = {}
                for _, animId in ipairs(poleDance.animations) do
                    if TBL_POLE_DANCE_ANIMATIONS then
                        for _, anim in ipairs(TBL_POLE_DANCE_ANIMATIONS) do
                            if anim.id == animId then
                                table.insert(animationNames, anim.label)
                                break
                            end
                        end
                    end
                end
                if #animationNames > 0 then
                    animationsText = "Animations: " .. table.concat(animationNames, ", ")
                else
                    animationsText = "Animations: " .. table.concat(poleDance.animations, ",")
                end
            else
                animationsText = "Aucune animation"
            end
            RageUI.Button(poleDance.label or name, animationsText, {RightLabel = "~r~Supprimer~s~"}, true, {
                onSelected = function()
                    local confirm = lib.alertDialog({
                        header = 'Confirmation',
                        content = 'Êtes-vous sûr de vouloir supprimer le pole dance "' .. (poleDance.label or name) .. '" ?',
                        centered = true,
                        cancel = true
                    })
                    if confirm == 'confirm' then
                        CORE.trigger_server_callback("fafadev:to_server:delete_pole_dance", function(success)
                            if success then
                                ESX.ShowNotification('Pole dance supprimé avec succès !')
                                CORE.trigger_server_callback("fafadev:to_server:get_pole_dance", function(pole_dance)
                                    TBL_POLE_DANCE = pole_dance
                                end)
                            else
                                ESX.ShowNotification('Erreur lors de la suppression du pole dance')
                            end
                        end, name)
                    end
                end
            })
        end
    end)
end

return pole_dance_builder
