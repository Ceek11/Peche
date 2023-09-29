lua54 'yes'
fx_version 'adamant'
games { 'gta5' };

name 'RageUI';

-- Libs
client_scripts {
    "src/RMenu.lua",
	"src/menu/RageUI.lua",
	"src/menu/Menu.lua",
	"src/menu/MenuController.lua",
	"src/components/*.lua",
	"src/menu/elements/*.lua",
	"src/menu/items/*.lua",
	"src/menu/panels/*.lua",
}


client_scripts {
	'@es_extended/locale.lua',
    "config_fishing.lua",
    "client/*.lua",
}



server_scripts {
	'@es_extended/locale.lua',
	'@oxmysql/lib/MySQL.lua',
    "server/*.lua",
}

