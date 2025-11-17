local spawnedPed = nil
local pedWalking = false

RegisterNetEvent('selling:spawnPed', function(spawnPos, playerPos, model)
    if spawnedPed ~= nil then return end

    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end

    spawnedPed = CreatePed(4, hash, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    SetPedFleeAttributes(spawnedPed, 0, false)

    pedWalking = true

    TaskGoToCoordAnyMeans(spawnedPed, playerPos.x, playerPos.y, playerPos.z, 1.0, 0, false, 786603, 0.0)

    CreateThread(function()
        while pedWalking and spawnedPed do
            local pedPos = GetEntityCoords(spawnedPed)
            local dist = #(pedPos - vector3(playerPos.x, playerPos.y, playerPos.z))

            if dist < 2.0 then
                pedWalking = false
                ClearPedTasks(spawnedPed)
                local dict = Config.HandshakeAnim.dict
                RequestAnimDict(dict)
                while not HasAnimDictLoaded(dict) do Wait(0) end

                TaskPlayAnim(PlayerPedId(), dict, Config.HandshakeAnim.anim, 1.0, 1.0, 2500, 49, 1.0, false, false, false)
                TaskPlayAnim(spawnedPed, dict, Config.HandshakeAnim.anim, 1.0, 1.0, 2500, 49, 1.0, false, false, false)

                TriggerServerEvent('selling:completeSell')
                Wait(2000)

                local walkTfAwayDirection = GetEntityForwardVector(PlayerPedId()) * -5.0
                local walkTfAwayPosition = GetEntityCoords(spawnedPed) + walkTfAwayDirection

                TaskGoStraightToCoord(spawnedPed, walkTfAwayPosition.x, walkTfAwayPosition.y, walkTfAwayPosition.z, 1.0, -1, 0.0, 0.0)
                Wait(5000)

                DeleteEntity(spawnedPed)
                spawnedPed = nil
            end
            Wait(200)
        end
    end)
end)

RegisterCommand('sellitem', function()
    TriggerServerEvent('selling:start')
end)