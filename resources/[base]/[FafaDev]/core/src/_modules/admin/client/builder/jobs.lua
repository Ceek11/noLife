local job_submenus = {}

local function CleanupObsoleteJobSubmenus(current_jobs)
    local current_keys = {}
    if current_jobs then
        for name, _ in pairs(current_jobs) do
            table.insert(current_keys, "job_" .. name)
        end
    end
    for key, submenu in pairs(job_submenus) do
        local exists = false
        for _, current_key in pairs(current_keys) do
            if key == current_key then
                exists = true
                break
            end
        end
        if not exists then
            job_submenus[key] = nil
        end
    end
end

function jobs_builder(jobsData)
    local TBL_JOBS = jobsData or {}
    CleanupObsoleteJobSubmenus(TBL_JOBS)
    
    RageUI.IsVisible(sub_menus_admin["jobs"], function()
        RageUI.Button("Créer un job", nil, {}, true, {
            onSelected = function()
                local input = lib.inputDialog("Créer un job", {
                    {type = 'input', label = 'Nom du job', description = 'Nom unique du job (ex: police, ambulance, mechanic)', required = true, min = 2, max = 50},
                    {type = 'input', label = 'Label du job', description = 'Nom affiché du job', required = true, min = 2, max = 50}
                })
                
                if input then
                    local jobData = {name = input[1], label = input[2]}
                    CORE.trigger_server_callback("fafadev:to_server:create_job", function(success)
                        if success then
                            ESX.ShowNotification('Job créé avec succès !')
                            CORE.trigger_server_callback("fafadev:to_server:get_jobs", function(jobs)
                                TBL_JOBS = jobs
                            end)
                        else
                            ESX.ShowNotification('Erreur lors de la création du job')
                        end
                    end, jobData)
                end
            end
        })
        
        RageUI.Line()
        
        for name, job in pairs(TBL_JOBS) do
            local label = job.label or name
            local info = string.format("Compte: %s | Whitelisted: %s", job.accountName or "N/A", job.whitelisted == 1 and "Oui" or "Non")
            local submenu_key = "job_" .. name
            
            if not job_submenus[submenu_key] then
                job_submenus[submenu_key] = RageUI.CreateSubMenu(sub_menus_admin["jobs"], label, "Gestion du job")
            else
                job_submenus[submenu_key].Title = label
            end
            
            RageUI.Button(label, info, {RightLabel = "→→→"}, true, {
                onSelected = function() end
            }, job_submenus[submenu_key])
        end
    end)
    
    for submenu_key, submenu in pairs(job_submenus) do
        RageUI.IsVisible(submenu, function()
            local job_name = string.match(submenu_key, "job_(.+)")
            local job_data = TBL_JOBS[job_name]
            
            if job_data then
                local job_label = job_data.label or job_name
                
                RageUI.Separator("~b~" .. job_label .. "~s~")
                RageUI.Separator("~y~Informations~s~")
                RageUI.Button("Nom du job", job_data.name or "N/A", {}, false, {})
                RageUI.Button("Label du job", job_data.label or "N/A", {}, false, {})
                RageUI.Button("Whitelisted", job_data.whitelisted == 1 and "Oui" or "Non", {}, false, {})
                RageUI.Button("Grade patron", "Boss (Grade 1)", {}, false, {})
                RageUI.Button("Salaire patron", "500€", {}, false, {})
                RageUI.Button("Compte société", job_data.accountName or "N/A", {}, false, {})
                RageUI.Button("Label compte", job_data.accountLabel or "N/A", {}, false, {})
                
                RageUI.Line()
                
                RageUI.Button("Modifier les informations", "Modifier les paramètres du job", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        local input = lib.inputDialog("Modifier le job", {
                            {type = 'input', label = 'Nom du job', description = 'Nom unique du job', required = true, min = 2, max = 50, default = job_data.name or ""},
                            {type = 'input', label = 'Label du job', description = 'Nom affiché du job', required = true, min = 2, max = 50, default = job_data.label or ""}
                        })
                        
                        if input then
                            local jobData = {name = input[1], label = input[2]}
                            CORE.trigger_server_callback("fafadev:to_server:update_job", function(success)
                                if success then
                                    ESX.ShowNotification('Job modifié avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_jobs", function(jobs)
                                        TBL_JOBS = jobs
                                        if job_submenus[submenu_key] then
                                            job_submenus[submenu_key].Title = input[2]
                                        end
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la modification du job')
                                end
                            end, job_name, jobData)
                        end
                    end
                })
                
                RageUI.Button("Supprimer le job", "Supprimer définitivement ce job", {RightLabel = "~r~Supprimer~s~"}, true, {
                    onSelected = function()
                        local confirm = lib.alertDialog({
                            header = 'Confirmation',
                            content = 'Êtes-vous sûr de vouloir supprimer le job "' .. job_label .. '" ?',
                            centered = true,
                            cancel = true
                        })
                        if confirm == 'confirm' then
                            CORE.trigger_server_callback("fafadev:to_server:delete_job", function(success)
                                if success then
                                    ESX.ShowNotification('Job supprimé avec succès !')
                                    CORE.trigger_server_callback("fafadev:to_server:get_jobs", function(jobs)
                                        TBL_JOBS = jobs
                                    end)
                                else
                                    ESX.ShowNotification('Erreur lors de la suppression du job')
                                end
                            end, job_name)
                        end
                    end
                })
            end
        end)
    end
end

return jobs_builder