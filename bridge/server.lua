akyolm383 = {}
local QBCore = exports['qb-core']:GetCoreObject()

function akyolm383.additem(source, item, amount)
    if Config.Inventory == 'ox_inventory' then
        local success, response = exports.ox_inventory:AddItem(source, item, amount)
        if success then
            print(response)
            return true
        end
    else
        local Player = QBCore.Functions.GetPlayer(source)
        return Player.Functions.AddItem(item, amount)
    end
end

lib.callback.register('five-illegal:server:checkItem', function(source, item)
    return akyolm383.checkitem(source, item)
end)

function akyolm383.checkitem(source, item)
    if Config.Inventory == 'ox_inventory' then
        local itemCount = exports.ox_inventory:Search(source, 'count', item)
        return itemCount > 0 and itemCount or false
    else
        local player = QBCore.Functions.GetPlayer(source)
        local itemData = player.Functions.GetItemByName(item)
        return itemData and itemData.amount > 0 and itemData.amount or false
    end
end

function akyolm383.removeitem(source, item, amount)
    if Config.Inventory == 'ox_inventory' then
        return exports.ox_inventory:RemoveItem(source, item, amount)
    else
        local player = QBCore.Functions.GetPlayer(source)
        return player.Functions.RemoveItem(item, amount)
    end
end

function akyolm383.addmoney(source, amount)
    local player = QBCore.Functions.GetPlayer(source)
    if Config.EsrarOdeme == 'markedbills' then
        player.Functions.AddItem(Config.EsrarOdeme, amount)
    else
        player.Functions.AddMoney(Config.EsrarOdeme, amount, 'sanane amk')
    end
end
