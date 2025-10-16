local tbl_events = {}
local last_request_time = {}

RegisterNetEvent("fafadev:to_server:get_info", function(token, name, ...)
    local now = os.time()

    last_request_time[source] = last_request_time[source] or {}
    if name ~= "fafadev:to_server:callback" and last_request_time[source][name] and now - last_request_time[source][name] < 1 then
        return
    end
    last_request_time[source][name] = now
    if name == "fafadev:to_server:player_joining" then
        local obj_event = tbl_events[name]
        if obj_event and obj_event.trigger then
            obj_event.trigger(source, ...)
        end
        return
    end
    if token ~= CORE.get_player_token(source) then
        DropPlayer(source, "Tentative de triche détectée. Veuillez vous reconnecter plus tard.")
        return
    end
    local obj_event = tbl_events[name]
    if obj_event and obj_event.trigger then
        obj_event.trigger(source, ...)
    else
        error(("No event registered for: %s"):format(name))
    end
end)

function CORE.register_server_event(name, trigger)
    if type(name) ~= "string" or type(trigger) ~= "function" then
        error("Invalid parameters for CORE.register_server_event")
    end
    if tbl_events[name] then
        error(("Event '%s' is already registered."):format(name))
    end
    tbl_events[name] = { trigger = trigger }
end

function CORE.trigger_client_event(name, target, ...)
    if type(name) ~= "string" then
        error("Invalid event name for CORE.trigger_client_event")
    end
    TriggerClientEvent("fafadev:to_client:get_info", target, name, ...)
end
