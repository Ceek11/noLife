TBL_GARAGES = {}

function FUN_LOAD_GARAGES()
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), 'data/garage.json')
    if str_file_content then
        local tbl_garages = json.decode(str_file_content)
        if tbl_garages then
            for _, garage in pairs(tbl_garages) do
                TBL_GARAGES[garage.name] = garage
            end
        end
    end
end

CORE.register_server_callback("fafadev:to_server:get_garages", function(source, cb)
    cb(TBL_GARAGES)
end)

local function SaveGarages()
    local garagesArray = {}
    for _, garage in pairs(TBL_GARAGES) do
        table.insert(garagesArray, garage)
    end
    SaveResourceFile(GetCurrentResourceName(), 'data/garage.json', json.encode(garagesArray), -1)
end

CORE.register_server_callback("fafadev:to_server:create_garage", function(source, cb, garageData)
    if not garageData or not garageData.name then
        cb(false)
        return
    end
    if TBL_GARAGES[garageData.name] then
        cb(false)
        return
    end
    TBL_GARAGES[garageData.name] = garageData
    SaveGarages()
    cb(true)
end)

CORE.register_server_callback("fafadev:to_server:delete_garage", function(source, cb, garageName)
    if not garageName or not TBL_GARAGES[garageName] then
        cb(false)
        return
    end
    TBL_GARAGES[garageName] = nil
    SaveGarages()
    cb(true)
end)