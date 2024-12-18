fx_version 'cerulean'
games { 'gta5' }

author 'Tiger (Discord: lets_tiger)'
description 'Newspaper Script'
version "1.0.0"

lua54 'yes'

client_scripts {
	'client/main.lua'
}

server_scripts {
	'server/main.lua',
	'server/version_check.lua'
}

shared_script {
	'config.lua'
}

files {
	'stream/TG_Textures.ytd',
    'html/index.html'
}

ui_page 'html/index.html'