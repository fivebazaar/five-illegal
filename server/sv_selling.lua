local QBCore = exports['qb-core']:GetCoreObject()
lib.locale()

local function getCopsAmount()
    local copsAmount = 0
    local onlinePlayers = QBCore.Functions.GetPlayers() 
    
    for _, playerId in ipairs(onlinePlayers) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            local job = Player.PlayerData.job
            for _, v in pairs(Config.PoliceJobs) do
                if job.name == v then
                    if Config.OnlyCopsOnDuty and not job.onduty then
                        return copsAmount
                    end
                    copsAmount = copsAmount + 1
                end
            end
        end
    end
    return copsAmount
end

function SendToWebhook(playerId, action, details, extra)
    local player = QBCore.Functions.GetPlayer(playerId)
    if not player then return end

    local playerName = player.PlayerData.name
    local playerIdentifier = player.PlayerData.citizenid
    local embed = {
        {
            ["color"] = 3066993,
            ["title"] = locale("DRUG_SALE_ALERT"), 
            ["description"] = locale("DRUG_SALE_DESCRIPTION"), 
            ["fields"] = {
                { ["name"] = locale("PLAYER_NAME"), ["value"] = playerName, ["inline"] = true },
                { ["name"] = locale("PLAYER_ID"), ["value"] = playerIdentifier, ["inline"] = true }, 
                { ["name"] = locale("ACTION"), ["value"] = action, ["inline"] = true }, 
                { ["name"] = locale("ITEM"), ["value"] = extra.item, ["inline"] = true }, 
                { ["name"] = locale("AMOUNT"), ["value"] = tostring(extra.amount), ["inline"] = true }, 
                { ["name"] = locale("PRICE"), ["value"] = tostring(extra.price), ["inline"] = true }, 
                { ["name"] = locale("COORDINATES"), ["value"] = string.format("X: %f, Y: %f, Z: %f", extra.coords.x, extra.coords.y, extra.coords.z), ["inline"] = true } 
            },
            ["footer"] = {
                ["text"] = locale("DRUG_SALE_SYSTEM") 
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    local payload = {
        username = locale("DRUG_SALE_BOT"), 
        embeds = embed
    }
    
    PerformHttpRequest(Config.WebhookURL, function(err, text, headers)
        if err == 204 then
            print("Webhook sent successfully, but no content was returned.")
        elseif err ~= 200 then
            print("Failed to send webhook, error code: " .. err)
            print("Error message: " .. (text or "empty"))
        else
            print("Webhook sent successfully")
        end
    end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
end    

RegisterNetEvent('five-illegal:server:initiatedrug', function(cad)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local price = cad.price * cad.amount
        print("Initial Price: " .. price)

        if Config.SellSettings['giveBonusOnPolice'] then
            local copsAmount = getCopsAmount()
            if copsAmount > 0 and copsAmount < 3 then
                price = price * 1.2
            elseif copsAmount >= 3 and copsAmount <= 6 then
                price = price * 1.5
            elseif copsAmount >= 7 and copsAmount <= 10 then
                price = price * 1.7
            elseif copsAmount >= 10 then
                price = price * 2.0
            end
        end

        price = math.floor(price)
        print("Price After Bonus: " .. price)

        local itemAmount = akyolm383.checkitem(src, cad.item)
        if itemAmount and itemAmount >= cad.amount then
            if akyolm383.removeitem(src, cad.item, cad.amount) then
                math.randomseed(GetGameTimer())
                local stealChance = math.random(0, 100)
                print("Steal Chance: " .. stealChance)

                if stealChance < Config.SellSettings['stealChance'] then
                    TriggerClientEvent('QBCore:Notify', src, locale('drug_stolen'), 'error')
                else
                    akyolm383.addmoney(src, price)
                    TriggerClientEvent('QBCore:Notify', src, locale('sold_drug'), 'success')
                end

                local coords = GetEntityCoords(GetPlayerPed(src))
                SendToWebhook(src, 'sell', nil, {item = cad.item, amount = cad.amount, price = price, coords = coords})
                print("Webhook sent successfully.")
                if Config.Debug then
                    print('You got ' .. cad.amount .. ' ' .. cad.item .. ' for $' .. price)
                end
            else
                TriggerClientEvent('QBCore:Notify', src, locale('fail_sell'):format(cad.item), 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, locale('no_item_left'):format(cad.item), 'error')
        end     
    end
end)

lib.callback.register('five-illegal:server:getPlayerItems', function(source)
    local playerItemsData = {}
    if Config.Inventory == "ox_inventory" then
        playerItemsData = exports.ox_inventory:Search(source, 'all')
    elseif Config.Inventory == "qb-inventory" then
        playerItemsData = QBCore.Functions.GetPlayer(source).PlayerData.items
    end
    return playerItemsData
end)

lib.callback.register('five-illegal:server:getCopsAmount', function(source)
    return getCopsAmount()
end)

RegisterNetEvent('five-illegal:server:checkItem')
AddEventHandler('five-illegal:server:checkItem', function(item)
    local src = source
    local itemCount = akyolm383.checkitem(src, item)
    TriggerClientEvent('five-illegal:client:checkItemResponse', src, itemCount)
end)
