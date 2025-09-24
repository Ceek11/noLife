chest_items_cache = {}
chest_info = {current_weight = 0, max_weight = 100}
chest_items_cache = {}


function load_chest_info()
    ESX.TriggerServerCallback("templatejobto_server:get_chest_info", function(info)
        chest_info = info
    end)
end

function load_chest_items()
    ESX.TriggerServerCallback("templatejobto_server:get_chest_items", function(chestItems)
        chest_items_cache = chestItems
    end)
end
