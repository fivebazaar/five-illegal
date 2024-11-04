Config={}
--GENERAL
Config.EsrarOdeme = "cash" --  (Nakit = cash / Banka = cash / Kara Para = markedbills)
Config.Inventory = 'ox_inventory' -- ox_inventory qb-inventory
Config.Menu = "ox_lib"  -- qb-menu / ox_lib
--Config.Interaction = "qb-core" -- Soon?
Config.Minigame = "bl_ui" -- ps-ui / bl_ui / ox_lib /
Config.Drugs = true -- true / false drugs setting
Config.Log = true -- true / false log
Config.Chance = 100  -- chance rate police dispatch
Config.Dispatch = true -- police dispatch true false
Config.Seller = true -- fixed npc seller true false
Config.Target = "ox_target" -- qb-target / ox_Target
Config.ProgressTime = 1000 --packed
Config.Updater = true
Config.Debug = true
Config.WebhookURL = "https://discord.com/api/webhooks/1300504240271134740/MpR2-nHBsDS4SeOhH6M4cw5osHTSGfZB7pIg5PfA6I1kqa_PP4zCLpdy5BEHZf88n3F7"
Config.RandomLocation = false -- weed collect location random or still
-- GUARD

-- Mesafe ve timeout ayarları
Config.MaxDistance = 10.0 -- Mesafe sınırı
Config.TimeoutLimit = 20   -- Timeout süresi (saniye cinsinden)
Config.MaxTimeoutAttempts = 3 -- Timeout limit sayısı
Config.KickOnTimeout = true -- Timeout limitini aşan oyuncuları at

-- Items
 --Collection 
Config.ForcedItems = "scissors"   -- forced item name
Config.ForcedItemsOnline = false -- true / false
Config.WeedItems = {
    {item = "weed_bad_ql", chance = 50},
    {item = "weed_max_ql", chance = 50}
}
Config.PackageWeedItems = { -- the equivalent of packaged weed 
    ["leaves_weed_bad_ql"] = "package_weed_bad_ql",
    ["leaves_weed_max_ql"] = "package_weed_max_ql" 
}
Config.LeavesWeedItems = {"leaves_weed_bad_ql", "leaves_weed_max_ql"} -- işlenmiş weed
Config.PackageSellWeedItems = {"package_weed_bad_ql", "package_weed_max_ql"}
Config.EmptyPackageItems = {"emptypackage"}

Config.WeedLocation = { -- ESRARLARIN CIKACAGI YERLER
vector3(1978.32, 4796.43, 42.42),
vector3(1975.47, 4793.58, 42.61),
vector3(1972.98, 4791.13, 42.61),
vector3(1970.38, 4788.88, 42.67),
vector3(1966.61, 4789.72, 42.83),   
vector3(1969.34, 4792.2, 42.82),
vector3(1971.91, 4794.81, 42.78),
vector3(1975.08, 4797.71, 42.75),
vector3(1977.39, 4800.22, 42.71),
}

Config.WeedLocationZCoord = 40.42 --weed collect prop z coords
Config.WeedMin = 1  -- Esrar toplarken minimum vereceği sayı
Config.WeedMax = 4 -- Esrar toplarken maximum vereceği sayı
--Processing
Config.WeedProcessAmount = 2 -- Kaç tane işlemesi gerektiğini belirliyorsunuz, örneğin 1 yaparsanız 1 adet işler 2 yaparsanız tek seferde 2 adet
-- Selling
Config.WeedSellAmount = 1 -- Esrar satarken minimum satılan miktar
Config.SellPrice = math.random(500, 1000) -- Esrar satış fiyatı 

Config.ProcessLocation = {
    targetZone = vector3(1389.78, 3608.75, 38.94), -- Satış hedef bölgesi koordinatları
    targetHeading = 309.21, -- Satış hedef bölgesi başlığı
    minZ = 36.94, -- Satış hedef bölgesi minimum Z koordinatı
    maxZ = 40.94 -- Satış hedef bölgesi maksimum Z koordinatı
}

Config.SellLocation = {
    targetZone = vector3(578.41, -2804.36, 6.06), -- Satış hedef bölgesi koordinatları
    targetHeading = 244.0, -- Satış hedef bölgesi başlığı
    minZ = 5.0, -- Satış hedef bölgesi minimum Z koordinatı
    maxZ = 7.0 -- Satış hedef bölgesi maksimum Z koordinatı
}

Config.Text = {
    Seller = "Satıcı" -- Hedef bölgesi etiketi
}
--coords
Config.NPC = vector4(578.41, -2804.36, 5.06, 243.48) --Satış NPC'sinin konumu

Config.EnableSelling = true -- Enable selling system

Config.MinimumCops = 0 -- Minimum cops required to sell drugs
Config.OnlyCopsOnDuty = false -- Check if cops are on-duty (Only QBCore).
Config.PoliceJobs = {
    'police',
    'offpolice',
    'sheriff',
    'offsheriff',
}

Config.SellSettings = {
    ['onlyAvailableItems'] = true, -- Only offers with drugs the player has in his inventory
    ['sellChance'] = 100, -- Chance to sell drug (in %)
    ['stealChance'] = 0, -- Chance that the ped dont give you money (in %)
    ['sellAmount'] = { -- Amount of drugs you can sell
        min = 1,
        max = 6,
    },
    ['sellTimeout'] = 20, -- Max time you get to choose your option (secs)
    ['giveBonusOnPolice'] = true, -- Give bonus money if there is police online | 1-2 Cops : x1.2 | 3-6 Cops : x1.5 | 7-10 Cops : x1.7 | +10 Cops : x2.0
}

Config.SellZones = {
    ['groove'] = {
        points = {
            vec3(-154.0, -1778.0, 30.0),
            vec3(48.0, -1690.0, 30.0),
            vec3(250.0, -1860.0, 30.0),
            vec3(142.0, -1993.0, 30.0),
            vec3(130.0, -2029.0, 30.0),
        },
        thickness = 27,
        drugs = {
            { item = 'package_weed_max_ql', price = math.random(100, 100)},
            { item = 'package_weed_bad_ql', price = math.random(100, 100)}
        }   
    },
    ['vinewood'] = {
        points = {
            vec3(685.0, 36.0, 84.0),
            vec3(647.0, 53.0, 84.0),
            vec3(575.0, 81.0, 84.0),
            vec3(529.0, 100.0, 84.0),
            vec3(52.0, 274.0, 84.0),
            vec3(-34.0, 42.0, 84.0),
            vec3(426.0, -125.0, 84.0),
            vec3(494.0, -140.0, 84.0),
            vec3(518.0, -101.0, 84.0),
            vec3(595.0, -60.0, 84.0),
            vec3(667.0, -9.0, 84.0),
        },
        thickness = 59.0,
        drugs = {
            { item = 'package_weed_bad_ql', price = math.random(100, 100)}
        }
    },
}

Config.BlacklistPeds = { 
    "mp_m_shopkeep_01",
    "s_m_y_ammucity_01",
    "s_m_m_lathandy_01",
    "s_f_y_clubbar_01",
    "ig_talcc",
    "g_f_y_vagos_01",
    "hc_hacker",
    "s_m_m_migrant_01",
}

function SendPoliceAlert(coords)
    exports['ps-dispatch']:DrugSale()
end
