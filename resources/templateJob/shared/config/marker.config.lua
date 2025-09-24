TBL_MARKER_DESIGN = {
    ["default"] = {
        marker_type = 22,
        marker_color = {r = 137, g = 201, b = 17, a = 255},
        marker_size = {x = 0.5, y = 0.5, z = 0.5},
        marker_rotation = {x = 0.0, y = 0.0, z = 0.0},
        bobUpAndDown = false, 
        faceCamera = false,
        rotate = false,
        draw_distance = 5.0,
        help_distance = 2.0,
        enable_alpha_transition = true,
        fadeIn_duration = 2000,
        fadeOut_duration = 1200,
        min_alpha = 55, 
        max_alpha = 255, 
    }
}


TBL_MARKERS_POINT = {
    {
        type = "boss",
        job_name = CONFIG_INFOS_JOB.job_name,
        coords = {
            {x = -1107.47, y = -832.27, z = 38.70}, 
        },
        onSelected = function()
            menu_boss()
        end
    },
    {
        type = "chest",
        job_name = CONFIG_INFOS_JOB.job_name,
        coords = {
            {x = -1100.47, y = -832.27, z = 38.70}, 
        },
        onSelected = function()
            menu_chest()
        end
    },
}