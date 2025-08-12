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
  UI('preMatch', Config.PreLobbyTime)
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
    if IsPedInAnyPlane(PlayerPedId()) then
      inPlane = true
    end
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
  RequestModel(hash)
  while not HasModelLoaded(hash) do Wait(0) end
  return hash
end

local function spawnStartPed()
  if not Config.UseStartPed or startPed then return end
  local hash = loadModel(Config.StartPed.model or 's_m_m_bouncer_01')
  local c = Config.StartPed.coords
  startPed = CreatePed(4, hash, c.x, c.y, c.z - 1.0, c.w, false, false)
  SetEntityAsMissionEntity(startPed, true, true)
  SetBlockingOfNonTemporaryEvents(startPed, true)
  SetEntityInvincible(startPed, true)
  FreezeEntityPosition(startPed, true)

  -- Simple idle
  TaskStartScenarioInPlace(startPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)

  -- Target options
  exports['ox_target']:addLocalEntity(startPed, {
    {
      icon = 'fa-solid fa-play',
      label = 'Start Battle Royale',
      distance = 2.0,
      onSelect = function()
        TriggerServerEvent('br:server:StartFromPed')
      end
    }
  })

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
  spawnStartPed()
end)

AddEventHandler('onResourceStop', function(res)
  if res ~= GetCurrentResourceName() then return end
  if startPed and DoesEntityExist(startPed) then DeleteEntity(startPed) end
  if startBlip then RemoveBlip(startBlip) end
end)

-- Loot creation/interaction
RegisterNetEvent('br:client:CreateLoot', function(coords, itemName, rarity, category)
  local model = `prop_box_wood04a`
  RequestModel(model)
  while not HasModelLoaded(model) do Wait(0) end

  local loot = CreateObject(model, coords.x, coords.y, coords.z, true, false, false)
  SetEntityAsMissionEntity(loot, true, true)
  PlaceObjectOnGroundProperly(loot)

  local blip = AddBlipForCoord(coords)
  SetBlipSprite(blip, 500)
  local colorMap = { Common=2, Rare=3, Epic=5, Legendary=46 }
  SetBlipColour(blip, colorMap[rarity] or 0)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(("[%s] %s"):format(category, itemName))
  EndTextCommandSetBlipName(blip)

  exports['ox_target']:addLocalEntity(loot, {
    {
      icon = 'fa-solid fa-box',
      label = ('[%s] Pick up %s (%s)'):format(category, itemName, rarity),
      onSelect = function()
        TriggerServerEvent('br:server:PickUpLoot', itemName)
        DeleteEntity(loot)
        RemoveBlip(blip)
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
  ApplyDamageToPed(PlayerPedId(), math.floor(dmg), false)
end)

-- Draw safe zone
CreateThread(function()
  while true do
    Wait(Config.Performance and (Config.Performance.safeZoneDrawInterval or 1500) or 1500)
    if currentCircle and currentCircle.radius and currentCircle.radius > 0 then
      DrawMarker(28, currentCircle.center.x, currentCircle.center.y, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0,
        currentCircle.radius * 2.0, currentCircle.radius * 2.0, 10.0,
        80, 150, 255, 60, false, false, 2, nil, nil, false)
    end
  end
end)

-- Spectate
RegisterNetEvent('br:client:EnterSpectator', function()
  local ped = PlayerPedId()
  SetEntityAlpha(ped, 120, false)
  SetEntityInvincible(ped, true)
end)
