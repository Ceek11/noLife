TBL_EMPLOYEES = {}
TBL_GRADE_JOB = {}
TBL_SORTED_GRADE_JOB = {}
TBL_PERMISSIONS = {}

function get_employees_list()
    ESX.TriggerServerCallback("templatejob:to_server:get_employees_list", function(employees)
        TBL_EMPLOYEES = employees
    end)
end

function get_grade_job()
    ESX.TriggerServerCallback("templatejob:to_server:get_grade_job", function(grades)
        TBL_GRADE_JOB = grades
        trier_grade_job()
    end)
end

function trier_grade_job()
    -- Copie directe du tableau (TBL_GRADE_JOB est maintenant un tableau indexé numériquement)
    TBL_SORTED_GRADE_JOB = {}
    for i = 1, #TBL_GRADE_JOB do
        TBL_SORTED_GRADE_JOB[i] = TBL_GRADE_JOB[i]
    end
    
    -- Tri manuel (bubble sort décroissant)
    for i = 1, #TBL_SORTED_GRADE_JOB - 1 do
        for j = i + 1, #TBL_SORTED_GRADE_JOB do
            if TBL_SORTED_GRADE_JOB[i].grade < TBL_SORTED_GRADE_JOB[j].grade then
                local tmp = TBL_SORTED_GRADE_JOB[i]
                TBL_SORTED_GRADE_JOB[i] = TBL_SORTED_GRADE_JOB[j]
                TBL_SORTED_GRADE_JOB[j] = tmp
            end
        end
    end
    return TBL_SORTED_GRADE_JOB
end

function get_permissions(grade_name)
    ESX.TriggerServerCallback("templatejob:to_server:get_permissions", function(permissions)
        TBL_PERMISSIONS = permissions
        local playerData = ESX.GetPlayerData()
        if playerData and playerData.job and playerData.job.grade_name == grade_name then
            update_player_permissions(permissions)
        end
    end, grade_name)
end