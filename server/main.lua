local QBCore = exports['qb-core']:GetCoreObject()
lib.locale()

local lastProcessTime = {}
local lastSellTime = {}
local timeoutAttempts = {}

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

local function sendKickWebhook(playerId, reason, processType)
    if Config.WebhookURL then
        local playerName = GetPlayerName(playerId)
        local kickMessage = {
            username = locale('timeout_bot_username'),
            embeds = {
                {
                    title = locale('player_kicked_title'),
                    description = string.format(locale('player_kicked_description'), playerName),
                    color = 16711680,
                    fields = {
                        { name = locale('player_name_field'), value = playerName, inline = true },
                        { name = locale('reason_field'), value = reason .. " (" .. processType .. ")", inline = true },
                        { name = locale('time_field'), value = os.date("%Y-%m-%d %H:%M:%S"), inline = true }
                    }
                }
            }
        }

        PerformHttpRequest(Config.WebhookURL, function(err, text, headers)
            if err == 200 or err == 204 then
                print("Webhook sent successfully.")
            else
                print("Failed to send webhook, error code:", err)
            end
        end, "POST", json.encode(kickMessage), { ["Content-Type"] = "application/json" })
    else
        print("Webhook URL yapılandırılmamış.")
    end
end

RegisterNetEvent("five-illegal:cannabiscollect")
AddEventHandler("five-illegal:cannabiscollect", function()
    local src = source
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local currentTime = os.time()
    if lastProcessTime[src] and currentTime - lastProcessTime[src] < Config.TimeoutLimit then
        timeoutAttempts[src] = (timeoutAttempts[src] or 0) + 1

        if Config.KickOnTimeout and timeoutAttempts[src] >= Config.MaxTimeoutAttempts then
            sendKickWebhook(src, locale('timeout_error'), "how is it: Collection") 
            DropPlayer(src, locale('kick_message'))
            timeoutAttempts[src] = nil
            return
        end
        
        TriggerClientEvent('QBCore:Notify', src, locale('timeout_error'), 'error')
        return 
    end

    lastProcessTime[src] = currentTime
    timeoutAttempts[src] = 0
    local itemeklendi = akyolm383.additem(src, randomcollect(), math.random(Config.EsrarMin, Config.EsrarMax))

    if itemeklendi then
        TriggerClientEvent('QBCore:Notify', src, locale('esrar_collecting_notify_success'), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, locale('esrar_collecting_notify_error'), 'error')
    end
end)


RegisterNetEvent("five-illegal:cannabisproccess")
AddEventHandler("five-illegal:cannabisproccess", function()
    local src = source
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local currentTime = os.time()
    if #(playerCoords - Config.ProcessLocation.targetZone) > Config.MaxDistance then
        TriggerClientEvent('QBCore:Notify', src, locale('distance_error'), 'error')
        return
    end
    if lastProcessTime[src] and currentTime - lastProcessTime[src] < Config.TimeoutLimit then
        timeoutAttempts[src] = (timeoutAttempts[src] or 0) + 1

        if Config.KickOnTimeout and timeoutAttempts[src] >= Config.MaxTimeoutAttempts then
            sendKickWebhook(src, locale('kick_message'), "how is it: processing") 
            DropPlayer(src, locale('kick_message'))
            timeoutAttempts[src] = nil
        else
            TriggerClientEvent('QBCore:Notify', src, locale('timeout_error'), 'error')
        end
        return
    end

    lastProcessTime[src] = currentTime
    timeoutAttempts[src] = 0
    for _, harvestedItem in pairs(Config.WeedItems) do
        local itemName = harvestedItem.item    
        if akyolm383.removeitem(src, itemName, Config.EsrarIslemeMiktar) then
            for _, newItem in pairs(Config.LeavesWeedItems) do
                if string.find(newItem, itemName) then
                    akyolm383.additem(src, newItem, Config.EsrarIslemeMiktar)
                end
            end
            TriggerClientEvent('QBCore:Notify', src, locale('esrar_process_notify_success'), 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, locale('esrar_process_notify_error'), 'error')
        end
    end
end)


RegisterNetEvent("five-illegal:esrarSell")
AddEventHandler("five-illegal:esrarSell", function(adet)
    local src = source
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local currentTime = os.time()
    if #(playerCoords - Config.SellLocation.targetZone) > Config.MaxDistance then
        TriggerClientEvent('QBCore:Notify', src, locale('distance_error'), 'error')
        return
    end
    if lastSellTime[src] and currentTime - lastSellTime[src] < Config.TimeoutLimit then
        timeoutAttempts[src] = (timeoutAttempts[src] or 0) + 1

        if Config.KickOnTimeout and timeoutAttempts[src] >= Config.MaxTimeoutAttempts then
            sendKickWebhook(src, locale('kick_message'), "how is it: selling") 
            DropPlayer(src, locale('kick_message'))
            timeoutAttempts[src] = nil
        else
            TriggerClientEvent('QBCore:Notify', src, locale('timeout_error'), 'error')
        end
        return
    end

    lastSellTime[src] = currentTime
    timeoutAttempts[src] = 0

    local paymentItem = Config.EsrarOdeme == "bank" and 'bank' or 'cash'
    for i, item in ipairs(Config.PackageSellWeedItems) do
        if akyolm383.removeitem(src, item, Config.EsrarSatisMiktar * adet) then
            local price = Config.SellPrice * adet
            akyolm383.addmoney(src, price)
            TriggerClientEvent('QBCore:Notify', src, locale('esrar_sell_notify_success', adet), 'success', 2500)

            if Config.Log then
                local coords = GetEntityCoords(GetPlayerPed(src))
                SendToWebhook(src, "sell", nil, {item = item, amount = adet, price = price, coords = coords})
            end
        else
            TriggerClientEvent('QBCore:Notify', src, locale('esrar_sell_notify_error'), 'error', 2500)
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
        local hasEmptyPackage, emptypackageItem = hasItemFromList(source, Config.EmptyPackageItems)
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
