local obj_menu_chest = zUI.CreateMenu(T("chest_title"), "", T("chest_subtitle"), CONFIG_INFOS_JOB.design_menu)
local obj_menu_chest_deposit = zUI.CreateSubMenu(obj_menu_chest, T("chest_deposit_title"), "", T("chest_deposit_title"))
local obj_menu_chest_withdraw = zUI.CreateSubMenu(obj_menu_chest, T("chest_withdraw_title"), "", T("chest_withdraw_title"))

local current_filter = 1

function menu_chest()
    load_chest_info()
    zUI.SetVisible(obj_menu_chest, true)
end


zUI.SetItems(obj_menu_chest, function()
    zUI.Separator(T("chest_weight_info", chest_info.current_weight, chest_info.max_weight), "center")
    zUI.Button(T("chest_deposit_button"), nil, {}, function(onSelected) end, obj_menu_chest_deposit)
    zUI.Button(T("chest_withdraw_button"), nil, {}, function(onSelected) 
        if onSelected then
            load_chest_items()
        end
    end, obj_menu_chest_withdraw)
end)

zUI.SetItems(obj_menu_chest_deposit, function()
    zUI.Separator(T("chest_deposit_separator"), "center")
    
    local obj_player_data = ESX.GetPlayerData()
    zUI.Line()

    zUI.List(T("chest_filter_label"), T("chest_filter_description"), {T("chest_filter_items"), T("chest_filter_weapons")}, current_filter, {}, function(onSelected, onChange, index)
        if onChange then
            current_filter = index
        end
    end)

    local tbl_player_inventory = current_filter == 1 and obj_player_data.inventory or obj_player_data.loadout
    local filtered_inventory = {}

    for _, item in pairs(tbl_player_inventory) do
        if (current_filter == 1 and item.count > 0) or current_filter == 2 then
            filtered_inventory[#filtered_inventory + 1] = item
        end
    end

    for i = 1, #filtered_inventory do
        local v = filtered_inventory[i]
        local qty = v.count or v.ammo or 0
        zUI.Button(v.label, nil, { RightLabel = ("~r~x%s"):format(qty) }, function(onSelected)
            if onSelected then
                local input = lib.inputDialog(T("chest_quantity_dialog_title"), {
                    { type = "number", label = T("chest_quantity_label"), min = 1, max = qty }
                })
                if input then
                    local selectedQty = tonumber(input[1])
                    if selectedQty and selectedQty > 0 and selectedQty <= qty then
                        TriggerServerEvent("templatejobto_server:deposit_item", v, selectedQty)
                        load_chest_info()
                    else
                        ESX.ShowNotification(T("chest_invalid_quantity"))
                    end
                end
            end
        end)
    end
end)


zUI.SetItems(obj_menu_chest_withdraw, function()
    zUI.Separator(T("chest_withdraw_separator"), "center")
    
    if #chest_items_cache == 0 then
        zUI.Button(T("chest_empty"), nil, {}, function(onSelected) end)
        return
    end
    
    for i = 1, #chest_items_cache do
        local item = chest_items_cache[i]
        zUI.Button(item.label, nil, { RightLabel = ("~g~x%s"):format(item.quantity) }, function(onSelected)
            if onSelected then
                local input = lib.inputDialog(T("chest_quantity_dialog_title"), {
                    { type = "number", label = T("chest_quantity_label"), min = 1, max = item.quantity }
                })
                if input then
                    local selectedQty = tonumber(input[1])
                    if selectedQty and selectedQty > 0 and selectedQty <= item.quantity then
                        TriggerServerEvent("templatejobto_server:withdraw_item", item, selectedQty)
                        load_chest_items()
                        load_chest_info()
                    else
                        ESX.ShowNotification(T("chest_invalid_quantity"))
                    end
                end
            end
        end)
    end
end)
