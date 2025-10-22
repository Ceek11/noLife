function shops_builder(shopsData)
    local TBL_SHOPS = shopsData or {}
    RageUI.IsVisible(sub_menus_admin["shops"], function()
        RageUI.Button("Crée un shop", nil, {}, true, {
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
end

return shops_builder