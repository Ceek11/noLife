function FUN_HANDLE_CLOAKROOMS(tbl_cloakrooms)
    AddTickHandler("cloakrooms", 0, function()
        local playerCoords = GetEntityCoords(PlayerPedId())
        local markerNear = false
        local xPlayer = ESX.GetPlayerData()
        local playerJob = xPlayer and xPlayer.job and xPlayer.job.name or nil
        
        for name, data in pairs(tbl_cloakrooms) do
            local hasAccess = true
            if data.job and data.job ~= "" then
                hasAccess = (playerJob == data.job)
            end
            
            if hasAccess then
                for _, coord in pairs(data.coords) do
                    local distance = #(playerCoords - vector3(coord.x, coord.y, coord.z))
                    if distance < 10.0 then
                        markerNear = true
                        DrawCustomMarker(coord.x, coord.y, coord.z)
                        if distance < 2.0 then
                            ESX.ShowHelpNotification(data.message)
                            if IsControlJustPressed(0, 38) then
                                FUN_OPEN_CLOAKROOM_MENU(data)
                            end
                        end
                    end
                end
            end
        end
        
        if not markerNear then
            SetIntervalEnabled(false, "cloakrooms")
        else
            SetIntervalEnabled(true, "cloakrooms")
        end
    end)
end

-- Callback pour rafraîchir les vestiaires
CORE.register_client_callback("fafadev:to_client:refresh_cloakrooms", function(handler, cloakroomsData)
    FUN_HANDLE_CLOAKROOMS(cloakroomsData)
    handler(true)
end)

