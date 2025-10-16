TBL_GARAGES = {}

function FUN_LOAD_GARAGES()
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), 'data/garage.json')
    if str_file_content then
        local tbl_garages = json.decode(str_file_content)
        if tbl_garages then
            for _, garage in pairs(tbl_garages) do
                TBL_GARAGES[garage.name] = garage
            end
            print("^2[GARAGE] Chargé " .. #tbl_garages .. " garage(s) depuis le JSON^0")
        else
            print("^1[GARAGE] Erreur lors du parsing du fichier garage.json^0")
        end
    else
        print("^1[GARAGE] Impossible de charger le fichier garage.json^0")
    end
end

CORE.register_server_callback("fafadev:to_server:get_garages", function(source, cb)
    cb(TBL_GARAGES)
end)
