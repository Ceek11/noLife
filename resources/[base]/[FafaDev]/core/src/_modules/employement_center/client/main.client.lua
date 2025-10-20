AddTickHandler("employement_center", 0, function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local markerNear = false
    for name, data in pairs(CONFIG_EMPLOYEMENT_CENTER.Jobs) do
        for _, coord in pairs(CONFIG_EMPLOYEMENT_CENTER.Coords) do
            local distance = #(playerCoords - vector3(coord.x, coord.y, coord.z))
            if distance < 10.0 then
                markerNear = true
                DrawCustomMarker(coord.x, coord.y, coord.z)
                if distance < 2.0 and not IS_JOB_CONFIRMATION_ACTIVE() then
                    ESX.ShowHelpNotification(CONFIG_EMPLOYEMENT_CENTER.message)
                    if IsControlJustPressed(0, 38) then
                        FUN_OPEN_EMPLOYEMENT_CENTER_MENU(data)
                    end
                end
            end
        end
    end
    
    if not markerNear then
        SetIntervalEnabled(false, "employement_center")
    else
        SetIntervalEnabled(true, "employement_center")
    end
end)