--took ffi funktions from FFIChatVoteReveal.lua
-- local CHudChat_Printf_Index = 27
-- local ChatPrefix = "\02[\07Table\02] "
-- local function FindHudElement(name)
--     local m_Table = mem.FindPattern("client.dll", "B9 ?? ?? ?? ?? 68 ?? ?? ?? ?? E8 ?? ?? ?? ?? 89 46 24")
--     local m_Function = mem.FindPattern("client.dll", "55 8B EC 53 8B 5D 08 56 57 8B F9 33 F6 39")

--     if m_Table ~= nil and m_Function ~= nil then
--         return ffi.cast("void*(__thiscall*)(void*, const char*)", m_Function)(ffi.cast("void**", m_Table + 0x1)[0], name)
--     end

--     return nil
-- end
-- local CHudChat = FindHudElement("CHudChat")
-- if CHudChat == nil then
--     error("CHudChat is nullptr.")
-- end
-- local CHudChat_Printf = ffi.cast("void(__cdecl*)(void*, int, int, const char*, ...)",
--     ffi.cast("void***", CHudChat)[0][CHudChat_Printf_Index])
-- local function ChatPrint(msg)
--     CHudChat_Printf(CHudChat, 0, 0, " " .. ChatPrefix .. msg)
-- end

local tab = gui.Tab(gui.Reference("Misc"), "DZesniffer", "DangerZone Elite Sniffer");
local main_box = gui.Groupbox(tab, "Sniffer", 16, 16, 400, 0);
local ranks_mode = gui.Combobox(main_box, "tablet.mode", "Message SendWay",
    "Only Console", "In Party chat")
local messagemaster = gui.Checkbox(main_box, "tablet.master", "Master Switch", 1)
local purchasemaster = gui.Checkbox(main_box, "tablet.purchasemaster", "Purchase sniffer", 1)
local respawnmaster = gui.Checkbox(main_box, "tablet.respawnmaster", "Respawn sniffer", 1)
local exitmaster = gui.Checkbox(main_box, "tablet.exitmaster", "Exit sniffer", 1)
local paradropmaster =  gui.Checkbox(main_box, "tablet.paradropmaster", "ParaDrop sniffer", 1)
local dronedispatchmaster =  gui.Checkbox(main_box, "tablet.dronedispatchmaster", "Drone Dispatch sniffer", 1)

gui.SetValue("misc.log.console",true)

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
    if not purchasemaster:GetValue() then
        cachemoneylist = {}
        cachelistpurchaseid = {}
    end
    if not respawnmaster:GetValue() then
        deadlist = {}
    end
    if players ~= nil then
        local moneylist = {}
        local playerlist = {}
        if ingamestatus and respawnmaster:GetValue() then
            for _, player in ipairs(players) do
                local playername = player:GetName()
                if player:IsAlive() and deadlist[playername] then
                    partyapisay("Respawn" .. string.gsub(': ' .. playername, '%s', ''))
                end
            end
            deadlist = {}
        end
        for _, player in ipairs(players) do
            local playerIndex = player:GetIndex()
            local playername = player:GetName()

            if player:GetName() ~= "GOTV" then
                local playerteamid = player:GetPropInt("m_nSurvivalTeam")
                if localindex ~= playerIndex and playerteamid ~= localteamid and exitmaster:GetValue() then
                    table.insert(playerlist, player:GetName())
                end
                if not player:IsAlive() and ingamestatus and respawnmaster:GetValue() then
                    deadlist[playername] = true
                end
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

        if (#cachelist ~= #playerlist or #cachelist == 0) and exitmaster:GetValue() then
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
    end
end)

client.AllowListener("client_disconnect");
client.AllowListener("begin_new_match");
client.AllowListener("survival_paradrop_spawn")
client.AllowListener("survival_paradrop_break")
client.AllowListener("drone_dispatched")
callbacks.Register("FireGameEvent", function(e)
    local eventName = e:GetName()
    if (eventName == "client_disconnect") or (eventName == "begin_new_match") then
        cachelistpurchaseid = {}
        cachemoneylist = {}
        cachelist = {}
        deadlist = {}
    end
    if paradropmaster:GetValue() then
        if eventName == "survival_paradrop_spawn" then
            partyapisay("ParaDrop_has_created!")
        elseif eventName == "survival_paradrop_break" then
            partyapisay("ParaDrop_has_destoryed!")
        end
    end
    if dronedispatchmaster:GetValue() and eventName == "drone_dispatched" and client.GetPlayerIndexByUserID(e:GetInt("userid")) ~= localindex and entities.GetByUserID(e:GetInt("userid")):GetPropInt("m_nSurvivalTeam") ~= localteamid then
        local playername = string.gsub(entities.GetByUserID(e:GetInt("userid")):GetName(), '%s', '')
        partyapisay(playername .. "_dispatched_Drone")
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
                        for j, data in ipairs(playerTeamData) do
                            local teammateString = abuseteam[teamstr] and "Cheater_Teammate:" or "Teammate:"
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
