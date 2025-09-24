TB_PEDS = {}

TB_PEDS.name = {
    {name = "a_m_m_golfer_01", category = "male"},
    {name = "a_m_m_polynesian_01", category = "male"},
}

TB_PEDS.categories = {
    {value = 'all', label = 'Tous les PNJ'},
    {value = 'male', label = 'Hommes'},
    {value = 'female', label = 'Femmes'},
    {value = 'animal', label = 'Animaux'},
    {value = 'police', label = 'Police'},
    {value = 'civilian', label = 'Civils'}
}

function TB_PEDS.filter_by_category(category_index)
    local filtered = {}
    local category_data = TB_PEDS.categories[category_index]
    
    if not category_data then return filtered end
    
    for _, pedData in ipairs(TB_PEDS.name) do
        if category_data.value == 'all' or pedData.category == category_data.value then
            table.insert(filtered, pedData.name)
        end
    end
    
    return filtered
end