local ANIM_CONFIG = {
    POINTING = {
        dict = "anim@mp_point",
        name = "task_mp_pointing",
        flag = 36,
        blendIn = 0.5,
        flags = 24
    },
    HANDS_UP = {
        dict = "missminuteman_1ig_2",
        name = "handsup_enter",
        blendIn = 8.0,
        blendOut = 8.0,
        duration = -1,
        flag = 50
    },
    CROUCH = {
        clipset = "move_ped_crouched",
        blendIn = 0.25,
        blendOut = 0.5
    }
}

local animationStates = {
    pointing = false,
    handsUp = false,
    crouched = false
}

local function loadAnimDict(dict, timeout)
    timeout = timeout or 5000
    local startTime = GetGameTimer()
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) and (GetGameTimer() - startTime) < timeout do
        Citizen.Wait(100)
    end
    
    return HasAnimDictLoaded(dict)
end

local function loadAnimSet(clipset, timeout)
    timeout = timeout or 5000
    local startTime = GetGameTimer()
    
    RequestAnimSet(clipset)
    while not HasAnimSetLoaded(clipset) and (GetGameTimer() - startTime) < timeout do
        Citizen.Wait(100)
    end
    
    return HasAnimSetLoaded(clipset)
end

local function startPointing()
    local ped = PlayerPedId()
    
    if not loadAnimDict(ANIM_CONFIG.POINTING.dict) then
        return false
    end
    
    animationStates.pointing = true
    SetPedCurrentWeaponVisible(ped, false, true, true, true)
    SetPedConfigFlag(ped, ANIM_CONFIG.POINTING.flag, true)
    TaskMoveNetworkByName(ped, ANIM_CONFIG.POINTING.name, ANIM_CONFIG.POINTING.blendIn, false, ANIM_CONFIG.POINTING.dict, ANIM_CONFIG.POINTING.flags)
    RemoveAnimDict(ANIM_CONFIG.POINTING.dict)
    
    return true
end

local function stopPointing()
    local ped = PlayerPedId()
    
    animationStates.pointing = false
    RequestTaskMoveNetworkStateTransition(ped, "Stop")
    
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    
    if not IsPedInAnyVehicle(ped, true) then
        SetPedCurrentWeaponVisible(ped, true, true, true, true)
    end
    
    SetPedConfigFlag(ped, ANIM_CONFIG.POINTING.flag, false)
    ClearPedSecondaryTask(ped)
    
    return true
end

local function canPlayAnimation(ped)
    return not IsPauseMenuActive() and 
           not IsPedSittingInAnyVehicle(ped) and 
           not IsEntityInWater(ped) and
           not IsPedDeadOrDying(ped, true)
end

local function managePointing()
    local ped = PlayerPedId()
    
    if not canPlayAnimation(ped) then 
        return false 
    end
    
    if animationStates.pointing then
        stopPointing()
    else
        if startPointing() then
            CreateThread(function()
                while animationStates.pointing do
                    Citizen.Wait(0)
                    local currentPed = PlayerPedId()
                    
                    local camPitch = GetGameplayCamRelativePitch()
                    camPitch = math.max(-70.0, math.min(camPitch, 42.0))
                    camPitch = (camPitch + 70.0) / 112.0

                    local camHeading = GetGameplayCamRelativeHeading()
                    camHeading = math.max(-180.0, math.min(camHeading, 180.0))
                    camHeading = (camHeading + 180.0) / 360.0

                    local cosHeading, sinHeading = Cos(camHeading), Sin(camHeading)
                    local coords = GetOffsetFromEntityInWorldCoords(currentPed,
                        (cosHeading * -0.2) - (sinHeading * (0.4 * camHeading + 0.3)),
                        (sinHeading * -0.2) + (cosHeading * (0.4 * camHeading + 0.3)), 0.6)
                    
                    local ray = Cast_3dRayPointToPoint(
                        coords.x, coords.y, coords.z - 0.2, 
                        coords.x, coords.y, coords.z + 0.2, 
                        0.4, 95, currentPed, 7
                    )
                    local _, blocked, _ = GetRaycastResult(ray)

                    SetTaskMoveNetworkSignalFloat(currentPed, "Pitch", camPitch)
                    SetTaskMoveNetworkSignalFloat(currentPed, "Heading", -camHeading + 1.0)
                    SetTaskMoveNetworkSignalBool(currentPed, "isBlocked", blocked)
                    SetTaskMoveNetworkSignalBool(currentPed, "isFirstPerson", GetCamViewModeForContext(GetCamActiveViewModeContext()) == 4)
                end
            end)
        end
    end
    
    return true
end

local function manageHandsUp()
    local ped = PlayerPedId()
    
    if not canPlayAnimation(ped) then 
        return false 
    end
    
    if not animationStates.handsUp then
        if loadAnimDict(ANIM_CONFIG.HANDS_UP.dict) then
            TaskPlayAnim(
                ped, 
                ANIM_CONFIG.HANDS_UP.dict, 
                ANIM_CONFIG.HANDS_UP.name, 
                ANIM_CONFIG.HANDS_UP.blendIn, 
                ANIM_CONFIG.HANDS_UP.blendOut, 
                ANIM_CONFIG.HANDS_UP.duration, 
                ANIM_CONFIG.HANDS_UP.flag, 
                0, 
                false, 
                false, 
                false
            )
            animationStates.handsUp = true
        else
            return false
        end
    else
        ClearPedTasks(ped)
        RemoveAnimDict(ANIM_CONFIG.HANDS_UP.dict)
        animationStates.handsUp = false
    end
    
    return true
end


local function manageCrouch()
    local ped = PlayerPedId()
    
    DisableControlAction(0, 36, true)
    
    if not canPlayAnimation(ped) then 
        return false 
    end

    if animationStates.crouched then
        ResetPedMovementClipset(ped, ANIM_CONFIG.CROUCH.blendOut)
        ClearPedTasks(ped)
        RemoveAnimSet(ANIM_CONFIG.CROUCH.clipset)
        animationStates.crouched = false
    else
        if loadAnimSet(ANIM_CONFIG.CROUCH.clipset) then
            SetPedMovementClipset(ped, ANIM_CONFIG.CROUCH.clipset, ANIM_CONFIG.CROUCH.blendIn)
            animationStates.crouched = true
        else
            return false
        end
    end
    
    return true
end

local function resetAllAnimations()
    local ped = PlayerPedId()
    
    if animationStates.pointing then
        stopPointing()
    end
    
    if animationStates.handsUp then
        ClearPedTasks(ped)
        RemoveAnimDict(ANIM_CONFIG.HANDS_UP.dict)
        animationStates.handsUp = false
    end
    
    if animationStates.crouched then
        ResetPedMovementClipset(ped, ANIM_CONFIG.CROUCH.blendOut)
        ClearPedTasks(ped)
        RemoveAnimSet(ANIM_CONFIG.CROUCH.clipset)
        animationStates.crouched = false
    end
    
    ResetPedMovementClipset(ped, 0.5)
    ClearPedTasks(ped)
end

RegisterCommand("reset", resetAllAnimations, false)
RegisterKeyMapping("reset", "Réinitialiser ~r~les animations", "keyboard", "R")
RegisterCommand("pointfinger", managePointing, false)
RegisterKeyMapping("pointfinger", "Pointer ~r~du doigt", "keyboard", "B")
RegisterCommand("crouch", manageCrouch, false)
RegisterKeyMapping("crouch", "S'accroupir", "keyboard", "LCONTROL")
RegisterCommand("handsup", manageHandsUp, false)
RegisterKeyMapping("handsup", 'Lever ~r~les mains', 'keyboard', "H")



