BR = BR or {}
local QBox = nil

function BR.GetCore(timeout)
  if QBox then return QBox end
  local waited = 0
  timeout = timeout or 8000
  while not QBox and waited < timeout do
    local ok, result = pcall(function()
      return exports['qbox-core']:GetCoreObject()
    end)
    if ok and result then
      QBox = result
      print('[BR] QBox core acquired')
      return QBox
    end
    Wait(200)
    waited = waited + 200
  end
  print('[BR] ERROR: QBox not acquired')
  return nil
end
