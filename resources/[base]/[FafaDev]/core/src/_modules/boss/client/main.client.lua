function FUN_HANDLE_BOSS_MENUS(boss_data)
    AddTickHandler("boss_menus", 0, function()
        local playerCoords = GetEntityCoords(PlayerPedId())
        local markerNear = false
        local xPlayer = ESX.GetPlayerData()
        local playerJob = xPlayer and xPlayer.job and xPlayer.job.name or nil
        local playerGrade = xPlayer and xPlayer.job and xPlayer.job.grade or 0
        
        for name, data in pairs(boss_data) do
            if FUN_CHECK_BOSS_ACCESS(data, playerJob, playerGrade) then
                for _, coord in pairs(data.coords) do
                    local distance = #(playerCoords - vector3(coord.x, coord.y, coord.z))
                    if distance < 10.0 then
                        markerNear = true
                        -- Vérifier si le marqueur doit être dessiné
                        if data.drawmarker ~= false then
                            DrawMarker(1, coord.x, coord.y, coord.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 200, false, true, 2, false, false, false, false)
                        end
                        if distance < 2.0 then
                            ESX.ShowHelpNotification(data.message)
                            if IsControlJustPressed(0, 38) then
                                all_job_menu_boss()
                            end
                        end
                    end
                end
            end
        end
        
        if not markerNear then
            SetIntervalEnabled(false, "boss_menus")
        else
            SetIntervalEnabled(true, "boss_menus")
        end
    end)
end

function FUN_CHECK_BOSS_ACCESS(bossData, playerJob, playerGrade)
    -- Vérifier l'accès par job
    if bossData.job and bossData.job ~= "" then
        if playerJob ~= bossData.job then
            return false
        end
    end
    
    -- Vérifier l'accès par grade
    if bossData.gradeAccess and #bossData.gradeAccess > 0 then
        local hasGradeAccess = false
        for _, grade in pairs(bossData.gradeAccess) do
            if playerGrade >= grade then
                hasGradeAccess = true
                break
            end
        end
        if not hasGradeAccess then
            return false
        end
    end
    
    return true
end



-- Gestion des offres d'emploi
local jobOfferActive = false

CORE.register_client_event("fafadev:to_client:boss_job_offer", function(data)
    jobOfferActive = true
    
    CreateThread(function()
        while jobOfferActive do
            ESX.ShowHelpNotification(("~g~%s~s~ vous propose un emploi: ~b~%s~s~\n~g~~INPUT_CONTEXT~~s~ pour accepter | ~r~~INPUT_DETONATE~~s~ pour refuser"):format(
                data.bossName, 
                data.jobName
            ))
            
            if IsControlJustPressed(0, 38) then 
                jobOfferActive = false
                CORE.trigger_server_event("fafadev:to_server:boss_accept_job_offer", data.bossId)
                break
            elseif IsControlJustPressed(0, 47) then
                jobOfferActive = false
                CORE.trigger_server_event("fafadev:to_server:boss_decline_job_offer", data.bossId)
                break
            end
            
            Wait(0)
        end
    end)
end)