-- Aimware-DangerZone-Lua
--Last Updated 2023/8/29 1.1.8 (New Version)
local tab = gui.Tab(gui.Reference("Misc"), "DZesniffer", "DangerZone Elite Sniffer");
local main_box = gui.Groupbox(tab, "Sniffer", 16, 16, 400, 0);
local ranks_mode = gui.Combobox(main_box, "tablet.mode", "Message SendWay",
    "Only Console", "In Party chat", "In Team Chat")
local messagemaster = gui.Checkbox(main_box, "tablet.master", "Master Switch", 1)
-- local purchasemaster = gui.Checkbox(main_box, "tablet.purchasemaster", "Purchase sniffer", 1)
local respawnmaster = gui.Checkbox(main_box, "tablet.respawnmaster", "Respawn sniffer", 1)
local exitmaster = gui.Checkbox(main_box, "tablet.exitmaster", "Exit sniffer", 1)
local paradropmaster = gui.Checkbox(main_box, "tablet.paradropmaster", "ParaDrop sniffer", 1)
local dronedispatchmaster = gui.Checkbox(main_box, "tablet.dronedispatchmaster", "Purchase Sniffer", 1)


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

local playerlist = {}
local ingamestatus = false
local cachelist = {}
local deadlist = {}
local reslist = {}
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
local teammatename = ""
local teammatenoshow = true
local pLocal = nil
local localindex = 0
local localteamid = 0
local lastcssplayernumber = 0
local teammateisin = false
local purchaseguy = 0
local purchasedex = false

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

local function returnweaponstr(player)
    if player:IsPlayer() and player:IsAlive() then
        local recstr = ""
        for i = 0, 63 do
            local weapon = player:GetPropEntity("m_hMyWeapons", i)
            if weapon:GetClass() ~= nil then
                recstr = recstr .. tostring(weapon) .. " "
            end
        end
        return recstr
    else
        return ""
    end
end

callbacks.Register("CreateMove", function()
    pLocal = entities.GetLocalPlayer()
    if pLocal == nil then return end
    localindex = pLocal:GetIndex()
    localteamid = pLocal:GetPropInt("m_nSurvivalTeam")
    if localteamid == -1 then localteamid = -2 end
    if not messagemaster:GetValue() then return end
    local players = entities.FindByClass("CCSPlayer")
    ingamestatus = ingame()
    if not exitmaster:GetValue() then cachelist = {} end

    if players ~= nil then
        local needupdatecssplayer = false
        local playernumber = #players
        if playernumber <= 1 or playernumber == nil then return end
        if lastcssplayernumber ~= playernumber then
            lastcssplayernumber = playernumber
            needupdatecssplayer = true
            playerlist = {}
            teammateisin = false
        end
        for _, player in ipairs(players) do
            local playerIndex = player:GetIndex()
            local playername = player:GetName()

            if player:GetName() ~= "GOTV" then
                if ingamestatus and respawnmaster:GetValue() then
                    if player:IsAlive() then
                        if deadlist[playername] == true then
                            local addstr = ""
                            if player_respawn_times[playername] then
                                addstr = "Next_Time:" ..
                                    math.floor(player_respawn_times[playername])
                            end
                            partyapisay("Respawn_Select" ..
                                string.gsub(': ' .. playername, '%s', '') .. addstr)
                            deadlist[playername] = false
                        elseif reslist[playername] then
                            if returnweaponstr(player) ~= "weapon_fists " then
                                partyapisay(string.gsub(': ' .. playername, '%s', '') .. "已经跳伞！")
                                reslist[playername] = false
                            end
                        end
                    end
                end
                local playerteamid = player:GetPropInt("m_nSurvivalTeam")
                if localindex ~= playerIndex and exitmaster:GetValue() and needupdatecssplayer then
                    if playerteamid == localteamid then
                        teammatename = player:GetName()
                        teammateisin = true
                    else
                        table.insert(playerlist, player:GetName())
                    end
                end
            end
        end
        if (#cachelist ~= #playerlist or #cachelist == 0) and exitmaster:GetValue() and #playerlist ~= 0 then
            if teammateisin and teammatenoshow then
                teammatenoshow = false
                partyapisay("Your_teammate_is" .. ":" .. string.gsub(teammatename, '%s', ''))
            end

            if not teammateisin and not teammatenoshow then
                partyapisay("Teammate_Exit" .. ":" .. string.gsub(teammatename, '%s', ''))
                teammatenoshow = true
            end
            for _, enemy in ipairs(cachelist) do
                if not findthisguy(enemy, playerlist) and enemy ~= teammatename then
                    if ingamestatus then
                        partyapisay("Defeat_Exit" .. ":" .. string.gsub(enemy, '%s', ''))
                        player_respawn_times[enemy] = nil
                    else
                        partyapisay("Warmup_Escaped" .. ":" .. string.gsub(enemy, '%s', ''))
                    end
                end
            end
            cachelist = playerlist
        end
        lastcssplayernumber = playernumber
        if purchasedex then
            local thisplayer = entities.GetByUserID(purchaseguy)
            if thisplayer == nil or not thisplayer:IsPlayer() then purchasedex = false end
            local playername = string.gsub(thisplayer:GetName(), '%s', '')
            if thisplayer:GetWeaponID() == 72 and ingamestatus then
                local purchaseIndex = (thisplayer:GetPropEntity("m_hActiveWeapon")):GetPropInt("m_nLastPurchaseIndex")
                if purchaseIndex ~= -1 then
                    partyapisay(playername .. "_purchased_" .. tabletitemindex[purchaseIndex])
                end
            end
            purchasedex = false
        end
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
        cachelist = {}
        deadlist = {}
        reslist = {}
        lastcssplayernumber = 0
        player_respawn_times = {}
        teammatename = ""
        teammatenoshow = true
        teammateisin = false
    end
    if paradropmaster:GetValue() then
        if eventName == "survival_paradrop_spawn" then
            partyapisay("ParaDrop_has_created!")
        elseif eventName == "survival_paradrop_break" then
            partyapisay("ParaDrop_has_destoryed!")
        end
    end
    if dronedispatchmaster:GetValue() and eventName == "drone_dispatched" then
        purchaseguy = e:GetInt("userid")
        purchasedex = true
    end
    if eventName == "player_death" and ingamestatus then
        deadlist[(entities.GetByUserID(e:GetInt("userid"))):GetName()] = true
        reslist[(entities.GetByUserID(e:GetInt("userid"))):GetName()] = true
        if (entities.GetByUserID(e:GetInt("userid"))):IsPlayer() then
            local teamid = (entities.GetByUserID(e:GetInt("userid"))):GetPropInt("m_nSurvivalTeam")
            if teamid == -1 or teamid == nil then return end
            local playername = (entities.GetByUserID(e:GetInt("userid"))):GetName()
            if player_respawn_times[playername] then
                player_respawn_times[playername] = player_respawn_times[playername] + 10
            else
                player_respawn_times[playername] = 20
            end
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
                                local teammateString = abuseteam[teamstr] and "CheaterTeammate:" or "Teammate:"
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