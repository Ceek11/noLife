ESX = exports["es_extended"]:getSharedObject()

function CORE.fun_is_table_empty(tbl)
    for _ in pairs(tbl) do
        return false
    end
    return true
end

function string.split(str, delimiter)
    local result = {}
    local pattern = "(.-)" .. delimiter
    local last_end = 1
    local s, e, cap = str:find(pattern, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(result, cap)
        end
        last_end = e + 1
        s, e, cap = str:find(pattern, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(result, cap)
    end
    return result
end
