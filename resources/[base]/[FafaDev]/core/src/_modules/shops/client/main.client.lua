function FUN_HANDLE_SHOPS(shops)
    AddTickHandler("shops", 0, function()
        local playerCoords = GetEntityCoords(PlayerPedId())
        local currentTime = GetGameTimer()
        local markerNear = false
        local xPlayer = ESX.GetPlayerData()
        local playerJob = xPlayer and xPlayer.job and xPlayer.job.name or nil
        local playerGrade = xPlayer and xPlayer.job and xPlayer.job.grade or 0
        for name, data in pairs(shops) do
            if FUN_CHECK_SHOP_ACCESS(data, playerJob, playerGrade) then
                for _, coord in pairs(data.coords) do
                    local distance = #(playerCoords - vector3(coord.x, coord.y, coord.z))
                    if distance < 10.0 then
                        markerNear = true
                        DrawMarker(1, coord.x, coord.y, coord.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 150, 255, 200, false, true, 2, false, false, false, false)
                        if distance < 2.0 then
                            ESX.ShowHelpNotification(data.message)
                            if IsControlJustPressed(0, 38) then
                                exports.ox_inventory:openInventory('shop', {type = name})
                            end
                        end
                    end
                end
            end
        end
        if not markerNear then
            SetIntervalEnabled(false, "shops")
        else
            SetIntervalEnabled(true, "shops")
        end
    end)
end

function FUN_CHECK_SHOP_ACCESS(shopData, playerJob, playerGrade)
    if shopData.jobAccess and #shopData.jobAccess > 0 then
        local hasJobAccess = false
        for _, job in pairs(shopData.jobAccess) do
            if playerJob == job then
                hasJobAccess = true
                break
            end
        end
        if not hasJobAccess then
            return false
        end
    end
    
    if shopData.gradeAccess and #shopData.gradeAccess > 0 then
        local hasGradeAccess = false
        for _, grade in pairs(shopData.gradeAccess) do
            if playerGrade >= grade then
                hasGradeAccess = true
                break
            end
        end
        if not hasGradeAccess then
            return false
        end
    end
    
    if shopData.haveLicense and #shopData.haveLicense > 0 then
        local hasAllLicenses = true
        for _, license in pairs(shopData.haveLicense) do
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
