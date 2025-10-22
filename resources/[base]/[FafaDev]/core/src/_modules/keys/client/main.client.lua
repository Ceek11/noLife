local function manageDoorPassengers(vehicle, lockStatus)
    for i = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2 do
        local pedInSeat = GetPedInVehicleSeat(vehicle, i)
        if pedInSeat and pedInSeat ~= 0 then
            SetVehicleDoorsLockedForPlayer(vehicle, pedInSeat, lockStatus == 4)
        end
    end
end

local function OpenCloseVehicle(vehicle)
    local playerPed = PlayerPedId()
    local isInsideVehicle = IsPedInVehicle(playerPed, vehicle, false)
    local lockStatus = GetVehicleDoorLockStatus(vehicle)

    if lockStatus == 0 then
        lockStatus = 1
    end

    CORE.trigger_server_callback('fafadev:to_server:keys_has_key', function(hasKey)
        if not hasKey then
            ESX.ShowNotification("~r~Vous n'avez pas les clés de ce véhicule.")
            return
        end

        if lockStatus == 1 then
            PlayVehicleDoorCloseSound(vehicle, 1)
            Entity(vehicle).state:set("locked", 2, true)
            ESX.ShowNotification("~r~Véhicule verrouillé.")
        elseif lockStatus == 2 then
            if isInsideVehicle then
                PlayVehicleDoorCloseSound(vehicle, 1)
                Entity(vehicle).state:set("locked", 4, true)
                ESX.ShowNotification("~r~Double verrouillage activé.")
            else
                PlayVehicleDoorOpenSound(vehicle, 0)
                Entity(vehicle).state:set("locked", 1, true)
                ESX.ShowNotification("~g~Véhicule déverrouillé.")
            end
        elseif lockStatus == 4 then
            PlayVehicleDoorOpenSound(vehicle, 0)
            Entity(vehicle).state:set("locked", 1, true)
            ESX.ShowNotification("~g~Véhicule déverrouillé.")
        end
        
        manageDoorPassengers(vehicle, lockStatus)
    end, GetVehicleNumberPlateText(vehicle))
end

RegisterCommand("lockvehicle", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle ~= 0 then
        OpenCloseVehicle(vehicle)
    else
        vehicle = lib.getClosestVehicle(playerCoords, 7.5, false)
        if DoesEntityExist(vehicle) then
            local dict = "anim@mp_player_intmenu@key_fob@"
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do
                Citizen.Wait(100)
            end
            TaskPlayAnim(playerPed, dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
            SetModelAsNoLongerNeeded(dict)
            OpenCloseVehicle(vehicle)
        else
            ESX.ShowNotification("~r~Aucun véhicule à proximité.")
        end
    end
end, false)

RegisterKeyMapping("lockvehicle", "Verrouiller/Déverrouiller le véhicule", "keyboard", "U")
AddStateBagChangeHandler('locked', nil, function(bagName, key, value)
    local entity = GetEntityFromStateBagName(bagName)
    if not DoesEntityExist(entity) then return end

    if value == 1 then
        SetVehicleDoorsLocked(entity, 1)
        SetVehicleDoorsLockedForAllPlayers(entity, false)
    elseif value == 2 then
        SetVehicleDoorsLocked(entity, 2)
        SetVehicleDoorsLockedForAllPlayers(entity, true)
    elseif value == 4 then
        SetVehicleDoorsLocked(entity, 4)
        SetVehicleDoorsLockedForAllPlayers(entity, true)
    end
end)

