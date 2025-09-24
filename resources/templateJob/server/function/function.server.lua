tbl_actions_employees = {
    [1] = recruit_employee,
    [2] = fire_employee,
    [3] = promote_employee,
    [4] = demote_employee,
}

function recruit_employee(xPlayer, xTarget)
    xTarget.setJob(CONFIG_INFOS_JOB.job_name, tostring(CONFIG_INFOS_JOB.first_grade))
    xPlayer.showNotification(T("notification_you_recruited", xTarget.getName()))
    xTarget.showNotification(T("notification_recruited_by", xPlayer.getName()))
    -- Webhook Discord
    send_discord_message(xPlayer.source, "boss", "boss", T("discord_title_recruit"), T("discord_boss_recruit", xTarget.getName()), xPlayer.getName())
end

function fire_employee(xPlayer, xTarget)
    xTarget.setJob(CONFIG_INFOS_JOB.unemployed_job, "0")
    xPlayer.showNotification(T("notification_you_fired", xTarget.getName()))
    xTarget.showNotification(T("notification_fired_by", xPlayer.getName()))
end

function promote_employee(xPlayer, xTarget)
    local newGrade = xTarget.getJob().grade + 1
    if newGrade <= CONFIG_INFOS_JOB.max_grade then 
        xTarget.setJob(CONFIG_INFOS_JOB.job_name, tostring(newGrade))
        xPlayer.showNotification(T("notification_you_promoted", xTarget.getName()))
        xTarget.showNotification(T("notification_promoted_by", xPlayer.getName()))
        -- Webhook Discord
        send_discord_message(xPlayer.source, "boss", "boss", T("discord_title_promote"), T("discord_boss_promote", xTarget.getName(), "Grade " .. newGrade), xPlayer.getName())
    else
        xPlayer.showNotification(T("error_cannot_promote_further"))
    end
end

function demote_employee(xPlayer, xTarget)
    local newGrade = xTarget.getJob().grade - 1
    if newGrade >= CONFIG_INFOS_JOB.first_grade then
        xTarget.setJob(CONFIG_INFOS_JOB.job_name, tostring(newGrade))
        xPlayer.showNotification(T("notification_you_demoted", xTarget.getName()))
        xTarget.showNotification(T("notification_demoted_by", xPlayer.getName()))
        -- Webhook Discord
        send_discord_message(xPlayer.source, "boss", "boss", T("discord_title_demote"), T("discord_boss_demote", xTarget.getName(), "Grade " .. newGrade), xPlayer.getName())
    else
        xPlayer.showNotification(T("error_cannot_demote_further"))
    end
end

function get_online_players_map()
    local online_players = {}
    for _, playerId in ipairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            online_players[xPlayer.identifier] = xPlayer
        end
    end
    return online_players
end


function hasSpecialCharacters(str)
    return string.match(str, "[^%w%s%-_]") ~= nil
end

function validateGradeCreation(gradeData, callback)
    local name = string.lower((gradeData[1] or ""):gsub("^%s*(.-)%s*$", "%1"))
    local salary = gradeData[2]
    local grade = gradeData[3]
    local label = (gradeData[4] or ""):gsub("^%s*(.-)%s*$", "%1")

    if hasSpecialCharacters(name) then
        return callback(false, "error_grade_special_characters")
    end
    
    MySQL.Async.fetchAll([[
        SELECT 
            (SELECT COUNT(*) FROM job_grades WHERE job_name = ? AND grade = ?) as count_number,
            (SELECT COUNT(*) FROM job_grades WHERE job_name = ? AND name = ?) as count_name
    ]], {CONFIG_INFOS_JOB.job_name, grade, CONFIG_INFOS_JOB.job_name, name}, function(result)
        if not result or not result[1] then
            return callback(false, "error_database")
        end

        local count_number = result[1].count_number or 0
        local count_name = result[1].count_name or 0
        
        if count_number > 0 then
            return callback(false, "error_grade_number_exists")
        end

        if count_name > 0 then
            return callback(false, "error_grade_name_exists")
        end

        callback(true, {name = name, salary = salary, grade = grade, label = label})
    end)
end
