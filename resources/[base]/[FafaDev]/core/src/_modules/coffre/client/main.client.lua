function FUN_HANDLE_CHESTS(tbl_chests)
    AddTickHandler("chests", 0, function()
        local playerCoords = GetEntityCoords(PlayerPedId())
        local currentTime = GetGameTimer()
        local markerNear = false
        local xPlayer = ESX.GetPlayerData()
        local playerJob = xPlayer and xPlayer.job and xPlayer.job.name or nil
        local playerGrade = xPlayer and xPlayer.job and xPlayer.job.grade or 0
        
        for name, data in pairs(tbl_chests) do
            -- Vérifier si le joueur a accès au coffre (job requis)
            local hasAccess = true
            if data.job and data.job ~= "" then
                hasAccess = (playerJob == data.job)
            end
            
            if hasAccess then
                for _, coord in pairs(data.coords) do
                    local distance = #(playerCoords - vector3(coord.x, coord.y, coord.z))
                    if distance < 10.0 then
                        markerNear = true
                        -- Vérifier si le marqueur doit être dessiné
                        if data.drawmarker ~= false then
                            DrawMarker(1, coord.x, coord.y, coord.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 150, 255, 200, false, true, 2, false, false, false, false)
                        end
                        if distance < 2.0 then
                            ESX.ShowHelpNotification(data.message)
                            if IsControlJustPressed(0, 38) then
                                FUN_OPEN_CHEST_MENU(data)
                            end
                        end
                    end
                end
            end
        end
        
        if not markerNear then
            SetIntervalEnabled(false, "chests")
        else
            SetIntervalEnabled(true, "chests")
        end
    end)
end