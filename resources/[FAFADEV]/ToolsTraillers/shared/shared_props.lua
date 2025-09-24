TB_PROPS = {}

TB_PROPS.name = {
    {name = "prop_bench_01a", category = "bench"},
}

TB_PROPS.categories = {
    {value = 'all', label = 'Tous les props'},
    {value = 'bench', label = 'Bancs'},
    {value = 'chair', label = 'Chaises'},
    {value = 'table', label = 'Tables'},
    {value = 'decoration', label = 'Décorations'},
    {value = 'vehicle', label = 'Véhicules'},
    {value = 'weapon', label = 'Armes'},
    {value = 'furniture', label = 'Mobilier'}
}

function TB_PROPS.filter_by_category(category_index)
    local filtered = {}
    local category_data = TB_PROPS.categories[category_index]
    
    if not category_data then return filtered end
    
    for _, propData in ipairs(TB_PROPS.name) do
        if category_data.value == 'all' or propData.category == category_data.value then
            table.insert(filtered, propData.name)
        end
    end
    
    return filtered
end