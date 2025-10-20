-- Variables globales
bool_in_dance = false
local animation_cache = {}

-- Fonction pour charger les dictionnaires d'animations
local loaded_anim_dicts = {}
local function LoadAnimDict(dict)
    if loaded_anim_dicts[dict] then
        return true
    end
    
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        local timeout = 0
        while not HasAnimDictLoaded(dict) and timeout < 100 do
            Wait(10)
            timeout = timeout + 1
        end
    end
    
    loaded_anim_dicts[dict] = true
    return true
end

-- Fonction pour trouver une animation par ID (globale)
function find_animation_by_id(anim_id)
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

-- Fonction pour gérer les interactions avec les points de pole dance
function FUN_HANDLE_POLE_DANCE(pole_dance_locations)
    AddTickHandler("pole_dance", 0, function()
        local playerCoords = GetEntityCoords(PlayerPedId())
        local currentTime = GetGameTimer()
        local markerNear = false
        local xPlayer = ESX.GetPlayerData()
        local playerJob = xPlayer and xPlayer.job and xPlayer.job.name or nil
        local playerGrade = xPlayer and xPlayer.job and xPlayer.job.grade or 0
        
        for name, data in pairs(pole_dance_locations) do
            if FUN_CHECK_POLE_DANCE_ACCESS(data, playerJob, playerGrade) then
                for _, coord in pairs(data.coords) do
                    local distance = #(playerCoords - vector3(coord.x, coord.y, coord.z))
                    if distance < 10.0 then
                        markerNear = true
                        -- Vérifier si le marqueur doit être dessiné
                        if data.drawmarker ~= false then
                            DrawCustomMarker(coord.x, coord.y, coord.z)
                        end
                        if distance < 2.0 then
                            ESX.ShowHelpNotification(data.message)
                            if IsControlJustPressed(0, 38) then
                                openPoleDanceMenu(data)
                            end
                        end
                    end
                end
            end
        end
        if not markerNear then
            SetIntervalEnabled(false, "pole_dance")
        else
            SetIntervalEnabled(true, "pole_dance")
        end
    end)
end

-- Fonction pour vérifier l'accès aux points de pole dance
function FUN_CHECK_POLE_DANCE_ACCESS(poleDanceData, playerJob, playerGrade)
    if poleDanceData.jobAccess and #poleDanceData.jobAccess > 0 then
        local hasJobAccess = false
        for _, job in pairs(poleDanceData.jobAccess) do
            if playerJob == job then
                hasJobAccess = true
                break
            end
        end
        if not hasJobAccess then
            return false
        end
    end
    
    if poleDanceData.gradeAccess and #poleDanceData.gradeAccess > 0 then
        local hasGradeAccess = false
        for _, grade in pairs(poleDanceData.gradeAccess) do
            if playerGrade >= grade then
                hasGradeAccess = true
                break
            end
        end
        if not hasGradeAccess then
            return false
        end
    end
    
    return true
end

-- Fonction pour démarrer une danse (globale)
function start_poledance(anim_id)
    if bool_in_dance then
        ESX.ShowNotification("~r~Vous dansez déjà !")
        return
    end

    local animation = find_animation_by_id(anim_id)
    if not animation then
        ESX.ShowNotification("~r~Animation non valide")
        return
    end

    bool_in_dance = true
    ESX.ShowNotification("~g~Vous avez commencé à danser")
    CORE.trigger_server_event('fCore:poledance:start', GetPlayerServerId(PlayerId()), anim_id)
end

-- Fonction pour arrêter une danse (globale)
function stop_poledance()
    if not bool_in_dance then
        ESX.ShowNotification("~r~Vous ne dansez pas actuellement")
        return
    end

    bool_in_dance = false
    ESX.ShowNotification("~y~Vous avez arrêté de danser")
    CORE.trigger_server_event('fCore:poledance:stop')  
end

-- Événements clients
CORE.register_client_event('fCore:poledance:play', function(sourceId, animIndex)
    if not sourceId or not animIndex then
        return
    end

    local myServerId = GetPlayerServerId(PlayerId())
    local ped

    if myServerId == sourceId then
        ped = PlayerPedId()
    else
        local player = GetPlayerFromServerId(sourceId)
        if player == -1 then 
            return 
        end
        ped = GetPlayerPed(player)
    end

    local anim = find_animation_by_id(animIndex)
    if not anim then 
        return 
    end

    if not LoadAnimDict(anim.dict) then
        return
    end
    
    local finalCoords = GetEntityCoords(ped)
    SetEntityCoords(ped, finalCoords.x, finalCoords.y, finalCoords.z, false, false, false, true)
    
    local currentHeading = GetEntityHeading(ped)
    SetEntityHeading(ped, currentHeading)
    
    local scene = NetworkCreateSynchronisedScene(
        finalCoords.x, finalCoords.y, finalCoords.z, 
        0.0, 0.0, 0.0, 
        2, false, true, 1065353216, 0, 1.3
    )
    
    NetworkAddPedToSynchronisedScene(
        ped, scene, anim.dict, anim.anim, 
        1.5, -4.0, 1, 1, 1148846080, 0
    )
    
    NetworkStartSynchronisedScene(scene)
end)

CORE.register_client_event('fCore:poledance:stop_client', function()
    ClearPedTasksImmediately(PlayerPedId())
    bool_in_dance = false
end)
