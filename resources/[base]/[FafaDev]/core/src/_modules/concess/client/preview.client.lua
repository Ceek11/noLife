local open_preview_menu = false
local preview_menu = RageUI.CreateMenu("Prévisualisation", "Prévisualisation")
local preview_menu_vehicles = RageUI.CreateSubMenu(preview_menu, "Véhicules", "Véhicules")
local preview_menu_vehicle_details = RageUI.CreateSubMenu(preview_menu_vehicles, "Détails véhicule", "Détails véhicule")

preview_menu.Closed = function()
    open_preview_menu = false
    DeletePreviewVehicle()
end

preview_menu_vehicle_details.Closed = function()
    DeletePreviewVehicle()
end

function FUN_OPEN_PREVIEW_MENU(concessData)
    current_concess_data = concessData
    
    if concessData and concessData.spawnPositions and #concessData.spawnPositions > 0 then
        preview_spawn_coords = concessData.spawnPositions[1]
    end
    
    open_preview_menu = not open_preview_menu
    RageUI.Visible(preview_menu, open_preview_menu)
    if open_preview_menu then
        FUN_GET_CATEGORIES()
        CreateThread(function()
            while open_preview_menu do
                RageUI.IsVisible(preview_menu, function()
                    if current_concess_data and current_concess_data.categories then
                        for _, categoryName in pairs(current_concess_data.categories) do
                            local category = TBL_CATEGORIES[categoryName]
                            if category then
                                RageUI.Button(category.name, "Prévisualisation", {}, true, {
                                    onSelected = function()
                                        selected_category = category
                                        FUN_GET_VEHICLES(category.name)
                                    end
                                }, preview_menu_vehicles)
                            end
                        end
                    end
                end)
                
                RageUI.IsVisible(preview_menu_vehicles, function()
                    if selected_category then
                        RageUI.Separator(string.format("~b~Catégorie: %s", selected_category.name))
                    end
                    
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
                                if vehicle.model then
                                    CreatePreviewVehicle(vehicle.model)
                                end
                            end
                        }, preview_menu_vehicle_details)
                    end
                end)
                
                RageUI.IsVisible(preview_menu_vehicle_details, function()
                    if current_vehicle_data then
                        RageUI.Separator(string.format("~b~%s - %s$", current_vehicle_data.name, current_vehicle_data.price))
                        
                        if current_vehicle_data.model then
                            local seats = GetVehicleSeats(current_vehicle_data.model)
                            RageUI.Separator(string.format("Nombre de places: ~g~%d", seats))
                        end
                    end
                    
                    RageUI.Separator("")
                    RageUI.Button("Tester le véhicule", "Téléporter à la zone de test", {RightLabel = "→"}, true, {
                        onSelected = function()
                            if current_vehicle_data and current_vehicle_data.model then
                                SpawnTestVehicle(current_vehicle_data.model)
                            end
                        end
                    })
                end)
                
                Wait(0)
            end
        end)
    end
end