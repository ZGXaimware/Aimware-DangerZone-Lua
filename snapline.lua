--author ZGXaimware
--version 1.0.0


local warning = gui.Checkbox(gui.Reference("Visuals", "Overlay", "Enemy"), "vis.dzline", "DangerZoneLine", 1)
local font = draw.CreateFont("Microsoft Tai Le", 45, 1000);
local fontA = draw.CreateFont("Microsoft Tai Le", 80, 1000);
local font1 = draw.CreateFont("Verdana", 22, 400);


local screenCenterX, screenH = draw.GetScreenSize();
screenCenterX = screenCenterX * 0.5;

local weaponClasses = {
    [11] = "asniper",
    [38] = "asniper",
    [1] = "hpistol",
    [64] = "hpistol",
    [14] = "lmg",
    [28] = "lmg",
    [2] = "pistol",
    [3] = "pistol",
    [4] = "pistol",
    [30] = "pistol",
    [32] = "pistol",
    [36] = "pistol",
    [61] = "pistol",
    [63] = "pistol",
    [7] = "rifle",
    [8] = "rifle",
    [10] = "rifle",
    [13] = "rifle",
    [16] = "rifle",
    [39] = "rifle",
    [60] = "rifle",
    [40] = "scout",
    [17] = "smg",
    [19] = "smg",
    [23] = "smg",
    [24] = "smg",
    [26] = "smg",
    [33] = "smg",
    [34] = "smg",
    [25] = "shotgun",
    [27] = "shotgun",
    [29] = "shotgun",
    [35] = "shotgun",
    [9] = "sniper",
    [37] = "SHIELD",
    [72] = "Tablet",
    [85] = "Bumpmine",
    [31] = "kniefetc",
    [42] = "kniefetc",
    [75] = "kniefetc",
    [74] = "kniefetc",
    [76] = "kniefetc",
    [59] = "kniefetc",
    [78] = "kniefetc",
    [80] = "kniefetc"
}

local hss = nil
local lcs = nil
local ams = nil
local chs = nil
local heals = nil
local DZ = nil
local Drones = nil
local isNeedW = false
local localabs = nil
local localweaponid = 0
local localarmor = 0

local local_player = nil


local function get_weapon_class(weapon_id)
    return weaponClasses[weapon_id] or "shared"
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

-- local function HookEntity()
--     local local_player = get_local_player()
--     if local_player == nil or not local_player:IsAlive() then return end
--     hss = entities.FindByClass("CHostage")
--     lcs = entities.FindByClass("CPhysPropLootCrate");
--     ams = entities.FindByClass("CPhysPropAmmoBox");
--     chs = entities.FindByClass("CItemCash");
--     heals = entities.FindByClass("CItem_Healthshot");
--     DZ = entities.FindByClass("CDangerZoneController")
--     Drones = entities.FindByClass("CDrone")
--     local_player:SetProp("m_flHealthShotBoostExpirationTime", -1)
--     local tablets = entities.FindByClass("CTablet")
--     if tablets ~= nil then
--         for i = 1, #tablets do
--             local tablet = tablets[i]
--             tablet:SetProp("m_bTabletReceptionIsBlocked", false)
--         end
--     end
-- end

local function SnapLines()
    if isNeedW then
        hss = entities.FindByClass("CHostage")
        lcs = entities.FindByClass("CPhysPropLootCrate");
        ams = entities.FindByClass("CPhysPropAmmoBox");
        chs = entities.FindByClass("CItemCash");
        heals = entities.FindByClass("CItem_Healthshot");
        DZ = entities.FindByClass("CDangerZoneController")
        Drones = entities.FindByClass("CDrone")


        if warning:GetValue() then
            draw.Color(255, 255, 255, 255);
            draw.SetFont(font1);
            draw.Text(screenCenterX - 782, screenH / 2 - 100, "SnapLine")

            local screenCenterX2 = screenCenterX * 2
            local screenCenterXPlus400 = screenCenterX + 400
            local screenCenterXMinus400 = screenCenterX - 400
            local screenCenterXPlus800 = screenCenterX + 800
            if hss ~= nil then
                for i = 1, #hss do
                    local hs = hss[i];
                    if hs ~= nil then
                        local distance = (hs:GetAbsOrigin() - localabs):Length()
                        if distance < 6000 then
                            local x, y = client.WorldToScreen(hs:GetAbsOrigin());
                            if x ~= nil and y ~= nil then
                                draw.Line(x, y, screenCenterX2, 100);
                            end
                        end
                    end
                end
            end

            draw.SetFont(font);
            draw.Color(255, 255, 255, 255);
            if lcs ~= nil then
                for i = 1, #lcs do
                    local lc = lcs[i];
                    if lc ~= nil then
                        local distance = (lc:GetAbsOrigin() - localabs):Length()
                        if distance < 3000 then
                            local x, y = client.WorldToScreen(lc:GetAbsOrigin());
                            if x ~= nil and y ~= nil then
                                draw.Line(x, y, screenCenterXPlus400, screenH);
                            end
                        end
                    end
                end
            end

            draw.Color(0, 0, 255, 255);
            if ams ~= nil then
                for i = 1, #ams do
                    local am = ams[i];
                    if am ~= nil then
                        local distance = (am:GetAbsOrigin() - localabs):Length()
                        if distance < 3000 then
                            local x, y = client.WorldToScreen(am:GetAbsOrigin());
                            if x ~= nil and y ~= nil then
                                draw.Line(x, y, screenCenterXMinus400, screenH);
                            end
                        end
                    end
                end
            end

            draw.Color(255, 0, 0, 255);
            if chs ~= nil then
                for i = 1, #chs do
                    local ch = chs[i];
                    if ch ~= nil then
                        local distance = (ch:GetAbsOrigin() - localabs):Length()
                        if distance < 3000 then
                            local x, y = client.WorldToScreen(ch:GetAbsOrigin());
                            if x ~= nil and y ~= nil then
                                draw.Line(x, y, screenCenterX, screenH);
                            end
                        end
                    end
                end
            end

            draw.Color(255, 255, 0, 255);
            if heals ~= nil then
                for i = 1, #heals do
                    local heal = heals[i];
                    if heal ~= nil then
                        local distance = (heal:GetAbsOrigin() - localabs):Length()
                        if distance < 3000 and distance ~= 0 then
                            local x, y = client.WorldToScreen(heal:GetAbsOrigin());
                            if x ~= nil and y ~= nil then
                                draw.Line(x, y, screenCenterXPlus800, screenH);
                            end
                        end
                    end
                end
            end
        end
        draw.Color(0, 0, 0, 255);
        if DZ ~= nil then
            draw.SetFont(font);
            for i = 1, #DZ do
                local DZS = DZ[i]
                if DZS:GetProp("m_bDangerZoneControllerEnabled") == 1 then
                    local startCirclePos = DZS:GetProp("m_vecEndGameCircleStart")
                    if startCirclePos ~= nil then
                        local x, y = client.WorldToScreen(startCirclePos)
                        if x ~= nil and y ~= nil then
                            draw.Line(x, y, screenCenterX - 100, 0);
                            draw.Line(x, y, screenCenterX + 100, 0);
                        end
                        draw.Color(255, 255, 255, 255);
                        local distance = (startCirclePos - localabs):Length()
                        draw.Text(screenCenterX - 800, screenH / 2 + 140, "EndCircle Distance:" .. math.floor(distance));
                    end
                end
            end
        end

        local dx, dy
        local BestMDistance = math.huge
        if Drones ~= nil then
            for i, Drone in pairs(Drones) do
                if Drone ~= nil then
                    local distance = (Drone:GetAbsOrigin() - localabs):Length()
                    if distance < 6000 then
                        dx, dy = client.WorldToScreen(Drone:GetAbsOrigin());
                        if dx ~= nil and dy ~= nil then
                            if Drone:GetProp("m_hCurrentPilot") ~= -1 then
                                draw.Text(dx, dy, "Manual Controlled")
                                if distance < BestMDistance then
                                    BestMDistance = distance
                                end
                            end
                            if Drone:GetProp("m_hDeliveryCargo") ~= -1 then
                                draw.Text(dx, dy + 100, "Has Cargo")
                            end
                        else
                            if Drone:GetProp("m_hCurrentPilot") ~= -1 then
                                if distance < BestMDistance then
                                    BestMDistance = distance
                                end
                            end
                        end
                    end
                end
            end
            if BestMDistance < 6000 then
                if BestMDistance < 1200 then
                    draw.SetFont(fontA)
                    draw.Color(255, 0, 0, 255);
                else
                    draw.SetFont(font)
                end
                draw.Text(screenCenterX - 800, screenH / 2 + 200, "MD Distance:" .. math.floor(BestMDistance));
                local Enemies = entities.FindByClass("CCSPlayer")
                draw.SetFont(font)
                if Enemies ~= nil then
                    local drawstep = 0
                    for i, Enemy in pairs(Enemies) do
                        if Enemy:IsAlive() then
                            local velocity = 0
                            local cvx = Enemy:GetPropFloat('localdata', 'm_vecVelocity[0]')
                            local cvy = Enemy:GetPropFloat('localdata', 'm_vecVelocity[1]')
                            if cvx ~= nil then
                                velocity = math.floor(math.min(10000, math.sqrt(cvx * cvx + cvy * cvy) + 0.5))
                            end
                            if get_weapon_class(Enemy:GetWeaponID()) == "Tablet" and velocity < 100 then
                                draw.Text(screenCenterX - 800, screenH / 2 + 300 + drawstep,
                                    "Possible:" .. Enemy:GetName());
                                drawstep = drawstep + 40
                            end
                        end
                    end
                end
            end
        end
    end
end

local function drawEspHook(builder)
    if isNeedW then
        local builder_entity = builder:GetEntity()
        if builder_entity == nil then return end
        local builder_name = builder_entity:GetName()
        local Distance = (localabs - builder_entity:GetAbsOrigin()):Length()

        if builder_name == "weapon_shield" or builder_name == "armor and helmet" then
            draw.Color(0, 0, 0, 255);
            if warning:GetValue() and Distance < 3000 and Distance ~= 0 then
                local x, y = client.WorldToScreen(builder_entity:GetAbsOrigin());
                if x ~= nil and y ~= nil then
                    draw.Line(x, y, screenCenterX - 800, screenH);
                end
            end
            if Distance < 5000 and Distance ~= 0 then
                draw.Color(255, 255, 0, 255);
                if localarmor < 60 then
                    if builder_name == "armor and helmet" then
                        local x, y = client.WorldToScreen(builder_entity:GetAbsOrigin());
                        if x ~= nil and y ~= nil then
                            draw.Line(x, y, screenCenterX - 400, 0);
                        end
                    end
                end
                if not string.find(returnweaponstr(local_player), "shield") and builder_name == "weapon_shield" then
                    local x, y = client.WorldToScreen(builder_entity:GetAbsOrigin());
                    if x ~= nil and y ~= nil then
                        draw.Line(x, y, screenCenterX - 400, 0);
                    end
                end
            end
        end
        if builder_name == "weapon_glock" or builder_name == "weapon_hkp2000" or builder_name == "pistol" or builder_name == "light weapons" or builder_name == "random drop" or builder_name == "cashbag" then
            draw.Color(204, 153, 255, 255);
            if warning:GetValue() and Distance < 3000 and Distance ~= 0 then
                local x, y = client.WorldToScreen(builder_entity:GetAbsOrigin());
                if x ~= nil and y ~= nil then
                    draw.Line(x, y, screenCenterX + 400, screenH);
                end
            end
            if Distance < 5000 and Distance ~= 0 then
                draw.Color(204, 0, 204, 255);

                if builder_name == "pistol" or builder_name == "weapon_hkp2000" or builder_name == "weapon_glock" then
                    if localweaponid == 69 then
                        local x, y = client.WorldToScreen(builder_entity:GetAbsOrigin());
                        if x ~= nil and y ~= nil then
                            draw.Line(x, y, screenCenterX + 400, 0);
                        end
                    end
                else
                    if builder_name == "light weapons" then
                        local player_weapon_class = get_weapon_class(localweaponid)
                        if player_weapon_class == "pistol" or player_weapon_class == "shotgun" or player_weapon_class == "kniefetc" then
                            local x, y = client.WorldToScreen(builder_entity:GetAbsOrigin());
                            if x ~= nil and y ~= nil then
                                draw.Line(x, y, screenCenterX + 400, 0);
                            end
                        end
                    end
                end
            end
        end
    end
end




-- callbacks.Register("CreateMove", "HookEntity", HookEntity)
callbacks.Register("Draw", "SnapLines", SnapLines)

callbacks.Register('DrawESP', "drawEspHook", drawEspHook)
callbacks.Register("CreateMove", function()
    local_player = entities.GetLocalPlayer()
    if local_player and local_player:IsAlive() and gui.GetValue("esp.master") and client.GetConVar("game_type") == "6" then
        isNeedW = true
        localabs = local_player:GetAbsOrigin()
        localweaponid = local_player:GetWeaponID()
        localarmor = local_player:GetProp("m_ArmorValue")

    else
        isNeedW = false
    end
end)
