zUI = exports["zUI-v2"]:getObject()

local current_ped_filter = 1
local current_animation_filter = 1
local current_prop_filter = 1

local obj_menu = zUI.CreateMenu("ToolsTraillers", "Outil de création cinématique", "Choisissez votre action", "default")
local obj_menu_player = zUI.CreateSubMenu(obj_menu, "Gestion du joueur", "Contrôles du personnage", "Téléportations, santé, invisibilité, animations...")
local obj_menu_vehicle = zUI.CreateSubMenu(obj_menu, "Véhicules", "Gestion des véhicules", "Spawn, customisation, enregistrement...")
local obj_menu_ped = zUI.CreateSubMenu(obj_menu, "PNJ", "Gestion des personnages non-joueurs", "Spawn de PNJ, comportements, animations...")
local obj_menu_props = zUI.CreateSubMenu(obj_menu, "Objets & Mapping", "Gestion des objets et mapping", "Props, placement, sauvegarde de scènes...")
local obj_menu_environment = zUI.CreateSubMenu(obj_menu, "Environnement", "Contrôle de l'environnement", "Météo, temps, gravité, filtres visuels...")
local obj_menu_editor = zUI.CreateSubMenu(obj_menu, "Rockstar Editor", "Fonctionnalités d'enregistrement", "Enregistrement, paramètres caméra...")

local obj_menu_ped_spawn = zUI.CreateSubMenu(obj_menu_ped, "Spawn PNJ", "Modèles de PNJ disponibles", "Spawn des différents modèles de PNJ")
local obj_menu_ped_behavior = zUI.CreateSubMenu(obj_menu_ped, "Comportements", "Comportements des PNJ", "Agressif, passif, garde du corps...")
local obj_menu_ped_equipment = zUI.CreateSubMenu(obj_menu_ped, "Équipements", "Armes et équipements", "Donner des armes et équipements aux PNJ")
local obj_menu_ped_groups = zUI.CreateSubMenu(obj_menu_ped, "Groupes", "Gestion des groupes", "Grouper des PNJ ensemble")

local obj_menu_props_list = zUI.CreateSubMenu(obj_menu_props, "Props Disponibles", "Liste des props", "Props disponibles via dépendances")
local obj_menu_props_scenes = zUI.CreateSubMenu(obj_menu_props, "Gestion Scènes", "Sauvegarde et chargement", "Gérer les scènes sauvegardées")
local obj_menu_props_tools = zUI.CreateSubMenu(obj_menu_props, "Outils Mapping", "Outils de placement", "Positionner et grouper les props")

local obj_menu_animations_player = zUI.CreateSubMenu(obj_menu_player, "Animations Joueur", "Animations du joueur", "Danses, gestes, poses...")

function OpenMainMenu()
    zUI.SetItems(obj_menu, function()
        zUI.Separator("ToolsTraillers", "center")
        zUI.Button("Gestion du joueur", "Téléportations, santé, invisibilité, animations...", {}, function(onSelected) end, obj_menu_player)
        zUI.Button("Véhicules", "Spawn, customisation, enregistrement...", {}, function(onSelected) end, obj_menu_vehicle)
        zUI.Button("PNJ", "Spawn de PNJ, comportements, animations...", {}, function(onSelected) end, obj_menu_ped)
        zUI.Button("Objets & Mapping", "Props, placement, sauvegarde de scènes...", {}, function(onSelected) end, obj_menu_props)
        zUI.Button("Environnement", "Météo, temps, gravité, filtres visuels...", {}, function(onSelected) end, obj_menu_environment)
        zUI.Button("Rockstar Editor", "Fonctionnalités d'enregistrement avancées", {}, function(onSelected) end, obj_menu_editor)
    end)
    
    zUI.SetVisible(obj_menu, true)
end

zUI.SetItems(obj_menu_player, function()
    zUI.Separator("Gestion du joueur", "center")
    zUI.Button("Téléportation Coords", "Téléportation vers des coordonnées", {}, function(onSelected)
        if onSelected then
            local input = lib.inputDialog('Téléportation', {
                {type = 'input', label = 'Coords (x,y,z)', required = true, default = '0.0,0.0,0.0'},
            })
            if input then
                local strCoords = input[1]
                local parts = {}
                for part in strCoords:gmatch("[^,]+") do
                    table.insert(parts, tonumber(part))
                end
                if #parts == 3 then
                    TeleportToCoords(parts[1], parts[2], parts[3])
                else
                    lib.notify({
                        title = 'ToolsTraillers',
                        description = 'Coords invalides',
                        type = 'error'
                    })
                end
            end
        end
    end)
    
    zUI.Button("Téléportation Waypoint", "Se téléporter vers le waypoint", {}, function(onSelected)
        if onSelected then
            TeleportToWaypoint()
        end
    end)
    
    zUI.Button("GoTo Joueur", "Aller vers un joueur par ID", {}, function(onSelected)
        if onSelected then
            local input = lib.inputDialog('GoTo Joueur', {
                {type = 'input', label = 'ID du joueur', required = true, default = '2', description = 'Entrez l\'ID du joueur cible'}
            })
            if input then
                local playerId = tonumber(input[1])
                if playerId then
                    GotoPlayer(playerId)
                else
                    lib.notify({
                        title = 'ToolsTraillers',
                        description = 'ID invalide',
                        type = 'error'
                    })
                end
            end
        end
    end)
    
    zUI.Button("Bring Joueur", "Amener un joueur vers vous par ID", {}, function(onSelected)
        if onSelected then
            local input = lib.inputDialog('Bring Joueur', {
                {type = 'input', label = 'ID du joueur', required = true, default = '2', description = 'Entrez l\'ID du joueur à amener'}
            })
            if input then
                local playerId = tonumber(input[1])
                if playerId then
                    BringPlayer(playerId)
                else
                    lib.notify({
                        title = 'ToolsTraillers',
                        description = 'ID invalide',
                        type = 'error'
                    })
                end
            end
        end
    end)    
-- Récupérer santé et armure actuelles
local ped = PlayerPedId()
local santeActuelle = GetEntityHealth(ped)
local armureActuelle = GetPedArmour(ped)

zUI.Button("Santé & Armure", "Régénérer santé ("..santeActuelle..") et armure ("..armureActuelle..")", {}, 
    function(onSelected)
        if onSelected then
            local input = lib.inputDialog('Santé & Armure', {
                {type = 'input', label = 'Santé', required = true, default = tostring(santeActuelle)},
                {type = 'input', label = 'Armure', required = true, default = tostring(armureActuelle)},
            })
            if input then
                local sante = tonumber(input[1])
                local armure = tonumber(input[2])

                if sante then
                    SetEntityHealth(ped, sante)
                else
                    lib.notify({
                        title = 'ToolsTraillers',
                        description = 'Valeur de santé invalide',
                        type = 'error'
                    })
                end

                if armure then
                    SetPedArmour(ped, armure)
                else
                    lib.notify({
                        title = 'ToolsTraillers',
                        description = 'Valeur d\'armure invalide',
                        type = 'error'
                    })
                end
            end
        end
    end
)

     zUI.Checkbox("No-clip", "Activer/désactiver le mode no-clip", GetNoclipState(), {}, function(onSelected, isChecked)
         if onSelected then
             ToggleNoclip()
         end
     end)
    zUI.Checkbox("Invisibilité", "Activer/désactiver l'invisibilité", GetInvisibilityState(), {}, function(onSelected, isChecked)
        if onSelected then
            ToggleInvisibility()
        end
    end)
    zUI.Button("Animations", "Danse, assis, gestes personnalisés", {}, function(onSelected) end, obj_menu_animations_player)
    zUI.Button("Arrêter Animation", "Arrêter l'animation en cours", {}, function(onSelected)
        if onSelected then
            StopAnimation()
        end
    end)
    zUI.Button("Slow Motion", "Ralentir le jeu (0.1x à 1.0x)", {}, function(onSelected)
        if onSelected then
            local input = lib.inputDialog('Slow Motion', {
                {type = 'slider', label = 'Vitesse', min = 0.1, max = 1.0, step = 0.05, default = currentTimeScale, description = '0.1 = très lent, 1.0 = normal'}
            })
            if input then
                local speed = tonumber(input[1])
                if speed then
                    SetSlowMotion(speed)
                    lib.notify({
                        title = 'ToolsTraillers',
                        description = 'Vitesse: ' .. speed .. 'x',
                        type = 'success'
                    })
                end
            end
        end
    end)
    
    if currentTimeScale ~= 1.0 then
        zUI.Button("Remettre Normal", "Remettre la vitesse normale (1.0x)", {}, function(onSelected)
            if onSelected then
                SetSlowMotion(1.0)
                lib.notify({
                    title = 'ToolsTraillers',
                    description = 'Vitesse normale restaurée',
                    type = 'info'
                })
            end
        end)
    end
end)

zUI.SetItems(obj_menu_vehicle, function()
    zUI.Separator("Véhicules", "center")
    zUI.Button("Spawn Véhicule", "Faire apparaître n'importe quel véhicule", {}, function(onSelected)
        if onSelected then
            local input = lib.inputDialog('Spawn Véhicule', {
                {type = 'input', label = 'Nom du véhicule', required = true, default = 'adder', description = 'Ex: adder, t20, sultan, zentorno...'}
            })
            if input then
                local vehicle = GetHashKey(input[1])
                SpawnVehicle(vehicle)
            end
        end
    end)
    zUI.Button("Customisation", "Couleurs, tuning, extras, liveries", {}, function(onSelected)end)
    zUI.Button("Réparer Véhicule", "Sélectionner et réparer un véhicule proche", {}, function(onSelected)
        if onSelected then
            RepairVehicle()
        end
    end)
    
    zUI.Button("Supprimer Véhicule", "Sélectionner et supprimer un véhicule proche", {}, function(onSelected)
        if onSelected then
            DeleteSelectedVehicle()
        end
    end)
    
    zUI.Button("Enregistrement Trajet", "Enregistrer et rejouer des trajets", {}, function(onSelected)
        if onSelected then
        end
    end)
    zUI.Button("Contrôle IA", "Poursuite, patrouille, stationnement", {}, function(onSelected)
        if onSelected then
        end
    end)
end)

zUI.SetItems(obj_menu_ped, function()
    zUI.Separator("PNJ", "center")
    zUI.Button("Spawn PNJ", "Modèles de PNJ disponibles", {}, function(onSelected) end, obj_menu_ped_spawn)
    zUI.Button("Comportements", "Agressif, passif, garde du corps...", {}, function(onSelected) end, obj_menu_ped_behavior)
    zUI.Button("Équipements", "Armes et équipements", {}, function(onSelected) end, obj_menu_ped_equipment)
    zUI.Button("Groupes", "Grouper des PNJ ensemble", {}, function(onSelected) end, obj_menu_ped_groups)
    
    zUI.Separator("Actions Rapides", "center")
    zUI.Button("Clone PNJ Face", "Cloner le PNJ face à moi", {}, function(onSelected)end)
    zUI.Button("Clone PNJ + Véhicule", "Cloner le PNJ avec son véhicule", {}, function(onSelected)end)
    zUI.Button("Sélectionner PNJ", "Sélectionner un PNJ proche", {}, function(onSelected)end)
end)

local function GetOptionsFromList(list)
    local options = {}
    for i, item in ipairs(list) do
        table.insert(options, {
            value = i,
            label = type(item) == 'table' and (item.name or item.label) or item
        })
    end
    return options
end

local function GetPedCategoryLabels()
    local labels = {}
    for _, category in ipairs(TB_PEDS.categories) do
        table.insert(labels, category.label)
    end
    return labels
end

zUI.SetItems(obj_menu_ped_spawn, function()
    zUI.Separator("Filtres", "center")
    
    zUI.List("Filtre PNJ", "Choisir la catégorie de PNJ à afficher", 
        GetPedCategoryLabels(), 
        current_ped_filter, {}, function(onSelected, onChange, index)
        if onChange then
            current_ped_filter = index
        end
    end)
    
    zUI.Line()
    
    local filteredPeds = TB_PEDS.filter_by_category(current_ped_filter)
    
    if #filteredPeds > 0 then
        zUI.Separator("PNJ Disponibles (" .. #filteredPeds .. ")", "center")
        
        for i, pedModel in ipairs(filteredPeds) do
            zUI.Button(pedModel, "Spawn ce PNJ", {}, function(onSelected)
                if onSelected then
                    SpawnPed(GetHashKey(pedModel))
                end
            end)
        end
    else
        zUI.Separator("Aucun PNJ dans cette catégorie", "center")
    end
    
    zUI.Separator("Recherche", "center")
    zUI.Button("Rechercher PNJ", "Rechercher un PNJ spécifique", {}, function(onSelected)
        if onSelected then
            local input = lib.inputDialog('Rechercher PNJ', {
                {type = 'input', label = 'Nom du PNJ', required = true, placeholder = 'Ex: a_m_m_golfer_01', description = 'Tapez le nom du PNJ à rechercher'}
            })
            if input then
                local searchTerm = string.lower(input[1])
                local found = false
                for _, pedData in ipairs(TB_PEDS.name) do
                    if string.find(string.lower(pedData.name), searchTerm) then
                        SpawnPed(GetHashKey(pedData.name))
                        found = true
                        break
                    end
                end
                if not found then
                    lib.notify({
                        title = 'ToolsTraillers',
                        description = 'PNJ non trouvé: ' .. input[1],
                        type = 'error'
                    })
                end
            end
        end
    end)
    
    zUI.Separator("Spawn Personnalisé", "center")
    zUI.Button("Spawn PNJ Personnalisé", "Faire apparaître un PNJ avec nom personnalisé", {}, function(onSelected)
        if onSelected then
            local input = lib.inputDialog('Spawn PNJ', {
                {type = 'input', label = 'Nom du PNJ', required = true, default = 'a_m_m_golfer_01', description = 'Ex: a_m_m_golfer_01, a_m_m_polynesian_01...'}
            })
            if input then
                local ped = GetHashKey(input[1])
                SpawnPed(ped)
            end
        end
    end)
end)

zUI.SetItems(obj_menu_ped_behavior, function()
    zUI.Separator("Comportements Disponibles", "center")
    zUI.Button("Agressif", "PNJ agressif qui attaque", {}, function(onSelected)end)
    zUI.Button("Passif", "PNJ passif et calme", {}, function(onSelected)end)
    zUI.Button("Garde du corps", "PNJ protecteur", {}, function(onSelected)end)
    zUI.Button("Fuyard", "PNJ qui fuit les combats", {}, function(onSelected)end)
    zUI.Button("Neutre", "PNJ neutre", {}, function(onSelected)end)
    zUI.Button("Ami", "PNJ amical", {}, function(onSelected)end)
    
    zUI.Separator("Comportements Avancés", "center")
    zUI.Button("Gang", "Comportement de gang", {}, function(onSelected)end)
    zUI.Button("Civil", "Comportement civil normal", {}, function(onSelected)end)
    zUI.Button("Police", "Comportement de police", {}, function(onSelected)end)
end)

zUI.SetItems(obj_menu_ped_equipment, function()
    zUI.Separator("Armes", "center")
    zUI.Button("Donner Arme", "Donner une arme au PNJ", {}, function(onSelected)end)
    zUI.Button("Retirer Armes", "Retirer toutes les armes", {}, function(onSelected)end)
    zUI.Button("Arme Aléatoire", "Donner une arme aléatoire", {}, function(onSelected)end)
    
    zUI.Separator("Équipements", "center")
    zUI.Button("Vêtements", "Changer les vêtements", {}, function(onSelected)end)
    zUI.Button("Accessoires", "Chapeaux, lunettes, etc.", {}, function(onSelected)end)
    zUI.Button("Armure", "Donner de l'armure", {}, function(onSelected)end)
end)

zUI.SetItems(obj_menu_ped_groups, function()
    zUI.Separator("Groupes Disponibles", "center")
    zUI.Button("Groupe de marche", "PNJ qui marchent ensemble", {}, function(onSelected)end)
    zUI.Button("Groupe de danse", "PNJ qui dansent ensemble", {}, function(onSelected)end)
    zUI.Button("Groupe de combat", "PNJ qui combattent ensemble", {}, function(onSelected)end)
    zUI.Button("Groupe de conversation", "PNJ qui discutent", {}, function(onSelected)end)
    
    zUI.Separator("Gestion Groupes", "center")
    zUI.Button("Créer Groupe", "Créer un nouveau groupe", {}, function(onSelected)end)
    zUI.Button("Ajouter au Groupe", "Ajouter PNJ au groupe", {}, function(onSelected)end)
    zUI.Button("Dissoudre Groupe", "Dissoudre le groupe sélectionné", {}, function(onSelected)end)
end)

zUI.SetItems(obj_menu_props, function()
    zUI.Separator("Objets & Mapping", "center")
    zUI.Button("Props Disponibles", "Liste des props via dépendances", {}, function(onSelected) end, obj_menu_props_list)
    zUI.Button("Gestion Scènes", "Sauvegarder et charger des scènes", {}, function(onSelected) end, obj_menu_props_scenes)
    zUI.Button("Outils Mapping", "Outils de placement et gestion", {}, function(onSelected) end, obj_menu_props_tools)
    
    zUI.Separator("Actions Rapides", "center")
    zUI.Button("Supprimer Props Proches", "Supprimer les props autour", {}, function(onSelected)end)
    zUI.Button("Désélectionner Tout", "Désélectionner tous les props", {}, function(onSelected)end)
    zUI.Button("Reset Position", "Remettre les props à leur position", {}, function(onSelected)end)
end)


local function GetPropCategoryLabels()
    local labels = {}
    for _, category in ipairs(TB_PROPS.categories) do
        table.insert(labels, category.label)
    end
    return labels
end

zUI.SetItems(obj_menu_props_list, function()
    zUI.Separator("Filtres", "center")
    
    zUI.List("Filtre Props", "Choisir la catégorie de props à afficher", 
        GetPropCategoryLabels(), 
        current_prop_filter, {}, function(onSelected, onChange, index)
        if onChange then
            current_prop_filter = index
        end
    end)
    
    zUI.Line()
    
    local filteredProps = TB_PROPS.filter_by_category(current_prop_filter)
    
    if #filteredProps > 0 then
        zUI.Separator("Props Disponibles (" .. #filteredProps .. ")", "center")
        
        for i, propModel in ipairs(filteredProps) do
            zUI.Button(propModel, "Utiliser cette dépendance", {}, function(onSelected)
                if onSelected then
                    lib.notify({
                        title = 'ToolsTraillers',
                        description = 'Prop: ' .. propModel .. ' (nécessite une dépendance)',
                        type = 'info'
                    })
                end
            end)
        end
    else
        zUI.Separator("Aucun prop dans cette catégorie", "center")
    end
    
    zUI.Separator("Recherche", "center")
    zUI.Button("Rechercher Prop", "Rechercher un prop spécifique", {}, function(onSelected)
        if onSelected then
            local input = lib.inputDialog('Rechercher Prop', {
                {type = 'input', label = 'Nom du prop', required = true, placeholder = 'Ex: bench, chair, table', description = 'Tapez le nom du prop à rechercher'}
            })
            if input then
                local searchTerm = string.lower(input[1])
                local found = false
                for _, propData in ipairs(TB_PROPS.name) do
                    if string.find(string.lower(propData.name), searchTerm) then
                        lib.notify({
                            title = 'ToolsTraillers',
                            description = 'Prop trouvé: ' .. propData.name,
                            type = 'success'
                        })
                        found = true
                        break
                    end
                end
                if not found then
                    lib.notify({
                        title = 'ToolsTraillers',
                        description = 'Prop non trouvé: ' .. input[1],
                        type = 'error'
                    })
                end
            end
        end
    end)
    
    zUI.Button("Sélectionner Prop", "Sélectionner un prop dans la liste", {}, function(onSelected)
        if onSelected then
            local input = lib.inputDialog('Sélectionner Prop', {
                {type = 'select', label = 'Prop', options = GetOptionsFromList(filteredProps), default = 1, required = true}
            })
            if input then
                local selectedIndex = input[1]
                local selectedProp = filteredProps[selectedIndex]
                lib.notify({
                    title = 'ToolsTraillers',
                    description = 'Prop sélectionné: ' .. selectedProp,
                    type = 'success'
                })
            end
        end
    end)
    
    zUI.Separator("Informations", "center")
    zUI.Button("Guide Props", "Comment utiliser les props", {}, function(onSelected)end)
    zUI.Button("Liste Complète", "Voir tous les props disponibles", {}, function(onSelected)end)
    zUI.Button("Ajouter Prop", "Ajouter un nouveau prop à la liste", {}, function(onSelected)
        if onSelected then
            local input = lib.inputDialog('Ajouter Prop', {
                {type = 'input', label = 'Nom du prop', required = true, placeholder = 'Ex: prop_new_item', description = 'Nom du nouveau prop à ajouter'}
            })
            if input then
                lib.notify({
                    title = 'ToolsTraillers',
                    description = 'Prop ajouté: ' .. input[1] .. ' (nécessite redémarrage)',
                    type = 'success'
                })
            end
        end
    end)
end)

zUI.SetItems(obj_menu_props_scenes, function()
    zUI.Separator("Gestion Scènes", "center")
    zUI.Button("Sauvegarder Scène", "Sauvegarder la scène actuelle", {}, function(onSelected)end)
    zUI.Button("Charger Scène", "Charger une scène sauvegardée", {}, function(onSelected)end)
    zUI.Button("Supprimer Scène", "Supprimer une scène", {}, function(onSelected)end)
    
    zUI.Separator("Gestion Avancée", "center")
    zUI.Button("Exporter Scène", "Exporter la scène en fichier", {}, function(onSelected)end)
    zUI.Button("Importer Scène", "Importer une scène depuis fichier", {}, function(onSelected)end)
    zUI.Button("Dupliquer Scène", "Dupliquer la scène actuelle", {}, function(onSelected)end)
end)

zUI.SetItems(obj_menu_props_tools, function()
    zUI.Separator("Placement", "center")
    zUI.Button("Position Props", "Ajuster position/rotation des props", {}, function(onSelected)end)
    zUI.Button("Alignement", "Aligner les props", {}, function(onSelected)end)
    zUI.Button("Mesure Distance", "Mesurer les distances", {}, function(onSelected)end)
    
    zUI.Separator("Gestion", "center")
    zUI.Button("Grouper Props", "Grouper des props ensemble", {}, function(onSelected)end)
    zUI.Button("Dupliquer Props", "Dupliquer un prop sélectionné", {}, function(onSelected)end)
    zUI.Button("Supprimer Sélection", "Supprimer les props sélectionnés", {}, function(onSelected)end)
    
    zUI.Separator("Outils Avancés", "center")
    zUI.Button("Snap to Grid", "Aligner sur une grille", {}, function(onSelected)end)
    zUI.Button("Mirror Props", "Miroir des props", {}, function(onSelected)end)
    zUI.Button("Randomize", "Randomiser position/rotation", {}, function(onSelected)end)
end)

zUI.SetItems(obj_menu_environment, function()
    zUI.Separator("Environnement", "center")
    zUI.Button("Météo", "Pluie, soleil, brouillard, neige", {}, function(onSelected)end)
    zUI.Button("Heure Dynamique", "Fixer, accélérer, ralentir le temps", {}, function(onSelected)end)
    zUI.Button("Gravité", "Modifier la gravité du monde", {}, function(onSelected)end)
    zUI.Button("Densité PNJ/Véhicules", "Ajuster la densité de population", {}, function(onSelected)
    end)
    zUI.Button("Filtres Visuels", "Timecycle, noir et blanc, ambiance cinéma", {}, function(onSelected)
    end)
    
    zUI.Separator("Slow Motion", "center")
    
    zUI.Button("Slow Motion Précise", "Ajuster précisément le ralentissement (0.1x à 1.0x)", {}, function(onSelected)
        if onSelected then
            local input = lib.inputDialog('Slow Motion Précise', {
                {type = 'slider', label = 'Vitesse', min = 0.1, max = 1.0, step = 0.05, default = currentTimeScale, description = 'Contrôle précis du ralentissement'}
            })
            if input then
                local speed = tonumber(input[1])
                if speed then
                    SetSlowMotion(speed)
                    lib.notify({
                        title = 'ToolsTraillers',
                        description = 'Vitesse: ' .. speed .. 'x',
                        type = 'success'
                    })
                end
            end
        end
    end)
    
    zUI.Button("Vitesses Prédéfinies", "Vitesses de ralentissement pour effets courants", {}, function(onSelected)
        if onSelected then
            local input = lib.inputDialog('Vitesses de Slow Motion', {
                {type = 'select', label = 'Vitesse', options = {
                    {value = 0.1, label = 'Très Lent (0.1x) - Effets ultra lents'},
                    {value = 0.25, label = 'Lent (0.25x) - Scènes dramatiques'},
                    {value = 0.5, label = 'Slow Motion (0.5x) - Classique cinéma'},
                    {value = 0.75, label = 'Lent Normal (0.75x) - Légèrement ralenti'},
                    {value = 1.0, label = 'Normal (1.0x) - Vitesse normale'}
                }, default = currentTimeScale}
            })
            if input then
                local speed = tonumber(input[1])
                if speed then
                    SetSlowMotion(speed)
                    lib.notify({
                        title = 'ToolsTraillers',
                        description = 'Vitesse: ' .. speed .. 'x',
                        type = 'success'
                    })
                end
            end
        end
    end)
end)

zUI.SetItems(obj_menu_editor, function()
    zUI.Separator("Rockstar Editor", "center")
    zUI.Button("Démarrer Enregistrement", "Commencer l'enregistrement de la scène", {}, function(onSelected) end)
    zUI.Button("Arrêter Enregistrement", "Arrêter l'enregistrement en cours", {}, function(onSelected)end)
    zUI.Button("Paramètres Caméra", "Configurer les paramètres de caméra", {}, function(onSelected)end)
end)


local function GetAnimationCategoryLabels()
    local labels = {}
    for _, category in ipairs(TB_ANIMATIONS.categories) do
        table.insert(labels, category.label)
    end
    return labels
end

zUI.SetItems(obj_menu_animations_player, function()
    zUI.Separator("Filtres", "center")
    
    zUI.List("Filtre Animation", "Choisir le type d'animation à afficher", 
        GetAnimationCategoryLabels(), 
        current_animation_filter, {}, function(onSelected, onChange, index)
        if onChange then
            current_animation_filter = index
        end
    end)
    
    zUI.Line()
    
    local filteredAnims = TB_ANIMATIONS.filter_by_category(current_animation_filter)
    
    if #filteredAnims > 0 then
        zUI.Separator("Animations Disponibles (" .. #filteredAnims .. ")", "center")
        
        for i, animData in ipairs(filteredAnims) do
            local animType = animData.category or "Inconnu"
            local duration = animData.duration and (animData.duration == -1 and "∞" or (animData.duration/1000) .. "s") or "N/A"
            zUI.Button(animData.name, "Type: " .. animType .. " | Durée: " .. duration, {}, function(onSelected)
                if onSelected then
                    PlayAnimationFromConfig(animData)
                end
            end)
        end
    else
        zUI.Separator("Aucune animation dans cette catégorie", "center")
    end
    
    zUI.Separator("Recherche", "center")
    zUI.Button("Rechercher Animation", "Rechercher une animation spécifique", {}, function(onSelected)
        if onSelected then
            local input = lib.inputDialog('Rechercher Animation', {
                {type = 'input', label = 'Nom de l\'animation', required = true, placeholder = 'Ex: danse, salut, marche', description = 'Tapez le nom de l\'animation à rechercher'}
            })
            if input then
                local searchTerm = string.lower(input[1])
                local found = false
                for _, animData in ipairs(TB_ANIMATIONS.name) do
                    if string.find(string.lower(animData.name), searchTerm) or string.find(string.lower(animData.category), searchTerm) then
                        PlayAnimationFromConfig(animData)
                        found = true
                        break
                    end
                end
                if not found then
                    lib.notify({
                        title = 'ToolsTraillers',
                        description = 'Animation non trouvée: ' .. input[1],
                        type = 'error'
                    })
                end
            end
        end
    end)
    
    zUI.Separator("Animations Rapides", "center")
    for i, animData in ipairs(TB_ANIMATIONS.name) do
        if i <= 8 then
            local duration = animData.duration and (animData.duration == -1 and "∞" or (animData.duration/1000) .. "s") or "N/A"
            zUI.Button(animData.name, animData.category .. " | " .. duration, {}, function(onSelected)
                if onSelected then
                    PlayAnimationFromConfig(animData)
                end
            end)
        end
    end
    zUI.Separator("Gestion", "center")
    zUI.Button("Arrêter Animation", "Arrêter l'animation actuelle", {}, function(onSelected)
        if onSelected then
            StopAnimation()
        end
    end)
    zUI.Button("Animation Personnalisée", "Saisir une animation personnalisée", {}, function(onSelected)
        if onSelected then
            local input = lib.inputDialog('Animation Personnalisée', {
                {type = 'input', label = 'Dictionnaire', required = true, placeholder = 'Ex: anim@amb@nightclub@dancers@', description = 'Nom du dictionnaire d\'animation'},
                {type = 'input', label = 'Animation', required = true, placeholder = 'Ex: hi_dance_facedj_11_v1_male^3', description = 'Nom de l\'animation'}
            })
            if input then
                local dict = input[1]
                local anim = input[2]
                local duration = input[3] or -1
                PlayAnimation(dict, anim, duration)
            end
        end
    end)
end)

RegisterCommand('toolstraillers', function()
    OpenMainMenu()
end, false)

