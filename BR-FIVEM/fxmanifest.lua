fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'KS-2ND'
description 'QBox Battle Royale'
version '1.2.0'

shared_scripts {
  '@ox_lib/init.lua',
  'shared/core.lua',
  'config.lua'
}

client_scripts {
  '@qbox-core/client/functions.lua',
  'client/**/*.lua',
  'client/*.lua'
}

server_scripts {
  '@qbox-core/server/functions.lua',
  'server/**/*.lua',
  'server/*.lua'
}

ui_page 'html/ui.html'

files {
  'html/ui.html',
  'html/style.css',
  'html/script.js',
  'sounds/*.ogg'
}

dependencies {
  'qbx_core',
  'ox_inventory',
  'ox_target'
}
