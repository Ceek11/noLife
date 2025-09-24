zUI = exports["zUI-v2"]:getObject()

local tickHandlers = {}
local intervalEnabled = false

function AddTickHandler(name, interval, callback)
    tickHandlers[name] = {interval = interval, callback = callback, lastRun = 0}
end

function SetIntervalEnabled(enabled)
    intervalEnabled = enabled
end

Citizen.CreateThread(function()
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

CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end
    
    init_player_permissions()
end)

RegisterNetEvent('esx:setJob', function(job)
    if job and job.grade_name then
        init_player_permissions()
    end
end)