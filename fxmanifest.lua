fx_version 'cerulean'
game 'gta5'

lua54 'yes'

name 'Admin Tools'
author 'Admin Tools'
description 'Standalone admin utilities for FiveM.'
version '1.1.0'

shared_script 'config.lua'

client_scripts {
    'client/coords.lua'
}

server_scripts {
    'server/coords.lua'
}
