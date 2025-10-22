-- Variables globales
local str_file_location = 'data/pole_dance.json'
TBL_POLE_DANCE = {}

-- Fonction pour charger les données de pole dance
function FUN_LOAD_POLE_DANCE()
    print("^2[POLE DANCE]^7 Chargement des données...")
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), str_file_location)
    print("^2[POLE DANCE]^7 Contenu du fichier: " .. tostring(str_file_content ~= nil))
    
    if str_file_content then
        local tbl_pole_dance = json.decode(str_file_content)
        print("^2[POLE DANCE]^7 Données décodées: " .. tostring(tbl_pole_dance ~= nil))
        
        if tbl_pole_dance then
            print("^2[POLE DANCE]^7 Nombre d'éléments: " .. #tbl_pole_dance)
            -- Le JSON est un tableau d'objets, on les convertit en clés numériques
            TBL_POLE_DANCE = {}
            for i, data in ipairs(tbl_pole_dance) do
                local key = "pole_dance_" .. i
                TBL_POLE_DANCE[key] = data
                print("^2[POLE DANCE]^7 Ajouté: " .. key .. " - " .. tostring(data.label))
            end
            print("^2[POLE DANCE]^7 Total chargé: " .. tostring(TBL_POLE_DANCE and #TBL_POLE_DANCE or 0))
        end
    else
        print("^1[POLE DANCE]^7 Erreur: Impossible de charger le fichier")
    end
end

-- Charger les données au démarrage
FUN_LOAD_POLE_DANCE()

-- Cache pour les animations
local animation_cache = {}

-- Fonction pour trouver une animation par ID
local function find_animation_by_id(anim_id)
    if animation_cache[anim_id] then
        return animation_cache[anim_id]
    end
    
    for _, anim in ipairs(TBL_POLE_DANCE_ANIMATIONS) do
        if anim.id == anim_id then
            animation_cache[anim_id] = anim
            return anim
        end
    end
    return nil
end

-- Callback pour récupérer les données de pole dance
CORE.register_server_callback("fafadev:to_server:get_pole_dance", function(source, cb)
    print("^2[POLE DANCE]^7 Demande de données depuis le client " .. source)
    print("^2[POLE DANCE]^7 TBL_POLE_DANCE contient " .. tostring(TBL_POLE_DANCE and #TBL_POLE_DANCE or 0) .. " éléments")
    
    -- Afficher le contenu de TBL_POLE_DANCE
    for key, value in pairs(TBL_POLE_DANCE) do
        print("^2[POLE DANCE]^7 Clé: " .. key .. " - Label: " .. tostring(value.label))
    end
    
    cb(TBL_POLE_DANCE)
end)

-- Événements serveur
CORE.register_server_event('fCore:poledance:start', function(sourceId, animIndex)
    if not sourceId or not animIndex then
        return
    end
    
    local xPlayer = ESX.GetPlayerFromId(sourceId)
    if not xPlayer then 
        return 
    end
    
    local animation = find_animation_by_id(animIndex)
    if not animation then
        xPlayer.showNotification('~r~Animation non valide')
        return
    end

    CORE.trigger_client_event('fCore:poledance:play', -1, sourceId, animIndex)
end)

CORE.register_server_event('fCore:poledance:stop', function(sourceId)
    local xPlayer = ESX.GetPlayerFromId(sourceId)
    if not xPlayer then 
        return 
    end
    
    CORE.trigger_client_event('fCore:poledance:stop_client', sourceId)
end)

-- Callbacks pour l'admin
CORE.register_server_callback("fafadev:to_server:create_pole_dance", function(source, cb, poleDanceData)
    if not poleDanceData or not poleDanceData.label or not poleDanceData.coords or not poleDanceData.animations then
        cb(false)
        return
    end
    
    -- Charger les données existantes
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), str_file_location)
    local tbl_pole_dance = {}
    if str_file_content then
        tbl_pole_dance = json.decode(str_file_content)
    end
    
    -- Ajouter le nouveau pole dance
    table.insert(tbl_pole_dance, poleDanceData)
    
    -- Sauvegarder dans le fichier
    local success = SaveResourceFile(GetCurrentResourceName(), str_file_location, json.encode(tbl_pole_dance, {indent = true}), -1)
    if success then
        -- Recharger les données
        FUN_LOAD_POLE_DANCE()
        -- Rafraîchir automatiquement les pole dance pour tous les joueurs
        CORE.trigger_client_callback("fafadev:to_client:refresh_pole_dance", -1, function() end, TBL_POLE_DANCE)
        cb(true)
    else
        cb(false)
    end
end)

CORE.register_server_callback("fafadev:to_server:update_pole_dance", function(source, cb, poleDanceKey, poleDanceData)
    if not poleDanceKey or not poleDanceData then
        cb(false)
        return
    end
    
    -- Vérifier si le pole dance existe dans TBL_POLE_DANCE
    if not TBL_POLE_DANCE[poleDanceKey] then
        cb(false)
        return
    end
    
    -- Extraire l'index du nom de la clé (pole_dance_1 -> 1)
    local index = tonumber(poleDanceKey:match("pole_dance_(%d+)"))
    if not index then
        cb(false)
        return
    end
    
    -- Charger les données existantes
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), str_file_location)
    if not str_file_content then
        cb(false)
        return
    end
    
    local tbl_pole_dance = json.decode(str_file_content)
    if not tbl_pole_dance or not tbl_pole_dance[index] then
        cb(false)
        return
    end
    
    -- Modifier le pole dance
    tbl_pole_dance[index] = poleDanceData
    
    -- Sauvegarder dans le fichier
    local success = SaveResourceFile(GetCurrentResourceName(), str_file_location, json.encode(tbl_pole_dance, {indent = true}), -1)
    if success then
        -- Recharger les données
        FUN_LOAD_POLE_DANCE()
        -- Rafraîchir automatiquement les pole dance pour tous les joueurs
        CORE.trigger_client_callback("fafadev:to_client:refresh_pole_dance", -1, function() end, TBL_POLE_DANCE)
        cb(true)
    else
        cb(false)
    end
end)

CORE.register_server_callback("fafadev:to_server:delete_pole_dance", function(source, cb, poleDanceKey)
    if not poleDanceKey then
        cb(false)
        return
    end
    
    -- Vérifier si le pole dance existe dans TBL_POLE_DANCE
    if not TBL_POLE_DANCE[poleDanceKey] then
        cb(false)
        return
    end
    
    -- Extraire l'index du nom de la clé (pole_dance_1 -> 1)
    local index = tonumber(poleDanceKey:match("pole_dance_(%d+)"))
    if not index then
        cb(false)
        return
    end
    
    -- Charger les données existantes
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), str_file_location)
    if not str_file_content then
        cb(false)
        return
    end
    
    local tbl_pole_dance = json.decode(str_file_content)
    if not tbl_pole_dance or not tbl_pole_dance[index] then
        cb(false)
        return
    end
    
    -- Supprimer le pole dance
    table.remove(tbl_pole_dance, index)
    
    -- Sauvegarder dans le fichier
    local success = SaveResourceFile(GetCurrentResourceName(), str_file_location, json.encode(tbl_pole_dance, {indent = true}), -1)
    if success then
        -- Recharger les données
        FUN_LOAD_POLE_DANCE()
        -- Rafraîchir automatiquement les pole dance pour tous les joueurs
        CORE.trigger_client_callback("fafadev:to_client:refresh_pole_dance", -1, function() end, TBL_POLE_DANCE)
        cb(true)
    else
        cb(false)
    end
end)


