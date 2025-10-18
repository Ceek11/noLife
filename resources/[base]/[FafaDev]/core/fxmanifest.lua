fx_version 'cerulean'
game 'gta5'

author 'FafaDev'
description 'FafaDev Core Framework'
version '1.0.0'

-- RageUI
client_scripts {
    'RageUI/RMenu.lua',
    'RageUI/menu/RageUI.lua',
    'RageUI/menu/Menu.lua',
    'RageUI/menu/MenuController.lua',
    'RageUI/components/*.lua',
    'RageUI/menu/elements/*.lua',
    'RageUI/menu/items/*.lua',
    'RageUI/menu/panels/*.lua',
    'RageUI/menu/windows/*.lua',
}

shared_scripts {
    'src/common.lua',
    'config/*.lua',
}

client_scripts {
    '@ox_lib/init.lua',
    'src/common.client.lua',
    'src/services/**/client.lua',
    'src/_modules/**/client/*.lua',
    'src/utils/*.lua',
    'src/task/**/client.lua',
    'src/admin/client/submenues/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'src/common.server.lua',
    'src/services/**/server.lua',
    'src/_modules/**/server/*.lua',
    'src/_modules/logs/server/events/*.lua',
    'src/task/**/server.lua',
}

files {
    'data/*.json',
}