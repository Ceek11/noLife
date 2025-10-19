function FUN_HANDLE_GARAGES(garages)
    AddTickHandler("garages", 0, function()
        local playerCoords = GetEntityCoords(PlayerPedId())
        local markerNear = false
        local xPlayer = ESX.GetPlayerData()
        local playerJob = xPlayer and xPlayer.job and xPlayer.job.name or nil
        
        for name, data in pairs(garages) do
            if FUN_CHECK_GARAGE_ACCESS(data, playerJob) then
                for _, coord in pairs(data.coords) do
                    local distance = #(playerCoords - vector3(coord.x, coord.y, coord.z))
                    if distance < 10.0 then
                        markerNear = true
                        local markerColor = data.isImpound and {255, 0, 0, 200} or {0, 150, 255, 200}
                        DrawMarker(1, coord.x, coord.y, coord.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, markerColor[1], markerColor[2], markerColor[3], markerColor[4], false, true, 2, false, false, false, false)
                        
                        if distance < 2.0 then
                            ESX.ShowHelpNotification(data.message)
                            if IsControlJustPressed(0, 38) then
                                local garageOptions = {
                                    garageName = name,
                                    garageLabel = data.name,
                                    typeGarage = data.type,
                                    spawnVehPositions = data.spawnPositions,
                                    previousPosition = {x = coord.x, y = coord.y, z = coord.z},
                                    isImpound = data.isImpound or false,
                                    jobAccess = data.jobAccess or {}
                                }
                                
                                if data.isImpound then
                                    openFourriereMenu(garageOptions)
                                else
                                    openGarageMenu(garageOptions)
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if not markerNear then
            SetIntervalEnabled(false, "garages")
        else
            SetIntervalEnabled(true, "garages")
        end
    end)
end

function FUN_CHECK_GARAGE_ACCESS(garageData, playerJob)
    if garageData.jobAccess and #garageData.jobAccess > 0 then
        for _, job in pairs(garageData.jobAccess) do
            if playerJob == job then
                return true
            end
        end
        return false
    end
    return true
end




