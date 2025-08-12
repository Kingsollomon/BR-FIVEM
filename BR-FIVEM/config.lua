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

-- Multiple loot zones
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

-- Categories and weights (sum 100)
Config.LootCategories = {
  { category = 'Weapons', weight = 45 },
  { category = 'Ammo',    weight = 25 },
  { category = 'Armors',  weight = 15 },
  { category = 'Medkits', weight = 15 }
}

-- Items by category and rarity
Config.Items = {
  Weapons = {
    Common    = { 'weapon_pistol', 'weapon_revolver' },
    Rare      = { 'weapon_smg', 'weapon_pumpshotgun' },
    Epic      = { 'weapon_assaultrifle', 'weapon_carbinerifle' },
    Legendary = { 'weapon_sniperrifle', 'weapon_mg' }
  },
  Ammo = {
    Common    = { 'pistol_ammo' },
    Rare      = { 'smg_ammo' },
    Epic      = { 'rifle_ammo' },
    Legendary = { 'sniper_ammo' }
  },
  Armors = {
    Common    = { 'armour' },
    Rare      = { 'heavyarmour' },
    Epic      = { 'armour_advanced' },
    Legendary = { 'armour_elite' }
  },
  Medkits = {
    Common    = { 'bandage' },
    Rare      = { 'firstaid' },
    Epic      = { 'painkillers' },
    Legendary = { 'adrenaline' }
  }
}

-- Rarity thresholds
Config.RarityChances = {
  Common    = 0.60,
  Rare      = 0.85,
  Epic      = 0.97,
  Legendary = 1.00
}

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

function Config:PickRarity(roll)
  if roll <= self.RarityChances.Common then return 'Common' end
  if roll <= self.RarityChances.Rare then return 'Rare' end
  if roll <= self.RarityChances.Epic then return 'Epic' end
  return 'Legendary'
end
