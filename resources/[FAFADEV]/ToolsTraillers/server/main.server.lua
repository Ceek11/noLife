RegisterNetEvent('toolstraillers:bringPlayer')
AddEventHandler('toolstraillers:bringPlayer', function(targetId)
    local source = source
    local targetPed = GetPlayerPed(targetId)
    
    if not targetPed or targetPed == 0 then
        TriggerClientEvent('lib:notify', source, {
            title = 'ToolsTraillers',
            description = 'Joueur introuvable',
            type = 'error'
        })
        return
    end
    
    local sourcePed = GetPlayerPed(source)
    local sourceCoords = GetEntityCoords(sourcePed)
    
    TriggerClientEvent('toolstraillers:teleportPlayer', targetId, sourceCoords.x, sourceCoords.y, sourceCoords.z)
    
    TriggerClientEvent('lib:notify', source, {
        title = 'ToolsTraillers',
        description = 'Joueur ' .. targetId .. ' téléporté vers vous',
        type = 'success'
    })
    
    TriggerClientEvent('lib:notify', targetId, {
        title = 'ToolsTraillers',
        description = 'Vous avez été téléporté par un admin',
        type = 'info'
    })
end)

RegisterNetEvent('toolstraillers:gotoPlayer')
AddEventHandler('toolstraillers:gotoPlayer', function(targetId)
    local source = source
    local targetPed = GetPlayerPed(targetId)
    
    if not targetPed or targetPed == 0 then
        TriggerClientEvent('lib:notify', source, {
            title = 'ToolsTraillers',
            description = 'Joueur introuvable',
            type = 'error'
        })
        return
    end
    
    local targetCoords = GetEntityCoords(targetPed)
    
    TriggerClientEvent('toolstraillers:teleportPlayer', source, targetCoords.x, targetCoords.y, targetCoords.z)
    
    TriggerClientEvent('lib:notify', source, {
        title = 'ToolsTraillers',
        description = 'Téléporté vers le joueur ' .. targetId,
        type = 'success'
    })
end)
