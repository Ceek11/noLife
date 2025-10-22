local pole_dance_submenus = {}

local function CleanupObsoletePoleDanceSubmenus(current_pole_dance)
    local current_keys = {}
    
    if current_pole_dance then
        for name, _ in pairs(current_pole_dance) do
            table.insert(current_keys, name)
        end
    end
    
    for key, submenu in pairs(pole_dance_submenus) do
        local exists = false
        for _, current_key in pairs(current_keys) do
            if key == current_key then
                exists = true
                break
            end
        end
        if not exists then
            pole_dance_submenus[key] = nil
        end
    end
end

local function CreatePoleDanceSubmenus(poleDanceData)
    if not poleDanceData then return end
    
    for name, poleDance in pairs(poleDanceData) do
        if not pole_dance_submenus[name] then
            local label = poleDance.label or name
            pole_dance_submenus[name] = RageUI.CreateSubMenu(sub_menus_admin["pole_dance"], label, "Gestion du pole dance")
        end
    end
end

function pole_dance_builder(poleDanceData)
    if poleDanceData then
        TBL_POLE_DANCE = poleDanceData
        CreatePoleDanceSubmenus(poleDanceData)
    end
    
    if not TBL_POLE_DANCE or next(TBL_POLE_DANCE) == nil then
        return
    end
    
    CleanupObsoletePoleDanceSubmenus(TBL_POLE_DANCE)
    
    RageUI.IsVisible(sub_menus_admin["pole_dance"], function()
        RageUI.Button("Créer un pole dance", nil, {}, true, {
            onSelected = function()
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
                    
                    local animations = input[4] or {}
                    
                    local jobAccess = {}
                    if input[5] and input[5] ~= "" then
                        jobAccess = string.split(input[5], ",")
                        for i, job in ipairs(jobAccess) do
                            jobAccess[i] = job:match("^%s*(.-)%s*$")
                        end
                    end
                    
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
                                CreatePoleDanceSubmenus(pole_dance)
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
            local label = poleDance.label or name
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
            
            RageUI.Button(label, animationsText, {RightLabel = "→→→"}, true, {
                onSelected = function()
                end
            }, pole_dance_submenus[name])
        end
    end)
    
    for submenu_key, submenu in pairs(pole_dance_submenus) do
        RageUI.IsVisible(submenu, function()
            local pole_dance_data = TBL_POLE_DANCE[submenu_key]
            
            if not pole_dance_data then
                return
            end
            
            local pole_dance_label = pole_dance_data.label or submenu_key
            
            RageUI.Separator("~b~" .. pole_dance_label .. "~s~")
            
            RageUI.Button("Se téléporter au pole dance", "Se téléporter aux coordonnées du pole dance", {RightLabel = "→→→"}, true, {
                onSelected = function()
                    if pole_dance_data.coords and #pole_dance_data.coords > 0 then
                        local coords = pole_dance_data.coords[1]
                        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
                        ESX.ShowNotification('Téléportation effectuée !')
                    else
                        ESX.ShowNotification('Aucune coordonnée trouvée pour ce pole dance')
                    end
                end
            })
            
            RageUI.Button("Modifier les informations", "Modifier les paramètres du pole dance", {RightLabel = "→→→"}, true, {
                onSelected = function()
                    local coordsString = ""
                    if pole_dance_data.coords then
                        local coordsList = {}
                        for _, coord in pairs(pole_dance_data.coords) do
                            table.insert(coordsList, string.format("%.2f,%.2f,%.2f", coord.x, coord.y, coord.z))
                        end
                        coordsString = table.concat(coordsList, "|")
                    end
                    
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
                    
                    local input = lib.inputDialog("Modifier le pole dance", {
                        {type = 'input', label = 'Label du pole dance', description = 'Nom affiché du pole dance', required = true, min = 2, max = 50, default = pole_dance_data.label or ""},
                        {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour accéder au pole dance', required = true, default = pole_dance_data.message or 'Appuyez sur ~INPUT_CONTEXT~ pour accéder au pole dance'},
                        {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: 127.830,-1284.796,29.280|100.0,200.0,30.0)', required = true, icon = 'map-marker-alt', default = coordsString},
                        {type = 'multi-select', label = 'Animations disponibles', description = 'Sélectionnez les animations disponibles', options = animationOptions, required = true, default = pole_dance_data.animations or {}},
                        {type = 'input', label = 'Jobs autorisés', description = 'Liste des jobs séparés par des virgules (vide=tous)', icon = 'briefcase', default = table.concat(pole_dance_data.jobAccess or {}, ",")},
                        {type = 'input', label = 'Grades autorisés', description = 'Liste des grades séparés par des virgules (vide=tous)', icon = 'star', default = table.concat(pole_dance_data.gradeAccess or {}, ",")},
                        {type = 'checkbox', label = 'Afficher le marqueur', description = 'Afficher le marqueur sur la carte', checked = pole_dance_data.drawmarker or false}
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
                        
                        local animations = input[4] or {}
                        
                        local jobAccess = {}
                        if input[5] and input[5] ~= "" then
                            jobAccess = string.split(input[5], ",")
                            for i, job in ipairs(jobAccess) do
                                jobAccess[i] = job:match("^%s*(.-)%s*$")
                            end
                        end
                        
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
                        
                        CORE.trigger_server_callback("fafadev:to_server:update_pole_dance", function(success)
                            if success then
                                ESX.ShowNotification('Pole dance modifié avec succès !')
                                CORE.trigger_server_callback("fafadev:to_server:get_pole_dance", function(pole_dance)
                                    TBL_POLE_DANCE = pole_dance
                                    if pole_dance_submenus[submenu_key] then
                                        pole_dance_submenus[submenu_key].Title = input[1]
                                    end
                                end)
                            else
                                ESX.ShowNotification('Erreur lors de la modification du pole dance')
                            end
                        end, submenu_key, poleDanceData)
                    end
                end
            })
            
            RageUI.Button("Supprimer le pole dance", "Supprimer définitivement ce pole dance", {RightLabel = "~r~Supprimer~s~"}, true, {
                onSelected = function()
                    local confirm = lib.alertDialog({
                        header = 'Confirmation',
                        content = 'Êtes-vous sûr de vouloir supprimer le pole dance "' .. pole_dance_label .. '" ?',
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
                        end, submenu_key)
                    end
                end
            })
        end)
    end
end

return pole_dance_builder