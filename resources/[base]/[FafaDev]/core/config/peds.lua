CONFIG_PEDS = {
    scenario_list = {
        "WORLD_HUMAN_CLIPBOARD",
        "WORLD_HUMAN_AA_COFFEE",
        "WORLD_HUMAN_AA_SMOKE",
        "WORLD_HUMAN_AA_DRINK",
        "WORLD_HUMAN_AA_DRINK_BEER",
        "WORLD_HUMAN_AA_DRINK_WINE",
        "WORLD_HUMAN_SMOKING",
        "WORLD_HUMAN_STAND_MOBILE",
        "WORLD_HUMAN_GUARD_STAND",
        "WORLD_HUMAN_LEANING",
    },
    
    anim_list = {
        clipboard = {
            dict = "mp_player_int_upper_business_suit", 
            anim = "mp_player_int_business_no_cellphone"
        },
        guard = {
            dict = "amb@world_human_guard_stand@male@base",
            anim = "base"
        },
        leaning = {
            dict = "amb@world_human_leaning@male@wall@back@legs_crossed@base",
            anim = "base"
        },
    },
    
    default_options = {
        invincible = true,
        freeze = true,
        blockEvents = true,
        canRagdoll = false,
        canPlayAmbient = true,
        randomScenario = true,
    },
    
    behavior_list = {
        {
            id = "normal",
            label = "Normal",
            description = "Comportement normal (invincible, figé)",
            options = {
                invincible = true,
                freeze = true,
                blockEvents = true,
                canRagdoll = false,
                canPlayAmbient = true,
            }
        },
        {
            id = "reactive",
            label = "Réactif",
            description = "Réagit aux événements (peut fuir, tomber)",
            options = {
                invincible = true,
                freeze = false,
                blockEvents = false,
                canRagdoll = true,
                canPlayAmbient = true,
            }
        },
        {
            id = "immortal_static",
            label = "Immortel statique",
            description = "Totalement figé et invincible",
            options = {
                invincible = true,
                freeze = true,
                blockEvents = true,
                canRagdoll = false,
                canPlayAmbient = false,
            }
        },
        {
            id = "mortal",
            label = "Mortel",
            description = "Peut être tué et réagit aux événements",
            options = {
                invincible = false,
                freeze = false,
                blockEvents = false,
                canRagdoll = true,
                canPlayAmbient = true,
            }
        },
    },
}