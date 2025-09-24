fx_version 'cerulean'
game 'gta5'

author 'FAFADEV'
description 'Outil complet pour la création de cinématiques et trailers sur FiveM'
version '1.0.0'

-- Dépendances
dependencies {
    'ox_lib'
}

-- Fichiers partagés
shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
    'shared/locales/*.lua'
}

-- Scripts côté client
client_scripts {
    'client/get_vehicles.client.lua',
    'client/get_player.client.lua',
    'client/noclip.lua',
    'client/function.client.lua',
    'client/menu.client.lua'
}

-- Scripts côté serveur
server_scripts {
    'server/*.lua'
}


-- Configuration des events
lua54 'yes'
