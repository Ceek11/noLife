function get_players() 
    local players = {}

    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)

        if DoesEntityExist(ped) then
            table.insert(players, player)
        end
    end

    return players
end

function is_in_table(tbl, val)
    if type(tbl) ~= "table" then return false end
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

function get_nearby_players(distance)
    local ped = GetPlayerPed(-1)
    local playerPos = GetEntityCoords(ped)
    local nearbyPlayers = {}

    for _, v in pairs(get_players()) do
        local otherPed = GetPlayerPed(v)
        local otherPedPos = otherPed ~= ped and IsEntityVisible(otherPed) and GetEntityCoords(otherPed)

        if otherPedPos and #(otherPedPos - playerPos) <= (distance or 6) then
            nearbyPlayers[#nearbyPlayers + 1] = v
        end
    end
    return nearbyPlayers
end

local wait = false;
local xWait = false

function get_nearby_player(solo, other)
    if wait then
        xWait = true
        while wait do
            Citizen.Wait(5)
        end
    end

    xWait = false
    local cTimer = GetGameTimer() + 10000;
    local oPlayer = get_nearby_players(2)

    if solo then
        oPlayer[#oPlayer + 1] = PlayerId()
    end

    if #oPlayer == 0 then
        ESX.ShowNotification(T("error_no_players_nearby"))
        return false
    end

    if #oPlayer == 1 and other then
        return oPlayer[1]
    end

    ESX.ShowNotification(T("player_selection_help"))
    Citizen.Wait(100)
    local cBase = 1
    wait = true
    while GetGameTimer() <= cTimer and not xWait do
        Citizen.Wait(0)
        DisableControlAction(0, 38, true)
        DisableControlAction(0, 73, true)
        DisableControlAction(0, 44, true)
        if IsDisabledControlJustPressed(0, 38) then
            wait = false
            return oPlayer[cBase]
        elseif IsDisabledControlJustPressed(0, 73) then
            ESX.ShowNotification(T("error_action_cancelled"))
            break
        elseif IsDisabledControlJustPressed(0, 44) then
            cBase = (cBase == #oPlayer) and 1 or (cBase + 1)
        end
        local cPed = GetPlayerPed(oPlayer[cBase])
        local cCoords = GetEntityCoords(cPed)
        DrawMarker(0, cCoords.x, cCoords.y, cCoords.z + 1.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.1, 0.1, 0.1, 0, 180, 10,30, 1, 1, 0, 0, 0, 0, 0)
    end
    wait = false
    return false
end
