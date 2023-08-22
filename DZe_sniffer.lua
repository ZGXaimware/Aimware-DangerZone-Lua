-- Aimware-DangerZone-Lua
--Last Updated 2023/8/15 1.1.5 (New Version)

local tab = gui.Tab(gui.Reference("Misc"), "DZesniffer", "DangerZone Elite Sniffer");
local main_box = gui.Groupbox(tab, "Sniffer", 16, 16, 400, 0);
local ranks_mode = gui.Combobox(main_box, "tablet.mode", "Message SendWay",
    "Only Console", "In Party chat","In Team Chat")
local messagemaster = gui.Checkbox(main_box, "tablet.master", "Master Switch", 1)
local purchasemaster = gui.Checkbox(main_box, "tablet.purchasemaster", "Purchase sniffer", 1)
local respawnmaster = gui.Checkbox(main_box, "tablet.respawnmaster", "Respawn sniffer", 1)
local exitmaster = gui.Checkbox(main_box, "tablet.exitmaster", "Exit sniffer", 1)
local paradropmaster = gui.Checkbox(main_box, "tablet.paradropmaster", "ParaDrop sniffer", 1)
local dronedispatchmaster = gui.Checkbox(main_box, "tablet.dronedispatchmaster", "Drone Dispatch sniffer(Purchase)", 0)
local gotvswitch = gui.Combobox(main_box, "tablet.gotvswitch", "GOTV Selection", "Off", "Disable on GOTV",
    "Force Enable on GOTV");

gui.SetValue("misc.log.console", true)

local function findthisguy(thisguy, tab)
    if tab == nil then return end
    for i, guy in ipairs(tab) do
        if guy == thisguy then
            return true
        end
    end
    return false
end

local ingamestatus = false
local cachelist = {}
local cachelistpurchaseid = {}
local cachemoneylist = {}
local deadlist = {}
local player_respawn_times = {}
local tabletitemindex = {
    [-1] = "None",
    [0] = "Knief",
    [1] = "Piston",
    [2] = "Smg",
    [3] = "Rifle",
    [4] = "Scout",
    [6] = "Armor",
    [7] = "Ammo box",
    [10] = "Smoke pack",
    [11] = "Jammer",
    [12] = "Healthshot",
    [13] = "DroneDetect Chip",
    [14] = "EndZone Chip",
    [15] = "Rich Chip",
    [16] = "Grenade pack",
    [17] = "Deagle",
    [18] = "DroneControl Chip",
    [19] = "Exojump set",
    [21] = "Shield"
}

local pLocal = nil
local localindex = 0
local localteamid = 0
local lastcssplayernumber = 0


local function GOTVstatus()
    local spLocal = entities.GetLocalPlayer()
    if gotvswitch:GetValue() == 0 then
        return spLocal
    end
    if spLocal == nil then return nil end

    if gotvswitch:GetValue() == 1 then
        if (spLocal:GetPropEntity("m_hObserverTarget")):IsPlayer() then
            return nil
        else
            return spLocal
        end
    end

    if gotvswitch:GetValue() == 2 then
        if (spLocal:GetPropEntity("m_hObserverTarget")):IsPlayer() then
            return spLocal:GetPropEntity("m_hObserverTarget")
        else
            return spLocal
        end
    end
end

local function ingame()
    local money = entities.FindByClass("CItemCash")
    return money ~= nil and #money ~= 0
end

local function partyapisay(message)
    print(message)
    if ranks_mode:GetValue() == 1 then
        panorama.RunScript(
            "PartyListAPI.SessionCommand('Game::Chat', 'run all xuid ' + MyPersonaAPI.GetXuid() + ' chat " ..
            message .. "');")
    elseif ranks_mode:GetValue() == 2 then
        client.ChatTeamSay(message)
    end
end



callbacks.Register("CreateMove", function()
    pLocal = GOTVstatus()
    if pLocal == nil then return end
    localindex = pLocal:GetIndex()
    localteamid = pLocal:GetPropInt("m_nSurvivalTeam")
    if localteamid == -1 then localteamid = -2 end
    if not messagemaster:GetValue() then return end
    local players = entities.FindByClass("CCSPlayer")
    ingamestatus = ingame()
    if not exitmaster:GetValue() then cachelist = {} end
    if not purchasemaster:GetValue() then
        cachemoneylist = {}
        cachelistpurchaseid = {}
    end
    -- if not respawnmaster:GetValue() then
    --     deadlist = {}
    -- end
    if players ~= nil then
        local moneylist = {}
        local needupdatecssplayer = false
        if lastcssplayernumber ~= #players then
            needupdatecssplayer = true
            playerlist = {}
        end
        for _, player in ipairs(players) do
            local playerIndex = player:GetIndex()
            local playername = player:GetName()

            if player:GetName() ~= "GOTV" then
                if ingamestatus and respawnmaster:GetValue() then
                    if player:IsAlive() and deadlist[playername] then
                        local addstr = ""
                        if player_respawn_times[playername] then addstr = "Next_Time:" ..
                            math.floor(player_respawn_times[playername]) end
                        partyapisay("Respawn" ..
                            string.gsub(': ' .. playername, '%s', '') .. addstr)
                        deadlist[playername] = nil
                    end
                    -- deadlist = {}
                end
                local playerteamid = player:GetPropInt("m_nSurvivalTeam")
                if localindex ~= playerIndex and playerteamid ~= localteamid and exitmaster:GetValue() and needupdatecssplayer then
                    table.insert(playerlist, player:GetName())
                end
                -- if not player:IsAlive() and ingamestatus and respawnmaster:GetValue() then
                --     deadlist[playername] = true
                -- end
                if player:GetWeaponID() == 72 and ingamestatus and purchasemaster:GetValue() then
                    local playerMoney = player:GetPropInt("m_iAccount")
                    local purchaseIndex = (player:GetPropEntity("m_hActiveWeapon")):GetPropInt("m_nLastPurchaseIndex")
                    moneylist[playerIndex] = playerMoney

                    if cachelistpurchaseid[playerIndex] == nil then
                        cachelistpurchaseid[playerIndex] = purchaseIndex
                    end
                    if cachemoneylist[playerIndex] == nil then
                        cachemoneylist[playerIndex] = playerMoney
                    end
                    if cachelistpurchaseid[playerIndex] ~= purchaseIndex then
                        if cachemoneylist[playerIndex] - playerMoney > 0 and purchaseIndex ~= -1 then
                            partyapisay(string.gsub(player:GetName(), '%s', '') ..
                                "_purchased_" .. tabletitemindex[purchaseIndex])
                        end
                        cachelistpurchaseid[playerIndex] = purchaseIndex
                    end
                end
            end
        end
        if ingamestatus and purchasemaster:GetValue() then cachemoneylist = moneylist end

        if (#cachelist ~= #playerlist or #cachelist == 0) and exitmaster:GetValue() and #playerlist ~= 0 then
            for i, enemy in ipairs(cachelist) do
                if not findthisguy(enemy, playerlist) then
                    if ingamestatus then
                        partyapisay("Defeat_Exit" .. ":" .. string.gsub(enemy, '%s', ''))
                    else
                        partyapisay("Warmup_Escaped" .. ":" .. string.gsub(enemy, '%s', ''))
                    end
                end
            end
            cachelist = playerlist
        end
        lastcssplayernumber = #players
    end
end)

client.AllowListener("client_disconnect");
client.AllowListener("begin_new_match");
client.AllowListener("survival_paradrop_spawn")
client.AllowListener("survival_paradrop_break")
client.AllowListener("drone_dispatched")
client.AllowListener("player_death")
callbacks.Register("FireGameEvent", function(e)
    local eventName = e:GetName()
    if (eventName == "client_disconnect") or (eventName == "begin_new_match") then
        cachelistpurchaseid = {}
        cachemoneylist = {}
        cachelist = {}
        deadlist = {}
        lastcssplayernumber = 0
        player_respawn_times = {}
    end
    if paradropmaster:GetValue() then
        if eventName == "survival_paradrop_spawn" then
            partyapisay("ParaDrop_has_created!")
        elseif eventName == "survival_paradrop_break" then
            partyapisay("ParaDrop_has_destoryed!")
        end
    end
    if dronedispatchmaster:GetValue() and eventName == "drone_dispatched" then --and client.GetPlayerIndexByUserID(e:GetInt("userid")) ~= localindex and entities.GetByUserID(e:GetInt("userid")):GetPropInt("m_nSurvivalTeam") ~= localteamid then
        local player = entities.GetByUserID(e:GetInt("userid"))
        local playername = string.gsub(entities.GetByUserID(e:GetInt("userid")):GetName(), '%s', '')
        if player:GetWeaponID() == 72 and ingamestatus then
            local purchaseIndex = (player:GetPropEntity("m_hActiveWeapon")):GetPropInt("m_nLastPurchaseIndex")
            if purchaseIndex ~= -1 then
                partyapisay(playername .. "_purchased_" .. tabletitemindex[purchaseIndex])
            end
            --partyapisay(playername .. "_dispatched_Drone")
        end
    end
    if eventName == "player_death" and ingamestatus then
        deadlist[(entities.GetByUserID(e:GetInt("userid"))):GetName()] = true

        local teamid = (entities.GetByUserID(e:GetInt("userid"))):GetPropInt("m_nSurvivalTeam")
        if teamid == -1 or teamid == nil then return end
        local playername = (entities.GetByUserID(e:GetInt("userid"))):GetName()
        if player_respawn_times[playername] then
            player_respawn_times[playername] = player_respawn_times[playername] + 10
        else
            player_respawn_times[playername] = 20
        end
    end
end)

local m_kg = gui.Button(main_box, "Check DZ Team", function()
    if client.GetConVar("game_type") ~= "6" then
        partyapisay("Not_DangerZone_Mode!")
        return
    end
    local playerdata = {}
    local abuseteam = {}
    local nonsingleteamout = {}
    local players = entities.FindByClass("CCSPlayer")
    if players ~= nil then
        for i, player in ipairs(players) do
            local playerName = player:GetName()
            local playerIndex = player:GetIndex()
            if playerName ~= "GOTV" then
                local playerTeam = player:GetPropInt("m_nSurvivalTeam")
                local teamstr = "team" .. playerTeam
                if entities.GetPlayerResources():GetPropInt("m_bHasCommunicationAbuseMute", playerIndex) == 1 and teamstr ~= "team-1" then
                    abuseteam[teamstr] = true
                end
                if playerdata[teamstr] == nil then
                    playerdata[teamstr] = {}
                end
                table.insert(playerdata[teamstr],
                    { playerIndex, playerName, playerTeam, player:IsAlive() })
            end
        end

        partyapisay("--------------------------------------")
        for i, player in ipairs(players) do
            local teamstr = "team" .. player:GetPropInt("m_nSurvivalTeam")
            local playerResources = entities.GetPlayerResources()
            local communicationMute = playerResources:GetPropInt("m_bHasCommunicationAbuseMute", player:GetIndex())
            local playerName = player:GetName()
            if teamstr == "team-1" and playerName ~= "GOTV" then
                if communicationMute == 1 then
                    partyapisay(string.gsub(playerName, '%s', '') .. "=Cheater_Solo")
                else
                    partyapisay(string.gsub(playerName, '%s', '') .. "=Solo")
                end
            else
                local playerTeamData = playerdata[teamstr]
                if playerTeamData ~= nil then
                    if #playerTeamData ~= 1 then
                        for j, data in ipairs(playerTeamData) do
                            if data[1] ~= player:GetIndex() then
                                local teammateString = abuseteam[teamstr] and "Cheater_Teammate:" or "Teammate:"
                                nonsingleteamout[teamstr] = teamstr ..
                                    ":" ..
                                    string.gsub(player:GetName(), '%s', '') ..
                                    "_" .. teammateString .. string.gsub(data[2], '%s', '')
                            end
                        end
                    else
                        if communicationMute == 1 then
                            nonsingleteamout[teamstr] = string.gsub(player:GetName(), '%s', '') ..
                                "=Might_Cheater_Solo"
                        else
                            nonsingleteamout[teamstr] = string.gsub(player:GetName(), '%s', '') .. "=Might_Solo"
                        end
                    end
                end
            end
        end
        for i = 0, 12 do
            local teamstr = "team" .. i
            if nonsingleteamout[teamstr] then
                partyapisay(nonsingleteamout[teamstr])
            end
        end
        partyapisay("Total:_" .. #players .. "_players")
        partyapisay("-----------------END------------------")
    end
end)
m_kg:SetWidth(268)
