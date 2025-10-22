local str_file_location = 'data/blips.json'
TBL_BLIPS = {}

function FUN_LOAD_BLIPS()
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), str_file_location)
    if str_file_content then
        local tbl_blips = json.decode(str_file_content)
        TBL_BLIPS = tbl_blips
    end
end

CORE.register_server_callback("fafadev:to_server:get_blips", function(source, cb)
    cb(TBL_BLIPS)
end)

CORE.register_server_callback("fafadev:to_server:create_blip", function(source, cb, blipData)
    if not blipData or not blipData.type then
        cb(false)
        return
    end
    
    if blipData.type == "classic" then
        if not TBL_BLIPS.ClassicBlips then
            TBL_BLIPS.ClassicBlips = {}
        end
        table.insert(TBL_BLIPS.ClassicBlips, blipData.data)
    elseif blipData.type == "entreprise" then
        if not TBL_BLIPS.Blips then
            TBL_BLIPS.Blips = {}
        end
        if not TBL_BLIPS.Blips.Entreprise then
            TBL_BLIPS.Blips.Entreprise = {}
        end
        table.insert(TBL_BLIPS.Blips.Entreprise, blipData.data)
    else
        cb(false)
        return
    end
    
    local success = SaveResourceFile(GetCurrentResourceName(), str_file_location, json.encode(TBL_BLIPS, {indent = true}), -1)
    if success then
        -- Rafraîchir automatiquement les blips pour tous les joueurs
        CORE.trigger_client_callback("fafadev:to_client:refresh_blips", -1, function() end, TBL_BLIPS)
        cb(true)
    else
        cb(false)
    end
end)

CORE.register_server_callback("fafadev:to_server:delete_blip", function(source, cb, blipType, blipIndex)
    if not blipType or not blipIndex then
        cb(false)
        return
    end
    
    if blipType == "classic" and TBL_BLIPS.ClassicBlips and TBL_BLIPS.ClassicBlips[blipIndex] then
        table.remove(TBL_BLIPS.ClassicBlips, blipIndex)
    elseif blipType == "entreprise" and TBL_BLIPS.Blips and TBL_BLIPS.Blips.Entreprise and TBL_BLIPS.Blips.Entreprise[blipIndex] then
        table.remove(TBL_BLIPS.Blips.Entreprise, blipIndex)
    else
        cb(false)
        return
    end
    
    local success = SaveResourceFile(GetCurrentResourceName(), str_file_location, json.encode(TBL_BLIPS, {indent = true}), -1)
    if success then
        CORE.trigger_client_callback("fafadev:to_client:refresh_blips", -1, function() end, TBL_BLIPS)
    end
    cb(success)
end)

CORE.register_server_callback("fafadev:to_server:refresh_blips", function(source, cb)
    CORE.trigger_client_callback("fafadev:to_client:refresh_blips", -1, function() end, TBL_BLIPS)
    cb(true)
end)
