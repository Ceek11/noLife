local incapacity_active = false
local attached_props = {}
local incapacity_end_time = 0
local incapacity_level = 0
local incapacity_threads = {}
local incapacity_display_thread = nil

-- Fonction utilitaire pour charger les animations
local function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(0)
        end
    end
end

-- Fonction de nettoyage améliorée
local function cleanupIncapacity()
    local playerPed = PlayerPedId()
    local playerId = PlayerId()
    
    -- Nettoyer les props
    if attached_props[playerId] then
        DeleteEntity(attached_props[playerId])
        attached_props[playerId] = nil
    end
    
    -- Arrêter tous les threads d'incapacité
    for _, thread in pairs(incapacity_threads) do
        if thread then
            thread = nil
        end
    end
    incapacity_threads = {}
    
    -- Réinitialiser le joueur
    ClearPedTasks(playerPed)
    ResetPedMovementClipset(playerPed, 0)
    ResetPedWeaponMovementClipset(playerPed)
    ResetPedStrafeClipset(playerPed)
    
    -- Réinitialiser les variables
    incapacity_active = false
    incapacity_end_time = 0
    incapacity_level = 0
    
    -- Arrêter le thread d'affichage
    if incapacity_display_thread then
        incapacity_display_thread = nil
    end
end

local function startIncapacityDisplay()
    if incapacity_display_thread then return end
    
    incapacity_display_thread = Citizen.CreateThread(function()
        while incapacity_active and incapacity_end_time > 0 do
            local timeLeft = math.ceil((incapacity_end_time - GetGameTimer()) / 1000)
            if timeLeft > 0 then
                local minutes = math.floor(timeLeft / 60)
                local seconds = timeLeft % 60
                
                SetTextFont(4)
                SetTextProportional(false)
                SetTextScale(0.5, 0.5)
                SetTextColour(255, 0, 0, 255)
                SetTextDropShadow()
                SetTextEdge(1, 0, 0, 0, 255)
                SetTextOutline()
                SetTextEntry("STRING")
                AddTextComponentString("~r~Incapacité Niveau " .. incapacity_level .. " - Temps restant: " .. string.format("%02d:%02d", minutes, seconds))
                DrawText(0.5, 0.05)
            else
                cleanupIncapacity()
                ESX.ShowNotification("~g~Votre incapacité a expiré")
                break
            end
            Wait(1000)
        end
        incapacity_display_thread = nil
    end)
end

RegisterNetEvent("fafadev:incapacity")
AddEventHandler("fafadev:incapacity", function(lvl)
    local incapacityData = CONFIG_INCAPACITY[lvl]
    if not incapacityData then return end

    local combat = incapacityData.combat or true
    local jump = incapacityData.jump or true
    local drive = incapacityData.drive or true
    local run = incapacityData.run or true
    local animation = incapacityData.animation or "move_m@injured"
    local time = incapacityData.time or 20
    local props = incapacityData.props or false
    local delete = incapacityData.delete or false
    local playerPed = PlayerPedId()

    if delete then 
        cleanupIncapacity()
        ESX.ShowNotification("~g~Votre incapacité a été supprimée")
        return
    end

    incapacity_active = true
    incapacity_level = lvl
    incapacity_end_time = GetGameTimer() + (time * 1000)
    TriggerServerEvent("fafadev:addIncapacity", time, lvl)
    ESX.ShowNotification("~r~Vous êtes maintenant en incapacité niveau " .. lvl)

    -- Thread pour désactiver le combat
    if combat then
        table.insert(incapacity_threads, Citizen.CreateThread(function()
            while incapacity_active do
                Wait(0)
                DisableControlAction(0, 24, true) -- Attaque
                DisableControlAction(0, 25, true) -- Viser
                DisableControlAction(0, 37, true) -- Sélecteur d'arme
                DisablePlayerFiring(PlayerId(), true)
                if IsControlJustPressed(0, 24) or IsControlJustPressed(0, 25) then
                    ESX.ShowNotification("~r~Vous ne pouvez pas combattre en étant en incapacité")
                end
            end
        end))
    end

    -- Thread pour désactiver le saut
    if jump then
        table.insert(incapacity_threads, Citizen.CreateThread(function()
            while incapacity_active do
                Wait(0)
                DisableControlAction(0, 22, true) -- Sauter
                if IsControlJustPressed(0, 22) then
                    ESX.ShowNotification("~r~Vous ne pouvez pas sauter en étant en incapacité")
                end
            end
        end))
    end

    -- Thread pour désactiver la conduite
    if drive then
        table.insert(incapacity_threads, Citizen.CreateThread(function()
            while incapacity_active do
                Wait(0)
                DisableControlAction(0, 71, true) -- Accélérer
                DisableControlAction(0, 72, true) -- Freiner
                DisableControlAction(0, 59, true) -- Direction
                if IsControlJustPressed(0, 71) or IsControlJustPressed(0, 72) then
                    ESX.ShowNotification("~r~Vous ne pouvez pas conduire en étant en incapacité")
                end
            end
        end))
    end

    -- Thread pour désactiver la course
    if run then
        table.insert(incapacity_threads, Citizen.CreateThread(function()
            while incapacity_active do
                Wait(0)
                DisableControlAction(0, 21, true) -- Courir
                if IsControlJustPressed(0, 21) then
                    ESX.ShowNotification("~r~Vous ne pouvez pas courir en étant en incapacité")
                end
            end
        end))
    end

    if props then 
        local propName = "prop_cs_walking_stick"
        RequestModel(GetHashKey(propName))
        while not HasModelLoaded(GetHashKey(propName)) do
            Citizen.Wait(0)
        end

        local playerCoords = GetEntityCoords(playerPed)
        local walkingStickProp = CreateObject(GetHashKey(propName), playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
        AttachEntityToEntity(walkingStickProp, playerPed, GetPedBoneIndex(playerPed, 57005), 0.12, 0.0, -0.02, 0.0, 270.0, 0.0, true, true, false, true, 1, true)
        attached_props[PlayerId()] = walkingStickProp
    end

    -- Thread pour l'animation de mouvement
    if animation then 
        table.insert(incapacity_threads, Citizen.CreateThread(function()
            LoadAnimDict(animation)
            
            SetPedMovementClipset(playerPed, animation, 1.0)
            SetPedWeaponMovementClipset(playerPed, animation)
            SetPedStrafeClipset(playerPed, animation)
            
            while incapacity_active do
                Citizen.Wait(0)
                if not IsPedRagdoll(playerPed) and not IsPedFalling(playerPed) then
                    SetPedMovementClipset(playerPed, animation, 1.0)
                end
            end
        end))
    end

    -- Timer pour l'expiration automatique (en minutes)
    if time and time > 0 then
        Citizen.SetTimeout(time * 60 * 1000, function()
            cleanupIncapacity()
            ESX.ShowNotification("~g~Votre incapacité a expiré")
        end)
    end

    startIncapacityDisplay()
end)

RegisterNetEvent("fafadev:checkIncapacity")
AddEventHandler("fafadev:checkIncapacity", function(incapacityData)
    if not incapacityData then return end
    
    local timeLeft = incapacityData.time - os.time()
    if timeLeft > 0 then
        -- Calculer le temps restant en millisecondes pour l'affichage
        local timeLeftMs = timeLeft * 1000
        incapacity_active = true
        incapacity_level = incapacityData.lvl
        incapacity_end_time = GetGameTimer() + timeLeftMs
        
        -- Redémarrer l'incapacité avec le temps restant
        TriggerEvent("fafadev:incapacity", incapacityData.lvl)
        ESX.ShowNotification("~r~Votre incapacité est toujours active (" .. math.ceil(timeLeft/60) .. " min restantes)")
    else
        TriggerServerEvent("fafadev:removeIncapacity", GetPlayerServerId(PlayerId()), 5)
    end
end)

Citizen.CreateThread(function()
    Wait(5000)
    TriggerServerEvent("fafadev:checkPlayerIncapacity")
end)

RegisterNetEvent("fafadev:startIncapacityDisplay")
AddEventHandler("fafadev:startIncapacityDisplay", function(level, timeLeft)
    incapacity_active = true
    incapacity_level = level
    incapacity_end_time = GetGameTimer() + (timeLeft * 1000)
    startIncapacityDisplay()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    cleanupIncapacity()
end)