<<<<<<<< HEAD:BR-FIVEM/config.lua
-- Start Ped (optional)
Config.UseStartPed = true
Config.StartPed = {
  model = 's_m_m_bouncer_01',               -- any ped model
  coords = vector4(204.16, -933.52, 30.69, 160.0), -- Legion Square, tweak to taste
  blip = {
    enabled = true,
    sprite = 606,   -- Controller
    color = 46,
    scale = 0.8,
    name = 'Battle Royale'
  }
}

Config = {}
========
-- BR-FIVEM | config.lua

-- Initialize once (prevents wiping values on reload)
Config = Config or {}

-- Start Ped (optional)
Config.UseStartPed = true
Config.StartPed = {
  model = 's_m_m_bouncer_01',
  coords = vector4(204.16, -933.52, 30.69, 160.0),
  blip = {
    enabled = true,
    name = 'Battle Royale',
    sprite = 280,   -- crosshair (widely supported)
    color  = 46,
    scale  = 0.8,
    shortRange = true
  }
}
>>>>>>>> a10f4f3 (your message describing the update):config.lua

-- Plane
Config.PlaneModel       = 'cuban800'
Config.PlaneAltitude    = 1200.0
Config.PlaneSpeed       = 80.0

-- Match
Config.MinPlayers       = 2
Config.PreLobbyTime     = 20

-- Safe Zone
Config.InitialRadius    = 3000.0
Config.ShrinkIntervals  = { 180, 120, 90, 60 }
Config.DamagePerSecond  = 10

-- Performance
Config.Performance = {
  safeZoneDrawInterval = 1500
}

-- Loot zones
Config.LootZones = {
  { name = 'Pillbox Hill',    coords = vector3(349.05, -592.37, 28.78) },
  { name = 'Airport',         coords = vector3(-1034.6, -2733.6, 13.76) },
  { name = 'Vinewood',        coords = vector3(325.2, 180.5, 104.6) },
  { name = 'Davis',           coords = vector3(89.2, -2046.3, 18.3) },
  { name = 'Paleto Bay',      coords = vector3(-182.0, 6274.2, 31.4) },
  { name = 'Mount Chiliad',   coords = vector3(450.8, 5566.6, 796.1) },
  { name = 'Grapeseed',       coords = vector3(1707.0, 4920.4, 41.8) },
  { name = 'Sandy Shores',    coords = vector3(1853.2, 3694.1, 33.2) }
}

-- Loot balance
Config.LootCountPerZone = 25

-- Categories and weights (sum ≈ 100)
Config.LootCategories = {
  { category = 'Weapons', weight = 45 },
  { category = 'Ammo',    weight = 25 },
  { category = 'Armors',  weight = 15 },
  { category = 'Medkits', weight = 15 }
}

-- Items by category and rarity
-- Ensure these item names exist in your ox_inventory/data/items.lua
Config.Items = {
  Weapons = {
    -- Handguns and basic gear
    Common = {
      'weapon_pistol',
      'weapon_snspistol',
      'weapon_combatpistol',
      'weapon_nightstick',
      'weapon_stungun'
    },

    -- AP pistol and early SMGs
    Rare = {
      'weapon_appistol',          -- AP Pistol
      'weapon_snspistol_mk2',
      'weapon_microsmg',
      'weapon_machinepistol',
      'weapon_heavypistol',
      'weapon_vintagepistol',
      'weapon_combatpdw',
      'weapon_specialcarbine'
    },

    -- Rifles and MK2 mid/high tier
    Epic = {
      'weapon_minismg',
      'weapon_assaultsmg',
      'weapon_smg_mk2',
      'weapon_bullpuprifle_mk2',
      'weapon_carbinerifle',
      'weapon_carbinerifle_mk2',
      'weapon_assaultrifle_mk2',
      'weapon_specialcarbine_mk2'
    },

    -- Endgame
    Legendary = {
      'weapon_marksmanrifle_mk2',
      'weapon_sniperrifle',
      'weapon_heavysniper_mk2',
      'weapon_rpg'
    }
  },

  -- Ammo items (use your actual ammo item IDs; these align with many ox_inventory setups)
  Ammo = {
    Common = {
      'ammo-9'          -- 9mm
    },
    Rare = {
      'ammo-smg',       -- SMG ammo
      'ammo-9'
    },
    Epic = {
      'ammo-rifle'      -- rifle ammo
    },
    Legendary = {
      'ammo-sniper',    -- sniper ammo
      'ammo-shotgun'    -- shotgun shells
    }
  },

  -- Body armor progression
  Armors = {
    Common    = { 'armor' },
    Rare      = { 'heavyarmor' },
    Epic      = { 'armor_advanced' },
    Legendary = { 'armor_elite' }
  },

  -- Healing items
  Medkits = {
    Common    = { 'bandage' },
    Rare      = { 'firstaid' },
    Epic      = { 'painkillers' },
    Legendary = { 'adrenaline' }
  }
}

-- Rarity thresholds (cumulative 0..1)
Config.RarityChances = {
  Common    = 0.60,
  Rare      = 0.85,
  Epic      = 0.97,
  Legendary = 1.00
}

<<<<<<<< HEAD:BR-FIVEM/config.lua
========
-- Utilities
>>>>>>>> a10f4f3 (your message describing the update):config.lua
function Config:RandomFloat()
  return math.random()
end

function Config:PickCategory()
  local roll, sum = math.random(1, 100), 0
  for _, cat in ipairs(self.LootCategories) do
    sum = sum + cat.weight
    if roll <= sum then return cat.category end
  end
  return self.LootCategories[#self.LootCategories].category
end

function Config:PickRarity()
  local roll = self:RandomFloat()
  if roll <= self.RarityChances.Common then return 'Common' end
  if roll <= self.RarityChances.Rare then return 'Rare' end
  if roll <= self.RarityChances.Epic then return 'Epic' end
  return 'Legendary'
end
