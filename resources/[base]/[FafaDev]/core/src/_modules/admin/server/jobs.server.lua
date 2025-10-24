CORE.register_server_callback("fafadev:to_server:get_jobs", function(source, cb)
    local jobs = {}
    MySQL.query('SELECT * FROM jobs', {}, function(result)
        if result then
            for _, job in ipairs(result) do
                jobs[job.name] = {
                    name = job.name,
                    label = job.label,
                    whitelisted = job.whitelisted,
                    accountName = "society_" .. job.name,
                    accountLabel = "Société " .. job.label
                }
            end
        end
        cb(jobs)
    end)
end)

CORE.register_server_callback("fafadev:to_server:create_job", function(source, cb, jobData)
    local success = false
    local accountName = "society_" .. jobData.name
    local accountLabel = "Société " .. jobData.label
    
    MySQL.query('SELECT name FROM jobs WHERE name = ?', {jobData.name}, function(result)
        if result and #result > 0 then
            cb(false)
            return
        end
        
        MySQL.insert('INSERT INTO jobs (name, label, whitelisted) VALUES (?, ?, ?)', {
            jobData.name,
            jobData.label,
            0
        }, function(insertId)
            if insertId then
                MySQL.query('SELECT id FROM job_grades WHERE job_name = ? AND grade = 20', {jobData.name}, function(gradeResult)
                    if not (gradeResult and #gradeResult > 0) then
                        MySQL.insert('INSERT INTO job_grades (job_name, grade, name, label, salary, skin_male, skin_female) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                            jobData.name, 20, 'boss', 'Boss', 500, '{}', '{}'
                        }, function(gradeId)
                            if gradeId then createAccount() else cb(false) end
                        end)
                    else
                        createAccount()
                    end
                end)
            else
                cb(false)
            end
        end)
        
        function createAccount()
            MySQL.query('SELECT name FROM addon_account WHERE name = ?', {accountName}, function(accountResult)
                if accountResult and #accountResult > 0 then
                    MySQL.query('SELECT id FROM addon_account_data WHERE account_name = ?', {accountName}, function(dataResult)
                        if dataResult and #dataResult > 0 then
                            success = true
                            cb(success)
                        else
                            MySQL.insert('INSERT INTO addon_account_data (account_name, money, owner) VALUES (?, ?, ?)', {
                                accountName, 0, nil
                            }, function(dataId)
                                success = dataId and true or false
                                cb(success)
                            end)
                        end
                    end)
                else
                    MySQL.insert('INSERT INTO addon_account (name, label, shared) VALUES (?, ?, ?)', {
                        accountName, accountLabel, 1
                    }, function(accountId)
                        if accountId then
                            MySQL.insert('INSERT INTO addon_account_data (account_name, money, owner) VALUES (?, ?, ?)', {
                                accountName, 0, nil
                            }, function(dataId)
                                success = dataId and true or false
                                cb(success)
                            end)
                        else
                            cb(false)
                        end
                    end)
                end
            end)
        end
    end)
end)

CORE.register_server_callback("fafadev:to_server:update_job", function(source, cb, jobName, jobData)
    local success = false
    
    if jobData.name ~= jobName then
        MySQL.query('SELECT name FROM jobs WHERE name = ?', {jobData.name}, function(result)
            if result and #result > 0 then
                cb(false)
                return
            end
            updateJob()
        end)
    else
        updateJob()
    end
    
    function updateJob()
        MySQL.update('UPDATE jobs SET name = ?, label = ? WHERE name = ?', {
            jobData.name, jobData.label, jobName
        }, function(affectedRows)
            if affectedRows > 0 then
                MySQL.query('SELECT id FROM job_grades WHERE job_name = ? AND grade = 20', {jobData.name}, function(gradeResult)
                    if gradeResult and #gradeResult > 0 then
                        MySQL.update('UPDATE job_grades SET name = ?, label = ?, salary = ? WHERE job_name = ? AND grade = 20', {
                            'boss', 'Boss', 500, jobData.name
                        }, function(gradeRows)
                            if gradeRows > 0 then updateAccount() else cb(false) end
                        end)
                    else
                        MySQL.insert('INSERT INTO job_grades (job_name, grade, name, label, salary, skin_male, skin_female) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                            jobData.name, 20, 'boss', 'Boss', 500, '{}', '{}'
                        }, function(gradeId)
                            if gradeId then updateAccount() else cb(false) end
                        end)
                    end
                end)
            else
                cb(false)
            end
        end)
    end
    
    function updateAccount()
        local newAccountName = "society_" .. jobData.name
        local newAccountLabel = "Société " .. jobData.label
        local oldAccountName = "society_" .. jobName
        
        MySQL.query('SELECT name FROM addon_account WHERE name = ?', {newAccountName}, function(accountResult)
            if accountResult and #accountResult > 0 then
                success = true
                cb(success)
            else
                MySQL.update('UPDATE addon_account SET name = ?, label = ? WHERE name = ?', {
                    newAccountName, newAccountLabel, oldAccountName
                }, function(accountRows)
                    if accountRows > 0 then
                        MySQL.update('UPDATE addon_account_data SET account_name = ? WHERE account_name = ?', {
                            newAccountName, oldAccountName
                        }, function(dataRows)
                            success = true
                            cb(success)
                        end)
                    else
                        cb(false)
                    end
                end)
            end
        end)
    end
end)

CORE.register_server_callback("fafadev:to_server:delete_job", function(source, cb, jobName)
    local accountName = "society_" .. jobName
    
    MySQL.query('DELETE FROM addon_account_data WHERE account_name = ?', {accountName}, function()
        MySQL.query('DELETE FROM addon_account WHERE name = ?', {accountName}, function()
            MySQL.query('DELETE FROM job_grades WHERE job_name = ?', {jobName}, function()
                MySQL.query('DELETE FROM jobs WHERE name = ?', {jobName}, function()
                    cb(true)
                end)
            end)
        end)
    end)
end)
