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
                            DrawCustomMarker(coord.x, coord.y, coord.z)
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
                            DrawCustomMarker(coord.x, coord.y, coord.z)   
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

function FUN_GET_VEHICLES(category)
    CORE.trigger_server_callback("fafadev:to_server:get_vehicles", function(vehicles)
        TBL_VEHICLES = vehicles
    end, category)
end

function FUN_GET_VEHICLES_BY_CATEGORIES(categories)
    CORE.trigger_server_callback("fafadev:to_server:get_vehicles_by_categories", function(vehicles)
        TBL_VEHICLES = vehicles
    end, categories)
end
