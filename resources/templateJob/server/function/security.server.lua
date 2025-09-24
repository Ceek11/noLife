function check_source(source)
    if not source or source <= 0 then 
        send_discord_message(source, "security", "security", "Erreur", T("security_player_not_found"), T("discord_unknown_player"))   
        return false
    end
    return true
end

function check_xplayer(xPlayer)
    if not xPlayer then
        send_discord_message(xPlayer.source, "security", "security", "Erreur", T("security_player_not_found_with_id", xPlayer.source), T("discord_unknown_player"))
        return false
    end
    return true
end

function check_job(xPlayer, job_name)
    local job = xPlayer.getJob()
    if job.name ~= job_name then
        send_discord_message(source, "security", "security", "Erreur", T("security_wrong_job", job_name), xPlayer.getName())
        return false
    end
    return true
end

function check_grade_name(xPlayer, grade_name)
    local grade = xPlayer.getGrade()
    if grade.name ~= grade_name then
        send_discord_message(source, "security", "security", "Erreur", T("security_wrong_grade", grade_name), xPlayer.getName())
        return false
    end
    return true
end

