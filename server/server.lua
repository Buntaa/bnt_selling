local ESX = exports['es_extended']:getSharedObject()

RegisterServerEvent('selling:start')
AddEventHandler('selling:start', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local itemToSell = nil
    local sellPrice = nil

    for item, price in pairs(Config.SellableItems) do
        local count = xPlayer.getInventoryItem(item).count
        if count > 0 then
            itemToSell = item
            sellPrice = price
            break
        end
    end

    if not itemToSell then
        TriggerClientEvent('esx:showNotification', src, "You have nothing to sell.")
        return
    end

    local pedModel = Config.PedModel[math.random(1, #Config.PedModel)]
    local ped = GetPlayerPed(src)
    local pos = GetEntityCoords(ped)

    local forward = GetEntityForwardVector(ped)
    local spawnPos = pos + forward * Config.SpawnDistance

    local loc = {
        x = spawnPos.x,
        y = spawnPos.y,
        z = spawnPos.z
    }

    local pcoords = {
        x = pos.x,
        y = pos.y,
        z = pos.z
    }

    TriggerClientEvent('selling:spawnPed', -1, loc, pcoords, pedModel)
    xPlayer.set('sellingItem', itemToSell)
end)

RegisterServerEvent('selling:completeSell')
AddEventHandler('selling:completeSell', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local item = xPlayer.get('sellingItem')
    if not item then
        print("[WARNING] Player attempted sell transaction with no item in sell state: " .. src)
        return
    end

    local price = Config.SellableItems[item]
    if not price then return end

    local count = xPlayer.getInventoryItem(item).count
    if count <= 0 then
        xPlayer.set('sellingItem', nil)
        print('[WARNING] Player tried to sell item they no longer have.' .. src)
        return
    end

    xPlayer.removeInventoryItem(item, 1)
    xPlayer.addAccountMoney("black_money", price)
    xPlayer.set("sellingItem", nil)

    TriggerClientEvent('esx:showNotification', src, ("You sold 1x  %s for $%d dirty money."):format(item, price))
end)