-- Variables pour les sous-menus des shops
local shop_submenus = {}

-- Fonction pour nettoyer les sous-menus obsolètes
local function CleanupObsoleteShopSubmenus(current_shops)
    local current_keys = {}
    
    -- Collecter les clés actuelles
    if current_shops then
        for name, _ in pairs(current_shops) do
            table.insert(current_keys, "shop_" .. name)
        end
    end
    
    -- Supprimer les sous-menus qui n'existent plus
    for key, submenu in pairs(shop_submenus) do
        local exists = false
        for _, current_key in pairs(current_keys) do
            if key == current_key then
                exists = true
                break
            end
        end
        if not exists then
            shop_submenus[key] = nil
        end
    end
end

function shops_builder(shopsData)
    local TBL_SHOPS = shopsData or {}
    
    -- Nettoyer les sous-menus obsolètes
    CleanupObsoleteShopSubmenus(TBL_SHOPS)
    
    RageUI.IsVisible(sub_menus_admin["shops"], function()
        RageUI.Button("Créer un shop", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un shop", {
                    {type = 'input', label = 'Nom du shop', description = 'Entrez le nom du shop', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Label du shop', description = 'Nom affiché du shop', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2 (ex: 32.586411,-743.623474,44.238464|100.0,200.0,30.0)', required = true, icon = 'map-marker-alt'},
                    {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir le shop', required = true, default = 'Appuyer sur ~INPUT_CONTEXT~ pour ouvrir le shop'},
                    {type = 'select', label = 'Type de monnaie', description = 'Type de monnaie accepté par le shop', required = true, options = {
                        {value = 'money', label = 'Argent liquide'},
                        {value = 'bank', label = 'Compte bancaire'},
                        {value = 'black_money', label = 'Argent sale'}
                    }, default = 'money'},
                    {type = 'input', label = 'Jobs autorisés', description = 'Liste des jobs séparés par des virgules (ex: police,ambulance)', icon = 'briefcase'},
                    {type = 'input', label = 'Grades autorisés', description = 'Liste des grades séparés par des virgules (ex: 0,1,2)', icon = 'star'},
                    {type = 'input', label = 'Licences requises', description = 'Liste des licences séparées par des virgules (ex: weapon,driver)', icon = 'id-card'},
                    {type = 'input', label = 'Items du shop', description = 'Format: nom,prix|nom2,prix2 (ex: bread,10|water,20)', required = true, icon = 'shopping-cart'},
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
                    
                    local shopData = {
                        name = input[1],
                        label = input[2],
                        coords = coordsArray,
                        message = input[4],
                        typeMoney = input[5],
                        jobAccess = input[6] and input[6] ~= "" and string.split(input[6], ",") or {},
                        gradeAccess = input[7] and input[7] ~= "" and string.split(input[7], ",") or {},
                        haveLicense = input[8] and input[8] ~= "" and string.split(input[8], ",") or {},
                        drawmarker = input[10],
                        items = {}
                    }
                    
                    if input[9] and input[9] ~= "" then
                        local itemsList = string.split(input[9], "|")
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
        
        -- Affichage des shops avec sous-menus
        for name, shop in pairs(TBL_SHOPS) do
            local label = shop.label or shop.name or name
            local info = string.format("Type: %s | Jobs: %s", shop.typeMoney or "money", table.concat(shop.jobAccess or {}, ", ") or "Tous")
            local submenu_key = "shop_" .. name
            
            -- Créer le sous-menu s'il n'existe pas
            if not shop_submenus[submenu_key] then
                shop_submenus[submenu_key] = RageUI.CreateSubMenu(sub_menus_admin["shops"], label, "Gestion du shop")
            else
                -- Mettre à jour le titre du sous-menu si le label a changé
                shop_submenus[submenu_key].Title = label
            end
            
            RageUI.Button(label, info, {RightLabel = "→→→"}, true, {
                onSelected = function()
                    -- Pas besoin d'action, le sous-menu s'ouvre automatiquement
                end
            }, shop_submenus[submenu_key])
        end
    end)
    
    -- Gestion des sous-menus individuels des shops
    for submenu_key, submenu in pairs(shop_submenus) do
        RageUI.IsVisible(submenu, function()
            local shop_name = string.match(submenu_key, "shop_(.+)")
            local shop_data = TBL_SHOPS[shop_name]
            
            if shop_data then
                local shop_label = shop_data.label or shop_data.name or shop_name
                
                RageUI.Separator("~b~" .. shop_label .. "~s~")
                
                -- Téléportation
                RageUI.Button("Se téléporter au shop", "Se téléporter aux coordonnées du shop", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        if shop_data.coords and #shop_data.coords > 0 then
                            local coords = shop_data.coords[1]
                            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
                            ESX.ShowNotification('Téléportation effectuée !')
                        end
                    end
                })
                
                -- Modification
                RageUI.Button("Modifier les informations", "Modifier les paramètres du shop", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        local coordsString = ""
                        if shop_data.coords then
                            local coordsList = {}
                            for _, coord in pairs(shop_data.coords) do
                                table.insert(coordsList, string.format("%.2f,%.2f,%.2f", coord.x, coord.y, coord.z))
                            end
                            coordsString = table.concat(coordsList, "|")
                        end
                        
                        local itemsString = ""
                        if shop_data.items then
                            local itemsList = {}
                            for _, item in pairs(shop_data.items) do
                                table.insert(itemsList, string.format("%s,%d", item.name, item.price))
                            end
                            itemsString = table.concat(itemsList, "|")
                        end
                        
                        local input = lib.inputDialog("Modifier le shop", {
                            {type = 'input', label = 'Nom du shop', description = 'Entrez le nom du shop', required = true, min = 2, max = 50, default = shop_data.name or ""},
                            {type = 'input', label = 'Label du shop', description = 'Nom affiché du shop', required = true, min = 2, max = 50, default = shop_data.label or ""},
                            {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z|x2,y2,z2', required = true, icon = 'map-marker-alt', default = coordsString},
                            {type = 'input', label = 'Message d\'interaction', description = 'Message affiché pour ouvrir le shop', required = true, default = shop_data.message or ""},
                            {type = 'select', label = 'Type de monnaie', description = 'Type de monnaie accepté par le shop', required = true, options = {
                                {value = 'money', label = 'Argent liquide'},
                                {value = 'bank', label = 'Compte bancaire'},
                                {value = 'black_money', label = 'Argent sale'}
                            }, default = shop_data.typeMoney or 'money'},
                            {type = 'input', label = 'Jobs autorisés', description = 'Liste des jobs séparés par des virgules', icon = 'briefcase', default = table.concat(shop_data.jobAccess or {}, ",")},
                            {type = 'input', label = 'Grades autorisés', description = 'Liste des grades séparés par des virgules', icon = 'star', default = table.concat(shop_data.gradeAccess or {}, ",")},
                            {type = 'input', label = 'Licences requises', description = 'Liste des licences séparées par des virgules', icon = 'id-card', default = table.concat(shop_data.haveLicense or {}, ",")},
                            {type = 'input', label = 'Items du shop', description = 'Format: nom,prix|nom2,prix2', required = true, icon = 'shopping-cart', default = itemsString},
                            {type = 'checkbox', label = 'Afficher le marqueur', description = 'Afficher le marqueur sur la carte', checked = shop_data.drawmarker or false}
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
                            
                            local shopData = {
                                name = input[1],
                                label = input[2],
                                coords = coordsArray,
                                message = input[4],
                                typeMoney = input[5],
                                jobAccess = input[6] and input[6] ~= "" and string.split(input[6], ",") or {},
                                gradeAccess = input[7] and input[7] ~= "" and string.split(input[7], ",") or {},
                                haveLicense = input[8] and input[8] ~= "" and string.split(input[8], ",") or {},
                                drawmarker = input[10],
                                items = {}
                            }
                            
                            if input[9] and input[9] ~= "" then
                                local itemsList = string.split(input[9], "|")
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
                            
                            CORE.trigger_server_callback("fafadev:to_server:update_shop", function(success)
                                if success then
                                    ESX.ShowNotification('Shop modifié avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_shops", function(shops)
                                        TBL_SHOPS = shops
                                        -- Mettre à jour le titre du sous-menu
                                        if shop_submenus[submenu_key] then
                                            shop_submenus[submenu_key].Title = input[2]
                                        end
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la modification du shop')
                                end
                            end, shop_name, shopData)
                        end
                    end
                })
                
                -- Suppression
                RageUI.Button("Supprimer le shop", "Supprimer définitivement ce shop", {RightLabel = "~r~Supprimer~s~"}, true, {
                    onSelected = function()
                        local confirm = lib.alertDialog({
                            header = 'Confirmation',
                            content = 'Êtes-vous sûr de vouloir supprimer le shop "' .. shop_label .. '" ?',
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
                            end, shop_name)
                        end
                    end
                })
            end
        end)
    end
end

return shops_builder