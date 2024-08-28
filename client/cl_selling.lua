local QBCore = exports['qb-core']:GetCoreObject()
lib.locale()

local SoldPeds = {}
local currentZone = nil
for zoneId, zoneConfig in pairs(Config.SellZones) do
    local coords = {}
    for _, point in ipairs(zoneConfig.points) do
        table.insert(coords, vector3(point.x, point.y, point.z))
    end

    lib.zones.poly({
        points = coords,
        thickness = zoneConfig.thickness,
        debug = Config.DebugPoly,
        onEnter = function()
            CreateSellTarget()
            currentZone = zoneId
            if Config.Debug then print("Entered Zone ["..zoneId.."]") end
        end,
        onExit = function()
            currentZone = nil
            RemoveSellTarget()
            if Config.Debug then print("Exited Zone ["..zoneId.."]") end
        end
    })
end

local function AddSoldPed(entity)
    SoldPeds[entity] = true
end
local function HasSoldPed(entity)
    return SoldPeds[entity] ~= nil
end

RegisterNetEvent('five-illegal:client:checkSellOffer', function(entity)
    local playerId = PlayerPedId()
    local copsAmount = lib.callback.await('five-illegal:server:getCopsAmount', false)

    if copsAmount < Config.MinimumCops then
        TriggerEvent('QBCore:Notify', locale('no_interest'), 'error')
        if Config.Debug then print('Not Enough Cops Online') end
        return
    end

    if HasSoldPed(entity) then
        TriggerEvent('QBCore:Notify', locale('allready_speak'), 'error')
        return
    end

    SetEntityAsMissionEntity(entity, true, true)
    TaskTurnPedToFaceEntity(entity, playerId, -1)
    Wait(500)

    local sellChance = math.random(0, 100)
    if sellChance > Config.SellSettings['sellChance'] then
        TriggerEvent('QBCore:Notify', locale('NOTIFICATION__CALLING__COPS'), 'error')
        TaskUseMobilePhoneTimed(entity, 8000)
        SetPedAsNoLongerNeeded(entity)
        ClearPedTasks(playerId)
        AddSoldPed(entity)

        local coords = GetEntityCoords(entity)
        SendPoliceAlert(coords)
        return
    end

    if not currentZone then
        print("Current Zone is nil")
        return
    end

    local zoneConfig = Config.SellZones[currentZone]
    local sellAmount = math.random(Config.SellSettings['sellAmount'].min, Config.SellSettings['sellAmount'].max)

    local sellItemData = zoneConfig.drugs[math.random(1, #zoneConfig.drugs)]
    if not sellItemData or not sellItemData.item then
        print("Selected Item for Sale is nil or item is nil")
        return
    end

    TriggerServerEvent('five-illegal:server:checkItem', sellItemData.item)

    RegisterNetEvent('five-illegal:client:checkItemResponse')
    AddEventHandler('five-illegal:client:checkItemResponse', function(itemCount)
        if itemCount and itemCount > 0 then
            local playerItems = math.min(itemCount, sellAmount)
            TriggerServerEvent('five-illegal:server:initiatedrug', {
                item = sellItemData.item,
                price = sellItemData.price,
                amount = playerItems,
                entity = entity
            })
            AddSoldPed(entity)
        else
            TriggerEvent('QBCore:Notify', locale('no_drugs'), 'error')
            SetPedAsNoLongerNeeded(entity)
        end
    end)
end)
