TBL_MARKER_DESIGN = {
    ["default"] = {
        marker_type = 1,                    -- Type de marqueur (22 = cylindre)
        marker_color = {r = 255, g = 0, b = 0, a = 255}, -- Couleur RGBA
        marker_size = {x = 0.5, y = 0.5, z = 0.5},         -- Taille du marqueur
        marker_rotation = {x = 0.0, y = 0.0, z = 0.0},     -- Rotation du marqueur
        bobUpAndDown = false,                -- Mouvement de haut en bas
        faceCamera = false,                  -- Face à la caméra
        rotate = false,                      -- Rotation automatique
    }
}

-- Fonction utilitaire pour dessiner un marqueur avec un design personnalisé
function DrawCustomMarker(x, y, z, designName, offsetZ)
    local design = TBL_MARKER_DESIGN[designName] or TBL_MARKER_DESIGN["default"]
    local zOffset = offsetZ or -1.0
    
    DrawMarker(
        design.marker_type,
        x, y, z + zOffset,
        design.marker_rotation.x, design.marker_rotation.y, design.marker_rotation.z,
        0.0, 0.0, 0.0,
        design.marker_size.x, design.marker_size.y, design.marker_size.z,
        design.marker_color.r, design.marker_color.g, design.marker_color.b, design.marker_color.a,
        design.bobUpAndDown and 1 or 0, design.faceCamera and 1 or 0, 2, design.rotate and 1 or 0, false, false, false
    )
end


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