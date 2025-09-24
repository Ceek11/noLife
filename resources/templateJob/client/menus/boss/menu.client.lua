local obj_menu = zUI.CreateMenu(T("menu_boss_title"), "", T("menu_boss_subtitle"), CONFIG_INFOS_JOB.design_menu)
local obj_menu_employees = zUI.CreateSubMenu(obj_menu, T("menu_employees_title"), "", T("menu_employees_title"))
local obj_menu_employees_detail = zUI.CreateSubMenu(obj_menu_employees, T("menu_employee_detail_title"), "", T("menu_employee_detail_title"))
local obj_menu_permissions = zUI.CreateSubMenu(obj_menu, T("menu_permissions_title"), "", T("menu_permissions_title"))
local obj_menu_salaries = zUI.CreateSubMenu(obj_menu, T("menu_salaries_title"), "", T("menu_salaries_title"))
local obj_menu_history = zUI.CreateSubMenu(obj_menu, T("menu_history_title"), "", T("menu_history_title"))
local obj_menu_permissions_detail = zUI.CreateSubMenu(obj_menu_permissions, T("menu_permissions_detail_title"), "", T("menu_permissions_detail_title"))
local index_action_employees = 1
local index_employees_detail = nil
local index_permissions_detail = nil
local selected_grade_data = nil


function menu_boss()
    zUI.SetVisible(obj_menu, true)
end

zUI.SetItems(obj_menu, function()
    zUI.Separator(T("menu_boss_separator"), "center")
    zUI.Button(T("menu_employees_title"), nil, {}, function(onSelected) 
        get_employees_list()
        get_grade_job()
    end, obj_menu_employees)
    zUI.Button(T("menu_permissions_title"), nil, {}, function(onSelected) 
        if onSelected then
            get_grade_job()
        end
    end, obj_menu_permissions)  
    zUI.Button(T("menu_salaries_title"), nil, {}, function(onSelected) 
        if onSelected then
            get_grade_job()
        end
    end, obj_menu_salaries)
    zUI.Button(T("menu_history_title"), nil, {}, function(onSelected) end, obj_menu_history)
end)

zUI.SetItems(obj_menu_employees, function()
    zUI.Separator(T("menu_employees_separator"), "center")
    zUI.List(T("menu_employees_actions"), "", {T("menu_employees_recruit"), T("menu_employees_fire"), T("menu_employees_promote"), T("menu_employees_demote")}, index_action_employees, {}, function(onSelected, onChange, index) 
        if onChange then
            index_action_employees = index
        end
        if onSelected then
            local targetT = get_nearby_player(false, true)
            if not targetT then return end
            TriggerServerEvent("templatejob:to_server:action_employees", targetT, index)
        end
    end)
    zUI.Line()
    
    local hasEmployees = false
    for k, v in pairs(TBL_EMPLOYEES) do
        hasEmployees = true
        
        -- Créer la description complète
        local statusText = v.is_online and T("menu_employees_online") or T("menu_employees_offline")
        local description = ("%s | %s | %s"):format(
            T("menu_employees_grade", v.grade_label),
            T("menu_employees_salary", v.salary or 0),
            T("menu_employees_status", statusText)
        )
        
        zUI.Button(v.name, description, {}, function(onSelected) 
            index_employees_detail = k
        end, obj_menu_employees_detail)
    end
    
    if not hasEmployees then
        zUI.Button(T("menu_employees_no_employees"), nil, {}, function(onSelected) end)
    end
end)

zUI.SetItems(obj_menu_employees_detail, function()
    if not index_employees_detail or not TBL_EMPLOYEES[index_employees_detail] then
        zUI.Button(T("menu_employees_error"), nil, {}, function(onSelected) end)
        return
    end
    
    local employee = TBL_EMPLOYEES[index_employees_detail]
    zUI.Separator(T("menu_employee_detail_separator", employee.name), "center")
    zUI.Line()
    
    for _, gradeData in ipairs(TBL_SORTED_GRADE_JOB) do
        local rightLabel = employee.grade == gradeData.grade and T("menu_employee_current") or T("menu_employee_promote")
        zUI.Button(gradeData.label, T("menu_employees_salary", gradeData.salary), {RightLabel = rightLabel}, function(onSelected) 
            if onSelected then
                TriggerServerEvent("templatejob:to_server:promote_employee", TBL_EMPLOYEES[index_employees_detail], gradeData.grade, gradeData.label)
            end
        end)
    end
    
    zUI.Button(T("menu_employee_fire"), nil, {RightLabel = T("menu_employee_fire_label")}, function(onSelected) 
        if onSelected then
            TriggerServerEvent("templatejob:to_server:fire_employee", TBL_EMPLOYEES[index_employees_detail])
        end
    end)
end)

zUI.SetItems(obj_menu_salaries, function()
    zUI.Separator(T("menu_salaries_separator"), "center")
    if not TBL_GRADE_JOB or next(TBL_GRADE_JOB) == nil then
        zUI.Separator(T("menu_salaries_no_grades"), "center")
        return
    end
    
    for _, gradeData in ipairs(TBL_SORTED_GRADE_JOB) do
        zUI.Button(gradeData.label, T("menu_employees_salary", gradeData.salary), {RightLabel = T("menu_salaries_modify")}, function(onSelected) 
            if onSelected then
                local input = lib.inputDialog(T("menu_salaries_dialog_title"), {
                    {
                        type = "number",
                        label = T("menu_salaries_dialog_label", gradeData.label),
                        description = T("menu_salaries_dialog_description"),
                        min = 0,
                        max = CONFIG_INFOS_JOB.max_salary,
                        default = gradeData.salary,
                        required = true
                    }
                })
                
                if input and input[1] then
                    TriggerServerEvent("templatejob:to_server:update_salary", gradeData.grade, input[1], gradeData.label)
                end
            end
        end)
    end
end)


zUI.SetItems(obj_menu_permissions, function()
    zUI.Separator(T("menu_permissions_separator"), "center")
    zUI.Button(T("menu_permissions_create_grade"), nil, {}, function(onSelected) 
        if onSelected then
            local input = lib.inputDialog(T("dialog_create_grade_title"), {
                {type = "input",label = T("dialog_create_grade_name"),description = T("dialog_create_grade_name_desc"), required = true},
                {type = "number", label = T("dialog_create_grade_salary"), description = T("dialog_create_grade_salary_desc"), min = 0, max = CONFIG_INFOS_JOB.max_salary, required = true},
                {type = "number", label = T("dialog_create_grade_grade"), description = T("dialog_create_grade_grade_desc"), min = 0, max = CONFIG_INFOS_JOB.max_grade, required = true},
                {type = "input",label = T("dialog_create_grade_label"),description = T("dialog_create_grade_label_desc"), required = true},
            })
            if input then
                TriggerServerEvent("templatejob:to_server:create_grade", input)
            end
        end
    end)
    zUI.Line()
    for i, gradeData in ipairs(TBL_SORTED_GRADE_JOB) do
        zUI.Button(gradeData.label, nil, {}, function(onSelected) 
            if onSelected then
                get_permissions(gradeData.name)
                index_permissions_detail = i
                selected_grade_data = gradeData
            end
        end, obj_menu_permissions_detail)
    end
end)

zUI.SetItems(obj_menu_permissions_detail, function()
    zUI.Separator(T("menu_permissions_separator"), "center")
    zUI.Button(T("menu_permissions_modify_grade"), nil, {}, function(onSelected) 
        if onSelected then
            local input = lib.inputDialog(T("dialog_modify_grade_title"), {
                {type = "input",label = T("dialog_modify_grade_name"),description = T("dialog_modify_grade_name_desc"), required = true},
                {type = "number", label = T("dialog_modify_grade_salary"), description = T("dialog_modify_grade_salary_desc"), min = 0, max = CONFIG_INFOS_JOB.max_salary, required = true},
                {type = "number", label = T("dialog_modify_grade_grade"), description = T("dialog_modify_grade_grade_desc"), min = 0, max = CONFIG_INFOS_JOB.max_grade, required = true},
                {type = "input",label = T("dialog_modify_grade_label"),description = T("dialog_modify_grade_label_desc"), required = true},
            })
            if input and selected_grade_data then
                TriggerServerEvent("templatejob:to_server:modify_grade", input, selected_grade_data.name)
            end
        end
    end)
    zUI.Button(T("menu_permissions_delete_grade"), nil, {}, function(onSelected) 
        if onSelected then
            local input = lib.inputDialog(T("dialog_modify_grade_title"), {
                {type = "checkbox",label = T("dialog_modify_grade_delete"),description = T("dialog_modify_grade_delete_desc")},
            })
            if input then
                if input[1] then
                    TriggerServerEvent("templatejob:to_server:delete_grade", selected_grade_data.name)
                end
            end
        end
    end)
    zUI.Line()
    for k, v in pairs(TBL_PERMISSIONS) do
        zUI.Checkbox(k, nil, v, {}, function(onSelected)
            if onSelected and selected_grade_data then
                local bool_new_state = not TBL_PERMISSIONS[k]
                TBL_PERMISSIONS[k] = bool_new_state
                TriggerServerEvent("templatejob:to_server:update_permissions", TBL_PERMISSIONS, selected_grade_data.name)
            end
        end)
    end
end)



