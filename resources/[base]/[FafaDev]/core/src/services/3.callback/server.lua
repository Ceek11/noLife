local tbl_callbacks = {}

CORE.register_server_event("fafadev:to_server:callback", function(source, name, ...)
    local handler = tbl_callbacks[name]
    if handler then
        handler(source, function(...)
            if ... == nil then
                error(("Callback handler must return at least one argument: %s"):format(name))
            end
            CORE.trigger_client_event("fafadev:to_client:back", source, name, ...)
        end, ...)
    else
        error(("Callback not found: %s"):format(name))
    end
end)

CORE.register_server_callback = function(name, handler)
    if tbl_callbacks[name] then
        error(("Callback already exists: %s"):format(name))
    end
    tbl_callbacks[name] = handler
end

CORE.register_server_event("fafadev:to_server:back", function(source, name, ...)
    local handler = tbl_callbacks[name]
    if handler then
        handler(...)
        tbl_callbacks[name] = nil
    else
        error(("Callback not found: %s"):format(name))
    end
end)

CORE.trigger_client_callback = function(name, target, handler, ...)
    tbl_callbacks[name] = handler
    CORE.trigger_client_event("fafadev:to_client:callback", target, name, ...)
end