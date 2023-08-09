--took ffi funktions from FFIChatVoteReveal.lua
local CHudChat_Printf_Index = 27
local ChatPrefix = "\02[\07Table\02] "
local function FindHudElement(name)
    local m_Table = mem.FindPattern("client.dll", "B9 ?? ?? ?? ?? 68 ?? ?? ?? ?? E8 ?? ?? ?? ?? 89 46 24")
    local m_Function = mem.FindPattern("client.dll", "55 8B EC 53 8B 5D 08 56 57 8B F9 33 F6 39")

    if m_Table ~= nil and m_Function ~= nil then
        return ffi.cast("void*(__thiscall*)(void*, const char*)", m_Function)(ffi.cast("void**", m_Table + 0x1)[0], name)
    end

    return nil
end
local CHudChat = FindHudElement("CHudChat")
if CHudChat == nil then
    error("CHudChat is nullptr.")
end
local CHudChat_Printf = ffi.cast("void(__cdecl*)(void*, int, int, const char*, ...)",
    ffi.cast("void***", CHudChat)[0][CHudChat_Printf_Index])
local function ChatPrint(msg)
    CHudChat_Printf(CHudChat, 0, 0, " " .. ChatPrefix .. msg)
end

local ranks_mode = gui.Combobox(gui.Reference("Misc", "General", "Extra"), "tablet.mode", "Message SendWay",
    "In Party chat", "Only Console")
client.AllowListener("client_disconnect");
client.AllowListener("begin_new_match");
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

local function ingame()
    local DZ = entities.FindByClass("CDangerZoneController")
    if DZ ~= nil then
        for i = 1, #DZ do
            local DZS = DZ[i]
            if DZS ~= nil then
                if DZS:GetProp("m_bDangerZoneControllerEnabled") == 1 then
                    return true
                end
            end
        end
    end
    return false
end


callbacks.Register("CreateMove", function(cmd)
    local players = entities.FindByClass("CCSPlayer")
    local ingamestatus = ingame()

    if players ~= nil then
        local moneylist = {}
        local playerlist = {}
        if ingamestatus then
            for i, player in ipairs(players) do
                local playername = player:GetName()
                if player:IsAlive() and deadlist[playername] then
                    print("Respawn" .. ": " .. playername)
                    ChatPrint("\04Respawn" .. ": " .. playername)
                end
            end
            deadlist = {}
        end
        for i, player in ipairs(players) do
            local playerIndex = player:GetIndex()
            local localindex = (entities.GetLocalPlayer()):GetIndex()
            local playername = player:GetName()

            if player:GetName() ~= "GOTV" then
                if localindex ~= playerIndex then
                    table.insert(playerlist, player:GetName())
                end
                if not player:IsAlive() and ingamestatus then
                    deadlist[playername] = true
                end


                if player:GetWeaponID() == 72 then
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
                            print(player:GetName() .. " purchased " .. tabletitemindex[purchaseIndex])
                            ChatPrint("\04" .. player:GetName() .. " purchased " .. tabletitemindex[purchaseIndex])
                        end

                        cachelistpurchaseid[playerIndex] = purchaseIndex
                    end
                end
            end
        end
        cachemoneylist = moneylist

        if #cachelist ~= #playerlist or #cachelist == 0 then
            local ranksModeValue = ranks_mode:GetValue()
            for i, enemy in ipairs(cachelist) do
                if not findthisguy(enemy, playerlist) then
                    if ingamestatus then
                        if ranksModeValue == 0 then
                            local message = "「Exit" .. string.gsub(": " .. enemy, "%s", "") .. "」"
                            panorama.RunScript(
                                "PartyListAPI.SessionCommand('Game::Chat', 'run all xuid ' + MyPersonaAPI.GetXuid() + ' chat " ..
                                message .. "');")
                        end
                        print("Defeat Exit" .. ": " .. enemy)
                        ChatPrint("\04Defeat Exit" .. ": " .. enemy)
                    else
                        if ranksModeValue == 0 then
                            local message = "「WExit" .. string.gsub(": " .. enemy, "%s", "") .. "」"
                            panorama.RunScript(
                                "PartyListAPI.SessionCommand('Game::Chat', 'run all xuid ' + MyPersonaAPI.GetXuid() + ' chat " ..
                                message .. "');")
                        end
                        print("Warmup Escaped" .. ": " .. enemy)
                        ChatPrint("\04Warmup Escaped" .. ": " .. enemy)
                    end
                end
            end
            cachelist = playerlist
        end
    end
end)



callbacks.Register("FireGameEvent", function(e)
    local eventName = e:GetName()
    if (eventName == "client_disconnect") or (eventName == "begin_new_match") then
        cachelistpurchaseid = {}
        cachemoneylist = {}
        cachelist = {}
        deadlist = {}
    end
end)
