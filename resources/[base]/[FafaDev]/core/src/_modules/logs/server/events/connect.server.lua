AddEventHandler('playerConnecting', function(name, _, _)
    local source = source
    CORE.fun_send_to_discord(source, "join", "green", "- Connexion d'un joueur", ("Le joueur %s vient de se connecter"):format(name), name)
end)