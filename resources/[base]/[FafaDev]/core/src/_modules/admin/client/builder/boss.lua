function boss_builder(bossData)
    local TBL_BOSS = bossData or {}
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
        for name, boss in pairs(TBL_BOSS) do 
            RageUI.Button(boss.label or name, nil, {RightLabel = "~r~Supprimer~s~"}, true, {
                onSelected = function()
                    local confirm = lib.alertDialog({
                        header = 'Confirmation',
                        content = 'Êtes-vous sûr de vouloir supprimer le menu boss "' .. (boss.label or name) .. '" ?',
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
                        end, name)
                    end
                end
            })
        end
    end)
end

return boss_builder
