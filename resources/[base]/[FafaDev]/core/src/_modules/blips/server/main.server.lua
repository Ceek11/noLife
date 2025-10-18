local str_file_location = 'data/blips.json'
TBL_BLIPS = {}

function FUN_LOAD_BLIPS()
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), str_file_location)
    if str_file_content then
        local tbl_blips = json.decode(str_file_content)
        for _, blip in pairs(tbl_blips) do
            TBL_BLIPS[blip.id] = blip
        end
    end
end

CORE.register_server_callback("fafadev:to_server:get_blips", function(source, cb)
    cb(TBL_BLIPS)
end)

CORE.register_server_callback("fafadev:to_server:create_blip", function(source, cb, blipData)
    if not blipData or not blipData.label or not blipData.coords then
        cb(false)
        return
    end
    
    local maxId = 0
    for id, _ in pairs(TBL_BLIPS) do
        if id > maxId then
            maxId = id
        end
    end
    blipData.id = maxId + 1
    
    TBL_BLIPS[blipData.id] = blipData
    
    local blipsArray = {}
    for _, blip in pairs(TBL_BLIPS) do
        table.insert(blipsArray, blip)
    end
    
    local success = SaveResourceFile(GetCurrentResourceName(), str_file_location, json.encode(blipsArray, {indent = true}), -1)
    if success then
        cb(true)
    else
        TBL_BLIPS[blipData.id] = nil
        cb(false)
    end
end)

CORE.register_server_callback("fafadev:to_server:delete_blip", function(source, cb, blipId)
    if not blipId or not TBL_BLIPS[blipId] then
        cb(false)
        return
    end
    
    TBL_BLIPS[blipId] = nil
    
    local blipsArray = {}
    for _, blip in pairs(TBL_BLIPS) do
        table.insert(blipsArray, blip)
    end
    
    local success = SaveResourceFile(GetCurrentResourceName(), str_file_location, json.encode(blipsArray, {indent = true}), -1)
    cb(success)
end)
