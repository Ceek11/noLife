local current_locations = {}

function FUN_HANDLE_LOCATIONS(locations)
    current_locations = locations
    AddTickHandler("locations", 0, function()
        local playerCoords = GetEntityCoords(PlayerPedId())
        local markerNear = false
        for _, data in pairs(current_locations) do
            for _, coord in pairs(data.coords) do
                local distance = #(playerCoords - vector3(coord.x, coord.y, coord.z))
                if distance < 10.0 then
                    markerNear = true
                    if data.drawmarker ~= false then
                        DrawMarker(1, coord.x, coord.y, coord.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 150, 255, 200, false, true, 2, false, false, false, false)
                    end
                end
                if distance < 2.0 then
                    ESX.ShowHelpNotification(data.message)
                    if IsControlJustPressed(0, 38) then
                        FUNC_OPEN_MENU_LOCATION(data)
                    end
                end
            end
        end
        if not markerNear then
            SetIntervalEnabled(false, "locations")
        else
            SetIntervalEnabled(true, "locations")
        end
    end)
end

CORE.register_client_callback("fafadev:to_client:refresh_locations", function(handler, locations)
    current_locations = locations
    handler()
end)