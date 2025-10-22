-- Variables pour les sous-menus des blips
local blip_submenus = {}

-- Fonction pour nettoyer les sous-menus obsolètes
local function CleanupObsoleteSubmenus(current_blips)
    local current_keys = {}
    
    -- Collecter les clés actuelles
    if current_blips and current_blips.ClassicBlips then
        for i, _ in pairs(current_blips.ClassicBlips) do
            table.insert(current_keys, "blip_classic_" .. i)
        end
    end
    
    if current_blips and current_blips.Blips and current_blips.Blips.Entreprise then
        for i, _ in pairs(current_blips.Blips.Entreprise) do
            table.insert(current_keys, "blip_entreprise_" .. i)
        end
    end
    
    -- Supprimer les sous-menus qui n'existent plus
    for key, submenu in pairs(blip_submenus) do
        local exists = false
        for _, current_key in pairs(current_keys) do
            if key == current_key then
                exists = true
                break
            end
        end
        if not exists then
            blip_submenus[key] = nil
        end
    end
end

function blips_builder(blipsData)
    local TBL_BLIPS = blipsData or {}
    
    -- Nettoyer les sous-menus obsolètes
    CleanupObsoleteSubmenus(TBL_BLIPS)
    
    RageUI.IsVisible(sub_menus_admin["blips"], function()
        RageUI.Button("Créer un blip classique", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un blip classique", {
                    {type = 'input', label = 'Label du blip', description = 'Nom affiché sur le blip', required = true, min = 2, max = 50},
                    {type = 'number', label = 'Sprite', description = 'Icône du blip (60=Police, 61=Hôpital, 108=Banque)', required = true, default = 1, min = 0, max = 826},
                    {type = 'number', label = 'Couleur', description = 'Couleur du blip (0-85)', required = true, default = 1, min = 0, max = 85},
                    {type = 'input', label = 'Taille', description = 'Taille du blip (0.5 - 2.0)', required = true, default = '0.8'},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z (ex: 425.13,-979.55,30.71)', required = true, icon = 'map-marker-alt'},
                    {type = 'input', label = 'Job requis', description = 'Job requis (ALL pour tous)', required = true, default = 'ALL'},
                    {type = 'input', label = 'Job2 requis', description = 'Job2 requis (ALL pour tous)', required = true, default = 'ALL'},
                    {type = 'checkbox', label = 'Activer la zone', description = 'Afficher une zone autour du blip'},
                    {type = 'input', label = 'Rayon de la zone', description = 'Rayon en mètres (si zone activée)', default = '50.0'},
                    {type = 'number', label = 'Couleur zone', description = 'Couleur de la zone (0-85)', default = 0, min = 0, max = 85}
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
                    
                    local blipData = {
                        type = "classic",
                        data = {
                            Label = input[1],
                            Id = tonumber(input[2]) or 1,
                            BColor = tonumber(input[3]) or 1,
                            BSize = tonumber(input[4]) or 0.8,
                            X = x,
                            Y = y,
                            Z = z,
                            Job = input[6],
                            Job2 = input[7],
                            Area = input[8],
                            ASize = input[8] and (tonumber(input[9]) or 50.0) or 0.0,
                            AColor = input[8] and (tonumber(input[10]) or 0) or 0
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
        
        RageUI.Button("Créer un blip d'entreprise", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un blip d'entreprise", {
                    {type = 'input', label = 'Nom du blip', description = 'Nom affiché sur le blip', required = true, min = 2, max = 50},
                    {type = 'number', label = 'Sprite', description = 'Icône du blip', required = true, default = 1, min = 0, max = 826},
                    {type = 'number', label = 'Couleur', description = 'Couleur du blip (0-85)', required = true, default = 1, min = 0, max = 85},
                    {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z (ex: 425.13,-979.55,30.71)', required = true, icon = 'map-marker-alt'},
                    {type = 'input', label = 'Job requis', description = 'Job requis pour voir le blip', required = true}
                })
                if input then
                    local coordsData = string.split(input[4], ",")
                    if #coordsData ~= 3 then
                        ESX.ShowNotification('Format de coordonnées invalide. Utilisez: x,y,z')
                        return
                    end
                    
                    local x, y, z = tonumber(coordsData[1]), tonumber(coordsData[2]), tonumber(coordsData[3])
                    if not x or not y or not z then
                        ESX.ShowNotification('Coordonnées invalides. Les valeurs doivent être des nombres')
                        return
                    end
                    
                    local blipData = {
                        type = "entreprise",
                        data = {
                            name = input[1],
                            id = tonumber(input[2]) or 1,
                            color = tonumber(input[3]) or 1,
                            pos = {x = x, y = y, z = z},
                            job = input[5]
                        }
                    }
                    
                    CORE.trigger_server_callback("fafadev:to_server:create_blip", function(success)
                        if success then
                            ESX.ShowNotification('Blip d\'entreprise créé avec succès !')
                            CORE.trigger_server_callback("fafadev:to_server:get_blips", function(blips)
                                TBL_BLIPS = blips
                            end)
                        else
                            ESX.ShowNotification('Erreur lors de la création du blip d\'entreprise')
                        end
                    end, blipData)
                end
            end
        })
        
        RageUI.Line()
        
        -- Affichage des blips classiques
        if TBL_BLIPS and TBL_BLIPS.ClassicBlips then
            for i, blip in pairs(TBL_BLIPS.ClassicBlips) do
                local label = blip.Label or ("Blip #" .. i)
                local info = string.format("Sprite: %d | Couleur: %d | Job: %s", blip.Id, blip.BColor, blip.Job)
                local submenu_key = "blip_classic_" .. i
                
                -- Créer le sous-menu s'il n'existe pas
                if not blip_submenus[submenu_key] then
                    blip_submenus[submenu_key] = RageUI.CreateSubMenu(sub_menus_admin["blips"], label, "Gestion du blip")
                else
                    -- Mettre à jour le titre du sous-menu si le label a changé
                    blip_submenus[submenu_key].Title = label
                end
                
                RageUI.Button(label, info, {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        -- Pas besoin d'action, le sous-menu s'ouvre automatiquement
                    end
                }, blip_submenus[submenu_key])
            end
        end
        
        -- Affichage des blips d'entreprise
        if TBL_BLIPS and TBL_BLIPS.Blips and TBL_BLIPS.Blips.Entreprise then
            for i, blip in pairs(TBL_BLIPS.Blips.Entreprise) do
                local label = blip.name or ("Blip Entreprise #" .. i)
                local info = string.format("Sprite: %d | Couleur: %d | Job: %s", blip.id, blip.color, blip.job)
                local submenu_key = "blip_entreprise_" .. i
                
                -- Créer le sous-menu s'il n'existe pas
                if not blip_submenus[submenu_key] then
                    blip_submenus[submenu_key] = RageUI.CreateSubMenu(sub_menus_admin["blips"], label, "Gestion du blip")
                else
                    -- Mettre à jour le titre du sous-menu si le label a changé
                    blip_submenus[submenu_key].Title = label
                end
                
                RageUI.Button(label, info, {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        -- Pas besoin d'action, le sous-menu s'ouvre automatiquement
                    end
                }, blip_submenus[submenu_key])
            end
        end
    end)
    
    -- Gestion des sous-menus individuels des blips
    for submenu_key, submenu in pairs(blip_submenus) do
        RageUI.IsVisible(submenu, function()
            local blip_type = string.find(submenu_key, "classic") and "classic" or "entreprise"
            local blip_index = tonumber(string.match(submenu_key, "_(%d+)$"))
            local blip_data = nil
            
            -- Récupérer les données du blip
            if blip_type == "classic" and TBL_BLIPS and TBL_BLIPS.ClassicBlips then
                blip_data = TBL_BLIPS.ClassicBlips[blip_index]
            elseif blip_type == "entreprise" and TBL_BLIPS and TBL_BLIPS.Blips and TBL_BLIPS.Blips.Entreprise then
                blip_data = TBL_BLIPS.Blips.Entreprise[blip_index]
            end
            
            if blip_data then
                local blip_name = ""
                if blip_type == "classic" then
                    blip_name = blip_data.Label or ("Blip #" .. blip_index)
                else
                    blip_name = blip_data.name or ("Blip Entreprise #" .. blip_index)
                end
                
                RageUI.Separator("~b~" .. blip_name .. "~s~")
                
                -- Téléportation
                RageUI.Button("Se téléporter au blip", "Se téléporter aux coordonnées du blip", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        local coords = nil
                        if blip_type == "classic" then
                            coords = vector3(blip_data.X, blip_data.Y, blip_data.Z)
                        else
                            coords = vector3(blip_data.pos.x, blip_data.pos.y, blip_data.pos.z)
                        end
                        
                        if coords then
                            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
                            ESX.ShowNotification('Téléportation effectuée !')
                        end
                    end
                })
                
                -- Modification
                RageUI.Button("Modifier les informations", "Modifier les paramètres du blip", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        if blip_type == "classic" then
                            local input = lib.inputDialog("Modifier le blip classique", {
                                {type = 'input', label = 'Label du blip', description = 'Nom affiché sur le blip', required = true, min = 2, max = 50, default = blip_data.Label or ""},
                                {type = 'number', label = 'Sprite', description = 'Icône du blip (60=Police, 61=Hôpital, 108=Banque)', required = true, default = blip_data.Id or 1, min = 0, max = 826},
                                {type = 'number', label = 'Couleur', description = 'Couleur du blip (0-85)', required = true, default = blip_data.BColor or 1, min = 0, max = 85},
                                {type = 'input', label = 'Taille', description = 'Taille du blip (0.5 - 2.0)', required = true, default = tostring(blip_data.BSize or 0.8)},
                                {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z (ex: 425.13,-979.55,30.71)', required = true, icon = 'map-marker-alt', default = string.format("%.2f,%.2f,%.2f", blip_data.X or 0, blip_data.Y or 0, blip_data.Z or 0)},
                                {type = 'input', label = 'Job requis', description = 'Job requis (ALL pour tous)', required = true, default = blip_data.Job or 'ALL'},
                                {type = 'input', label = 'Job2 requis', description = 'Job2 requis (ALL pour tous)', required = true, default = blip_data.Job2 or 'ALL'},
                                {type = 'checkbox', label = 'Activer la zone', description = 'Afficher une zone autour du blip', default = blip_data.Area or false},
                                {type = 'input', label = 'Rayon de la zone', description = 'Rayon en mètres (si zone activée)', default = tostring(blip_data.ASize or 50.0)},
                                {type = 'number', label = 'Couleur zone', description = 'Couleur de la zone (0-85)', default = blip_data.AColor or 0, min = 0, max = 85}
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
                                
                                local blipData = {
                                    type = "classic",
                                    index = blip_index,
                                    data = {
                                        Label = input[1],
                                        Id = tonumber(input[2]) or 1,
                                        BColor = tonumber(input[3]) or 1,
                                        BSize = tonumber(input[4]) or 0.8,
                                        X = x,
                                        Y = y,
                                        Z = z,
                                        Job = input[6],
                                        Job2 = input[7],
                                        Area = input[8],
                                        ASize = input[8] and (tonumber(input[9]) or 50.0) or 0.0,
                                        AColor = input[8] and (tonumber(input[10]) or 0) or 0
                                    }
                                }
                                
                                CORE.trigger_server_callback("fafadev:to_server:update_blip", function(success)
                                    if success then
                                        ESX.ShowNotification('Blip modifié avec succès !')
                                        CORE.trigger_server_callback("fafadev:to_server:get_blips", function(blips)
                                            TBL_BLIPS = blips
                                            -- Mettre à jour le titre du sous-menu
                                            if blip_submenus[submenu_key] then
                                                blip_submenus[submenu_key].Title = input[1]
                                            end
                                        end)
                                    else
                                        ESX.ShowNotification('Erreur lors de la modification du blip')
                                    end
                                end, blipData)
                            end
                        else
                            local input = lib.inputDialog("Modifier le blip d'entreprise", {
                                {type = 'input', label = 'Nom du blip', description = 'Nom affiché sur le blip', required = true, min = 2, max = 50, default = blip_data.name or ""},
                                {type = 'number', label = 'Sprite', description = 'Icône du blip', required = true, default = blip_data.id or 1, min = 0, max = 826},
                                {type = 'number', label = 'Couleur', description = 'Couleur du blip (0-85)', required = true, default = blip_data.color or 1, min = 0, max = 85},
                                {type = 'input', label = 'Coordonnées', description = 'Format: x,y,z (ex: 425.13,-979.55,30.71)', required = true, icon = 'map-marker-alt', default = string.format("%.2f,%.2f,%.2f", blip_data.pos.x or 0, blip_data.pos.y or 0, blip_data.pos.z or 0)},
                                {type = 'input', label = 'Job requis', description = 'Job requis pour voir le blip', required = true, default = blip_data.job or ""}
                            })
                            if input then
                                local coordsData = string.split(input[4], ",")
                                if #coordsData ~= 3 then
                                    ESX.ShowNotification('Format de coordonnées invalide. Utilisez: x,y,z')
                                    return
                                end
                                
                                local x, y, z = tonumber(coordsData[1]), tonumber(coordsData[2]), tonumber(coordsData[3])
                                if not x or not y or not z then
                                    ESX.ShowNotification('Coordonnées invalides. Les valeurs doivent être des nombres')
                                    return
                                end
                                
                                local blipData = {
                                    type = "entreprise",
                                    index = blip_index,
                                    data = {
                                        name = input[1],
                                        id = tonumber(input[2]) or 1,
                                        color = tonumber(input[3]) or 1,
                                        pos = {x = x, y = y, z = z},
                                        job = input[5]
                                    }
                                }
                                
                                CORE.trigger_server_callback("fafadev:to_server:update_blip", function(success)
                                    if success then
                                        ESX.ShowNotification('Blip d\'entreprise modifié avec succès !')
                                        CORE.trigger_server_callback("fafadev:to_server:get_blips", function(blips)
                                            TBL_BLIPS = blips
                                            -- Mettre à jour le titre du sous-menu
                                            if blip_submenus[submenu_key] then
                                                blip_submenus[submenu_key].Title = input[1]
                                            end
                                        end)
                                    else
                                        ESX.ShowNotification('Erreur lors de la modification du blip d\'entreprise')
                                    end
                                end, blipData)
                            end
                        end
                    end
                })
                
                -- Suppression
                RageUI.Button("Supprimer le blip", "Supprimer définitivement ce blip", {RightLabel = "~r~Supprimer~s~"}, true, {
                    onSelected = function()
                        local confirm = lib.alertDialog({
                            header = 'Confirmation',
                            content = 'Êtes-vous sûr de vouloir supprimer le blip "' .. blip_name .. '" ?',
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
                            end, blip_type, blip_index)
                        end
                    end
                })
            end
        end)
    end
end

return blips_builder