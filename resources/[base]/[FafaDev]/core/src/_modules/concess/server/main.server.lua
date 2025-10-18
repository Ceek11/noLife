local concess = LoadResourceFile(GetCurrentResourceName(), "data/concess.json")
TBL_CONCESS = json.decode(concess)
TBL_CATEGORIE = {}
TBL_VEHICLE = {}
function FUN_LOAD_CONCESS()
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), "data/concess.json")
    if str_file_content then
        local tbl_concess = json.decode(str_file_content)
        if tbl_concess then
            -- Itérer sur les catégories (sell, preview)
            for category, concessList in pairs(tbl_concess) do
                if type(concessList) == "table" then
                    -- Itérer sur chaque concession dans la catégorie
                    for _, concessData in ipairs(concessList) do
                        if concessData and concessData.name then
                            TBL_CONCESS[concessData.name] = concessData
                        end
                    end
                end
            end
        end
    end
end

CORE.register_server_callback("fafadev:to_server:get_concess", function(source, cb)
    cb(TBL_CONCESS)
end)

CreateThread(function()
    local vehicles = MySQL.query.await('SELECT * FROM vehicles')
    for _, vehicle in ipairs(vehicles or {}) do
        TBL_VEHICLE[vehicle.name] = vehicle
    end

    local categories = MySQL.query.await('SELECT * FROM vehicle_categories')
    for _, category in ipairs(categories or {}) do
        TBL_CATEGORIE[category.name] = category
    end
end)

CORE.register_server_callback("fafadev:to_server:get_categories", function(source, cb)
    cb(TBL_CATEGORIE)
end)

CORE.register_server_callback("fafadev:to_server:get_vehicles", function(source, cb)
    cb(TBL_VEHICLE)
end)


