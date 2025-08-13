<<<<<<<< HEAD:BR-FIVEM/client/main.lua
========
-- BR-FIVEM | client/main.lua

>>>>>>>> a10f4f3 (your message describing the update):client/main.lua
local matchActive = false
local currentCircle = { center = vector2(0.0, 0.0), radius = 0.0 }
local worldSuppressed = false

print('[BR] client/main.lua loaded')

-- NUI helper
local function UI(action, data)
  SendNUIMessage({ action = action, data = data })
end

-- World state: disable ambient peds/traffic
RegisterNetEvent('br:client:SetWorldState', function(disable)
  worldSuppressed = disable
end)

CreateThread(function()
  while true do
    Wait(worldSuppressed and 0 or 500)
    if worldSuppressed then
      SetPedDensityMultiplierThisFrame(0.0)
      SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
      SetVehicleDensityMultiplierThisFrame(0.0)
      SetRandomVehicleDensityMultiplierThisFrame(0.0)
      SetParkedVehicleDensityMultiplierThisFrame(0.0)
      SetGarbageTrucks(false)
      SetRandomBoats(false)
    end
  end
end)

-- Announcements
RegisterNetEvent('br:client:Announce', function(msg, soundKey)
  UI('announce', msg)
  if soundKey then UI('playSound', soundKey .. '.ogg') end
end)

-- Match lifecycle
RegisterNetEvent('br:client:MatchStarting', function()
  matchActive = true
  UI('preMatch', (Config and Config.PreLobbyTime) or 10)
end)

RegisterNetEvent('br:client:MatchEnded', function(winner, kills)
  matchActive = false
  UI('endMatch', { winner = winner, kills = kills })
  UI('playSound', 'victory.ogg')
end)

-- Plane
RegisterNetEvent('br:client:PlaneSpawned', function(netId)
  local ped = PlayerPedId()
  local plane = NetToVeh(netId)
  if DoesEntityExist(plane) then
    TaskWarpPedIntoVehicle(ped, plane, -1)
    UI('announce', 'Board the plane!')
    UI('playSound', 'plane_engine.ogg')
  end
end)

-- Jump/parachute
CreateThread(function()
  local inPlane = false
  while true do
    Wait(0)
    if IsPedInAnyPlane(PlayerPedId()) then inPlane = true end
    if inPlane and IsControlJustPressed(0, 22) then -- SPACE
      local ped = PlayerPedId()
      TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, false), 256)
      Wait(300)
      GiveWeaponToPed(ped, `GADGET_PARACHUTE`, 1, false, true)
      TaskParachute(ped, true)
      SetPedParachuteTintIndex(ped, math.random(0, 7))
      UI('playSound', 'jump.ogg')
      inPlane = false
    end
  end
end)

-- Start Ped spawn and interaction
local startPed, startBlip

local function loadModel(model)
  local hash = type(model) == 'string' and GetHashKey(model) or model
<<<<<<<< HEAD:BR-FIVEM/client/main.lua
  RequestModel(hash)
  while not HasModelLoaded(hash) do Wait(0) end
  return hash
end

local function spawnStartPed()
  if not Config.UseStartPed or startPed then return end
  local hash = loadModel(Config.StartPed.model or 's_m_m_bouncer_01')
  local c = Config.StartPed.coords
  startPed = CreatePed(4, hash, c.x, c.y, c.z - 1.0, c.w, false, false)
========
  if not IsModelInCdimage(hash) or not IsModelValid(hash) then
    print(('[BR] Invalid model requested: %s'):format(tostring(model)))
    return nil
  end
  RequestModel(hash)
  local timeout = GetGameTimer() + 10000
  while not HasModelLoaded(hash) do
    if GetGameTimer() > timeout then
      print('[BR] Model load timed out'); return nil
    end
    Wait(0)
  end
  return hash
end

local function safeAddTarget(entity, options)
  pcall(function()
    return exports.ox_target:addLocalEntity(entity, options)
  end)
end

local function spawnStartPed()
  if not Config or not Config.UseStartPed or startPed then return end
  local sp = Config.StartPed or {}
  local c  = sp.coords
  if not c or not c.x or not c.y or not c.z then
    print('[BR] Config.StartPed.coords invalid'); return
  end

  local hash = loadModel(sp.model or 's_m_m_bouncer_01')
  if not hash then return end

  local x, y, z, h = c.x, c.y, c.z, c.w or 0.0
  local _, groundZ = GetGroundZFor_3dCoord(x + 0.0, y + 0.0, z + 5.0, false)
  if groundZ and groundZ > 0.0 then z = groundZ end

  startPed = CreatePed(4, hash, x, y, z - 1.0, h, false, false)
>>>>>>>> a10f4f3 (your message describing the update):client/main.lua
  SetEntityAsMissionEntity(startPed, true, true)
  SetBlockingOfNonTemporaryEvents(startPed, true)
  SetEntityInvincible(startPed, true)
  FreezeEntityPosition(startPed, true)
<<<<<<<< HEAD:BR-FIVEM/client/main.lua

  -- Simple idle
  TaskStartScenarioInPlace(startPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)

  -- Target options
  exports['ox_target']:addLocalEntity(startPed, {
========
  TaskStartScenarioInPlace(startPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)

  safeAddTarget(startPed, {
>>>>>>>> a10f4f3 (your message describing the update):client/main.lua
    {
      icon = 'fa-solid fa-play',
      label = 'Start Battle Royale',
      distance = 2.0,
      onSelect = function()
        TriggerServerEvent('br:server:StartFromPed')
      end
    }
  })

<<<<<<<< HEAD:BR-FIVEM/client/main.lua
  -- Blip
  if Config.StartPed.blip and Config.StartPed.blip.enabled then
    startBlip = AddBlipForCoord(c.xyz)
    SetBlipSprite(startBlip, Config.StartPed.blip.sprite or 606)
    SetBlipColour(startBlip, Config.StartPed.blip.color or 46)
    SetBlipScale(startBlip, Config.StartPed.blip.scale or 0.8)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.StartPed.blip.name or 'Battle Royale')
    EndTextCommandSetBlipName(startBlip)
  end
end

CreateThread(function()
  -- Small delay to ensure map and streaming are ready
  Wait(1500)
========
  if sp.blip and sp.blip.enabled then
    startBlip = AddBlipForCoord(x, y, z)
    SetBlipSprite(startBlip, sp.blip.sprite or 280)
    SetBlipColour(startBlip, sp.blip.color or 46)
    SetBlipScale(startBlip, sp.blip.scale or 0.8)
    SetBlipAsShortRange(startBlip, sp.blip.shortRange ~= false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(sp.blip.name or 'Battle Royale')
    EndTextCommandSetBlipName(startBlip)
  end

  SetModelAsNoLongerNeeded(hash)
end

CreateThread(function()
  local t = GetGameTimer() + 10000
  while not NetworkIsSessionStarted() and GetGameTimer() < t do
    Wait(100)
  end
  Wait(500)
>>>>>>>> a10f4f3 (your message describing the update):client/main.lua
  spawnStartPed()
end)

AddEventHandler('onResourceStop', function(res)
  if res ~= GetCurrentResourceName() then return end
  if startPed and DoesEntityExist(startPed) then DeleteEntity(startPed) end
<<<<<<<< HEAD:BR-FIVEM/client/main.lua
  if startBlip then RemoveBlip(startBlip) end
========
  if startBlip and DoesBlipExist(startBlip) then RemoveBlip(startBlip) end
>>>>>>>> a10f4f3 (your message describing the update):client/main.lua
end)

-- Loot creation/interaction
RegisterNetEvent('br:client:CreateLoot', function(coords, itemName, rarity, category)
  local model = `prop_box_wood04a`
  RequestModel(model)
  local timeout = GetGameTimer() + 10000
  while not HasModelLoaded(model) do
    if GetGameTimer() > timeout then
      print('[BR] Loot model load timed out'); return
    end
    Wait(0)
  end

  local loot = CreateObject(model, coords.x, coords.y, coords.z, true, false, false)
  SetEntityAsMissionEntity(loot, true, true)
  PlaceObjectOnGroundProperly(loot)

  local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
  SetBlipSprite(blip, 500)
  local colorMap = { Common = 2, Rare = 3, Epic = 5, Legendary = 46 }
  SetBlipColour(blip, colorMap[rarity] or 0)
  SetBlipScale(blip, 0.7)
  SetBlipAsShortRange(blip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(("[%s] %s"):format(category or 'Loot', itemName or 'Item'))
  EndTextCommandSetBlipName(blip)

<<<<<<<< HEAD:BR-FIVEM/client/main.lua
  exports['ox_target']:addLocalEntity(loot, {
    {
      icon = 'fa-solid fa-box',
      label = ('[%s] Pick up %s (%s)'):format(category, itemName, rarity),
========
  safeAddTarget(loot, {
    {
      icon = 'fa-solid fa-box',
      label = ('[%s] Pick up %s (%s)'):format(category or 'Loot', itemName or 'Item', rarity or 'Common'),
>>>>>>>> a10f4f3 (your message describing the update):client/main.lua
      onSelect = function()
        TriggerServerEvent('br:server:PickUpLoot', itemName)
        if DoesEntityExist(loot) then DeleteEntity(loot) end
        if blip and DoesBlipExist(blip) then RemoveBlip(blip) end
      end
    }
  })
end)

-- Safe zone init/update
RegisterNetEvent('br:client:InitializeSafeZone', function(circle)
  currentCircle = circle
  UI('updateCircle', circle.radius)
end)

RegisterNetEvent('br:client:UpdateSafeZone', function(data)
  currentCircle = data.to or currentCircle
  UI('updateCircle', currentCircle.radius)
  UI('playSound', 'circle_warning.ogg')
end)

-- Zone damage
RegisterNetEvent('br:client:ApplyZoneDamage', function(dmg)
<<<<<<<< HEAD:BR-FIVEM/client/main.lua
  ApplyDamageToPed(PlayerPedId(), math.floor(dmg), false)
========
  ApplyDamageToPed(PlayerPedId(), math.floor(dmg or 1), false)
>>>>>>>> a10f4f3 (your message describing the update):client/main.lua
end)

-- Draw safe zone
CreateThread(function()
  while true do
    local interval = (Config and Config.Performance and Config.Performance.safeZoneDrawInterval) or 1500
    Wait(interval)
    if currentCircle and currentCircle.radius and currentCircle.radius > 0 then
      DrawMarker(
        28,
        currentCircle.center.x, currentCircle.center.y, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0,
        currentCircle.radius * 2.0, currentCircle.radius * 2.0, 10.0,
        80, 150, 255, 60,
        false, false, 2, nil, nil, false
      )
    end
  end
end)

-- Spectate
RegisterNetEvent('br:client:EnterSpectator', function()
  local ped = PlayerPedId()
  SetEntityAlpha(ped, 120, false)
  SetEntityInvincible(ped, true)
end)
