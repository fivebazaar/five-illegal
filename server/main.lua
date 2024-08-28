local QBCore = exports['qb-core']:GetCoreObject()
lib.locale()

    function randomcollect()
        local totalChance = 0
        for _, v in ipairs(Config.WeedItems) do
            totalChance = totalChance + v.chance
        end

        local randomChance = math.random(1, totalChance)
        local cumulativeChance = 0

        for _, v in ipairs(Config.WeedItems) do
            cumulativeChance = cumulativeChance + v.chance
            if randomChance <= cumulativeChance then
                return v.item
            end
        end
    end

    RegisterNetEvent("five-illegal:cannabiscollect")
    AddEventHandler("five-illegal:cannabiscollect", function()
        local itemeklendi = akyolm383.additem(source, randomcollect(), math.random(Config.EsrarMin, Config.EsrarMax))

        if itemeklendi then
            TriggerClientEvent('QBCore:Notify', source, locale('esrar_collecting_notify_success'), 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, locale('esrar_collecting_notify_error'), 'error')
        end
    end)

    
    RegisterNetEvent("five-illegal:cannabisproccess")
    AddEventHandler("five-illegal:cannabisproccess", function()
        for _, harvestedItem in pairs(Config.WeedItems) do
            local itemName = harvestedItem.item    
            if akyolm383.removeitem(source, itemName, Config.EsrarIslemeMiktar) then
                for _, newItem in pairs(Config.LeavesWeedItems) do
                    if string.find(newItem, itemName) then
                        akyolm383.additem(source, newItem, Config.EsrarIslemeMiktar)
                    end
                end
                TriggerClientEvent('QBCore:Notify', source, locale('esrar_process_notify_success'), 'success')
            else
                TriggerClientEvent('QBCore:Notify', source, locale('esrar_process_notify_error'), 'error')
            end
        end
    end)
    
    
    RegisterNetEvent("five-illegal:esrarSell")
AddEventHandler("five-illegal:esrarSell", function(adet)
    local paymentItem = Config.EsrarOdeme == "bank" and 'bank' or 'cash'
    for i, item in ipairs(Config.PackageSellWeedItems) do
        if akyolm383.removeitem(source, item, Config.EsrarSatisMiktar * adet) then
            local price = Config.SellPrice * adet
            akyolm383.addmoney(source, price)
            TriggerClientEvent('QBCore:Notify', source, locale('esrar_sell_notify_success', adet), 'success', 2500)

            if Config.Log then
                local coords = GetEntityCoords(GetPlayerPed(source))
                SendToWebhook(source, "sell", nil, {item = item, amount = adet, price = price, coords = coords})
            end
        else
            TriggerClientEvent('QBCore:Notify', source, locale('esrar_sell_notify_error'), 'error', 2500)
        end
    end
end)

for _, item in ipairs(Config.PackageSellWeedItems) do
    QBCore.Functions.CreateUseableItem(item, function(source)
        TriggerClientEvent('five-illegal:client:cannabis', source)
    end)
end

RegisterNetEvent('five-illegal:server:cannabis', function()
    for i, item in ipairs(Config.PackageSellWeedItems) do
        if akyolm383.removeitem(source, item, 1) then
            break 
        end
    end
end)

for leavesItem, packageItem in pairs(Config.PackageWeedItems) do
    QBCore.Functions.CreateUseableItem(leavesItem, function(source)

        local function hasItemFromList(player, itemList)
            for _, itemName in ipairs(itemList) do
                local item = akyolm383.checkitem(source, itemName)
                if item then
                    return true, itemName
                end
            end
            return false, nil
        end

        local hasEmptyPackage, emptypackageItem = hasItemFromList(xPlayer, Config.EmptyPackageItems)

        if not hasEmptyPackage then
            TriggerClientEvent('QBCore:Notify', source, locale('empty_package_error'), 'error')
        else
            TriggerClientEvent('five-illegal:progbarstart', source, leavesItem, emptypackageItem, packageItem)
        end

    end)
end

RegisterNetEvent('five-illegal:progbarok')
AddEventHandler('five-illegal:progbarok', function(leavesItem, emptypackageItem, packageItem)
    local src = source

    if akyolm383.removeitem(src, leavesItem, 1) and akyolm383.removeitem(src, emptypackageItem, 1) and akyolm383.additem(src, packageItem, 1) then
        TriggerClientEvent('QBCore:Notify', src, locale('esrar_process_success'), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, locale('esrar_process_notify_error'), 'error')
    end
    
end)
