ESX = exports["es_extended"]:getSharedObject()

function CORE.fun_is_table_empty(tbl)
    for _ in pairs(tbl) do
        return false
    end
    return true
end