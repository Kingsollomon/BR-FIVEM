fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'BR-FIVEM'
author 'KS-2ND'
version '1.2.1'
description 'QBox Battle Royale'

shared_scripts {
  '@ox_lib/init.lua',
  'shared/core.lua',
  'config.lua'
}

client_scripts {
  'client/*.lua'
}

server_scripts {
  'server/*.lua'
}

ui_page 'html/ui.html'

files {
  'html/ui.html',
  'html/style.css',
  'html/script.js',
  'html/sounds/*.ogg',
  'html/fonts/*',
  'html/images/*'
}

dependencies {
  'qbx_core',
  'ox_inventory',
  'ox_target'
<<<<<<<< HEAD:BR-FIVEM/fxmanifest.lua
========
}

escrow_ignore {
  'config.lua',
  'shared/*.lua'
>>>>>>>> a10f4f3 (your message describing the update):fxmanifest.lua
}
