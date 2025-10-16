AddEventHandler('onResourceStop', function(resource_name)
    local str_upper_resource_name = string.upper(resource_name)
    CORE.fun_send_to_discord(-100, "scripts_status", "red", "🔴 - Arrêt d'une ressource", ("La ressource **%s** vient de s'arrêter."):format(str_upper_resource_name), "Serveur")
end)