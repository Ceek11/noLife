local ESX = exports["es_extended"]:getSharedObject()

local keyCache = {}
local cacheDuration = 30000

local function cleanCache()
    local currentTime = os.time()
    for key, data in pairs(keyCache) do
        if currentTime - data.timestamp > (cacheDuration / 1000) then
            keyCache[key] = nil
        end
    end
end

local function getCacheKey(playerId, plate)
    return playerId .. "_" .. plate
end

local function hasPlayerKey(playerId, plate)
    local cacheKey = getCacheKey(playerId, plate)
    local cached = keyCache[cacheKey]
    
    if cached and (os.time() - cached.timestamp) < (cacheDuration / 1000) then
        return cached.hasKey
    end
    
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return false end
    
    local ownedVehicle = MySQL.single.await('SELECT plate FROM owned_vehicles WHERE plate = ? AND owner = ?', {plate, xPlayer.identifier})
    if ownedVehicle then
        keyCache[cacheKey] = {hasKey = true, timestamp = os.time()}
        return true
    end
    
    local givenKey = MySQL.single.await('SELECT id FROM vehicle_keys WHERE plate = ? AND owner = ? AND (expires_at IS NULL OR expires_at > NOW())', {plate, xPlayer.identifier})
    if givenKey then
        keyCache[cacheKey] = {hasKey = true, timestamp = os.time()}
        return true
    end
    
    keyCache[cacheKey] = {hasKey = false, timestamp = os.time()}
    return false
end

CORE.register_server_callback("fafadev:to_server:keys_has_key", function(source, cb, plate)
    local hasKey = hasPlayerKey(source, plate)
    cb(hasKey)
end)

CORE.register_server_callback("fafadev:to_server:keys_get_owned_vehicles", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb({})
        return
    end

    MySQL.Async.fetchAll('SELECT plate FROM owned_vehicles WHERE owner = ?', {xPlayer.identifier}, function(result)
        local vehicles = {}
        if result then
            for _, v in pairs(result) do
                vehicles[v.plate] = true
            end
        end
        cb(vehicles)
    end)
end)

AddEventHandler('playerDropped', function()
    local source = source
    for key, data in pairs(keyCache) do
        if string.find(key, tostring(source) .. "_") then
            keyCache[key] = nil
        end
    end
end)

CreateThread(function()
    while true do
        Wait(60000)
        cleanCache()
    end
end)

