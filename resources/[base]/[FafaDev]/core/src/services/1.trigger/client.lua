local tbl_events = {}

RegisterNetEvent("fafadev:to_client:get_info", function(name, ...) 
    local obj_event = tbl_events[name]
    if obj_event and obj_event.trigger then
        local bool_success, result = pcall(function(...)
            obj_event.trigger(...)
        end, ...)
        if not bool_success then
            error(("Error in event '%s': %s"):format(name, result))
        end
    else
        error(("No event registered for: %s"):format(name))
    end
end)

function CORE.register_client_event(name, trigger)
    if type(name) ~= "string" or type(trigger) ~= "function" then
        error("Invalid parameters for CORE.register_client_event")
    end
    if tbl_events[name] then
        error(("Event '%s' is already registered."):format(name))
    end
    tbl_events[name] = { trigger = trigger }
    return true
end

function CORE.trigger_server_event(name, ...)
    if type(name) ~= "string" then
        error("Invalid event name for CORE.trigger_server_event")
    end
    TriggerServerEvent("fafadev:to_server:get_info", CLIENT.token, name, ...)
    return true
end
