akyolm383 = {}
local QBCore = exports['qb-core']:GetCoreObject()
function akyolm383.minigame()
    if Config.Minigame == 'ox_lib' then
        local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 1}, 'easy'}, {'w', 'a', 's', 'd'})
        if success then 
            return true 
        else
            TriggerEvent('QBCore:Notify', locale('minigame_failure'), 'error') 
            return false 
        end
    elseif Config.Minigame == 'ps-ui' then
        local result = nil
        exports['ps-ui']:Circle(function(success)
            result = success
        end)
        while result == nil do
            Wait(0)
        end
        if not result then
            TriggerEvent('QBCore:Notify', locale('minigame_failure'), 'error')
        end
        return result
    elseif Config.Minigame == 'bl_ui' then
        local success = exports.bl_ui:CircleProgress(1, 50)
        if success then 
            return true 
        else
            TriggerEvent('QBCore:Notify', locale('minigame_failure'), 'error')
            return false 
        end
    else
        print('Config.Minigame is incorrect')
    end
end


