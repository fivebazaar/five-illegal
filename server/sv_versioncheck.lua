Citizen.CreateThread(function()
    if not Config.Updater then
        -- print("^1[INFO]^0 Update checker is disabled.")
        return
    end

    local updatePath = "/fivebazaar/five-illegal" 
    local resourceName = "five-illegal ("..GetCurrentResourceName()..")" 
    
    function checkVersion(err, responseText, headers)
        if err ~= 200 then
            print("^1[ERROR]^0 HTTP Request failed with error code: " .. tostring(err))
            return
        end
        
        local curVersionContent = LoadResourceFile(GetCurrentResourceName(), "version") 
        
        if curVersionContent == nil then
            print("^1[ERROR]^0 Local version file is missing or couldn't be read.")
            return
        end
        
        local curVersion = json.decode(curVersionContent)
        local remoteVersion = json.decode(responseText)

        if remoteVersion == nil then
            print("^1[ERROR]^0 Failed to get the remote version from the GitHub repository.")
            return
        end

        if curVersion == nil then
            print("^1[ERROR]^0 Local version file is missing or couldn't be read.")
            return
        end

        if curVersion.version < remoteVersion.version then
            print("^5======================================^7")
            print("^1[OUTDATED]^0 "..resourceName.." is outdated.")
            print("^3Current Version: ^0" .. curVersion.version)
            print("^2New Version: ^0" .. remoteVersion.version)
            print("^0Please update it from ^4https://github.com"..updatePath.."^0.")
            print('^7Notes: ^4' ..remoteVersion.message.. '^7.')
            print("^5======================================^7")
        elseif curVersion.version > remoteVersion.version then
            print("^1[WARNING]^0 You somehow skipped a few versions of "..resourceName.." or the git went offline. If it's still online, I advise you to update (or downgrade?).")
        else
            print("^5======================================^7")
            print("^2[five-illegal] - The Script is up to date!")
            print("^7Current Version: ^4" ..curVersion.version.. "^7")
            print('^7Notes: ^4' ..curVersion.message.. '^7.')
            print("^5======================================^7")
        end
    end
    
    PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/main/version", checkVersion, "GET")
end)
