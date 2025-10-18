local open_preview_menu = false
local preview_menu = RageUI.CreateMenu("Prévisualisation", "Prévisualisation")
local preview_menu_vehicles = RageUI.CreateSubMenu(preview_menu, "Véhicules", "Véhicules")
local preview_menu_vehicle_details = RageUI.CreateSubMenu(preview_menu_vehicles, "Détails véhicule", "Détails véhicule")
preview_menu.Closed = function()
    open_preview_menu = false
end

function FUN_OPEN_PREVIEW_MENU()
    open_preview_menu = not open_preview_menu
    RageUI.Visible(preview_menu, open_preview_menu)
    if open_preview_menu then
        FUN_GET_CATEGORIES()
        CreateThread(function()
            while open_preview_menu do
                RageUI.IsVisible(preview_menu, function()
                    for _, category in pairs(TBL_CATEGORIES) do
                        RageUI.Button(category.name, "Prévisualisation", {}, true, {
                            onSelected = function()
                                FUN_GET_VEHICLES()
                            end
                        }, preview_menu_vehicles)
                    end
                end)
                RageUI.IsVisible(preview_menu_vehicles, function()
                    for _, vehicle in pairs(TBL_VEHICLES) do
                        RageUI.Button(vehicle.name, "Prévisualisation", {RightLabel = string.format("%s$", vehicle.price)}, true, {
                            onSelected = function()
                            end
                        }, preview_menu_vehicle_details)
                    end
                end)
                RageUI.IsVisible(preview_menu_vehicle_details, function()
                   RageUI.Button("Tester le véhicule", "Tester le véhicule", {}, true, {
                    onSelected = function()
                    end
                   })
                end)
                Wait(0)
            end
        end)
    end
end