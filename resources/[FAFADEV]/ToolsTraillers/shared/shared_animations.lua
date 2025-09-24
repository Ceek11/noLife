TB_ANIMATIONS = {}

TB_ANIMATIONS.name = {
    {name = "Salut", dict = "gestures@m@standing@casual", anim = "gesture_hello", category = "geste", duration = 3000},
    {name = "Pointer", dict = "gestures@m@standing@casual", anim = "gesture_point", category = "geste", duration = 3000},
    {name = "Danse Woogie", dict = "anim@mp_player_intcelebrationmale@the_woogie", anim = "the_woogie", category = "danse", duration = 10000},
    {name = "S'asseoir", dict = "anim@heists@prison_heistig_5_p1_guard_checks_bus", anim = "loop", category = "pose", duration = -1},
    {name = "S'allonger", dict = "switch@michael@bed", anim = "sleep_loop", category = "pose", duration = -1},
    {name = "Fumer", dict = "amb@world_human_smoking@male@male_a@base", anim = "base", category = "pose", duration = -1},
    {name = "Boire", dict = "amb@world_human_drinking@beer@male@idle_a", anim = "idle_a", category = "pose", duration = 5000},
    {name = "Téléphoner", dict = "cellphone@", anim = "cellphone_call_listen_base", category = "pose", duration = -1},
    {name = "Applaudir", dict = "mp_player_intcelebrationmale@clapping", anim = "clapping", category = "geste", duration = 5000},
    {name = "Bras croisés", dict = "amb@world_human_hang_out_street@male_a@idle_a", anim = "idle_a", category = "pose", duration = -1}
}

TB_ANIMATIONS.categories = {
    {value = 'all', label = 'Toutes les animations'},
    {value = 'danse', label = 'Danses'},
    {value = 'geste', label = 'Gestes'},
    {value = 'pose', label = 'Poses'},
    {value = 'mouvement', label = 'Mouvements'},
    {value = 'emotion', label = 'Émotions'}
}

function TB_ANIMATIONS.filter_by_category(category_index)
    local filtered = {}
    local category_data = TB_ANIMATIONS.categories[category_index]
    
    if not category_data then return filtered end
    
    for _, animData in ipairs(TB_ANIMATIONS.name) do
        if category_data.value == 'all' or animData.category == category_data.value then
            table.insert(filtered, animData)
        end
    end
    
    return filtered
end