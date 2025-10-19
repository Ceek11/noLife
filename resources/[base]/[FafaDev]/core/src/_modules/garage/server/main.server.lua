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
