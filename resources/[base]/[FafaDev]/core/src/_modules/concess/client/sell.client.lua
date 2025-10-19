local open_sell_menu = false
local sell_menu = RageUI.CreateMenu("Vente de véhicules", "Vente de véhicules")
local sell_menu_vehicle_details = RageUI.CreateSubMenu(sell_menu, "Détails du véhicule", "Détails du véhicule")
sell_menu.Closed = function()
    open_sell_menu = false
end

function FUN_OPEN_SELL_MENU(concessData)
    current_concess_data = concessData
    open_sell_menu = not open_sell_menu
    RageUI.Visible(sell_menu, open_sell_menu)
    if open_sell_menu then
        if concessData and concessData.categories then
            FUN_GET_VEHICLES_BY_CATEGORIES(concessData.categories)
        else
            FUN_GET_VEHICLES(nil)
        end
        CreateThread(function()
            while open_sell_menu do
                RageUI.IsVisible(sell_menu, function()
                    RageUI.Separator("~b~Filtres")
                    RageUI.Button("Rechercher", "Entrez un nom de véhicule", {RightLabel = search_filter ~= "" and search_filter or "Aucun"}, true, {
                        onSelected = function()
                            local input = lib.inputDialog("Recherche", {
                                {type = 'input', label = 'Nom du véhicule', placeholder = 'Nom du véhicule', maxLength = 30}
                            })
                            if input and input[1] then
                                search_filter = input[1]
                            end
                        end
                    })
                    
                    RageUI.List("Trier par", {"Prix croissant", "Prix décroissant", "Nom A-Z", "Nom Z-A"}, 
                        sort_type == "price_asc" and 1 or sort_type == "price_desc" and 2 or sort_type == "name_asc" and 3 or 4, 
                        nil, {}, true, {
                        onListChange = function(index)
                            if index == 1 then sort_type = "price_asc"
                            elseif index == 2 then sort_type = "price_desc"
                            elseif index == 3 then sort_type = "name_asc"
                            elseif index == 4 then sort_type = "name_desc"
                            end
                        end
                    })
                    
                    RageUI.Button("Prix min", "Définir le prix minimum", {RightLabel = string.format("%s$", price_min_filter)}, true, {
                        onSelected = function()
                            local input = lib.inputDialog("Prix minimum", {
                                {type = 'number', label = 'Prix minimum', default = price_min_filter, min = 0}
                            })
                            if input and input[1] then
                                price_min_filter = tonumber(input[1])
                            end
                        end
                    })
                    
                    RageUI.Button("Prix max", "Définir le prix maximum", {RightLabel = price_max_filter == 999999999 and "Illimité" or string.format("%s$", price_max_filter)}, true, {
                        onSelected = function()
                            local input = lib.inputDialog("Prix maximum", {
                                {type = 'number', label = 'Prix maximum', default = price_max_filter == 999999999 and 999999999 or price_max_filter, min = 0}
                            })
                            if input and input[1] then
                                price_max_filter = tonumber(input[1])
                            end
                        end
                    })
                    
                    RageUI.Button("~r~Reset", "Supprimer tous les filtres", {}, true, {
                        onSelected = function()
                            search_filter = ""
                            price_min_filter = 0
                            price_max_filter = 999999999
                            sort_type = "price_asc"
                        end
                    })
                    
                    RageUI.Separator("~b~Véhicules")
                    
                    local filteredVehicles = FilterVehicles(TBL_VEHICLES)
                    filteredVehicles = SortVehicles(filteredVehicles)
                    
                    for _, vehicle in pairs(filteredVehicles) do
                        RageUI.Button(vehicle.name, nil, {RightLabel = string.format("%s$", vehicle.price)}, true, {
                            onSelected = function()
                                current_vehicle_data = vehicle
                            end
                        }, sell_menu_vehicle_details)
                    end
                end)
                
                RageUI.IsVisible(sell_menu_vehicle_details, function()
                    if current_vehicle_data then
                        RageUI.Separator(string.format("~b~%s - %s$", current_vehicle_data.name, current_vehicle_data.price))
                        
                        if current_vehicle_data.model then
                            local seats = GetVehicleSeats(current_vehicle_data.model)
                            RageUI.Separator(string.format("Nombre de places: ~g~%d", seats))
                        end
                    end
                    
                    RageUI.Separator("")
                    RageUI.Button("Acheter le véhicule", "Acheter ce véhicule", {RightLabel = "→"}, true, {
                        onSelected = function()
                            if current_vehicle_data then
                                StartVehicleSale()
                            end
                        end
                    })
                end)
                Wait(0)
            end
        end)
    end
end