local open_all_job_menu_boss = false
local all_job_obj_menu = RageUI.CreateMenu("Menu Boss", "Gestion des employés")
local all_job_obj_menu_employees = RageUI.CreateSubMenu(all_job_obj_menu, "Employés", "Liste des employés")
local all_job_obj_menu_employees_detail = RageUI.CreateSubMenu(all_job_obj_menu_employees, "Détails Employé", "Gestion d'un employé")
local all_job_obj_menu_permissions = RageUI.CreateSubMenu(all_job_obj_menu, "Permissions", "Gestion des permissions")
local all_job_obj_menu_salaries = RageUI.CreateSubMenu(all_job_obj_menu, "Salaires", "Gestion des salaires")
local all_job_obj_menu_history = RageUI.CreateSubMenu(all_job_obj_menu, "Historique", "Historique des actions")
local all_job_obj_menu_permissions_detail = RageUI.CreateSubMenu(all_job_obj_menu_permissions, "Détails Permissions", "Modifier les permissions")
all_job_obj_menu.Closed = function()
    open_all_job_menu_boss = false
end

local all_job_index_action_employees = 1
local all_job_index_employees_detail = nil
local all_job_index_permissions_detail = nil
local all_job_selected_grade_data = nil


function all_job_menu_boss()
    open_all_job_menu_boss = not open_all_job_menu_boss
    RageUI.Visible(all_job_obj_menu, open_all_job_menu_boss)
    if open_all_job_menu_boss then
        CreateThread(function()
            while open_all_job_menu_boss do
                RageUI.IsVisible(all_job_obj_menu, function()
                    RageUI.Separator(" GESTION BOSS ")
                    RageUI.Button("Employés", nil, {}, true, {
                        onSelected = function()
                            all_job_get_employees_list()
                            all_job_get_grade_job()
                        end
                    }, all_job_obj_menu_employees)
                    RageUI.Button("Permissions", nil, {}, true, {
                        onSelected = function()
                            all_job_get_grade_job()
                        end
                    }, all_job_obj_menu_permissions)  
                    RageUI.Button("Salaires", nil, {}, true, {
                        onSelected = function()
                            all_job_get_grade_job()
                        end
                    }, all_job_obj_menu_salaries)
                    RageUI.Button("Historique", nil, {}, true, {
                        onSelected = function() end
                    }, all_job_obj_menu_history)
                end)
                
                RageUI.IsVisible(all_job_obj_menu_employees, function()
                    RageUI.Separator(" GESTION EMPLOYÉS ")
                    RageUI.List("Actions employés", {"Recruter", "Licencier", "Promouvoir", "Rétrograder"}, all_job_index_action_employees, nil, {}, true, {
                        onListChange = function(Index, Item)
                            all_job_index_action_employees = Index
                        end,
                        onSelected = function(Index, Item)
                            local targetT = CORE.get_nearby_player(false, true)
                            if targetT then
                                CORE.trigger_server_event("fafadev:to_server:boss_action_employees", GetPlayerServerId(targetT), Index)
                            end
                        end
                    })
                    RageUI.Line()
                    
                    local hasEmployees = false
                    for k, v in pairs(FAFA_JOB_EMPLOYEES) do
                        hasEmployees = true
                        
                        local statusText = v.is_online and "En ligne" or "Hors ligne"
                        local description = ("%s | %s | %s"):format(
                            "Grade: " .. (v.grade_label or "Inconnu"),
                            "Salaire: " .. (v.salary or 0) .. "$",
                            "Statut: " .. statusText
                        )
                        
                        local displayName = ("%s | %s"):format(v.grade_label or "Inconnu", v.name)
                        RageUI.Button(displayName, description, {}, true, {
                            onSelected = function()
                                all_job_index_employees_detail = k
                            end
                        }, all_job_obj_menu_employees_detail)
                    end
                    
                    if not hasEmployees then
                        RageUI.Button("Aucun employé", nil, {}, true, {
                            onSelected = function() end
                        })
                    end
                end)
            
                RageUI.IsVisible(all_job_obj_menu_employees_detail, function()
                    if not all_job_index_employees_detail or not FAFA_JOB_EMPLOYEES[all_job_index_employees_detail] then
                        RageUI.Button("Erreur", nil, {}, true, {
                            onSelected = function() end
                        })
                        return
                    end
                    
                    local employee = FAFA_JOB_EMPLOYEES[all_job_index_employees_detail]
                    RageUI.Separator(employee.name)
                    RageUI.Line()
                    
                    for _, gradeData in ipairs(FAFA_JOB_SORTED_GRADE_JOB) do
                        local rightLabel = employee.grade == gradeData.grade and "Actuel" or "Promouvoir"
                        RageUI.Button(gradeData.label, "Salaire: " .. gradeData.salary .. "$", {RightLabel = rightLabel}, true, {
                            onSelected = function()
                                CORE.trigger_server_event("fafadev:to_server:boss_promote_employee", FAFA_JOB_EMPLOYEES[all_job_index_employees_detail], gradeData.grade, gradeData.label)
                            end
                        })
                    end
                    
                    RageUI.Button("Licencier", nil, {RightLabel = "~r~Licencier"}, true, {
                        onSelected = function()
                            CORE.trigger_server_event("fafadev:to_server:boss_fire_employee", FAFA_JOB_EMPLOYEES[all_job_index_employees_detail])
                        end
                    })
                end)
            
                RageUI.IsVisible(all_job_obj_menu_salaries, function()
                    RageUI.Separator(" GESTION SALAIRES ")
                    if not FAFA_JOB_GRADE_JOB or next(FAFA_JOB_GRADE_JOB) == nil then
                        RageUI.Separator("Aucun grade disponible")
                        return
                    end
                    
                    for _, gradeData in ipairs(FAFA_JOB_SORTED_GRADE_JOB) do
                        RageUI.Button(gradeData.label, "Salaire: " .. gradeData.salary .. "$", {RightLabel = "Modifier"}, true, {
                            onSelected = function()
                                local input = lib.inputDialog("Modifier le salaire", {
                                    {
                                        type = "number",
                                        label = "Salaire pour " .. gradeData.label,
                                        description = "Entrez le nouveau salaire pour ce grade",
                                        min = 0,
                                        max = 100000,
                                        default = gradeData.salary,
                                        required = true
                                    }
                                })
                                
                                if input and input[1] then
                                    CORE.trigger_server_event("fafadev:to_server:boss_update_salary", gradeData.grade, input[1], gradeData.label)
                                end
                            end
                        })
                    end
                end)
            
            
                RageUI.IsVisible(all_job_obj_menu_permissions, function()
                    RageUI.Separator(" GESTION PERMISSIONS ")
                    RageUI.Button("Créer un grade", nil, {}, true, {
                        onSelected = function()
                            local input = lib.inputDialog("Créer un nouveau grade", {
                                {type = "input",label = "Nom du grade",description = "Nom interne du grade (ex: boss, employee)", required = true},
                                {type = "number", label = "Salaire", description = "Salaire du grade en dollars", min = 0, max = 100000, required = true},
                                {type = "number", label = "Niveau", description = "Niveau hiérarchique du grade (0 = plus bas)", min = 0, max = 10, required = true},
                                {type = "input",label = "Label",description = "Nom affiché du grade (ex: Patron, Employé)", required = true},
                            })
                            if input then
                                CORE.trigger_server_event("fafadev:to_server:boss_create_grade", input)
                            end
                        end
                    })
                    RageUI.Line()
                    for i, gradeData in ipairs(FAFA_JOB_SORTED_GRADE_JOB) do
                        local displayGrade = ("%d. %s"):format(gradeData.grade, gradeData.label)
                        RageUI.Button(displayGrade, nil, {}, true, {
                            onSelected = function()
                                all_job_get_permissions(gradeData.name)
                                all_job_index_permissions_detail = i
                                all_job_selected_grade_data = gradeData
                            end
                        }, all_job_obj_menu_permissions_detail)
                    end
                end)
            
                RageUI.IsVisible(all_job_obj_menu_permissions_detail, function()
                    RageUI.Separator(" MODIFIER PERMISSIONS ")
                    RageUI.Button("Modifier le grade", nil, {}, true, {
                        onSelected = function()
                            local input = lib.inputDialog("Modifier le grade", {
                                {type = "input",label = "Nom du grade",description = "Nom interne du grade", required = true},
                                {type = "number", label = "Salaire", description = "Salaire du grade", min = 0, max = 100000, required = true},
                                {type = "number", label = "Niveau", description = "Niveau hiérarchique", min = 0, max = 10, required = true},
                                {type = "input",label = "Label",description = "Nom affiché du grade", required = true},
                            })
                            if input and all_job_selected_grade_data then
                                CORE.trigger_server_event("fafadev:to_server:boss_modify_grade", input, all_job_selected_grade_data.name)
                            end
                        end
                    })
                    RageUI.Button("Supprimer le grade", nil, {}, true, {
                        onSelected = function()
                            local input = lib.inputDialog("Confirmer la suppression", {
                                {type = "checkbox",label = "Je confirme la suppression",description = "Cocher pour confirmer la suppression du grade"},
                            })
                            if input then
                                if input[1] then
                                    CORE.trigger_server_event("fafadev:to_server:boss_delete_grade", all_job_selected_grade_data.name)
                                end
                            end
                        end
                    })
                    RageUI.Line()
                    for k, v in pairs(FAFA_JOB_PERMISSIONS) do
                        RageUI.Checkbox(k, nil, v, {}, {
                            onChecked = function()
                                if all_job_selected_grade_data then
                                    local bool_new_state = not FAFA_JOB_PERMISSIONS[k]
                                    FAFA_JOB_PERMISSIONS[k] = bool_new_state
                                    CORE.trigger_server_event("fafadev:to_server:boss_update_permissions", FAFA_JOB_PERMISSIONS, all_job_selected_grade_data.name)
                                end
                            end,
                            onUnChecked = function()
                                if all_job_selected_grade_data then
                                    local bool_new_state = not FAFA_JOB_PERMISSIONS[k]
                                    FAFA_JOB_PERMISSIONS[k] = bool_new_state
                                    CORE.trigger_server_event("fafadev:to_server:boss_update_permissions", FAFA_JOB_PERMISSIONS, all_job_selected_grade_data.name)
                                end
                            end
                        })
                    end
                end)
                Wait(0)
            end
        end)
    end
end

