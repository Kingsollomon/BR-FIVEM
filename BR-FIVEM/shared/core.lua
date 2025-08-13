-- BR-FIVEM | shared/core.lua
-- Centralized, resilient QBox getter for both client/server.

BR = BR or {}

local function tryGetCore()
  -- Prefer qbx_core export
  if GetResourceState('qbx_core') == 'started' then
    local ok, core = pcall(function()
      return exports['qbx_core']:GetCoreObject()
    end)
    if ok and core then return core end
  end

  -- Fallback: global QBCore (some builds expose it)
  if _G.QBCore then return _G.QBCore end

  -- Last resort: qb-core (if someone renamed)
  if GetResourceState('qb-core') == 'started' then
    local ok, core = pcall(function()
      return exports['qb-core']:GetCoreObject()
    end)
    if ok and core then return core end
  end

  return nil
end

function BR.GetCore(timeoutMs)
  local deadline = GetGameTimer() + (timeoutMs or 8000)
  local core = tryGetCore()
  while not core and GetGameTimer() < deadline do
    Wait(100)
    core = tryGetCore()
  end
  if not core then
    print('[BR] ERROR: QBox not acquired (qbx_core export missing).')
  end
  return core
end
