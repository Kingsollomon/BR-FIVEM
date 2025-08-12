local QBox = exports['qbx_core']:GetCoreObject()

local coreName = GetResourceState('qbx_core') == 'started' and 'qbx_core' or 'qb-core'
local QBox = exports[coreName]:GetCoreObject()

local matchActive = false
local killCounts = {}
local playerState = {}  -- src => 'alive' | 'spectating'
local currentCircle = { center = vector2(0, 0), radius = 0.0 }
local shrinkTimers = {}

print('[BR] server/main.lua loaded')

-- Helpers
local function Announce(text, soundKey)
  TriggerClientEvent('br:client:Announce', -1, text, soundKey)
end

local function GetPlayers()
  return QBox.Functions.GetPlayers()
end

RegisterNetEvent('br:server:StartFromPed', function()
  local src = source
  if matchActive then
    TriggerClientEvent('br:client:Announce', src, 'A match is already in progress.', nil)
    return
  end
  StartPreLobby()
end)

-- Lobby
local function StartPreLobby()
  matchActive = false
  killCounts = {}
  playerState = {}
  Announce(("Waiting for players... %d/%d"):format(#GetPlayers(), Config.MinPlayers), nil)

  SetTimeout(Config.PreLobbyTime * 1000, function()
    if #GetPlayers() >= Config.MinPlayers then
      StartMatch()
    else
      StartPreLobby()
    end
  end)
end

function StartMatch()
  matchActive = true
  killCounts = {}
  for _, src in ipairs(GetPlayers()) do
    playerState[src] = 'alive'
  end
  Announce("Match is starting!", 'planeEngine')

  TriggerClientEvent('br:client:MatchStarting', -1)
  TriggerEvent('br:server:StartPlaneDrop')
  TriggerEvent('br:server:StartLoot')
  TriggerEvent('br:server:StartSafeZone')
  TriggerClientEvent('br:client:SetWorldState', -1, true)
end

-- Plane
RegisterNetEvent('br:server:StartPlaneDrop', function()
  local spawnPt = vector4(-2000.0, 3000.0, Config.PlaneAltitude, 0.0)
  QBox.Functions.SpawnVehicle(Config.PlaneModel, spawnPt, function(veh)
    SetEntityInvincible(veh, true)
    SetVehicleForwardSpeed(veh, Config.PlaneSpeed)
    TriggerClientEvent('br:client:PlaneSpawned', -1, VehToNet(veh))
  end)
end)

-- Loot spawn
RegisterNetEvent('br:server:StartLoot', function()
  for _, zone in ipairs(Config.LootZones) do
    for i = 1, Config.LootCountPerZone do
      local xOff, yOff = math.random(-50, 50), math.random(-50, 50)
      local coords = vector3(zone.coords.x + xOff, zone.coords.y + yOff, zone.coords.z)
      local category = Config:PickCategory()
      local rarity = Config:PickRarity(Config:RandomFloat())
      local pool = Config.Items[category][rarity]
      local item = pool[math.random(#pool)]
      TriggerClientEvent('br:client:CreateLoot', -1, coords, item, rarity, category)
    end
  end
end)

-- Pickups
RegisterNetEvent('br:server:PickUpLoot', function(itemName)
  local src = source
  local Player = QBox.Functions.GetPlayer(src)
  if not Player then return end
  Player.Functions.AddItem(itemName, 1)
  TriggerClientEvent('inventory:client:ItemBox', src, { name = itemName }, 'add')
end)

-- Safe zone
local function RandomPoint()
  return vector2(math.random(-2500, 2500), math.random(-2500, 2500))
end

local function ClearShrinkTimers()
  shrinkTimers = {}
end

local function LerpVector2(a, b, t)
  return vector2(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t)
end

function StartSafeZone()
  ClearShrinkTimers()
  currentCircle = { center = RandomPoint(), radius = Config.InitialRadius }
  TriggerClientEvent('br:client:InitializeSafeZone', -1, currentCircle)

  local radius = currentCircle.radius
  local center = currentCircle.center

  for _, interval in ipairs(Config.ShrinkIntervals) do
    local id = SetTimeout(interval * 1000, function()
      if not matchActive then return end
      radius = radius * 0.7
      local target = RandomPoint()
      center = LerpVector2(center, target, 0.25)
      currentCircle = { center = center, radius = radius }
      TriggerClientEvent('br:client:UpdateSafeZone', -1, { to = currentCircle })
      Announce("Circle is closing!", 'circleWarning')
    end)
    table.insert(shrinkTimers, id)
  end

  CreateThread(function()
    while matchActive do
      Wait(1000)
      for _, src in ipairs(GetPlayers()) do
        if playerState[src] == 'alive' then
          local ped = GetPlayerPed(src)
          local p = GetEntityCoords(ped)
          if #(vector2(p.x, p.y) - currentCircle.center) > currentCircle.radius then
            TriggerClientEvent('br:client:ApplyZoneDamage', src, Config.DamagePerSecond)
          end
        end
      end
    end
  end)
end
RegisterNetEvent('br:server:StartSafeZone', StartSafeZone)

-- Death & transfer
RegisterNetEvent('br:server:OnPlayerDeath', function(killerId)
  local victim = source
  local Victim = QBox.Functions.GetPlayer(victim)
  if not Victim then return end

  if killerId and killerId ~= victim then
    local Killer = QBox.Functions.GetPlayer(killerId)
    if Killer then
      local items = Victim.PlayerData.items or {}
      local snapshot = {}
      for slot, item in pairs(items) do
        if item and item.name and item.amount > 0 then
          table.insert(snapshot, { name = item.name, amount = item.amount, slot = slot })
        end
      end
      for _, it in ipairs(snapshot) do
        Victim.Functions.RemoveItem(it.name, it.amount, it.slot)
        Killer.Functions.AddItem(it.name, it.amount)
      end

      killCounts[killerId] = (killCounts[killerId] or 0) + 1
      local killerName = (Killer.PlayerData.charinfo and Killer.PlayerData.charinfo.firstname) or ('ID ' .. tostring(killerId))
      TriggerClientEvent('br:client:KillFeed', -1, killerName, killCounts[killerId])
    end
  else
    local coords = GetEntityCoords(GetPlayerPed(victim))
    local items = Victim.PlayerData.items or {}
    for _, item in pairs(items) do
      if item and item.name then
        TriggerClientEvent('br:client:CreateLoot', -1, coords, item.name, 'Common', 'Misc')
        Victim.Functions.RemoveItem(item.name, item.amount, item.slot)
      end
    end
  end

  playerState[victim] = 'spectating'
  TriggerClientEvent('br:client:EnterSpectator', victim)

  SetTimeout(500, function()
    local alive, last = 0, nil
    for _, src in ipairs(GetPlayers()) do
      if playerState[src] == 'alive' then
        alive = alive + 1
        last = src
      end
    end

    if matchActive and alive <= 1 then
      matchActive = false
      ClearShrinkTimers()
      local winnerName, kills = 'Unknown', 0
      if last then
        local P = QBox.Functions.GetPlayer(last)
        if P and P.PlayerData and P.PlayerData.charinfo then
          winnerName = P.PlayerData.charinfo.firstname
          kills = killCounts[last] or 0
        else
          winnerName = 'ID ' .. tostring(last)
        end
      end
      TriggerClientEvent('br:client:MatchEnded', -1, winnerName, kills)
      TriggerClientEvent('br:client:SetWorldState', -1, false)
      SetTimeout(15000, StartPreLobby)
    end
  end)
end)

-- Late joiners
RegisterNetEvent('QBCore:Server:PlayerLoaded', function()
  local src = source
  if matchActive then
    playerState[src] = 'spectating'
    TriggerClientEvent('br:client:SetWorldState', src, true)
    TriggerClientEvent('br:client:InitializeSafeZone', src, currentCircle)
  end
end)

-- Cleanup
AddEventHandler('playerDropped', function()
  local src = source
  playerState[src] = nil
  killCounts[src] = nil
end)

-- Boot
AddEventHandler('onResourceStart', function(res)
  if res == GetCurrentResourceName() then
    if not Config.UseStartPed then
      StartPreLobby()
    else
      print('[BR] StartPed mode: waiting for players to use the ped.')
    end
  end
end)

