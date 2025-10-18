function FUN_HANDLE_CONCESS(concess)
    AddTickHandler("concess", 0, function()
        local playerCoords = GetEntityCoords(PlayerPedId())
        local markerNear = false
        
        if concess.sell then
            for _, data in pairs(concess.sell) do
                for _, coord in pairs(data.coords) do
                    local distance = #(playerCoords - vector3(coord.x, coord.y, coord.z))
                    
                    if distance < 15.0 then
                        markerNear = true
                        if data.drawmarker then
                            DrawMarker(2, coord.x, coord.y, coord.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 255, 0, 0, 255, false, true, 2, false, false, false, false)
                        end
                    end
                    if distance < 2.0 then
                        ESX.ShowHelpNotification(data.message)
                        if IsControlJustPressed(0, 38) then
                            FUN_OPEN_SELL_MENU(data)
                        end
                    end
                end
            end
        end
        
        if concess.preview then
            for _, data in pairs(concess.preview) do
                for _, coord in pairs(data.coords) do
                    local distance = #(playerCoords - vector3(coord.x, coord.y, coord.z))
                    
                    if distance < 15.0 then
                        markerNear = true
                        if data.drawmarker then
                            DrawMarker(TBL_MARKER_DESIGN["default"].marker_type, coord.x, coord.y, coord.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, TBL_MARKER_DESIGN["default"].marker_size.x, TBL_MARKER_DESIGN["default"].marker_size.y, TBL_MARKER_DESIGN["default"].marker_size.z, TBL_MARKER_DESIGN["default"].marker_color.r, TBL_MARKER_DESIGN["default"].marker_color.g, TBL_MARKER_DESIGN["default"].marker_color.b, TBL_MARKER_DESIGN["default"].marker_color.a, false, true, 2, false, false, false, false)   
                        end
                    end
                    if distance < 2.0 then
                        ESX.ShowHelpNotification(data.message)
                        if IsControlJustPressed(0, 38) then
                            FUN_OPEN_PREVIEW_MENU(data)
                        end
                    end
                end
            end
        end
        
        if not markerNear then
            SetIntervalEnabled(false, "concess")
        else
            SetIntervalEnabled(true, "concess")
        end
    end)
end

TBL_CATEGORIES = {}
TBL_VEHICLES = {}
function FUN_GET_CATEGORIES()
    CORE.trigger_server_callback("fafadev:to_server:get_categories", function(categories)
        TBL_CATEGORIES = categories
    end)
end

function FUN_GET_VEHICLES()
    CORE.trigger_server_callback("fafadev:to_server:get_vehicles", function(vehicles)
        TBL_VEHICLES = vehicles
    end)
end
