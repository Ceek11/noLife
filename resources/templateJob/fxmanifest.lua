fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Votre Nom'
description 'Template Job - Script de job modulaire pour FiveM'
version '1.0.0'

dependencies {
    'es_extended',
    'oxmysql',
    'zUI-v2'
}

shared_scripts {
    '@es_extended/imports.lua',
    'shared/config/*.lua',
    'shared/locales/*.lua',
    'shared/utils/*.lua'
}

client_scripts {
    '@ox_lib/init.lua',
    'client/function/*.lua',
    'client/utils/*.lua',
    'client/markers/*.lua',
    'client/menus/**/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/utils/*.lua',
    'server/function/*.lua',
    'server/main/*.lua',
}

