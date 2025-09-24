
RegisterServerEventWithLog("templatejob:to_server:action_employees", function(targetT, index)
    local _source = source
    if not check_source(_source) or not check_source(targetT) then return end
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xTarget = ESX.GetPlayerFromId(targetT)
    if not (xPlayer) or not check_xplayer(xTarget) then return end
    if not check_job(xPlayer, CONFIG_INFOS_JOB.job_name) then return end
    if index == 1 then
        tbl_actions_employees[index](xPlayer, xTarget)
    elseif index == 2 then
        tbl_actions_employees[index](xPlayer, xTarget)
    elseif index == 3 then
        tbl_actions_employees[index](xPlayer, xTarget)  
    elseif index == 4 then   
        tbl_actions_employees[index](xPlayer, xTarget)
    end
end)

RegisterServerCallbackWithLog("templatejob:to_server:get_employees_list", function(source, cb)
    local employees = {}
    local online_players = get_online_players_map()


    MySQL.Async.fetchAll([[
        SELECT u.firstname, u.lastname, u.job_grade, u.identifier, 
               COALESCE(jg.label, 'Inconnu') as grade_label,
               COALESCE(jg.salary, 0) as salary,
               COALESCE(jg.name, 'Inconnu') as job_name
        FROM users u
        LEFT JOIN job_grades jg 
               ON u.job = jg.job_name AND u.job_grade = jg.grade
        WHERE u.job = ?
    ]], {CONFIG_INFOS_JOB.job_name}, function(result)
        for i = 1, #result do
            local v = result[i]
            table.insert(employees, {
                name        = ("%s %s"):format(v.firstname, v.lastname),
                grade       = v.job_grade,
                grade_label = v.grade_label,
                salary      = v.salary,
                job_name    = v.job_name,
                identifier  = v.identifier,
                is_online   = online_players[v.identifier] ~= nil,
            })
        end
        cb(employees)
    end)
end)


RegisterServerCallbackWithLog("templatejob:to_server:get_grade_job", function(source, cb)
    local TBL_GRADE_JOB = {}
    MySQL.Async.fetchAll("SELECT label, salary, name, grade FROM job_grades WHERE job_name = ?", {CONFIG_INFOS_JOB.job_name}, function(result)
        for i = 1, #result do
            local v = result[i]
            table.insert(TBL_GRADE_JOB, {
                label = v.label,
                salary = v.salary,
                name = v.name,
                grade = v.grade
            })
        end
        cb(TBL_GRADE_JOB)
    end)
end)

RegisterServerEventWithLog("templatejob:to_server:promote_employee", function(employee, grade, gradeLabel)
    local _source = source
    if not check_source(_source) then return end
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not check_xplayer(xPlayer) then return end
    if not check_job(xPlayer, CONFIG_INFOS_JOB.job_name) then return end

    local online_players = {}
    for _, playerId in ipairs(ESX.GetPlayers()) do
        local xP = ESX.GetPlayerFromId(playerId)
        if xP then
            online_players[xP.identifier] = xP
        end
    end

    local xTarget = online_players[employee.identifier]

    if xTarget then
        xTarget.setJob(CONFIG_INFOS_JOB.job_name, grade)
        xTarget.showNotification(T("notification_promoted_to_grade", gradeLabel))
    end

    MySQL.Async.execute("UPDATE users SET job_grade = ? WHERE identifier = ?", {grade, employee.identifier}, function(affectedRows)
        if affectedRows > 0 then
            xPlayer.showNotification(T("notification_you_promoted_to_grade", employee.name, gradeLabel))
            -- Webhook Discord
            send_discord_message(_source, "boss", "boss", T("discord_title_promote"), T("discord_boss_promote", employee.name, gradeLabel), xPlayer.getName())
        else
            xPlayer.showNotification(T("error_promotion_failed"))
        end
    end)
end)


RegisterServerEventWithLog("templatejob:to_server:fire_employee", function(employee)
    local _source = source
    if not check_source(_source) then return end
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not check_xplayer(xPlayer) then return end
    if not check_job(xPlayer, CONFIG_INFOS_JOB.job_name) then return end

    -- Lookup direct des joueurs connectés
    local online_players = {}
    for _, playerId in ipairs(ESX.GetPlayers()) do
        local xP = ESX.GetPlayerFromId(playerId)
        if xP then
            online_players[xP.identifier] = xP
        end
    end

    local xTarget = online_players[employee.identifier]

    if xTarget then
        xTarget.setJob(CONFIG_INFOS_JOB.unemployed_job, "0")
        xTarget.showNotification(T("notification_fired_by", xPlayer.getName()))
    end

    -- Mise à jour BDD
    MySQL.Async.execute(
        "UPDATE users SET job = ? WHERE identifier = ?", 
        {CONFIG_INFOS_JOB.unemployed_job, employee.identifier}, 
        function(affectedRows)
            if affectedRows > 0 then
                xPlayer.showNotification(T("notification_you_fired", employee.name))
                -- Webhook Discord
                send_discord_message(_source, "boss", "boss", T("discord_title_fire"), T("discord_boss_fire", employee.name), xPlayer.getName())
            else
                xPlayer.showNotification(T("error_firing_failed"))
            end
        end
    )
end)


RegisterServerEventWithLog("templatejob:to_server:update_salary", function(grade, salary, gradeLabel)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not check_source(_source) then return end
    if not check_xplayer(xPlayer) then return end
    MySQL.Async.execute("UPDATE job_grades SET salary = ? WHERE grade = ? AND job_name = ?", {salary, grade, CONFIG_INFOS_JOB.job_name}, function(affectedRows)
        if affectedRows > 0 then
            xPlayer.showNotification(T("notification_salary_updated", gradeLabel))
            -- Webhook Discord
            send_discord_message(_source, "boss", "boss", T("discord_title_salary_update"), T("discord_boss_salary_update", gradeLabel, salary), xPlayer.getName())
        else
            xPlayer.showNotification(T("error_salary_update_failed"))
        end
    end)
end)

RegisterServerCallbackWithLog("templatejob:to_server:get_permissions", function(source, cb, grade_name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not check_source(_source) then return end
    if not check_xplayer(xPlayer) then return end
    
    local permissions = LoadResourceFile(GetCurrentResourceName(), "data/permissions.json")
    local permissions_tbl = json.decode(permissions)
    
    if permissions_tbl[grade_name] and permissions_tbl[grade_name].permissions then
        cb(permissions_tbl[grade_name].permissions)
    else
        cb({}) -- Retourner un tableau vide si le grade n'existe pas
        return
    end
end)


RegisterServerEventWithLog("templatejob:to_server:create_grade", function(new_grade)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not check_source(_source) then return end
    if not check_xplayer(xPlayer) then return end
    
    validateGradeCreation(new_grade, function(isValid, result)
        if not isValid then
            xPlayer.showNotification(T(result))
            return
        end
        
        MySQL.Async.execute("INSERT INTO job_grades (job_name, name, label, salary, grade) VALUES (?, ?, ?, ?, ?)", 
            {CONFIG_INFOS_JOB.job_name, result.name, result.label, result.salary, result.grade}, function(affectedRows)
            if affectedRows > 0 then
                -- LOAD le permission.json et ajouter le grade a la table permissions
                local permissions = LoadResourceFile(GetCurrentResourceName(), "data/permissions.json")
                local permissions_tbl = json.decode(permissions)
                permissions_tbl[result.name] = {
                    permissions = CONFIG_INFOS_JOB.permissions
                }
                SaveResourceFile(GetCurrentResourceName(), "data/permissions.json", json.encode(permissions_tbl), -1)
                xPlayer.showNotification(T("notification_grade_created", result.label))
                -- Webhook Discord
                send_discord_message(_source, "boss", "boss", T("discord_title_grade_create"), T("discord_boss_grade_create", result.label, result.grade, result.salary), xPlayer.getName())
            else
                xPlayer.showNotification(T("error_grade_creation_failed"))
                return
            end
        end)
    end)
end)

RegisterServerEventWithLog("templatejob:to_server:update_permissions", function(permissions, grade_name)

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not check_source(_source) then return end
    if not check_xplayer(xPlayer) then return end
    
    local permissions_file = LoadResourceFile(GetCurrentResourceName(), "data/permissions.json")
    local permissions_tbl = json.decode(permissions_file)
    
    if permissions_tbl[grade_name] then
        permissions_tbl[grade_name].permissions = permissions
        SaveResourceFile(GetCurrentResourceName(), "data/permissions.json", json.encode(permissions_tbl), -1)
        xPlayer.showNotification(T("notification_permissions_updated", grade_name))
        -- Webhook Discord
        send_discord_message(_source, "boss", "boss", T("discord_title_permissions_update"), T("discord_boss_permissions_update", grade_name), xPlayer.getName())
    else
        xPlayer.showNotification(T("error_grade_not_found"))
        return
    end
end)

RegisterServerEventWithLog("templatejob:to_server:modify_grade", function(new_grade, grade_name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not check_source(_source) then return end
    if not check_xplayer(xPlayer) then return end
    
    validateGradeCreation(new_grade, function(isValid, result)
        if not isValid then
            xPlayer.showNotification(T(result))
            return
        end
        
        MySQL.Async.execute("UPDATE job_grades SET name = ?, salary = ?, grade = ?, label = ? WHERE name = ? AND job_name = ?", 
            {result.name, result.salary, result.grade, result.label, grade_name, CONFIG_INFOS_JOB.job_name}, 
            function(affectedRows)
                if affectedRows > 0 then
                    -- Mettre à jour les permissions si le nom du grade a changé
                    if result.name ~= grade_name then
                        local permissions_file = LoadResourceFile(GetCurrentResourceName(), "data/permissions.json")
                        local permissions_tbl = json.decode(permissions_file)
                        
                        if permissions_tbl[grade_name] then
                            -- Copier les permissions de l'ancien nom vers le nouveau
                            permissions_tbl[result.name] = permissions_tbl[grade_name]
                            permissions_tbl[grade_name] = nil
                            SaveResourceFile(GetCurrentResourceName(), "data/permissions.json", json.encode(permissions_tbl), -1)
                        end
                    end
                    
                    xPlayer.showNotification(T("notification_grade_modified", result.label))
                    -- Webhook Discord
                    send_discord_message(_source, "boss", "boss", T("discord_title_grade_modify"), T("discord_boss_grade_modify", result.label), xPlayer.getName())
                else
                    xPlayer.showNotification(T("error_grade_modification_failed"))
                end
            end)
    end)
end)

RegisterServerEventWithLog("templatejob:to_server:delete_grade", function(grade_name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not check_source(_source) then return end
    if not check_xplayer(xPlayer) then return end
    
    -- Vérifier s'il y a des employés avec ce grade
    MySQL.Async.fetchAll("SELECT COUNT(*) as count FROM users WHERE job = ? AND job_grade = (SELECT grade FROM job_grades WHERE name = ? AND job_name = ?)", 
        {CONFIG_INFOS_JOB.job_name, grade_name, CONFIG_INFOS_JOB.job_name}, function(result)
        if result[1].count > 0 then
            xPlayer.showNotification(T("error_grade_has_employees"))
            return
        end
        
        -- Supprimer les permissions du fichier
        local permissions_file = LoadResourceFile(GetCurrentResourceName(), "data/permissions.json")
        local permissions_tbl = json.decode(permissions_file)
        permissions_tbl[grade_name] = nil
        SaveResourceFile(GetCurrentResourceName(), "data/permissions.json", json.encode(permissions_tbl), -1)
        
        -- Supprimer le grade de la base de données
        MySQL.Async.execute("DELETE FROM job_grades WHERE name = ? AND job_name = ?", {grade_name, CONFIG_INFOS_JOB.job_name}, function(affectedRows)
            if affectedRows > 0 then
                xPlayer.showNotification(T("notification_grade_deleted", grade_name))
                -- Webhook Discord
                send_discord_message(_source, "boss", "boss", T("discord_title_grade_delete"), T("discord_boss_grade_delete", grade_name), xPlayer.getName())
            else
                xPlayer.showNotification(T("error_grade_deletion_failed"))
            end
        end)
    end)
end)