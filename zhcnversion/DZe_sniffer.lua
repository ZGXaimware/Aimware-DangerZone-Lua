-- Aimware-DangerZone-Lua
--Last Updated 2023/8/29 1.1.8 (New Version)
local tab = gui.Tab(gui.Reference("Misc"), "DZesniffer", "特训专家监听器");
local main_box = gui.Groupbox(tab, "Sniffer", 16, 16, 400, 0);
local ranks_mode = gui.Combobox(main_box, "tablet.mode", "消息发送模式",
    "只控制台", "派对聊天(不用队友去屏蔽)", "小队聊天")
local messagemaster = gui.Checkbox(main_box, "tablet.master", "主开关", 1)
-- local purchasemaster = gui.Checkbox(main_box, "tablet.purchasemaster", "Purchase sniffer", 1)
local respawnmaster = gui.Checkbox(main_box, "tablet.respawnmaster", "复活监听", 1)
local exitmaster = gui.Checkbox(main_box, "tablet.exitmaster", "退出监听", 1)
local paradropmaster = gui.Checkbox(main_box, "tablet.paradropmaster", "空投监听", 1)
local dronedispatchmaster = gui.Checkbox(main_box, "tablet.dronedispatchmaster", "购买监听", 0)
local gotvswitch = gui.Combobox(main_box, "tablet.gotvswitch", "GOTV选择", "Off", "Disable on GOTV",
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

local playerlist = {}
local ingamestatus = false
local cachelist = {}
-- local cachelistpurchaseid = {}
-- local cachemoneylist = {}
local deadlist = {}
local player_respawn_times = {}
local tabletitemindex = {
    [-1] = "空",
    [0] = "刀",
    [1] = "手枪",
    [2] = "冲锋枪",
    [3] = "步枪",
    [4] = "鸟狙",
    [6] = "护甲",
    [7] = "子弹盒",
    [10] = "烟闪套装",
    [11] = "屏蔽器",
    [12] = "医疗针",
    [13] = "无人机检测芯片",
    [14] = "安全区检测芯片",
    [15] = "富贵芯片",
    [16] = "手雷套装",
    [17] = "沙鹰",
    [18] = "无人机控制芯片",
    [19] = "EXO弹跳套装",
    [21] = "大盾"
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
    -- if not purchasemaster:GetValue() then
    --     cachemoneylist = {}
    --     cachelistpurchaseid = {}
    -- end
    -- if not respawnmaster:GetValue() then
    --     deadlist = {}
    -- end
    if players ~= nil then
        -- local moneylist = {}
        local needupdatecssplayer = false
        if lastcssplayernumber ~= #players then
            needupdatecssplayer = true
            playerlist = {}
            teammateisin = false
        end
        for _, player in ipairs(players) do
            local playerIndex = player:GetIndex()
            local playername = player:GetName()

            if player:GetName() ~= "GOTV" then
                if ingamestatus and respawnmaster:GetValue() then
                    if player:IsAlive() and deadlist[playername] then
                        local addstr = ""
                        if player_respawn_times[playername] then
                            addstr = "下一次时间:" ..
                                math.floor(player_respawn_times[playername])
                        end
                        partyapisay("复活" ..
                            string.gsub(': ' .. playername, '%s', '') .. addstr)
                        deadlist[playername] = nil
                    end
                    -- deadlist = {}
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


                -- if not player:IsAlive() and ingamestatus and respawnmaster:GetValue() then
                --     deadlist[playername] = true
                -- end
                -- if player:GetWeaponID() == 72 and ingamestatus and purchasemaster:GetValue() then
                --     local playerMoney = player:GetPropInt("m_iAccount")
                --     local purchaseIndex = (player:GetPropEntity("m_hActiveWeapon")):GetPropInt("m_nLastPurchaseIndex")
                --     moneylist[playerIndex] = playerMoney

                --     if cachelistpurchaseid[playerIndex] == nil then
                --         cachelistpurchaseid[playerIndex] = purchaseIndex
                --     end
                --     if cachemoneylist[playerIndex] == nil then
                --         cachemoneylist[playerIndex] = playerMoney
                --     end
                --     if cachelistpurchaseid[playerIndex] ~= purchaseIndex then
                --         if cachemoneylist[playerIndex] - playerMoney > 0 and purchaseIndex ~= -1 then
                --             partyapisay(string.gsub(player:GetName(), '%s', '') ..
                --                 "_purchased_" .. tabletitemindex[purchaseIndex])
                --         end
                --         cachelistpurchaseid[playerIndex] = purchaseIndex
                --     end
                -- end
            end
        end
        -- if ingamestatus and purchasemaster:GetValue() then cachemoneylist = moneylist end

        if (#cachelist ~= #playerlist or #cachelist == 0) and exitmaster:GetValue() and #playerlist ~= 0 then
            if teammateisin and teammatenoshow then
                teammatenoshow = false
                partyapisay("你的队友是" .. ":" .. string.gsub(teammatename, '%s', ''))
            end

            if not teammateisin and not teammatenoshow then
                partyapisay("你的队友已离开" .. ":" .. string.gsub(teammatename, '%s', ''))
                teammatenoshow = true
            end



            for _, enemy in ipairs(cachelist) do
                if not findthisguy(enemy, playerlist) and enemy ~= teammatename then
                    if ingamestatus then
                        partyapisay("退出" .. ":" .. string.gsub(enemy, '%s', ''))
                    else
                        partyapisay("热身畏惧跑路" .. ":" .. string.gsub(enemy, '%s', ''))
                    end
                end
            end
            cachelist = playerlist
        end
        lastcssplayernumber = #players
        if purchasedex then
            local thisplayer = entities.GetByUserID(purchaseguy)
            local playername = string.gsub(thisplayer:GetName(), '%s', '')
            if thisplayer:GetWeaponID() == 72 and ingamestatus then
                local purchaseIndex = (thisplayer:GetPropEntity("m_hActiveWeapon")):GetPropInt("m_nLastPurchaseIndex")
                if purchaseIndex ~= -1 then
                    partyapisay(playername .. "_购买了_" .. tabletitemindex[purchaseIndex])
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
        -- cachelistpurchaseid = {}
        -- cachemoneylist = {}
        cachelist = {}
        deadlist = {}
        lastcssplayernumber = 0
        player_respawn_times = {}
        teammatename = ""
        teammatenoshow = true
        teammateisin = false
    end
    if paradropmaster:GetValue() then
        if eventName == "survival_paradrop_spawn" then
            partyapisay("生成了空投！")
        elseif eventName == "survival_paradrop_break" then
            partyapisay("空投被摧毁！")
        end
    end
    if dronedispatchmaster:GetValue() and eventName == "drone_dispatched" then
        purchaseguy = e:GetInt("userid")
        purchasedex = true
    end
    if eventName == "player_death" and ingamestatus then
        if (entities.GetByUserID(e:GetInt("userid"))):IsPlayer() then
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
    end
end)

local m_kg = gui.Button(main_box, "检查特训组队情况", function()
    if client.GetConVar("game_type") ~= "6" then
        partyapisay("非头号特训模式!")
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
                    partyapisay(string.gsub(playerName, '%s', '') .. "=单排外纪")
                else
                    partyapisay(string.gsub(playerName, '%s', '') .. "=单排")
                end
            else
                local playerTeamData = playerdata[teamstr]
                if playerTeamData ~= nil then
                    if #playerTeamData ~= 1 then
                        for j, data in ipairs(playerTeamData) do
                            if data[1] ~= player:GetIndex() then
                                local teammateString = abuseteam[teamstr] and "外纪队友:" or "队友:"
                                nonsingleteamout[teamstr] = teamstr ..
                                    ":" ..
                                    string.gsub(player:GetName(), '%s', '') ..
                                    "=" .. teammateString .. string.gsub(data[2], '%s', '')
                            end
                        end
                    else
                        if communicationMute == 1 then
                            nonsingleteamout[teamstr] = string.gsub(player:GetName(), '%s', '') ..
                                "=可能单排外纪"
                        else
                            nonsingleteamout[teamstr] = string.gsub(player:GetName(), '%s', '') .. "=可能单排"
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
        partyapisay("总共:" .. #players .. "名玩家")
        partyapisay("-----------------END------------------")
    end
end)
m_kg:SetWidth(268)
