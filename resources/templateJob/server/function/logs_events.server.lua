
-- Fonction pour décoder une table en chaîne lisible
function table_to_string(tbl, depth)
    depth = depth or 0
    if depth > 3 then return "{...}" end -- Éviter la récursion infinie
    
    if type(tbl) ~= "table" then
        return tostring(tbl)
    end
    
    local result = {}
    local count = 0
    
    -- Compter les éléments pour déterminer si c'est un array ou un objet
    for _ in pairs(tbl) do count = count + 1 end
    
    if count == 0 then
        return "{}"
    end
    
    table.insert(result, "{")
    
    local first = true
    for k, v in pairs(tbl) do
        if not first then
            table.insert(result, ", ")
        end
        first = false
        
        if type(k) == "string" then
            table.insert(result, ("%s="):format(k))
        elseif type(k) == "number" then
            table.insert(result, ("[%d]="):format(k))
        else
            table.insert(result, ("[%s]="):format(tostring(k)))
        end
        
        if type(v) == "table" then
            table.insert(result, table_to_string(v, depth + 1))
        elseif type(v) == "string" then
            table.insert(result, ("'%s'"):format(v))
        else
            table.insert(result, tostring(v))
        end
    end
    
    table.insert(result, "}")
    return table.concat(result)
end

function log_event(event_name, source_id, args)
    local xPlayer = ESX.GetPlayerFromId(source_id)
    local player_name = xPlayer and xPlayer.getName() or T("logs_unknown_player")
    
    local args_str = ""
    if args and #args > 0 then
        local arg_strings = {}
        for i, arg in ipairs(args) do
            if type(arg) == "table" then
                table.insert(arg_strings, table_to_string(arg))
            elseif type(arg) == "string" then
                table.insert(arg_strings, ("'%s'"):format(tostring(arg)))
            else
                table.insert(arg_strings, tostring(arg))
            end
        end
        args_str = table.concat(arg_strings, ", ")
    end
    
    local timestamp = os.date("[%H:%M:%S]")
    print(("%s [RPC] {%s} %s called '%s' with args : [%s]"):format(
        timestamp,
        tostring(source_id), 
        player_name, 
        event_name, 
        args_str
    ))
end

function RegisterServerEventWithLog(eventName, callback)
    RegisterServerEvent(eventName, function(...)
        local source_id = source
        local args = {}
        for i = 1, select('#', ...) do
            local arg = select(i, ...)
            args[i] = arg
        end
        
        log_event(eventName, source_id, args)
        
        if callback then
            callback(...)
        end
    end)
end


function RegisterServerCallbackWithLog(eventName, callback)
    ESX.RegisterServerCallback(eventName, function(source, cb, ...)
        local source_id = source
        local args = {}
        local arg_count = select('#', ...)
        
        -- Capturer seulement les arguments réels du client (après source et cb)
        for i = 1, arg_count do
            local arg = select(i, ...)
            args[i] = arg
        end
        
        log_event(eventName, source_id, args)
        
        if callback then
            callback(source, cb, ...)
        end
    end)
end

