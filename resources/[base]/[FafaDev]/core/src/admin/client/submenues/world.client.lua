function string.split(str, delimiter)
    local result = {}
    local pattern = "(.-)" .. delimiter
    local last_end = 1
    local s, e, cap = str:find(pattern, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(result, cap)
        end
        last_end = e + 1
        s, e, cap = str:find(pattern, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(result, cap)
    end
    return result
end


local builder_menu = RageUI.CreateSubMenu(sub_menus_admin["server"], "Gestion Builder", "Gestion des éléments du serveur")
local shops_menu = RageUI.CreateSubMenu(builder_menu, "Gestion des Shops", "Gestion des shops du serveur")
local chests_menu = RageUI.CreateSubMenu(builder_menu, "Gestion des Coffres", "Gestion des coffres du serveur")
local boss_menu = RageUI.CreateSubMenu(builder_menu, "Gestion des Menus Boss", "Gestion des menus boss du serveur")
local cloakrooms_menu = RageUI.CreateSubMenu(builder_menu, "Gestion des Vestiaires", "Gestion des vestiaires du serveur")
local TBL_SHOPS = {}
local TBL_CHESTS = {}
local TBL_BOSS = {}
local TBL_CLOAKROOMS = {}
function OpenMenuWorldAdmin()
    RageUI.IsVisible(sub_menus_admin["server"], function()
        RageUI.Button("Menu mapping", nil, {}, true, {})
        RageUI.Button("Gestion Builder", nil, {}, true, {}, builder_menu)
        RageUI.Button("Gestion BDD", nil, {}, true, {})
    end)
    RageUI.IsVisible(builder_menu, function()
        RageUI.Button("Gestion des Shops", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_shops", function(shops)
                    TBL_SHOPS = shops
                end)
            end
        }, shops_menu)
        RageUI.Button("Gestion des Coffres", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_chests", function(chests)
                    TBL_CHESTS = chests
                end)
            end
        }, chests_menu)
        RageUI.Button("Gestion des Menus Boss", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_boss", function(boss)
                    TBL_BOSS = boss
                end)
            end
        }, boss_menu)
        RageUI.Button("Gestion des Vestiaires", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_cloakrooms", function(cloakrooms)
                    TBL_CLOAKROOMS = cloakrooms
                end)
            end
        }, cloakrooms_menu)
    end)
    RageUI.IsVisible(shops_menu, function()
        RageUI.Button("Crée un shop", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un shop", {
                    {type = 'input', label = 'Nom du shop', description = 'Entrez le nom du shop', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: 32.586411,-743.623474,44.238464|100.0,200.0,30.0)', required = true, icon = 'map-marker-alt'},
                    {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir le shop', required = true, default = 'Appuyer sur ~INPUT_CONTEXT~ pour ouvrir le shop'},
                    {type = 'input', label = 'Jobs autorisés', description = 'Liste des jobs séparés par des virgules (ex: police,ambulance)', icon = 'briefcase'},
                    {type = 'input', label = 'Grades autorisés', description = 'Liste des grades séparés par des virgules (ex: 0,1,2)', icon = 'star'},
                    {type = 'input', label = 'Licences requises', description = 'Liste des licences séparées par des virgules (ex: weapon,driver)', icon = 'id-card'},
                    {type = 'input', label = 'Items du shop', description = 'Format: nom,prix|nom2,prix2 (ex: bread,10|water,20)', required = true, icon = 'shopping-cart'}
                })
                if input then
                    local coordsList = string.split(input[2], "|")
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
                    
                    local shopData = {
                        name = input[1],
                        coords = coordsArray,
                        message = input[3],
                        jobAccess = input[4] and input[4] ~= "" and string.split(input[4], ",") or {},
                        gradeAccess = input[5] and input[5] ~= "" and string.split(input[5], ",") or {},
                        haveLicense = input[6] and input[6] ~= "" and string.split(input[6], ",") or {},
                        items = {}
                    }
                    
                    if input[7] and input[7] ~= "" then
                        local itemsList = string.split(input[7], "|")
                        for _, item in pairs(itemsList) do
                            local itemData = string.split(item, ",")
                            if #itemData == 2 then
                                table.insert(shopData.items, {
                                    name = itemData[1],
                                    price = tonumber(itemData[2])
                                })
                            end
                        end
                    end
                    CORE.trigger_server_callback("fafadev:to_server:create_shop", function(success)
                        if success then
                            ESX.ShowNotification('Shop créé avec succès !')
                            CORE.trigger_server_callback("fafadev:to_server:get_shops", function(shops)
                                TBL_SHOPS = shops
                            end)
                        else
                            ESX.ShowNotification('Erreur lors de la création du shop')
                        end
                    end, shopData)
                end
            end
        })
        RageUI.Line()
        for _, shop in pairs(TBL_SHOPS) do 
            RageUI.Button(shop.name, nil, {RightLabel = "~r~Supprimer~s~"}, true, {
                onSelected = function()
                    local confirm = lib.alertDialog({
                        header = 'Confirmation',
                        content = 'Êtes-vous sûr de vouloir supprimer le shop "' .. shop.name .. '" ?',
                        centered = true,
                        cancel = true
                    })
                    if confirm == 'confirm' then
                        CORE.trigger_server_callback("fafadev:to_server:delete_shop", function(success)
                            if success then
                                ESX.ShowNotification('Shop supprimé avec succès !')
                                CORE.trigger_server_callback("fafadev:to_server:get_shops", function(shops)
                                    TBL_SHOPS = shops
                                end)
                            else
                                ESX.ShowNotification('Erreur lors de la suppression du shop')
                            end
                        end, shop.name)
                    end
                end
            })
        end
    end)
    RageUI.IsVisible(chests_menu, function()
        RageUI.Button("Créer un coffre", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un coffre", {
                    {type = 'input', label = 'Nom du coffre', description = 'Entrez le nom du coffre (unique)', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Label du coffre', description = 'Nom affiché du coffre', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Job requis', description = 'Job nécessaire pour accéder au coffre (optionnel)', icon = 'briefcase'},
                    {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir le coffre', required = true, default = 'Appuyer sur ~INPUT_CONTEXT~ pour accéder au coffre'},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: 32.586411,-743.623474,44.238464|100.0,200.0,30.0)', required = true, icon = 'map-marker-alt'},
                    {type = 'number', label = 'Poids maximum', description = 'Poids maximum du coffre (défaut: 2000)', default = 2000, min = 100, max = 10000}
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
        for name, chest in pairs(TBL_CHESTS) do 
            RageUI.Button(chest.label or name, nil, {RightLabel = "~r~Supprimer~s~"}, true, {
                onSelected = function()
                    local confirm = lib.alertDialog({
                        header = 'Confirmation',
                        content = 'Êtes-vous sûr de vouloir supprimer le coffre "' .. (chest.label or name) .. '" ?',
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
                        end, name)
                    end
                end
            })
        end
    end)
    RageUI.IsVisible(boss_menu, function()
        RageUI.Button("Créer un menu boss", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un menu boss", {
                    {type = 'input', label = 'Nom du menu boss', description = 'Entrez le nom du menu boss (unique)', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Label du menu boss', description = 'Nom affiché du menu boss', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Job requis', description = 'Job nécessaire pour accéder au menu boss', required = true, icon = 'briefcase'},
                    {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir le menu boss', required = true, default = 'Appuyer sur ~INPUT_CONTEXT~ pour ouvrir le menu boss'},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: 32.586411,-743.623474,44.238464|100.0,200.0,30.0)', required = true, icon = 'map-marker-alt'},
                    {type = 'input', label = 'Grades autorisés', description = 'Liste des grades séparés par des virgules (ex: 1,2,3)', required = true, icon = 'star'},
                    {type = 'input', label = 'Permissions', description = 'Format: boss:true,menuF6:true,chest:true,cloakroom:true,garage:true', required = true, default = 'boss:true,menuF6:true,chest:true,cloakroom:true,garage:true'}
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
                        permissions = permissions
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
    
    RageUI.IsVisible(cloakrooms_menu, function()
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

