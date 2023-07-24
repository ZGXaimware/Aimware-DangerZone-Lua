--author ZGXaimware
--version 1.0.0


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

local cachelist = {}
local cachelistpurchaseid = {}
local cachemoneylist = {}
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

callbacks.Register("CreateMove", function(cmd)
    local players = entities.FindByClass("CCSPlayer")

    if players ~= nil then
        local moneylist = {}
        local playerlist = {}

        for i, player in ipairs(players) do
            local playerIndex = player:GetIndex()

            if player:GetName() ~= "GOTV" and entities.GetPlayerResources():GetPropInt("m_iPing", playerIndex) ~= 0 then
                table.insert(playerlist, player:GetName())
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
                            print(player:GetName() .. " has brought " .. tabletitemindex[purchaseIndex])
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
                    if entities.FindByClass("CItemCash") ~= nil then
                        if ranksModeValue == 0 then
                            local message = "「Defeat Exit" .. string.gsub(": " .. enemy, "%s", "") .. "」"
                            panorama.RunScript(
                                "PartyListAPI.SessionCommand('Game::Chat', 'run all xuid ' + MyPersonaAPI.GetXuid() + ' chat " ..
                                message .. "');")
                        end
                        print("Defeat Exit" .. ": " .. enemy)
                    else
                        if ranksModeValue == 0 then
                            local message = "「Warmup Escaped" .. string.gsub(": " .. enemy, "%s", "") .. "」"
                            panorama.RunScript(
                                "PartyListAPI.SessionCommand('Game::Chat', 'run all xuid ' + MyPersonaAPI.GetXuid() + ' chat " ..
                                message .. "');")
                        end
                        print("Warmup Escaped" .. ": " .. enemy)
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
    end
end)
