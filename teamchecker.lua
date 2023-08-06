--author ZGXaimware
--version 1.0.5


local playerdata = {}
local abuseteam = {}
local nonsingleteamout = {}
local totalnumber = 0


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
    print("--------------------------------------")
    for i, player in ipairs(players) do
        local teamstr = "team" .. player:GetPropInt("m_nSurvivalTeam")
        local playerResources = entities.GetPlayerResources()
        local communicationMute = playerResources:GetPropInt("m_bHasCommunicationAbuseMute", player:GetIndex())
        local playerName = player:GetName()
        if teamstr == "team-1" and playerName ~= "GOTV" then
            if communicationMute == 1 then
                print(playerName .. " Cheater Solo")
            else
                print(playerName .. " Solo")
            end
        else
            local playerTeamData = playerdata[teamstr]
            if playerTeamData ~= nil then
                for j, data in ipairs(playerTeamData) do
                    if data[1] ~= player:GetIndex() then
                        local teammateString = abuseteam[teamstr] and "Cheater Teammate:" or "Teammate:"
                        nonsingleteamout[teamstr] = teamstr ..
                        ": " .. player:GetName() .. " " .. teammateString .. data[2]
                    end
                end
            end
        end
    end
    for i = 0, 11 do
        local teamstr = "team" .. i
        if nonsingleteamout[teamstr] then
            print(nonsingleteamout[teamstr])
        end
    end
    print("Total: " .. #players - 1 .. " players")
    print("-----------------END------------------")
end
