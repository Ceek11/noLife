local markerAlphaStates = {}

local function calculateAlpha(markerKey, isNear, design, currentTime)
    local state = markerAlphaStates[markerKey]
    if not state then
        state = {
            currentAlpha = design.min_alpha,
            targetAlpha = design.min_alpha,
            lastUpdate = currentTime,
            isTransitioning = false
        }
        markerAlphaStates[markerKey] = state
    end
    
    local targetAlpha = isNear and design.max_alpha or design.min_alpha
    
    if state.targetAlpha ~= targetAlpha then
        state.targetAlpha = targetAlpha
        state.startAlpha = state.currentAlpha
        state.startTime = currentTime
        state.isTransitioning = true
    end
    
    if state.isTransitioning then
        local duration = isNear and design.fadeIn_duration or design.fadeOut_duration
        local elapsed = currentTime - state.startTime
        local progress = math.min(elapsed / duration, 1.0)
        
        local easedProgress = 1 - math.pow(1 - progress, 3) 
        
        state.currentAlpha = math.floor(state.startAlpha + (state.targetAlpha - state.startAlpha) * easedProgress)
        
        if progress >= 1.0 then
            state.currentAlpha = state.targetAlpha
            state.isTransitioning = false
        end
    end
    
    state.lastUpdate = currentTime
    return state.currentAlpha
end

AddTickHandler("marker", 0, function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local currentTime = GetGameTimer()
    local markerNear = false
    local hasActiveTransitions = false
    
    local xPlayer = ESX.GetPlayerData()
    local playerJob = xPlayer and xPlayer.job and xPlayer.job.name or nil
    
    for name, data in pairs(TBL_MARKERS_POINT) do
        local hasPermission = has_permission(data.type)
        if not (data.job_name and playerJob ~= data.job_name) and hasPermission then
            local design = TBL_MARKER_DESIGN[data.design] or TBL_MARKER_DESIGN["default"]
            
            for i, coords in ipairs(data.coords) do
            local markerKey = name .. "_" .. i
            local dist = #(playerCoords - vector3(coords.x, coords.y, coords.z))
            local isNear = dist < design.draw_distance
            
            if isNear then
                markerNear = true
                
                local alpha = design.enable_alpha_transition and 
                    calculateAlpha(markerKey, true, design, currentTime) or 
                    design.marker_color.a
                    DrawMarker(design.marker_type,coords.x, coords.y, coords.z - 1.0,design.marker_rotation.x, design.marker_rotation.y, design.marker_rotation.z,0.0, 0.0, 0.0,design.marker_size.x, design.marker_size.y, design.marker_size.z,design.marker_color.r, design.marker_color.g, design.marker_color.b, alpha,design.bobUpAndDown, design.faceCamera, 2, design.rotate, nil, nil, false                )
                
                if dist < design.help_distance then
                    ESX.ShowHelpNotification(T("interaction_help"))
                    if IsControlJustPressed(0, 38) then
                        if data.onSelected then
                            data.onSelected()
                        end
                    end
                end
            elseif hasPermission then
                if design.enable_alpha_transition and markerAlphaStates[markerKey] then
                    local alpha = calculateAlpha(markerKey, false, design, currentTime)
                    if alpha > design.min_alpha then
                        hasActiveTransitions = true
                        DrawMarker(design.marker_type,coords.x, coords.y, coords.z - 1.0,design.marker_rotation.x, design.marker_rotation.y, design.marker_rotation.z,0.0, 0.0, 0.0,design.marker_size.x, design.marker_size.y, design.marker_size.z,design.marker_color.r, design.marker_color.g, design.marker_color.b, alpha,design.bobUpAndDown, design.faceCamera, 2, design.rotate, nil, nil, false)
                    end
                end
            end
            end
        end
    end
    
    if not markerNear and not hasActiveTransitions then
        SetIntervalEnabled(false)
    else
        SetIntervalEnabled(true)
    end
end)

