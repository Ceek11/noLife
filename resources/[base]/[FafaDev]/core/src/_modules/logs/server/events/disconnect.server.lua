AddEventHandler('playerDropped', function(reason)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    local str_player_name = xPlayer.getName()
    CORE.fun_send_to_discord(source, "leave", "orange", "- Déconnexion d'un joueur", ("Le joueur **%s** vient de se déconnecter (Raison: **%s**)"):format(str_player_name, reason), str_player_name)
end)