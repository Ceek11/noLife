local str_file_location = 'data/peds.json'
TBL_PEDS = {}

function FUN_LOAD_PEDS()
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), str_file_location)
    if str_file_content then
        local tbl_peds = json.decode(str_file_content)
        if tbl_peds then
            for i, ped in pairs(tbl_peds) do
                TBL_PEDS[i] = ped
            end
        end
    end
end

CORE.register_server_callback("fafadev:to_server:get_peds", function(source, cb)
    cb(TBL_PEDS)
end)

CORE.register_server_callback("fafadev:to_server:create_ped", function(source, cb, pedData)
    if not pedData or not pedData.ped_model or not pedData.ped_coords then
        cb(false)
        return
    end
    
    table.insert(TBL_PEDS, pedData)
    
    local success = SaveResourceFile(GetCurrentResourceName(), str_file_location, json.encode(TBL_PEDS, {indent = true}), -1)
    if success then
        -- Rafraîchir automatiquement les peds pour tous les joueurs
        CORE.trigger_client_callback("fafadev:to_client:refresh_peds", -1, function() end, TBL_PEDS)
        cb(true)
    else
        table.remove(TBL_PEDS, #TBL_PEDS)
        cb(false)
    end
end)

CORE.register_server_callback("fafadev:to_server:delete_ped", function(source, cb, pedIndex)
    if not pedIndex or not TBL_PEDS[pedIndex] then
        cb(false)
        return
    end
    
    table.remove(TBL_PEDS, pedIndex)
    
    local success = SaveResourceFile(GetCurrentResourceName(), str_file_location, json.encode(TBL_PEDS, {indent = true}), -1)
    if success then
        -- Rafraîchir automatiquement les peds pour tous les joueurs
        CORE.trigger_client_callback("fafadev:to_client:refresh_peds", -1, function() end, TBL_PEDS)
    end
    cb(success)
end)