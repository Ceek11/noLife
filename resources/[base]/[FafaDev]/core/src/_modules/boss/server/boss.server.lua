

-- Fonction simple pour valider la création de grade
function validate_grade_creation(new_grade, callback)
    local isValid = new_grade and new_grade[1] and new_grade[2] and new_grade[3] and new_grade[4]
    if isValid then
        local result = {
            name = new_grade[1],
            salary = new_grade[2],
            grade = new_grade[3],
            label = new_grade[4]
        }
        callback(true, result)
    else
        callback(false, "Données de grade invalides")
    end
end

CORE.register_server_event("fafadev:to_server:boss_action_employees", function(source, targetT, index)
    local _source = source
    if not _source or not targetT then return end
    
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xTarget = ESX.GetPlayerFromId(targetT)
    
    if not xPlayer or not xTarget then return end
    
    -- Actions sur les employés (recruter, licencier, promouvoir, rétrograder)
    if index == 1 then
        -- Recruter - Envoyer une offre d'emploi
        if xTarget.job.name ~= "unemployed" then
            xPlayer.showNotification("~r~Ce joueur a déjà un emploi!")
            return
        end
        
        -- Envoyer l'offre d'emploi au joueur cible
        CORE.trigger_client_event("fafadev:to_client:boss_job_offer", targetT, {
            bossName = xPlayer.getName(),
            jobName = xPlayer.job.name,
            bossId = _source
        })
        
        xPlayer.showNotification("Offre d'emploi envoyée à " .. xTarget.getName())
        
    elseif index == 2 then
        -- Licencier
        xTarget.setJob("unemployed", 0)
        xPlayer.showNotification("Employé licencié: " .. xTarget.getName())
    elseif index == 3 then
        -- Promouvoir (grade + 1)
        local newGrade = math.min(xTarget.job.grade + 1, 10)
        xTarget.setJob(xPlayer.job.name, newGrade)
        xPlayer.showNotification("Employé promu: " .. xTarget.getName())
    elseif index == 4 then   
        -- Rétrograder (grade - 1)
        local newGrade = math.max(xTarget.job.grade - 1, 0)
        xTarget.setJob(xPlayer.job.name, newGrade)
        xPlayer.showNotification("Employé rétrogradé: " .. xTarget.getName())
    end
end)

CORE.register_server_callback("fafadev:to_server:boss_get_employees_list", function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not _source or not xPlayer then 
        cb({})
        return 
    end
    local playerJob = xPlayer.job.name
    
    local employees = {}
    local online_players = {}
    for _, playerId in ipairs(ESX.GetPlayers()) do
        local xP = ESX.GetPlayerFromId(playerId)
        if xP then
            online_players[xP.identifier] = xP
        end
    end

    MySQL.Async.fetchAll([[
        SELECT u.firstname, u.lastname, u.job_grade, u.identifier, 
               COALESCE(jg.label, 'Inconnu') as grade_label,
               COALESCE(jg.salary, 0) as salary,
               COALESCE(jg.name, 'Inconnu') as job_name
        FROM users u
        LEFT JOIN job_grades jg 
               ON u.job = jg.job_name AND u.job_grade = jg.grade
        WHERE u.job = ?
    ]], {playerJob}, function(result)
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


CORE.register_server_callback("fafadev:to_server:boss_get_grade_job", function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not _source or not xPlayer then 
        cb({})
        return 
    end
    local playerJob = xPlayer.job.name
    
    local FAFA_JOB_GRADE_JOB = {}
    MySQL.Async.fetchAll("SELECT label, salary, name, grade FROM job_grades WHERE job_name = ?", {playerJob}, function(result)
        for i = 1, #result do
            local v = result[i]
            table.insert(FAFA_JOB_GRADE_JOB, {
                label = v.label,
                salary = v.salary,
                name = v.name,
                grade = v.grade
            })
        end
        cb(FAFA_JOB_GRADE_JOB)
    end)
end)

CORE.register_server_event("fafadev:to_server:boss_promote_employee", function(source, employee, grade, gradeLabel)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not _source or not xPlayer then return end
    local playerJob = xPlayer.job.name

    local online_players = {}
    for _, playerId in ipairs(ESX.GetPlayers()) do
        local xP = ESX.GetPlayerFromId(playerId)
        if xP then
            online_players[xP.identifier] = xP
        end
    end

    local xTarget = online_players[employee.identifier]

    if xTarget then
        xTarget.setJob(playerJob, grade)
        xTarget.showNotification("Vous avez été promu au grade: " .. gradeLabel)
    end

    MySQL.Async.execute("UPDATE users SET job_grade = ? WHERE identifier = ?", {grade, employee.identifier}, function(affectedRows)
        if affectedRows > 0 then
            xPlayer.showNotification("Vous avez promu " .. employee.name .. " au grade: " .. gradeLabel)
        else
            xPlayer.showNotification("Erreur lors de la promotion")
        end
    end)
end)


CORE.register_server_event("fafadev:to_server:boss_fire_employee", function(source, employee)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not _source or not xPlayer then return end
    local playerJob = xPlayer.job.name

    local online_players = {}
    for _, playerId in ipairs(ESX.GetPlayers()) do
        local xP = ESX.GetPlayerFromId(playerId)
        if xP then
            online_players[xP.identifier] = xP
        end
    end

    local xTarget = online_players[employee.identifier]

    if xTarget then
        xTarget.setJob("unemployed", "0")
        xTarget.showNotification("Vous avez été licencié par: " .. xPlayer.getName())
    end

    MySQL.Async.execute(
        "UPDATE users SET job = ? WHERE identifier = ?", 
        {"unemployed", employee.identifier}, 
        function(affectedRows)
            if affectedRows > 0 then
                xPlayer.showNotification("Vous avez licencié: " .. employee.name)
            else
                xPlayer.showNotification("Erreur lors du licenciement")
            end
        end
    )
end)


CORE.register_server_event("fafadev:to_server:boss_update_salary", function(source, grade, salary, gradeLabel)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not _source or not xPlayer then return end
    local playerJob = xPlayer.job.name
    MySQL.Async.execute("UPDATE job_grades SET salary = ? WHERE grade = ? AND job_name = ?", {salary, grade, playerJob}, function(affectedRows)
        if affectedRows > 0 then
            xPlayer.showNotification("Salaire mis à jour pour: " .. gradeLabel)
        else
            xPlayer.showNotification("Erreur lors de la mise à jour du salaire")
        end
    end)
end)

CORE.register_server_callback("fafadev:to_server:boss_get_permissions", function(source, cb, grade_name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not _source or not xPlayer then return end
    
    local permissions_file = LoadResourceFile(GetCurrentResourceName(), "data/boss_perms.json")
    local permissions_tbl = {}
    
    if permissions_file then
        permissions_tbl = json.decode(permissions_file) or {}
    end
    
    local grade_permissions = {}
    if permissions_tbl[grade_name] and permissions_tbl[grade_name].permissions then
        grade_permissions = permissions_tbl[grade_name].permissions
    else
        grade_permissions = {
            boss = false,
            menuF6 = false,
            chest = false,
            cloakroom = false,
            garage = false
        }
    end
    
    cb(grade_permissions)
end)


CORE.register_server_event("fafadev:to_server:boss_create_grade", function(source, new_grade)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not _source or not xPlayer then return end
    local playerJob = xPlayer.job.name
    
    validate_grade_creation(new_grade, function(isValid, result)
        if not isValid then
            xPlayer.showNotification(result)
            return
        end
        
        MySQL.Async.execute("INSERT INTO job_grades (job_name, name, label, salary, grade) VALUES (?, ?, ?, ?, ?)", 
            {playerJob, result.name, result.label, result.salary, result.grade}, function(affectedRows)
            if affectedRows > 0 then
                local permissions = LoadResourceFile(GetCurrentResourceName(), "data/boss_perms.json")
                local permissions_tbl = json.decode(permissions)
                permissions_tbl[result.name] = {
                    permissions = {
                        boss = false,
                        menuF6 = false,
                        chest = false,
                        cloakroom = false,
                        garage = false
                    }
                }
                SaveResourceFile(GetCurrentResourceName(), "data/boss_perms.json", json.encode(permissions_tbl), -1)
                xPlayer.showNotification("Grade créé: " .. result.label)
            else
                xPlayer.showNotification("Erreur lors de la création du grade")
            end
        end)
    end)
end)

CORE.register_server_event("fafadev:to_server:boss_update_permissions", function(source, permissions, grade_name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not _source or not xPlayer then return end
    
    local permissions_file = LoadResourceFile(GetCurrentResourceName(), "data/boss_perms.json")
    local permissions_tbl = {}
    
    if permissions_file then
        permissions_tbl = json.decode(permissions_file) or {}
    end
    
    if not permissions_tbl[grade_name] then
        permissions_tbl[grade_name] = {}
    end
    permissions_tbl[grade_name].permissions = permissions
    
    SaveResourceFile(GetCurrentResourceName(), "data/boss_perms.json", json.encode(permissions_tbl), -1)
    xPlayer.showNotification("Permissions mises à jour pour: " .. grade_name)
end)

CORE.register_server_event("fafadev:to_server:boss_modify_grade", function(source, new_grade, grade_name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not _source or not xPlayer then return end
    local playerJob = xPlayer.job.name
    
    validate_grade_creation(new_grade, function(isValid, result)
        if not isValid then
            xPlayer.showNotification(result)
            return
        end
        
        MySQL.Async.execute("UPDATE job_grades SET name = ?, salary = ?, grade = ?, label = ? WHERE name = ? AND job_name = ?", 
            {result.name, result.salary, result.grade, result.label, grade_name, playerJob}, 
            function(affectedRows)
                if affectedRows > 0 then
                    if result.name ~= grade_name then
                        local permissions_file = LoadResourceFile(GetCurrentResourceName(), "data/boss_perms.json")
                        local permissions_tbl = json.decode(permissions_file)
                        
                        if permissions_tbl[grade_name] then
                            permissions_tbl[result.name] = permissions_tbl[grade_name]
                            permissions_tbl[grade_name] = nil
                            SaveResourceFile(GetCurrentResourceName(), "data/boss_perms.json", json.encode(permissions_tbl), -1)
                        end
                    end
                    
                    xPlayer.showNotification("Grade modifié: " .. result.label)
                else
                    xPlayer.showNotification("Erreur lors de la modification du grade")
                end
            end)
    end)
end)

CORE.register_server_event("fafadev:to_server:boss_delete_grade", function(source, grade_name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not _source or not xPlayer then return end
    local playerJob = xPlayer.job.name
    
    MySQL.Async.fetchAll("SELECT COUNT(*) as count FROM users WHERE job = ? AND job_grade = (SELECT grade FROM job_grades WHERE name = ? AND job_name = ?)", 
        {playerJob, grade_name, playerJob}, function(result)
        if result[1].count > 0 then
            xPlayer.showNotification("Ce grade a encore des employés, impossible de le supprimer")
            return
        end
        
        local permissions_file = LoadResourceFile(GetCurrentResourceName(), "data/boss_perms.json")
        local permissions_tbl = json.decode(permissions_file)
        permissions_tbl[grade_name] = nil
        SaveResourceFile(GetCurrentResourceName(), "data/boss_perms.json", json.encode(permissions_tbl), -1)
        
        MySQL.Async.execute("DELETE FROM job_grades WHERE name = ? AND job_name = ?", {grade_name, playerJob}, function(affectedRows)
            if affectedRows > 0 then
                xPlayer.showNotification("Grade supprimé: " .. grade_name)
            else
                xPlayer.showNotification("Erreur lors de la suppression du grade")
            end
        end)
    end)
end)


-- Événement pour accepter une offre d'emploi
CORE.register_server_event("fafadev:to_server:boss_accept_job_offer", function(source, bossId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xBoss = ESX.GetPlayerFromId(bossId)
    
    if not _source or not xPlayer or not xBoss then return end
    
    -- Vérifier que le joueur est toujours au chômage
    if xPlayer.job.name ~= "unemployed" then
        xPlayer.showNotification("~r~Vous avez déjà un emploi!")
        return
    end
    
    -- Donner le job au joueur
    xPlayer.setJob(xBoss.job.name, 0)
    xPlayer.showNotification("~g~Vous avez accepté l'offre d'emploi!")
    xBoss.showNotification("~g~" .. xPlayer.getName() .. " a accepté votre offre d'emploi!")
end)

-- Événement pour refuser une offre d'emploi
CORE.register_server_event("fafadev:to_server:boss_decline_job_offer", function(source, bossId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xBoss = ESX.GetPlayerFromId(bossId)
    
    if not _source or not xPlayer or not xBoss then return end
    
    xPlayer.showNotification("~r~Vous avez refusé l'offre d'emploi")
    xBoss.showNotification("~r~" .. xPlayer.getName() .. " a refusé votre offre d'emploi")
end)
