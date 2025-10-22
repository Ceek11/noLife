local LoadedPeds = {}

local function GetRandomScenario()
    if CONFIG_PEDS.scenario_list and #CONFIG_PEDS.scenario_list > 0 then
        local randomIndex = math.random(1, #CONFIG_PEDS.scenario_list)
        return CONFIG_PEDS.scenario_list[randomIndex]
    end
    return nil
end

local function GetBehaviorOptions(pedData)
    if pedData.options then
        return pedData.options
    end
    
    if pedData.behavior then
        for _, behavior in pairs(CONFIG_PEDS.behavior_list) do
            if behavior.id == pedData.behavior then
                return behavior.options
            end
        end
    end
    
    return CONFIG_PEDS.default_options or {}
end

local function ApplyPedOptions(ped, pedData)
    local options = GetBehaviorOptions(pedData)
    
    SetEntityAsMissionEntity(ped, true, true)
    
    if options.blockEvents then
        SetBlockingOfNonTemporaryEvents(ped, true)
    end
    
    if options.invincible then
        SetPedDiesWhenInjured(ped, false)
        SetEntityInvincible(ped, true)
    end
    
    if options.canPlayAmbient then
        SetPedCanPlayAmbientAnims(ped, true)
    end
    
    if not options.canRagdoll then
        SetPedCanRagdollFromPlayerImpact(ped, false)
    end
    
    if options.freeze then
        FreezeEntityPosition(ped, true)
    end
end

local function ApplyAnimation(ped, pedData)
    if pedData.scenario then
        TaskStartScenarioInPlace(ped, pedData.scenario, 0, true)
    elseif pedData.animation then
        local anim = nil
        
        if type(pedData.animation) == "string" then
            anim = CONFIG_PEDS.anim_list[pedData.animation]
        elseif type(pedData.animation) == "table" then
            anim = pedData.animation
        end
        
        if anim and anim.dict and anim.anim then
            RequestAnimDict(anim.dict)
            local timeout = 0
            while not HasAnimDictLoaded(anim.dict) and timeout < 1000 do
                Wait(10)
                timeout = timeout + 10
            end
            
            if HasAnimDictLoaded(anim.dict) then
                TaskPlayAnim(ped, anim.dict, anim.anim, 8.0, 0.0, -1, 1, 0, false, false, false)
            end
        end
    elseif CONFIG_PEDS.default_options.randomScenario then
        local randomScenario = GetRandomScenario()
        if randomScenario then
            TaskStartScenarioInPlace(ped, randomScenario, 0, true)
        end
    end
end

local function CreatePedFromData(pedData)
    local peds = {}
    
    for _, coords in pairs(pedData.ped_coords) do
        local pedHash = GetHashKey(pedData.ped_model)
        
        RequestModel(pedHash)
        local timeout = 0
        while not HasModelLoaded(pedHash) and timeout < 1000 do
            Wait(10)
            timeout = timeout + 10
        end
        
        if HasModelLoaded(pedHash) then
            local ped = CreatePed(4, pedHash, coords.x, coords.y, coords.z, coords.w or 0.0, false, true)
            
            ApplyPedOptions(ped, pedData)
            ApplyAnimation(ped, pedData)
            
            table.insert(peds, ped)
            SetModelAsNoLongerNeeded(pedHash)
        end
    end
    
    return peds
end

local function RemoveAllPeds()
    for _, pedGroup in pairs(LoadedPeds) do
        for _, ped in pairs(pedGroup) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
    end
    LoadedPeds = {}
end

function FUN_HANDLE_PEDS(tbl_peds)
    RemoveAllPeds()
    
    for index, pedData in pairs(tbl_peds) do
        local createdPeds = CreatePedFromData(pedData)
        LoadedPeds[index] = createdPeds
    end
end

CORE.register_client_callback("fafadev:to_client:refresh_peds", function(handler, peds)
    FUN_HANDLE_PEDS(peds)
    handler(true)
end)
