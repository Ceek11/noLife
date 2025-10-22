-- Variables pour les sous-menus des boss
local boss_submenus = {}

-- Fonction pour nettoyer les sous-menus obsolètes
local function CleanupObsoleteBossSubmenus(current_boss)
    local current_keys = {}
    
    -- Collecter les clés actuelles
    if current_boss then
        for name, _ in pairs(current_boss) do
            table.insert(current_keys, "boss_" .. name)
        end
    end
    
    -- Supprimer les sous-menus qui n'existent plus
    for key, submenu in pairs(boss_submenus) do
        local exists = false
        for _, current_key in pairs(current_keys) do
            if key == current_key then
                exists = true
                break
            end
        end
        if not exists then
            boss_submenus[key] = nil
        end
    end
end

function boss_builder(bossData)
    local TBL_BOSS = bossData or {}
    
    -- Nettoyer les sous-menus obsolètes
    CleanupObsoleteBossSubmenus(TBL_BOSS)
    
    RageUI.IsVisible(sub_menus_admin["boss"], function()
        RageUI.Button("Créer un menu boss", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un menu boss", {
                    {type = 'input', label = 'Nom du menu boss', description = 'Entrez le nom du menu boss (unique)', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Label du menu boss', description = 'Nom affiché du menu boss', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Job requis', description = 'Job nécessaire pour accéder au menu boss', required = true, icon = 'briefcase'},
                    {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir le menu boss', required = true, default = 'Appuyer sur ~INPUT_CONTEXT~ pour ouvrir le menu boss'},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: 32.586411,-743.623474,44.238464|100.0,200.0,30.0)', required = true, icon = 'map-marker-alt'},
                    {type = 'input', label = 'Grades autorisés', description = 'Liste des grades séparés par des virgules (ex: 1,2,3)', required = true, icon = 'star'},
                    {type = 'input', label = 'Permissions', description = 'Format: boss:true,menuF6:true,chest:true,cloakroom:true,garage:true', required = true, default = 'boss:true,menuF6:true,chest:true,cloakroom:true,garage:true'},
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
                    
                    -- Fonction pour nettoyer les espaces
                    local function trim(str)
                        return str:match("^%s*(.-)%s*$")
                    end
                    
                    -- Parsing des grades
                    local gradeAccess = {}
                    if input[6] and input[6] ~= "" then
                        local gradesList = string.split(input[6], ",")
                        for _, gradeStr in pairs(gradesList) do
                            local grade = tonumber(trim(gradeStr))
                            if grade then
                                table.insert(gradeAccess, grade)
                            end
                        end
                    end
                    
                    -- Parsing des permissions
                    local permissions = {}
                    if input[7] and input[7] ~= "" then
                        local permissionsList = string.split(input[7], ",")
                        for _, permStr in pairs(permissionsList) do
                            local permData = string.split(permStr, ":")
                            if #permData == 2 then
                                local key = trim(permData[1])
                                local value = trim(permData[2]) == "true"
                                permissions[key] = value
                            end
                        end
                    end
                    
                    local bossData = {
                        name = input[1],
                        label = input[2],
                        job = input[3],
                        message = input[4],
                        coords = coordsArray,
                        gradeAccess = gradeAccess,
                        permissions = permissions,
                        drawmarker = input[8]
                    }
                    
                    CORE.trigger_server_callback("fafadev:to_server:create_boss", function(success)
                        if success then
                            ESX.ShowNotification('Menu boss créé avec succès !')
                            CORE.trigger_server_callback("fafadev:to_server:get_boss", function(boss)
                                TBL_BOSS = boss
                            end)
                        else
                            ESX.ShowNotification('Erreur lors de la création du menu boss')
                        end
                    end, bossData)
                end
            end
        })
        
        RageUI.Line()
        
        -- Affichage des boss avec sous-menus
        for name, boss in pairs(TBL_BOSS) do
            local label = boss.label or name
            local info = string.format("Job: %s | Grades: %s", boss.job or "N/A", table.concat(boss.gradeAccess or {}, ", ") or "Tous")
            local submenu_key = "boss_" .. name
            
            -- Créer le sous-menu s'il n'existe pas
            if not boss_submenus[submenu_key] then
                boss_submenus[submenu_key] = RageUI.CreateSubMenu(sub_menus_admin["boss"], label, "Gestion du menu boss")
            else
                -- Mettre à jour le titre du sous-menu si le label a changé
                boss_submenus[submenu_key].Title = label
            end
            
            RageUI.Button(label, info, {RightLabel = "→→→"}, true, {
                onSelected = function()
                    -- Pas besoin d'action, le sous-menu s'ouvre automatiquement
                end
            }, boss_submenus[submenu_key])
        end
    end)
    
    -- Gestion des sous-menus individuels des boss
    for submenu_key, submenu in pairs(boss_submenus) do
        RageUI.IsVisible(submenu, function()
            local boss_name = string.match(submenu_key, "boss_(.+)")
            local boss_data = TBL_BOSS[boss_name]
            
            if boss_data then
                local boss_label = boss_data.label or boss_name
                
                RageUI.Separator("~b~" .. boss_label .. "~s~")
                
                -- Téléportation
                RageUI.Button("Se téléporter au menu boss", "Se téléporter aux coordonnées du menu boss", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        if boss_data.coords and #boss_data.coords > 0 then
                            local coords = boss_data.coords[1]
                            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
                            ESX.ShowNotification('Téléportation effectuée !')
                        end
                    end
                })
                
                -- Modification
                RageUI.Button("Modifier les informations", "Modifier les paramètres du menu boss", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        local coordsString = ""
                        if boss_data.coords then
                            local coordsList = {}
                            for _, coord in pairs(boss_data.coords) do
                                table.insert(coordsList, string.format("%.2f,%.2f,%.2f", coord.x, coord.y, coord.z))
                            end
                            coordsString = table.concat(coordsList, "|")
                        end
                        
                        local gradesString = ""
                        if boss_data.gradeAccess then
                            local gradesList = {}
                            for _, grade in pairs(boss_data.gradeAccess) do
                                table.insert(gradesList, tostring(grade))
                            end
                            gradesString = table.concat(gradesList, ",")
                        end
                        
                        local permissionsString = ""
                        if boss_data.permissions then
                            local permissionsList = {}
                            for key, value in pairs(boss_data.permissions) do
                                table.insert(permissionsList, string.format("%s:%s", key, tostring(value)))
                            end
                            permissionsString = table.concat(permissionsList, ",")
                        end
                        
                        local input = lib.inputDialog("Modifier le menu boss", {
                            {type = 'input', label = 'Nom du menu boss', description = 'Entrez le nom du menu boss (unique)', required = true, min = 2, max = 50, default = boss_data.name or ""},
                            {type = 'input', label = 'Label du menu boss', description = 'Nom affiché du menu boss', required = true, min = 2, max = 50, default = boss_data.label or ""},
                            {type = 'input', label = 'Job requis', description = 'Job nécessaire pour accéder au menu boss', required = true, icon = 'briefcase', default = boss_data.job or ""},
                            {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir le menu boss', required = true, default = boss_data.message or ""},
                            {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2', required = true, icon = 'map-marker-alt', default = coordsString},
                            {type = 'input', label = 'Grades autorisés', description = 'Liste des grades séparés par des virgules', required = true, icon = 'star', default = gradesString},
                            {type = 'input', label = 'Permissions', description = 'Format: boss:true,menuF6:true,chest:true,cloakroom:true,garage:true', required = true, default = permissionsString},
                            {type = 'checkbox', label = 'Afficher le marqueur', description = 'Afficher le marqueur sur la carte', checked = boss_data.drawmarker or false}
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
                            
                            -- Fonction pour nettoyer les espaces
                            local function trim(str)
                                return str:match("^%s*(.-)%s*$")
                            end
                            
                            -- Parsing des grades
                            local gradeAccess = {}
                            if input[6] and input[6] ~= "" then
                                local gradesList = string.split(input[6], ",")
                                for _, gradeStr in pairs(gradesList) do
                                    local grade = tonumber(trim(gradeStr))
                                    if grade then
                                        table.insert(gradeAccess, grade)
                                    end
                                end
                            end
                            
                            -- Parsing des permissions
                            local permissions = {}
                            if input[7] and input[7] ~= "" then
                                local permissionsList = string.split(input[7], ",")
                                for _, permStr in pairs(permissionsList) do
                                    local permData = string.split(permStr, ":")
                                    if #permData == 2 then
                                        local key = trim(permData[1])
                                        local value = trim(permData[2]) == "true"
                                        permissions[key] = value
                                    end
                                end
                            end
                            
                            local bossData = {
                                name = input[1],
                                label = input[2],
                                job = input[3],
                                message = input[4],
                                coords = coordsArray,
                                gradeAccess = gradeAccess,
                                permissions = permissions,
                                drawmarker = input[8]
                            }
                            
                            CORE.trigger_server_callback("fafadev:to_server:update_boss", function(success)
                                if success then
                                    ESX.ShowNotification('Menu boss modifié avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_boss", function(boss)
                                        TBL_BOSS = boss
                                        -- Mettre à jour le titre du sous-menu
                                        if boss_submenus[submenu_key] then
                                            boss_submenus[submenu_key].Title = input[2]
                                        end
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la modification du menu boss')
                                end
                            end, boss_name, bossData)
                        end
                    end
                })
                
                -- Suppression
                RageUI.Button("Supprimer le menu boss", "Supprimer définitivement ce menu boss", {RightLabel = "~r~Supprimer~s~"}, true, {
                    onSelected = function()
                        local confirm = lib.alertDialog({
                            header = 'Confirmation',
                            content = 'Êtes-vous sûr de vouloir supprimer le menu boss "' .. boss_label .. '" ?',
                            centered = true,
                            cancel = true
                        })
                        if confirm == 'confirm' then
                            CORE.trigger_server_callback("fafadev:to_server:delete_boss", function(success)
                                if success then
                                    ESX.ShowNotification('Menu boss supprimé avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_boss", function(boss)
                                        TBL_BOSS = boss
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la suppression du menu boss')
                                end
                            end, boss_name)
                        end
                    end
                })
            end
        end)
    end
end

return boss_builder
