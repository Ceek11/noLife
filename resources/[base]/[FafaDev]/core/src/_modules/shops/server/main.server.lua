local str_file_location = 'data/shops.json'
TBL_SHOPS = {}

function FUN_LOAD_SHOPS()
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), str_file_location)
    tbl_shops = json.decode(str_file_content)
    for _, shop in pairs(tbl_shops) do
        TBL_SHOPS[shop.name] = shop
        exports.ox_inventory:RegisterShop(shop.name, {
            name = shop.name,
            inventory = shop.items,
        })
    end
end


CORE.register_server_callback("fafadev:to_server:get_shops", function(source, cb)
    cb(TBL_SHOPS)
end)

CORE.register_server_callback("fafadev:to_server:create_shop", function(source, cb, shopData)
    if not shopData or not shopData.name or not shopData.coords or not shopData.items then
        cb(false)
        return
    end
    
    if TBL_SHOPS[shopData.name] then
        cb(false)
        return
    end
    
    TBL_SHOPS[shopData.name] = shopData
    
    exports.ox_inventory:RegisterShop(shopData.name, {
        name = shopData.name,
        inventory = shopData.items,
    })
    
    local shopsArray = {}
    for _, shop in pairs(TBL_SHOPS) do
        table.insert(shopsArray, shop)
    end
    
    local success = SaveResourceFile(GetCurrentResourceName(), str_file_location, json.encode(shopsArray, {indent = true}), -1)
    if success then
        cb(true)
    else
        TBL_SHOPS[shopData.name] = nil
        cb(false)
    end
end)

CORE.register_server_callback("fafadev:to_server:delete_shop", function(source, cb, shopName)
    if not shopName or not TBL_SHOPS[shopName] then
        cb(false)
        return
    end
    
    TBL_SHOPS[shopName] = nil
    
    local shopsArray = {}
    for _, shop in pairs(TBL_SHOPS) do
        table.insert(shopsArray, shop)
    end
    
    local success = SaveResourceFile(GetCurrentResourceName(), str_file_location, json.encode(shopsArray, {indent = true}), -1)
    if success then
        cb(true)
    else
        cb(false)
    end
end)

