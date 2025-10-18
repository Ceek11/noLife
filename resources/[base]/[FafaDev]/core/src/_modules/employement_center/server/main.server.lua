CORE.register_server_event("fafadev:to_server:employement_center", function(source, jobName)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not _source or not xPlayer then return end
    
    local playerJob = xPlayer.job.name
    if playerJob ~= "unemployed" then
        xPlayer.showNotification("~r~Erreur: ~s~Vous avez déjà un emploi! Vous devez d'abord démissionner.")
        return
    end
    
    local jobExists = false
    local jobLabel = jobName
    for _, job in pairs(CONFIG_EMPLOYEMENT_CENTER.Jobs) do
        if job.name == jobName then
            jobExists = true
            jobLabel = job.label
            break
        end
    end
    
    if not jobExists then
        xPlayer.showNotification("~r~Erreur: ~s~Ce job n'existe pas!")
        return
    end
    
    xPlayer.setJob(jobName, 0)
    xPlayer.showNotification("~g~Félicitations! ~s~Vous avez été embauché comme ~b~" .. jobLabel)
end)