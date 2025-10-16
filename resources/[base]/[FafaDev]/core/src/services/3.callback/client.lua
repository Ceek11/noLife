local tbl_callbacks = {}

CORE.register_client_event("fafadev:to_client:back", function(name, ...)
    local handler = tbl_callbacks[name]
    if handler then
        handler(...)
        tbl_callbacks[name] = nil
    else
        error(("Callback not found: %s"):format(name))
    end
end)

CORE.trigger_server_callback = function(name, handler, ...)
    tbl_callbacks[name] = handler
    CORE.trigger_server_event("fafadev:to_server:callback", name, ...)
end

CORE.register_client_event("fafadev:to_client:callback", function(name, ...)
    local handler = tbl_callbacks[name]
    if handler then
        handler(function(...)
            if ... == nil then
                error(("Callback handler must return at least one argument: %s"):format(name))
            end
            CORE.trigger_server_event("fafadev:to_server:back", name, ...)
        end, ...)
    else
        error(("Callback not found: %s"):format(name))
    end
end)

CORE.register_client_callback = function(name, handler)
    if tbl_callbacks[name] then
        error(("Callback already exists: %s"):format(name))
    end
    tbl_callbacks[name] = handler
end
