FAFA_JOB_EMPLOYEES = {}
FAFA_JOB_GRADE_JOB = {}
FAFA_JOB_SORTED_GRADE_JOB = {}
FAFA_JOB_PERMISSIONS = {}

function all_job_get_employees_list()
    CORE.trigger_server_callback("fafadev:to_server:boss_get_employees_list", function(employees)
        FAFA_JOB_EMPLOYEES = employees
    end)
end

function all_job_get_grade_job()
    CORE.trigger_server_callback("fafadev:to_server:boss_get_grade_job", function(grades)
        FAFA_JOB_GRADE_JOB = grades
        all_job_trier_grade_job()
    end)
end

function all_job_trier_grade_job()
    FAFA_JOB_SORTED_GRADE_JOB = {}
    for i = 1, #FAFA_JOB_GRADE_JOB do
        FAFA_JOB_SORTED_GRADE_JOB[i] = FAFA_JOB_GRADE_JOB[i]
    end
    
    for i = 1, #FAFA_JOB_SORTED_GRADE_JOB - 1 do
        for j = i + 1, #FAFA_JOB_SORTED_GRADE_JOB do
            if FAFA_JOB_SORTED_GRADE_JOB[i].grade < FAFA_JOB_SORTED_GRADE_JOB[j].grade then
                local tmp = FAFA_JOB_SORTED_GRADE_JOB[i]
                FAFA_JOB_SORTED_GRADE_JOB[i] = FAFA_JOB_SORTED_GRADE_JOB[j]
                FAFA_JOB_SORTED_GRADE_JOB[j] = tmp
            end
        end
    end
    return FAFA_JOB_SORTED_GRADE_JOB
end

function all_job_get_permissions(grade_name)
    CORE.trigger_server_callback("fafadev:to_server:boss_get_permissions", function(permissions)
        FAFA_JOB_PERMISSIONS = permissions
        -- Les permissions sont maintenant stockées dans FAFA_JOB_PERMISSIONS
    end, grade_name)
end
