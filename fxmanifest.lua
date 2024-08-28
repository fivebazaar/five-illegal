fx_version "adamant"
author "viccdevz & akyolm383"
game "gta5"
scriptname "five-illegal"
lua54 "yes"
version 'v1.0.0'

client_scripts {
    "client/*.lua",
    "bridge/client.lua"
}
 
server_scripts {
    "server/*.lua",
    "bridge/server.lua"
}

files {
    'locales/*.json'
  }
  
shared_scripts { 
	'shared/*.lua',
    '@ox_lib/init.lua',
}

dependencies {

}
