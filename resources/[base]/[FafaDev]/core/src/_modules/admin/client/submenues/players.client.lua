function OpenMenuPlayersAdmin() 
    RageUI.IsVisible(sub_menus_admin["players"], function()
        --[[ 
        Filtre En ligne, hors ligne, tout
        Faire une recherche 
        Afficher ceux dans une zone / all maps
         x Joueurs options [
            TP la personne, TP Back, TP à la personne 
            Soins (Heal / Revive)
            Donne de l'argent (money, black_money, bank)
            Actions sanction (ban, kick, warn)
            Jail 
            Spectate
            envoyer un message 
            give un item 
            setjob 
            freeze
            
        ]--]]
    end)
end