function FUN_HANDLE_GARAGES(garages)
    AddTickHandler("garages", 0, function()
        local playerCoords = GetEntityCoords(PlayerPedId())
        local currentTime = GetGameTimer()
        local markerNear = false
        local xPlayer = ESX.GetPlayerData()
        local playerJob = xPlayer and xPlayer.job and xPlayer.job.name or nil
        local playerGrade = xPlayer and xPlayer.job and xPlayer.job.grade or 0
        
        for name, data in pairs(garages) do
            if FUN_CHECK_GARAGE_ACCESS(data, playerJob, playerGrade) then
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
                                    isImpound = data.isImpound or false
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

function FUN_CHECK_GARAGE_ACCESS(garageData, playerJob, playerGrade)
    -- Vérifier l'accès par job
    if garageData.jobAccess and #garageData.jobAccess > 0 then
        local hasJobAccess = false
        for _, job in pairs(garageData.jobAccess) do
            if playerJob == job then
                hasJobAccess = true
                break
            end
        end
        if not hasJobAccess then
            return false
        end
    end
    
    -- Vérifier l'accès par grade
    if garageData.gradeAccess and #garageData.gradeAccess > 0 then
        local hasGradeAccess = false
        for _, grade in pairs(garageData.gradeAccess) do
            if playerGrade >= grade then
                hasGradeAccess = true
                break
            end
        end
        if not hasGradeAccess then
            return false
        end
    end
    
    -- Vérifier les licences requises
    if garageData.haveLicense and #garageData.haveLicense > 0 then
        local hasAllLicenses = true
        for _, license in pairs(garageData.haveLicense) do
            if not FUN_HAS_LICENSE(license) then
                hasAllLicenses = false
                break
            end
        end
        if not hasAllLicenses then
            return false
        end
    end
    
    return true
end

function FUN_HAS_LICENSE(licenseName)
    local xPlayer = ESX.GetPlayerData()
    if xPlayer and xPlayer.licenses then
        for _, license in pairs(xPlayer.licenses) do
            if license.name == licenseName and license.status then
                return true
            end
        end
    end
    return false
end
