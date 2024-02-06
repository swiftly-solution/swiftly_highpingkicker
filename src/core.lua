local immune_steamids = {}
local checks = {}
local max_ping = 150
local checks_to_kick = 10

function PingCheckerTimer()
    for i=1,playermanager:GetPlayerCap() do 
        local player = GetPlayer(i-1)
        if not player then goto continue end
        if player:IsFakeClient() == 1 then goto continue end
        local steamid = player:GetSteamID()
        if immune_steamids[steamid] then goto continue end

        local ping = player:GetLatency()
        if ping > max_ping then
            checks[steamid] = checks[steamid] + 1
            if checks[steamid] >= checks_to_kick then
                player:Drop(DisconnectReason.Timedout)
            end
        else
            if checks[steamid] > 0 then
                checks[steamid] = checks[steamid] - 1
            end
        end

        ::continue::
    end
end

function LoadConfiguration()
    immune_steamids = {}

    for i=0,config:FetchArraySize("highpingkicker.immune_steamids")-1,1 do
        immune_steamids[tonumber(config:Fetch("highpingkicker.immune_steamids["..i.."]"))] = true
    end

    max_ping = config:Fetch("highpingkicker.max_ping")
    checks_to_kick = config:Fetch("highpingkicker.checks_to_kick")
end

events:on("OnClientConnect", function(playerid)
    local player = GetPlayer(playerid)
    if not player then return false end

    checks[player:GetSteamID()] = 0
    return true
end)

events:on("OnClientDisconnect", function(playerid)
    local player = GetPlayer(playerid)
    if not player then return end

    checks[player:GetSteamID()] = nil
end)

events:on("OnPluginStart", function()
    timers:create(5000, PingCheckerTimer)

    LoadConfiguration()
end)

function GetPluginAuthor()
    return "Swiftly Solution"
end

function GetPluginVersion()
    return "v1.0.0"
end

function GetPluginName()
    return "Last Disconnects"
end

function GetPluginWebsite()
    return "https://github.com/swiftly-solution/swiftly_highpingkicker"
end