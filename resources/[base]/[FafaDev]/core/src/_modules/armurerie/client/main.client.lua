function FUN_HANDLE_ARMURERIE(armurerieData)
    AddTickHandler("armurerie", 0, function()
        local playerCoords = GetEntityCoords(PlayerPedId())
        local markerNear = false
        local xPlayer = ESX.GetPlayerData()
        local playerJob = xPlayer and xPlayer.job and xPlayer.job.name or nil
        
        for _, data in pairs(armurerieData) do
            local hasAccess = true
            if data.job and data.job ~= "" then
                hasAccess = (playerJob == data.job)
            end
            
            if hasAccess then
                for _, coord in pairs(data.coords) do
                    local distance = #(playerCoords - vector3(coord.x, coord.y, coord.z))
                    
                    if distance < 10.0 then
                        markerNear = true
                        DrawCustomMarker(coord.x, coord.y, coord.z)
                        if distance < 2.0 then
                            ESX.ShowHelpNotification(data.message)
                            if IsControlJustPressed(0, 38) then
                                FUN_OPEN_ARMURERIE_MENU(data)
                            end
                        end
                    end
                end
            end
        end
        
        if not markerNear then
            SetIntervalEnabled(false, "armurerie")
        else
            SetIntervalEnabled(true, "armurerie")
        end
    end)
end