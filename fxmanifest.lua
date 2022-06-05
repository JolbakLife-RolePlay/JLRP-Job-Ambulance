fx_version 'cerulean'
use_fxv2_oal 'yes'
game 'gta5'
lua54 'yes'

name 'JLRP-Job-Ambulance'
author 'Mahan Moulaei'
discord 'Mahan#8183'
description 'JolbakLifeRP Ambulance Job'

version '0.0'

shared_scripts {
	'@JLRP-Framework/shared/locale.lua',
	'@ox_lib/init.lua',
	'config.lua',
	'shared/*.lua',
	'locales/*.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/commands.lua',
	'server/MySQL.lua'
}

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/CircleZone.lua',
	'client/main.lua'
}

dependencies {
	'oxmysql',
	'JLRP-Framework'
}