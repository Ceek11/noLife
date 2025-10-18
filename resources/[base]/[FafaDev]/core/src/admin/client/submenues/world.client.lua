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
local locations_menu = RageUI.CreateSubMenu(builder_menu, "Gestion des Locations", "Gestion des locations du serveur")
local blips_menu = RageUI.CreateSubMenu(builder_menu, "Gestion des Blips", "Gestion des blips du serveur")
local peds_menu = RageUI.CreateSubMenu(builder_menu, "Gestion des Peds", "Gestion des peds du serveur")
local pole_dance_menu = RageUI.CreateSubMenu(builder_menu, "Gestion des Pole Dance", "Gestion des pole dance du serveur")
local TBL_SHOPS = {}
local TBL_CHESTS = {}
local TBL_BOSS = {}
local TBL_CLOAKROOMS = {}
local TBL_LOCATIONS = {}
local TBL_BLIPS = {}
local TBL_PEDS = {}
local TBL_POLE_DANCE = {}
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
        RageUI.Button("Gestion des Locations", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_locations", function(locations)
                    TBL_LOCATIONS = locations
                end)
            end
        }, locations_menu)
        RageUI.Button("Gestion des Blips", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_blips", function(blips)
                    TBL_BLIPS = blips
                end)
            end
        }, blips_menu)
        RageUI.Button("Gestion des Peds", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_peds", function(peds)
                    TBL_PEDS = peds
                end)
            end
        }, peds_menu)
        RageUI.Button("Gestion des Pole Dance", nil, {}, true, {
            onSelected = function()
                CORE.trigger_server_callback("fafadev:to_server:get_pole_dance", function(pole_dance)
                    TBL_POLE_DANCE = pole_dance
                end)
            end
        }, pole_dance_menu)
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
                    {type = 'input', label = 'Items du shop', description = 'Format: nom,prix|nom2,prix2 (ex: bread,10|water,20)', required = true, icon = 'shopping-cart'},
                    {type = 'checkbox', label = 'Afficher le marqueur', description = 'Afficher le marqueur sur la carte', checked = true}
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
                        drawmarker = input[8],
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
    
    RageUI.IsVisible(locations_menu, function()
        RageUI.Button("Créer une location", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer une location", {
                    {type = 'input', label = 'Nom de la location', description = 'Entrez le nom de la location (unique)', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Label de la location', description = 'Nom affiché de la location', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir la location', required = true, default = 'Appuyer sur ~INPUT_CONTEXT~ pour accéder à la location'},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: 32.586,-743.623,44.238|100.0,200.0,30.0)', required = true, icon = 'map-marker-alt'},
                    {type = 'input', label = 'Positions de spawn', description = 'Format: x,y,z,w|x2,y2,z2,w2 (ex: 32.586,-743.623,44.238,90.0|100.0,200.0,30.0,180.0)', required = true, icon = 'car'},
                    {type = 'input', label = 'Véhicules', description = 'Format: model,label,price,deposit|model2,label2,price2,deposit2 (ex: adder,Adder,500,1000|zentorno,Zentorno,450,900)', required = true, icon = 'list'},
                    {type = 'checkbox', label = 'Afficher le marqueur', description = 'Afficher le marqueur sur la carte', checked = true}
                })
                if input then
                    local coordsList = string.split(input[4], "|")
                    local coordsArray = {}
                    for i, coordString in pairs(coordsList) do
                        local coordsData = string.split(coordString, ",")
                        if #coordsData ~= 3 then
                            ESX.ShowNotification(string.format('Format de coordonnées invalide à la position %s. Utilisez: x,y,z', i))
                            return
                        end
                        local x, y, z = tonumber(coordsData[1]), tonumber(coordsData[2]), tonumber(coordsData[3])
                        if not x or not y or not z then
                            ESX.ShowNotification(string.format('Coordonnées invalides à la position %s. Les valeurs doivent être des nombres', i))
                            return
                        end
                        table.insert(coordsArray, {x = x, y = y, z = z})
                    end
                    
                    local spawnsList = string.split(input[5], "|")
                    local spawnsArray = {}
                    for i, spawnString in pairs(spawnsList) do
                        local spawnData = string.split(spawnString, ",")
                        if #spawnData ~= 4 then
                            ESX.ShowNotification(string.format('Format de spawn invalide à la position %s. Utilisez: x,y,z,w', i))
                            return
                        end
                        local x, y, z, w = tonumber(spawnData[1]), tonumber(spawnData[2]), tonumber(spawnData[3]), tonumber(spawnData[4])
                        if not x or not y or not z or not w then
                            ESX.ShowNotification(string.format('Position de spawn invalide à la position %s. Les valeurs doivent être des nombres', i))
                            return
                        end
                        table.insert(spawnsArray, {x = x, y = y, z = z, w = w})
                    end
                    
                    local vehiclesList = string.split(input[6], "|")
                    local vehiclesArray = {}
                    for i, vehicleString in pairs(vehiclesList) do
                        local vehicleData = string.split(vehicleString, ",")
                        if #vehicleData ~= 4 then
                            ESX.ShowNotification(string.format('Format de véhicule invalide à la position %s. Utilisez: model,label,price,deposit', i))
                            return
                        end
                        local price = tonumber(vehicleData[3])
                        local deposit = tonumber(vehicleData[4])
                        if not price or not deposit then
                            ESX.ShowNotification(string.format('Prix ou caution invalide à la position %s. Les valeurs doivent être des nombres', i))
                            return
                        end
                        table.insert(vehiclesArray, {
                            model = vehicleData[1],
                            label = vehicleData[2],
                            price = price,
                            deposit = deposit
                        })
                    end
                    
                    local locationData = {
                        name = input[1],
                        label = input[2],
                        message = input[3],
                        coords = coordsArray,
                        spawn_positions = spawnsArray,
                        vehicles_list = vehiclesArray,
                        drawmarker = input[7]
                    }
                    
                    CORE.trigger_server_callback("fafadev:to_server:create_location", function(success)
                        if success then
                            ESX.ShowNotification('Location créée avec succès !')
                            CORE.trigger_server_callback("fafadev:to_server:get_locations", function(locations)
                                TBL_LOCATIONS = locations
                            end)
                        else
                            ESX.ShowNotification('Erreur lors de la création de la location')
                        end
                    end, locationData)
                end
            end
        })
        RageUI.Line()
        for name, location in pairs(TBL_LOCATIONS) do 
            RageUI.Button(location.label or name, nil, {RightLabel = "~r~Supprimer~s~"}, true, {
                onSelected = function()
                    local confirm = lib.alertDialog({
                        header = 'Confirmation',
                        content = string.format('Êtes-vous sûr de vouloir supprimer la location "%s" ?', location.label or name),
                        centered = true,
                        cancel = true
                    })
                    if confirm == 'confirm' then
                        CORE.trigger_server_callback("fafadev:to_server:delete_location", function(success)
                            if success then
                                ESX.ShowNotification('Location supprimée avec succès !')
                                CORE.trigger_server_callback("fafadev:to_server:get_locations", function(locations)
                                    TBL_LOCATIONS = locations
                                end)
                            else
                                ESX.ShowNotification('Erreur lors de la suppression de la location')
                            end
                        end, name)
                    end
                end
            })
        end
    end)
    
    RageUI.IsVisible(blips_menu, function()
        RageUI.Button("Créer un blip", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un blip", {
                    {type = 'input', label = 'Label du blip', description = 'Nom affiché sur le blip', required = true, min = 2, max = 50},
                    {type = 'number', label = 'Sprite', description = 'Icône du blip (60=Police, 61=Hôpital, 108=Banque)', required = true, default = 1, min = 0, max = 826},
                    {type = 'number', label = 'Couleur', description = 'Couleur du blip (0-85)', required = true, default = 1, min = 0, max = 85},
                    {type = 'number', label = 'Taille', description = 'Taille du blip (0.5 - 2.0)', required = true, default = 0.8, min = 0.1, max = 2.0},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z (ex: 425.13,-979.55,30.71)', required = true, icon = 'map-marker-alt'},
                    {type = 'checkbox', label = 'Short Range', description = 'Visible uniquement de près', checked = true},
                    {type = 'input', label = 'Jobs autorisés', description = 'Liste des jobs séparés par des virgules (vide=tous)', icon = 'briefcase'},
                    {type = 'input', label = 'Grades minimum', description = 'Liste des grades séparés par des virgules (vide=tous)', icon = 'star'},
                    {type = 'checkbox', label = 'Activer la zone', description = 'Afficher une zone autour du blip'},
                    {type = 'number', label = 'Rayon de la zone', description = 'Rayon en mètres (si zone activée)', default = 50.0, min = 1, max = 500},
                    {type = 'checkbox', label = 'Afficher cercle zone', description = 'Afficher le cercle sur la carte', checked = true},
                    {type = 'input', label = 'Couleur zone (RGBA)', description = 'Format: r,g,b,a (ex: 255,0,0,50)', default = '255,255,255,50'}
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
                    
                    local jobs = {}
                    if input[7] and input[7] ~= "" then
                        jobs = string.split(input[7], ",")
                        for i, job in ipairs(jobs) do
                            jobs[i] = job:match("^%s*(.-)%s*$")
                        end
                    end
                    
                    local grades = {}
                    if input[8] and input[8] ~= "" then
                        local gradesList = string.split(input[8], ",")
                        for _, gradeStr in pairs(gradesList) do
                            local grade = tonumber(gradeStr:match("^%s*(.-)%s*$"))
                            if grade then
                                table.insert(grades, grade)
                            end
                        end
                    end
                    
                    local areaColor = {r = 255, g = 255, b = 255, a = 50}
                    if input[12] and input[12] ~= "" then
                        local colorData = string.split(input[12], ",")
                        if #colorData == 4 then
                            areaColor.r = tonumber(colorData[1]) or 255
                            areaColor.g = tonumber(colorData[2]) or 255
                            areaColor.b = tonumber(colorData[3]) or 255
                            areaColor.a = tonumber(colorData[4]) or 50
                        end
                    end
                    
                    local blipData = {
                        label = input[1],
                        sprite = input[2],
                        color = input[3],
                        scale = input[4],
                        coords = {x = x, y = y, z = z},
                        shortRange = input[6],
                        jobs = jobs,
                        grades = grades,
                        area = {
                            enabled = input[9],
                            radius = input[10],
                            color = areaColor,
                            showBlip = input[11]
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
        RageUI.Line()
        for id, blip in pairs(TBL_BLIPS) do 
            RageUI.Button(blip.label or ("Blip #" .. id), "Sprite: " .. blip.sprite .. " | Couleur: " .. blip.color, {RightLabel = "~r~Supprimer~s~"}, true, {
                onSelected = function()
                    local confirm = lib.alertDialog({
                        header = 'Confirmation',
                        content = 'Êtes-vous sûr de vouloir supprimer le blip "' .. (blip.label or ("Blip #" .. id)) .. '" ?',
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
                        end, id)
                    end
                end
            })
        end
    end)
    
    RageUI.IsVisible(peds_menu, function()
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
    
    RageUI.IsVisible(pole_dance_menu, function()
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