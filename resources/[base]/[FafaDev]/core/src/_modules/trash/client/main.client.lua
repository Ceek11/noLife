local trashBinHashes = {}
local isSearching = false
local CONFIG_TRASH_DATA = {}

local function loadTrashBinModels()
    if CONFIG_TRASH and CONFIG_TRASH.trash_bin_models then
        for i = 1, #CONFIG_TRASH.trash_bin_models do
            local modelName = CONFIG_TRASH.trash_bin_models[i]
            local modelHash = GetHashKey(modelName)
            trashBinHashes[modelHash] = true
        end
    end
end

local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

local function findNearestTrashBin()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local handle, object = FindFirstObject()
    local success
    local nearest, dist = nil, 3.0
    
    repeat
        if DoesEntityExist(object) then
            local model = GetEntityModel(object)
            if trashBinHashes[model] then
                local binCoords = GetEntityCoords(object)
                local d = #(playerCoords - binCoords)
                if d < dist then
                    dist = d
                    nearest = {
                        entity = object,
                        coords = binCoords,
                        id = tostring(object)
                    }
                end
            end
        end
        success, object = FindNextObject(handle)
    until not success

    EndFindObject(handle)
    return nearest, dist
end

local function searchTrashBin(bin)
    if isSearching then 
        ESX.ShowNotification("Vous êtes déjà en train de fouiller")
        return 
    end

    if CONFIG_TRASH_DATA[bin.id] then
        ESX.ShowNotification("~r~Cette poubelle a déjà été fouillée")
        return
    end

    isSearching = true
    
    loadAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    TaskPlayAnim(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 8.0, -8.0, -1, 1, 0, false, false, false)
    ESX.ShowNotification("Vous fouillez la poubelle...")
    
    local searchTime = CONFIG_TRASH.time or 5000
    Wait(searchTime)
    
    ClearPedTasks(PlayerPedId())
    CORE.trigger_server_event("fafadev:to_server:search_trash_bin", bin.id)
    isSearching = false
end

Citizen.CreateThread(function()
    while not CONFIG_TRASH do
        Citizen.Wait(100)
    end
    
    loadTrashBinModels()
    
    while true do
        local delay = 2000
        local bin, dist = findNearestTrashBin()
        
        if bin and dist < 10.0 then
            delay = 500
            if dist < (CONFIG_TRASH.max_distance or 3.0) and not IsPedInAnyVehicle(PlayerPedId(), false) then
                delay = 0
                local message = "Appuyez sur ~INPUT_CONTEXT~ pour fouiller la poubelle"
                ESX.ShowHelpNotification(message)
                if IsControlJustPressed(0, 38) then
                    searchTrashBin(bin)
                end
            end
        end
        
        Citizen.Wait(delay)
    end
end)

CORE.register_client_event("fafadev:to_client:trash_search_result", function(item_name, item_label, count, money_amount)
    if item_name and item_label then
        if item_name == "money" then
            ESX.ShowNotification(("Vous avez trouvé ~g~%s$~s~ dans la poubelle"):format(money_amount))
        elseif item_name == "already_searched" then
            ESX.ShowNotification("~r~Cette poubelle a déjà été fouillée")
        else
            ESX.ShowNotification(("Vous avez trouvé ~g~%s~s~ (x%s) dans la poubelle"):format(item_label, count))
        end
    else
        ESX.ShowNotification("Vous n'avez rien trouvé dans cette poubelle")
    end
end)

CORE.register_client_event("fafadev:to_client:sync_trash_data", function(trash_data)
    CONFIG_TRASH_DATA = trash_data
end)