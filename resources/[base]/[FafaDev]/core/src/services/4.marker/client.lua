TBL_MARKER_DESIGN = {
    ["default"] = {
        marker_type = 22,                    -- Type de marqueur (22 = cylindre)
        marker_color = {r = 137, g = 201, b = 17, a = 255}, -- Couleur RGBA
        marker_size = {x = 0.5, y = 0.5, z = 0.5},         -- Taille du marqueur
        marker_rotation = {x = 0.0, y = 0.0, z = 0.0},     -- Rotation du marqueur
        bobUpAndDown = false,                -- Mouvement de haut en bas
        faceCamera = false,                  -- Face à la caméra
        rotate = false,                      -- Rotation automatique
    }
}


local tickHandlers = {}
local intervalEnabled = false
local activeHandlers = {}

function AddTickHandler(name, interval, callback)
    tickHandlers[name] = {interval = interval, callback = callback, lastRun = 0}
end

function SetIntervalEnabled(enabled, handlerName)
    if enabled then
        activeHandlers[handlerName] = true
    else
        activeHandlers[handlerName] = nil
    end
    
    local hasActiveHandler = false
    for _ in pairs(activeHandlers) do
        hasActiveHandler = true
        break
    end
    
    if hasActiveHandler and not intervalEnabled then
        intervalEnabled = true
    elseif not hasActiveHandler and intervalEnabled then
        intervalEnabled = false
    end
end

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end
    while true do 
        local interval = 2000
        local now = GetGameTimer()
        for name, handler in pairs(tickHandlers) do
            if now - handler.lastRun >= handler.interval then
                handler.callback()
                handler.lastRun = now
            end
        end
        
        if intervalEnabled then
            for name, handler in pairs(tickHandlers) do
                if handler.interval >= 0 and handler.interval < interval then
                    interval = handler.interval
                end
            end
        end
        
        Wait(interval)
    end
end)