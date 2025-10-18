local open_menu_location = false
local menu_location = RageUI.CreateMenu("locations", "Locations")   
local current_rented_vehicle = nil
local current_deposit = 0

menu_location.Close = function()
    open_menu_location = false
end

function FUNC_OPEN_MENU_LOCATION(data)
    open_menu_location = not open_menu_location
    RageUI.Visible(menu_location, open_menu_location)
    if open_menu_location then
        CreateThread(function()
            while open_menu_location do
                RageUI.IsVisible(menu_location, function()
                    if current_rented_vehicle then
                        RageUI.Button("~r~Retourner le véhicule", string.format("Récupérer votre caution de %s$", current_deposit), {}, true, {
                            onSelected = function()
                                TriggerServerEvent("fafadev:to_server:return_vehicle")
                                current_rented_vehicle = nil
                                ESX.ShowNotification(string.format("~g~Véhicule retourné - Caution remboursée: %s$", current_deposit))
                                current_deposit = 0
                            end
                        })
                    end
                    for _, vehicle in pairs(data.vehicles_list) do
                        local description = string.format("Location: %s$ | Caution: %s$", vehicle.price, vehicle.deposit)
                        RageUI.Button(vehicle.label, description, {RightLabel = string.format("%s$", vehicle.price)}, not current_rented_vehicle, {
                            onSelected = function()
                                local vehPrice = vehicle.price
                                local vehDeposit = vehicle.deposit
                                CORE.trigger_server_callback("fafadev:to_server:rent_vehicle", function(result)
                                    if result.success then
                                        current_rented_vehicle = result.netId
                                        current_deposit = result.deposit
                                        local veh = NetToVeh(result.netId)
                                        if DoesEntityExist(veh) then
                                            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                                        end
                                        ESX.ShowNotification(string.format("~g~Véhicule loué: %s$ | Caution: %s$", vehPrice, vehDeposit))
                                    else
                                        ESX.ShowNotification(string.format("~r~%s", result.message))
                                    end
                                end, data.name, vehicle.model, vehicle.price, vehicle.deposit)
                            end
                        })
                    end
                end)
                Wait(0)
            end
        end)
    end
end
