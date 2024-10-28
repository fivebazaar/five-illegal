local QBCore = exports['qb-core']:GetCoreObject()
lib.locale()

function CreateEsrarZones()
    for i = 1, #Config.Esrartoplama do
        if Config.Target == "qb-target" then
            exports['qb-target']:AddBoxZone("Esrar" .. i, Config.Esrartoplama[i], 1, 1, {
                name = "Esrar",
                heading = 114.34,
                debugPoly = false,
                minZ = 41.59,
                maxZ = 43.59
            }, {
                options = {
                    {
                        type = "client",
                        event = "five-illegal:cannabiscollect",
                        icon = "fas fa-leaf",
                        label = locale('esrar_collecting_target'),
                    }
                },
                distance = 1.5
            })
        elseif Config.Target == "ox_target" then
            exports.ox_target:addBoxZone({
                coords = Config.Esrartoplama[i],
                size = vec3(1, 1, 1),
                rotation = 114.34,
                minZ = 41.59,
                maxZ = 43.59,
                options = {
                    {
                        name = "Esrar",
                        event = "five-illegal:cannabiscollect",
                        icon = "fas fa-leaf",
                        label = locale('esrar_collecting_target'),
                    }
                },
                distance = 1.5
            })
        end
    end
end

CreateEsrarZones()

RegisterNetEvent('five-illegal:cannabiscollect')
AddEventHandler('five-illegal:cannabiscollect', function()
    if not topluyormu then
        local collectAllowed = true

        if Config.ForcedItemsOnline then
            collectAllowed = QBCore.Functions.HasItem(Config.ForcedItems)
        end

        if collectAllowed then
            topluyormu = true

            QBCore.Functions.Progressbar('esrartopla', locale('esrar_collecting'), 2000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = "special_ped@zombie@base",
                anim = "base",
                flags = 49,
            }, {
                model = "p_cs_scissors_s",
                coords = { x = 0.0, y = 0.0, z = 0.0 },
                rotation = { x = 420.0, y = 50.0, z = 0.0 },
            }, {}, function() 
                TriggerServerEvent('five-illegal:cannabiscollect')
                topluyormu = false
            end, function() 
                topluyormu = false
                TriggerEvent('QBCore:Notify', locale('weed_collect_fail'), 'error')
            end)

        else
            TriggerEvent('QBCore:Notify', locale('esrar_collecting_item_notfound'), 'error')
        end
    end
end)




CreateThread(function()
    if Config.Target == "qb-target" then
        exports['qb-target']:AddBoxZone("Process", Config.ProcessLocation.targetZone, 1, 1, {
            name = "Process",
            heading = Config.ProcessLocation.targetHeading,
            debugPoly = false,
            minZ = Config.ProcessLocation.minZ,
            maxZ = Config.ProcessLocation.maxZ,
        }, {
            options = {
                {
                    type = "client",
                    event = "five-illegal:cannabisproccess",
                    icon = "fas fa-leaf",
                    label = locale('esrar_process_target'),
                }
            },
            distance = 1.5
        })
    elseif Config.Target == "ox_target" then
        exports.ox_target:addBoxZone({
            coords = Config.ProcessLocation.targetZone,
            size = vec3(1, 1, 1),
            rotation = Config.ProcessLocation.targetHeading,
            minZ = Config.ProcessLocation.minZ,
            maxZ = Config.ProcessLocation.maxZ,
            options = {
                {
                    name = "Process",
                    event = "five-illegal:cannabisproccess",
                    icon = "fas fa-leaf",
                    label = locale('esrar_process_target'),
                }
            },
            distance = 1.5
        })
    end
end)


RegisterNetEvent('five-illegal:cannabisproccess')
AddEventHandler('five-illegal:cannabisproccess', function()
    local minigame = akyolm383.minigame()
    if minigame then TriggerServerEvent("five-illegal:cannabisproccess") end
end)

local function debugPrint(message)
    if Config.Debug then
        print(message)
    end
end

CreateThread(function()
    if Config.Seller then
        debugPrint("Creating Seller target...")
        if Config.Target == "qb-target" then
            exports['qb-target']:AddBoxZone("Seller", Config.SellLocation.targetZone, 1, 1, {
                name = "Seller",
                heading = Config.SellLocation.targetHeading,
                debugPoly = false,
                minZ = Config.SellLocation.minZ,
                maxZ = Config.SellLocation.maxZ,
            }, {
                options = {
                    {
                        type = "event",
                        event = "esrarsatis:menu",
                        icon = "fas fa-hands",
                        label = Config.Text.Seller,
                    },
                },
                distance = 1.5
            })
        elseif Config.Target == "ox_target" then
            exports.ox_target:addBoxZone({
                coords = Config.SellLocation.targetZone,
                size = vec3(1, 1, 1),
                rotation = Config.SellLocation.targetHeading,
                minZ = Config.SellLocation.minZ,
                maxZ = Config.SellLocation.maxZ,
                options = {
                    {
                        name = "Seller",
                        event = "esrarsatis:menu",
                        icon = "fas fa-hands",
                        label = Config.Text.Seller,
                    }
                },
                distance = 1.5
            })
        else
            debugPrint("Invalid Target type: " .. Config.Target)
        end
    end
end)

if Config.Seller then
    RegisterNetEvent('esrarsatis:menu')
    AddEventHandler('esrarsatis:menu', function()
        debugPrint("esrarsatis:menu triggered. Selected menu: " .. Config.Menu)
        if Config.Menu == "qb-menu" then
            debugPrint("Opening qb-menu...")
            TriggerEvent('qb-menu:open')
        elseif Config.Menu == "ox_lib" then
            debugPrint("Opening ox-input...")
            TriggerEvent('ox-input:openMenu')
        else
            debugPrint("No valid value found for Config.Menu: " .. Config.Menu)
        end
    end)

    if Config.Menu == "ox_lib" then
        RegisterNetEvent('ox-input:open')
        AddEventHandler('ox-input:open', function()
            debugPrint("OX input opening...")
            local input = lib.inputDialog(locale('sell_weed_title'), {locale('sell_weed_prompt')})
            if not input then 
                debugPrint("Input was empty or closed.")
                return 
            end

            local amount = tonumber(input[1])
            if not amount or amount <= 0 then
                debugPrint("Invalid amount: " .. tostring(input[1]))
                return
            end

            debugPrint("Sending sell request to server, amount: " .. amount)
            TriggerServerEvent("five-illegal:esrarSell", amount)

            if Config.Dispatch and math.random(1, 100) <= Config.Chance then
                debugPrint("Dispatch triggered.")
                Wait(3000)
                exports['ps-dispatch']:DrugSale()
                TriggerEvent('QBCore:Notify', locale('cannabis_selling_police_dispatch'), 'error')
            end
        end)
    end

    if Config.Menu == "qb-menu" then
        RegisterNetEvent('qb-menu:open')
        AddEventHandler('qb-menu:open', function()
            debugPrint("Opening QB menu...")
            exports['qb-menu']:openMenu({
                {
                    header = locale('menu_header_qb'),
                    icon = 'fas fa-code',
                    isMenuHeader = true,
                },
                {
                    header = locale('menu_option_qb'),
                    txt = locale('menu_txt_qb'),
                    icon = 'fas fa-code-merge',
                    params = {
                        event = 'qb-input:open',
                    }
                }
            })
        end)

        RegisterNetEvent('qb-input:open')
        AddEventHandler('qb-input:open', function()
            debugPrint("QB input triggered...")
            local keyboard = exports['qb-input']:ShowInput({
                header = locale('input_header_qb'),
                submitText = locale('input_submit_qb'),
                inputs = {
                    {
                        type = 'number',
                        isRequired = true,
                        text = locale('input_text_qb'),
                        name = 'input',
                    }
                }
            })

            if not keyboard or not tonumber(keyboard.input) or tonumber(keyboard.input) <= 0 then
                debugPrint("Invalid amount entered! Input: " .. tostring(keyboard.input))
                return
            end

            local amount = tonumber(keyboard.input)
            debugPrint("Sending sell request to server, amount: " .. amount)
            TriggerServerEvent("five-illegal:esrarSell", amount)

            if Config.Dispatch and math.random(1, 100) <= Config.Chance then
                debugPrint("Dispatch triggered.")
                Wait(3000)
                exports['ps-dispatch']:DrugSale()
                TriggerEvent('QBCore:Notify', locale('cannabis_selling_police_dispatch'), 'error')
            end
        end)
    end

    if Config.Menu == "ox_lib" then
        RegisterNetEvent('ox-input:openMenu')
        AddEventHandler('ox-input:openMenu', function()
            debugPrint("Opening OX menu...")
            lib.showContext("esrarsatismenu")
        end)

        lib.registerContext({
            id = 'esrarsatismenu',
            title = locale('menu_header_ox'),
            options = {
                {
                    title = locale('menu_title_ox'),
                    description = locale('menu_desc_ox'),
                    icon = 'code-merge',
                    event = 'ox-input:open',
                    arrow = true
                }
            }
        })
    end
end

--blips
if Blips.blipactivated then
    for _, blipData in ipairs(Blips) do
        local blip = AddBlipForCoord(blipData.position.x, blipData.position.y, blipData.position.z)
        SetBlipSprite(blip, 140)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 2)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipData.label)
        EndTextCommandSetBlipName(blip)
    end
end

-- NPC
local NPC = Config.NPC
if Config.Seller then
    Citizen.CreateThread(function()

        local ped_hash2 = 0xA956BD9E -- Ped Hash Giriniz https://wiki.rage.mp/index.php?title=Peds
        
        RequestModel(ped_hash2)
        while not HasModelLoaded(ped_hash2) do
            Wait(1)
        end

        local ped_info2 = CreatePed(1, ped_hash2, Config.NPC, false, true)
        SetBlockingOfNonTemporaryEvents(ped_info2, true)
        SetPedDiesWhenInjured(ped_info2, false)
        SetPedCanPlayAmbientAnims(ped_info2, true)
        SetPedCanRagdollFromPlayerImpact(ped_info2, false)
        SetEntityInvincible(ped_info2, true)
        FreezeEntityPosition(ped_info2, true)
    end)
end
function AddPropToCoords(coords)
    local propModel = "prop_pot_plant_inter_03a"
    local propHeading = 0.0
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Wait(500)
    end
    local prop = CreateObject(GetHashKey(propModel), coords, false, false, false)
    SetEntityHeading(prop, propHeading)
    FreezeEntityPosition(prop, true)
end

Citizen.CreateThread(function()
    for _, coord in ipairs(Config.Esrartoplama) do
        AddPropToCoords(coord)
    end
end)

local function heal()
    if healing then return end

    healing = true

    local count = 9
    while count > 0 do
        Wait(1000)
        count -= 1
        SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) + 6)
    end
    healing = false
end

local function waowEffect()
    local startStamina = 30
    local mathrandom = math.random(5000, 8000)
    StartScreenEffect('DrugsMichaelAliensFightIn', 3.0, 0)
    heal()
    while startStamina > 0 do
        Wait(1000)
        startStamina -= 1
        RestorePlayerStamina(PlayerId(), 1.0)
        if math.random(1, 100) < 51 then
            SetFlash(0, 0, 500, 7000, 500)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08)
        end
    end
    StopScreenEffect('DrugsMichaelAliensFightIn')
    StartScreenEffect('DrugsMichaelAliensFight', 3.0, 0)
    Wait(mathrandom)
    StopScreenEffect('DrugsMichaelAliensFight')
    StartScreenEffect('DrugsMichaelAliensFightOut', 3.0, 0)
    Wait(mathrandom)
    StopScreenEffect('DrugsMichaelAliensFightOut')
end

local function drugsEffect()
    local startStamina = 20
    local ped = PlayerPedId()
    waowEffect()
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.1)
    while startStamina > 0 do
        Wait(1000)
        if math.random(1, 100) < 20 then
            RestorePlayerStamina(PlayerId(), 1.0)
        end
        startStamina -= 1
        if math.random(1, 100) < 10 and IsPedRunning(ped) then
            SetPedToRagdoll(ped, math.random(1000, 3000), math.random(1000, 3000), 3, false, false, false)
        end
        if math.random(1, 300) < 10 then
            waowEffect()
            Wait(math.random(3000, 6000))
        end
    end
    if IsPedRunning(ped) then
        SetPedToRagdoll(ped, math.random(1000, 3000), math.random(1000, 3000), 3, false, false, false)
    end
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
end

RegisterNetEvent('five-illegal:client:cannabis', function()
    if not Config.Drugs then
        return
    end
    local ped = PlayerPedId()
    QBCore.Functions.Progressbar('snort_coke', locale('consumables.coke_progress'), math.random(5000, 8000), false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'switch@trevor@trev_smoking_meth',
        anim = 'trev_smoking_meth_loop',
        flags = 49,
    }, {}, {}, function()
        StopAnimTask(ped, 'switch@trevor@trev_smoking_meth', 'trev_smoking_meth_loop', 1.0)
        TriggerServerEvent('five-illegal:server:cannabis')
        TriggerServerEvent('hud:server:RelieveStress', math.random(2, 4))
        -- locale halledilecek
        TriggerEvent('QBCore:Notify', 'Kendini daha dinç hissediyorsun!', 'info')
        drugsEffect()
    end, function()
        StopAnimTask(ped, 'switch@trevor@trev_smoking_meth', 'trev_smoking_meth_loop', 1.0)
        QBCore.Functions.Notify(locale('consumables.cannabis_canceled'), 'error')
    end)
end)

local function isPedBlacklisted(ped)
	local model = GetEntityModel(ped)
	for i = 1, #Config.BlacklistPeds do
		if model == GetHashKey(Config.BlacklistPeds[i]) then
			return true
		end
	end
	return false
end

CreateSellTarget = function()
    if Config.Target == 'qb-target' then
        if not exports['qb-target'] then return end
        exports['qb-target']:AddGlobalPed({
            options = {
                {
                    label = locale('sell_weed_label'),
                    icon = 'fas fa-comment',
                    action = function(entity)
                        TriggerEvent('five-illegal:client:checkSellOffer', entity)
                    end,
                    canInteract = function(entity)
                        if not IsPedDeadOrDying(entity, false) and not IsPedInAnyVehicle(entity, false) and (GetPedType(entity)~=28) and (not IsPedAPlayer(entity)) and (not isPedBlacklisted(entity)) and not IsPedInAnyVehicle(PlayerPedId(), false) then
                            return true
                        end
                        return false
                    end,
                }
            },
            distance = 4,
        })

    elseif Config.Target == 'ox_target' then
        if not exports.ox_target then return end
        exports.ox_target:addGlobalPed({
            {
                label = locale('sell_weed_label'),
                icon = 'fas fa-comment',
                onSelect = function(data)
                    TriggerEvent('five-illegal:client:checkSellOffer', data.entity)
                end,
                canInteract = function(entity, _, _, _, _)
                    if not IsPedDeadOrDying(entity, false) and not IsPedInAnyVehicle(entity, false) and (GetPedType(entity)~=28) and (not IsPedAPlayer(entity)) and (not isPedBlacklisted(entity)) and not IsPedInAnyVehicle(PlayerPedId(), false) then
                        return true
                    end
                    return false
                end,
                distance = 4
            }
        })
    end
end

RemoveSellTarget = function()
    if Config.Target == 'qb-target' then
        if not exports['qb-target'] then return end
        exports['qb-target']:RemoveGlobalPed("Esrar Sat")
    elseif Config.Target == 'ox_target' then
        if not exports.ox_target then return end
        exports.ox_target:removeGlobalPed('Esrar Sat')
    end
end

RegisterNetEvent('five-illegal:progbarstart')
AddEventHandler('five-illegal:progbarstart', function(leavesItem, emptypackageItem, packageItem)
    QBCore.Functions.Progressbar('process_weed', locale('process_weed_progress'), Config.ProgressTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'amb@prop_human_parking_meter@female@idle_a',
        anim = 'idle_a_female',
        flags = 49,
    }, {}, {}, function() 
        TriggerServerEvent('five-illegal:progbarok', leavesItem, emptypackageItem, packageItem)
    end, function()
        QBCore.Functions.Notify(locale('process_cancelled'), 'error')
    end)
end)



