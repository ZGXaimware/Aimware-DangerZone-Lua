-- Aimware-DangerZone-Lua
--Last Updated 2023/9/15 1.1.9  (New Version)
panorama.RunScript([[
	CompetitiveMatchAPI.GetCooldownSecondsRemaining = MyPersonaAPI.IsVacBanned = () => 0;
		]])
local tab = gui.Tab(gui.Reference("Visuals"), "DZevis", "DangerZone Elite Visual");
local main_box = gui.Groupbox(tab, "ESP", 16, 16, 200, 0);
local visual_box = gui.Groupbox(tab, "SnapLine", 232, 16, 200, 0);
local line_box = gui.Groupbox(tab, "SubLine", 448, 16, 174, 0);
local espmaster = gui.Checkbox(main_box, "vis.dzespmaster", "ESP Master Switch", 1)
local showammo = gui.Checkbox(main_box, "vis.showammo", "Show Ammo", 1)
local showdistance = gui.Checkbox(main_box, "vis.showdistance", "Show Distance", 1)
local showteamstatus = gui.Checkbox(main_box, "vis.showteamstatus", "Show TeamStatus", 1)
local showguntype = gui.Checkbox(main_box, "vis.showguntype", "Show GunType", 1)
local barrelmaster = gui.Checkbox(main_box, "vis.barrelmaster", "Show Barrel ESP", 1)
local remotebombmaster = gui.Checkbox(main_box, "vis.remotebombmaster", "Show RemoteBomb ESP", 1)
local removegrassmaster = gui.Checkbox(main_box, "vis.removegrassmaster", "Remove Grass", 1)
removegrassmaster:SetDescription("It will only makes change on game start")
local linemaster = gui.Checkbox(visual_box, "vis.dzespmaster", "Line Master Switch", 1)
local linesubmaster = gui.Checkbox(line_box, "vis.dzespmaster", "SubLine Master Switch", 1)
local hsmaster = gui.Checkbox(line_box, "vis.hsmaster", "Hostage Snapline", 0)
local ammomaster = gui.Checkbox(line_box, "vis.ammomaster", "Ammobox Snapline", 1)
local boxmaster = gui.Checkbox(line_box, "vis.boxmaster", "NormalBox Snapline", 0)
local cashmaster = gui.Checkbox(line_box, "vis.cashmaster", "Cash Snapline", 0)
local healmaster = gui.Checkbox(line_box, "vis.healmaster", "Healthshot Snapline", 0)
local dronemaster = gui.Checkbox(visual_box, "vis.dronemasterr", "Drone Detector", 1)
local endcirclemaster = gui.Checkbox(visual_box, "vis.endzone", "EndZone Detector/Line", 1)
local shieldarmormaster = gui.Checkbox(line_box, "vis.shieldarmormaster", "Shield/Armor Snapline", 1)
local guidemaster = gui.Checkbox(visual_box, "vis.endzone", "GuideLine(Very useful)", 1)
local wpmaster = gui.Checkbox(line_box, "vis.wpmaster", "Weapon Snapline", 1)
local pLocal = nil
local font = draw.CreateFont("Microsoft Tai Le", 45, 1000);
local fontA = draw.CreateFont("Microsoft Tai Le", 80, 1000);
local font1 = draw.CreateFont("Verdana", 22, 400);
local screenCenterX, screenH = draw.GetScreenSize();
screenCenterX = screenCenterX * 0.5;
local screenCenterX2 = screenCenterX * 2
local screenCenterXPlus400 = screenCenterX + 400
local screenCenterXMinus400 = screenCenterX - 400
local screenCenterXPlus800 = screenCenterX + 800
local ENDdistance = 0
local BestMDistance = math.huge
local playerdata = {}
local abuseteam = {}
local hss = nil
local lcs = nil
local ams = nil
local chs = nil
local heals = nil
local DZ = nil
local Drones = nil
local plocallive = false
local localabs = nil
local localweaponid = 0
local localarmor = 0
local Enemies = nil
local drawxy = {}
local dronetable = {}
local drawespxy = {}
local isNeedW = false
local Teamcalled = false
local player_respawn_times = {}
local visualenabled = gui.GetValue("esp.master")
local function returnweaponstr(player)
	local recstr = ""
	if player:IsPlayer() and player:IsAlive() then
		for i = 0, 63 do
			local weapon = player:GetPropEntity("m_hMyWeapons", i)
			if weapon:GetClass() ~= nil then
				recstr = recstr .. tostring(weapon) .. " "
			end
		end
	end
	return recstr
end
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
	[31] = "zeus",
	[37] = "SHIELD",
	[85] = "Bumpmine",
	[75] = "kniefetc",
	[74] = "kniefetc",
	[76] = "kniefetc",
	[59] = "kniefetc",
	[42] = "kniefetc",
	[78] = "kniefetc",
	[80] = "kniefetc",
	[70] = "RemoteBomb",
	[72] = "Tablet",
	[69] = "Fists"
}

local function get_weapon_class(weapon_id)
	return weaponClasses[weapon_id] or "shared"
end


local function ingame()
	local money = entities.FindByClass("CItemCash")
	return money ~= nil and #money ~= 0
end

callbacks.Register("CreateMove", function()
	if not espmaster:GetValue() or not visualenabled or not isNeedW or not showteamstatus:GetValue() or client.GetConVar("game_type") ~= "6" then
		Teamcalled = false
		return
	end
	playerdata = {}
	abuseteam = {}
	if Enemies ~= nil then
		Teamcalled = true
		for _, player in ipairs(Enemies) do
			if player:GetName() ~= "GOTV" and entities.GetPlayerResources():GetPropInt("m_iPing", player:GetIndex()) ~= 0 then
				local teamstr = "team" .. player:GetPropInt("m_nSurvivalTeam")
				if entities.GetPlayerResources():GetPropInt("m_bHasCommunicationAbuseMute", player:GetIndex()) == 1 and teamstr ~= "team-1" then
					abuseteam[teamstr] = true
				end
				if playerdata[teamstr] == nil then playerdata[teamstr] = {} end
				if player:IsAlive() then
					table.insert(playerdata[teamstr],
						{ player:GetIndex(), player:GetName(), player:GetAbsOrigin(), player:IsAlive() })
				else
					table.insert(playerdata[teamstr],
						{ player:GetIndex(), player:GetName(), player:GetAbsOrigin(), player:IsAlive() })
				end
			end
		end
	else
		Teamcalled = false
	end
end)


local function drawEspHookESP(builder)
	if not espmaster:GetValue() or not visualenabled or not isNeedW then return end
	local builder_entity = builder:GetEntity()
	if builder_entity == nil then return end
	if not builder_entity:IsPlayer() or not builder_entity:IsAlive() then return end
	if showammo:GetValue() and plocallive then
		local current_weapon = builder_entity:GetPropEntity("m_hActiveWeapon")
		if current_weapon:GetProp("m_iClip1") ~= nil then
			builder:Color(0, 150, 240, 255)
			builder:AddTextBottom(tostring(current_weapon:GetProp("m_iClip1") ..
				"/" .. current_weapon:GetProp("m_iPrimaryReserveAmmoCount")))
		end
	end
	local lpabs = builder_entity:GetAbsOrigin()

	if showdistance:GetValue() and plocallive then
		local Distance = math.floor((lpabs - pLocal:GetAbsOrigin()):Length())
		if Distance ~= nil then
			builder:AddTextLeft("D:" .. Distance)
		end
	end

	if showteamstatus:GetValue() and Teamcalled then
		builder:Color(255, 255, 255, 255)
		local righttext = ""
		local teamstr = "team" .. builder_entity:GetPropInt("m_nSurvivalTeam")
		local ischeater = entities.GetPlayerResources():GetPropInt("m_bHasCommunicationAbuseMute",
			builder_entity:GetIndex())

		if teamstr == "team-1" then
			if ischeater == 1 then
				righttext = "Cheater Solo"
			else
				righttext = "Solo"
			end
		else
			if playerdata[teamstr] ~= nil and #playerdata[teamstr] > 1 then
				for _, data in ipairs(playerdata[teamstr]) do
					if data[2] ~= builder_entity:GetName() then
						local respawntime = 0.00
						if not data[4] then
							if player_respawn_times[data[2]] then
								respawntime = player_respawn_times[data[2]][1] + player_respawn_times[data[2]][2] -
									globals.CurTime()
								if respawntime < 0 then respawntime = 0 end
							end
						end
						if abuseteam[teamstr] then
							if ischeater == 1 then
								righttext = data[4] and
									"(M)(Cheater) " .. math.floor((lpabs - data[3]):Length()) .. " " .. data[2] or
									"(M)(Cheater)(Dead) " .. data[2] .. " R:" .. string.format("%.1f", respawntime) ..
									"s"
							else
								righttext = data[4] and
									"(Cheater) " .. math.floor((lpabs - data[3]):Length()) .. " " .. data[2] or
									"(Cheater)(Dead) " .. data[2] .. " R:" .. string.format("%.1f", respawntime) .. "s"
							end
						else
							righttext = data[4] and math.floor((lpabs - data[3]):Length()) .. " " .. data[2] or
								"(Dead) " .. data[2] .. " R:" .. string.format("%.1f", respawntime) .. "s"
						end
					end
				end
			else
				if ischeater == 1 then
					righttext = "Might Cheater Solo"
				else
					righttext = "Might Solo"
				end
			end
		end
		if righttext ~= "" then
			builder:AddTextRight(righttext)
		end
	end
	if showguntype:GetValue() and plocallive then
		builder:Color(255, 0, 0, 255)
		local guntype = get_weapon_class(builder_entity:GetWeaponID())
		if string.find(returnweaponstr(builder_entity), "shield") ~= nil and guntype ~= "SHIELD" then
			builder:AddTextTop("(S)" .. guntype)
		else
			builder:AddTextTop(guntype)
		end
	end
end



local function SnapLines()
	ENDdistance = 0
	BestMDistance = math.huge
	drawxy = {}
	dronetable = {}
	visualenabled = gui.GetValue("esp.master")
	if not linemaster:GetValue() or not visualenabled then return end
	if plocallive then
		if hsmaster:GetValue() then hss = entities.FindByClass("CHostage") end
		if boxmaster:GetValue() then lcs = entities.FindByClass("CPhysPropLootCrate") end
		if ammomaster:GetValue() then ams = entities.FindByClass("CPhysPropAmmoBox") end
		if cashmaster:GetValue() then chs = entities.FindByClass("CItemCash") end
		if healmaster:GetValue() then heals = entities.FindByClass("CItem_Healthshot") end
		if endcirclemaster:GetValue() then DZ = entities.FindByClass("CDangerZoneController") end
		if dronemaster:GetValue() then Drones = entities.FindByClass("CDrone") end


		if linesubmaster:GetValue() then
			if hss ~= nil and hsmaster:GetValue() then
				for i = 1, #hss do
					local hs = hss[i];
					if hs:GetAbsOrigin() ~= nil then
						local distance = (hs:GetAbsOrigin() - localabs):Length()
						if distance < 6000 then
							local x, y = client.WorldToScreen(hs:GetAbsOrigin());
							if x ~= nil and y ~= nil then
								table.insert(drawxy, { x, y, screenCenterX2, 100, 255, 255, 255, 255 })
							end
						end
					end
				end
			end

			if lcs ~= nil and boxmaster:GetValue() then
				for i = 1, #lcs do
					local lc = lcs[i];
					if lc:GetAbsOrigin() ~= nil then
						local distance = (lc:GetAbsOrigin() - localabs):Length()
						if distance < 3000 then
							local x, y = client.WorldToScreen(lc:GetAbsOrigin());
							if x ~= nil and y ~= nil then
								table.insert(drawxy, { x, y, screenCenterXPlus400, screenH, 255, 255, 255, 255 })
							end
						end
					end
				end
			end

			if ams ~= nil and ammomaster:GetValue() then
				for i = 1, #ams do
					local am = ams[i];
					if am:GetAbsOrigin() ~= nil then
						local distance = (am:GetAbsOrigin() - localabs):Length()
						if distance < 3000 then
							local x, y = client.WorldToScreen(am:GetAbsOrigin());
							if x ~= nil and y ~= nil then
								table.insert(drawxy, { x, y, screenCenterXMinus400, screenH, 0, 0, 255, 255 })
							end
						end
					end
				end
			end

			if chs ~= nil and cashmaster:GetValue() then
				for i = 1, #chs do
					local ch = chs[i];
					if ch:GetAbsOrigin() ~= nil then
						local distance = (ch:GetAbsOrigin() - localabs):Length()
						if distance < 3000 then
							local x, y = client.WorldToScreen(ch:GetAbsOrigin());
							if x ~= nil and y ~= nil then
								table.insert(drawxy, { x, y, screenCenterX, screenH, 255, 0, 0, 255 })
							end
						end
					end
				end
			end

			if heals ~= nil and healmaster:GetValue() then
				for i = 1, #heals do
					local heal = heals[i];
					if heal:GetAbsOrigin() ~= nil then
						local distance = (heal:GetAbsOrigin() - localabs):Length()
						if distance < 3000 and distance ~= 0 then
							local x, y = client.WorldToScreen(heal:GetAbsOrigin());
							if x ~= nil and y ~= nil then
								table.insert(drawxy, { x, y, screenCenterXPlus800, screenH, 255, 255, 0, 255 })
							end
						end
					end
				end
			end
		end
		if DZ ~= nil and endcirclemaster:GetValue() then
			for i = 1, #DZ do
				local DZS = DZ[i]
				if DZS ~= nil then
					if DZS:GetProp("m_bDangerZoneControllerEnabled") == 1 then
						local startCirclePos = DZS:GetProp("m_vecEndGameCircleStart")
						if startCirclePos ~= nil then
							local x, y = client.WorldToScreen(startCirclePos)
							if x ~= nil and y ~= nil then
								table.insert(drawxy, { x, y, screenCenterX - 100, 0, 0, 0, 0, 255 })
								table.insert(drawxy, { x, y, screenCenterX + 100, 0, 0, 0, 0, 255 })
							end
							ENDdistance = math.floor((startCirclePos - localabs):Length())
						end
					end
				end
			end
		end

		if Drones ~= nil and dronemaster:GetValue() then
			for i, Drone in pairs(Drones) do
				if Drone:GetAbsOrigin() ~= nil then
					local distance = (Drone:GetAbsOrigin() - localabs):Length()
					if distance < 6000 then
						local dx, dy = client.WorldToScreen(Drone:GetAbsOrigin());
						if dx ~= nil and dy ~= nil then
							if Drone:GetProp("m_hCurrentPilot") ~= -1 then
								table.insert(dronetable, { dx, dy, "Manual Controlled" })
								if distance < BestMDistance then
									BestMDistance = distance
								end
							end
							if Drone:GetProp("m_hDeliveryCargo") ~= -1 then
								table.insert(dronetable, { dx, dy + 100, "Has Cargo" })
							end
						end
					end
				end
			end
			if BestMDistance < 6000 then
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
								table.insert(dronetable,
									{ screenCenterX - 800, screenH / 2 + 300 + drawstep, "Possible:" .. Enemy:GetName() })
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
	if not linemaster:GetValue() or not visualenabled then return end

	if plocallive then
		drawespxy = {}
		local builder_entity = builder:GetEntity()
		if builder_entity == nil then return end
		local builder_name = builder_entity:GetName()
		if builder_entity:GetAbsOrigin() == nil then return end
		local Distance = (localabs - builder_entity:GetAbsOrigin()):Length()

		if builder_name == "weapon_shield" or builder_name == "armor and helmet" then
			if linesubmaster:GetValue() and Distance < 3000 and Distance ~= 0 and shieldarmormaster:GetValue() then
				local x, y = client.WorldToScreen(builder_entity:GetAbsOrigin());
				if x ~= nil and y ~= nil then
					table.insert(drawespxy, { x, y, screenCenterX - 800, screenH, 0, 0, 0, 255 })
				end
			end
			if Distance < 5000 and Distance ~= 0 and guidemaster:GetValue() then
				if localarmor < 60 then
					if builder_name == "armor and helmet" then
						local x, y = client.WorldToScreen(builder_entity:GetAbsOrigin());
						if x ~= nil and y ~= nil then
							table.insert(drawespxy, { x, y, screenCenterX - 500, 0, 255, 140, 0, 255 })
						end
					end
				end
				if not string.find(returnweaponstr(pLocal), "shield") and builder_name == "weapon_shield" then
					local x, y = client.WorldToScreen(builder_entity:GetAbsOrigin());
					if x ~= nil and y ~= nil then
						table.insert(drawespxy, { x, y, screenCenterX - 500, 0, 255, 140, 0, 255 })
					end
				end
			end
		end
		if builder_name == "weapon_glock" or builder_name == "weapon_hkp2000" or builder_name == "pistol" or builder_name == "light weapons" or builder_name == "random drop" or builder_name == "cashbag" then
			if linesubmaster:GetValue() and Distance < 3000 and Distance ~= 0 and wpmaster:GetValue() then
				local x, y = client.WorldToScreen(builder_entity:GetAbsOrigin());
				if x ~= nil and y ~= nil then
					table.insert(drawespxy, { x, y, screenCenterX + 500, screenH, 204, 153, 255, 255 })
				end
			end
			if Distance < 5000 and Distance ~= 0 and guidemaster:GetValue() then
				if builder_name == "pistol" or builder_name == "weapon_hkp2000" or builder_name == "weapon_glock" then
					if localweaponid == 69 then
						local x, y = client.WorldToScreen(builder_entity:GetAbsOrigin());
						if x ~= nil and y ~= nil then
							table.insert(drawespxy, { x, y, screenCenterX + 500, 0, 255, 255, 224, 255 })
						end
					end
				else
					if builder_name == "light weapons" then
						local player_weapon_class = get_weapon_class(localweaponid)
						if player_weapon_class == "pistol" or player_weapon_class == "shotgun" or player_weapon_class == "kniefetc" then
							local x, y = client.WorldToScreen(builder_entity:GetAbsOrigin());
							if x ~= nil and y ~= nil then
								table.insert(drawespxy, { x, y, screenCenterX + 400, 0, 255, 255, 224, 255 })
							end
						end
					end
				end
			end
		end
		for _, key in pairs(drawespxy) do
			draw.Color(key[5], key[6], key[7], key[8])
			draw.Line(key[1], key[2], key[3], key[4])
		end
	end
end


local function DrawLine()
	if not linemaster:GetValue() or not visualenabled then return end
	if linesubmaster:GetValue() and ingame() then
		draw.Color(255, 255, 255, 255);
		draw.SetFont(font1);
		draw.Text(screenCenterX - 782, screenH / 2 - 100, "SubSnapLine")
	end
	for _, key in pairs(drawxy) do
		draw.Color(key[5], key[6], key[7], key[8])
		draw.Line(key[1], key[2], key[3], key[4])
	end

	for _, key in pairs(dronetable) do
		if BestMDistance < 1200 then
			draw.SetFont(fontA)
			draw.Color(255, 0, 0, 255);
		else
			draw.SetFont(font)
			draw.Color(255, 255, 255, 255);
		end
		draw.Text(key[1], key[2], key[3])
	end
	if #dronetable ~= 0 and BestMDistance < 6000 then
		draw.Text(screenCenterX - 800, screenH / 2 + 200, "MD Distance:" .. math.floor(BestMDistance));
	end
	draw.SetFont(font)
	draw.Color(255, 255, 255, 255);
	if ENDdistance ~= 0 then
		draw.Text(screenCenterX - 800, screenH / 2 + 140,
			"EndCircle Distance:" .. ENDdistance);
	end
end





callbacks.Register("CreateMove", "SnapLines", SnapLines)
callbacks.Register('DrawESP', "drawEspHook", drawEspHook)
callbacks.Register('DrawESP', "drawEspHookESP", drawEspHookESP)
callbacks.Register("Draw", "DrawLine", DrawLine)

callbacks.Register("CreateMove", function()
	pLocal = entities.GetLocalPlayer()
	if pLocal == nil then
		plocallive = false
		isNeedW = false
	else
		local weaponstr = returnweaponstr(pLocal)
		Enemies = entities.FindByClass("CCSPlayer")
		if pLocal:IsAlive() then
			isNeedW = true
			if weaponstr ~= "weapon_fists " and ingame() then
				plocallive = true
				localabs = pLocal:GetAbsOrigin()
				localweaponid = pLocal:GetWeaponID()
				localarmor = pLocal:GetProp("m_ArmorValue")
			else
				plocallive = false
			end
		else
			plocallive = false
			isNeedW = false
		end
	end
end)

local svg_charge =
[[<svg xmlns="http://www.w3.org/2000/svg" width="400" height="342.86"><g fill-rule="evenodd"><path fill="#181806" d="M7.2 3.94V7.9H0v56.26h7.2v13.3c.01 7.3.1 13.62.21 14.04.3 1.13.83 1.22 7.77 1.4l6.43.16v6.45c0 8.25-.72 7.53 7.55 7.53h6.46l.12 13.71c.13 16.74-.86 14.84 7.9 15.04l6.62.15v6.66c0 8.09-.67 7.38 6.86 7.29 3.2-.04 6.08-.05 6.38-.02.5.05.57 1.5.72 13.8.22 16.77-.79 14.88 7.91 14.9h6.6v6.63c0 8.36-.76 7.64 7.93 7.52l6.6-.09.22-1.5c.35-2.29.55-9.62.32-11.42-.32-2.5-.5-2.61-4.78-2.82-4.54-.22-6.03-.49-6.6-1.2-1.27-1.58-1.55-2.66-1.7-6.54a50.4 50.4 0 0 0-.8-7.05c-.36-1.7-.8-4-1-5.11-.2-1.12-.4-2.06-.45-2.1-.59-.47-1.63-.8-1.63-.53 0 .23-.29.24-.85.02-.63-.23-.87-.2-.88.1-.02.23-.16.11-.32-.27-.17-.38-.31-.48-.32-.23-.02.24-.2.34-.4.2-.22-.12-.51-.03-.66.2-.2.35-.49.3-1.25-.23-.99-.68-2.18-.7-2.18-.04 0 .22-.2.2-.51-.07-.42-.35-.52-.32-.52.13 0 .72-.32.7-.9-.04-.4-.55-.45-.5-.47.42l-.02 1.03-.5-.85c-.26-.47-.5-.7-.54-.52-.03.2-.17-.2-.31-.85-.2-1-.26-.78-.31 1.2-.06 2.29-.08 2.35-.5 1.37-1.06-2.42-.81-7.43.3-6.42.16.13.17.06.04-.16-.12-.22-.07-.5.12-.62.18-.12.33-.55.32-.97-.01-.41.08-3.16.2-6.1l.21-5.33-1.22-4.04c-1.15-3.78-1.88-5.26-2.38-4.76-.12.12-.21.03-.21-.19s-.12-.36-.26-.31c-.14.04-.93-.65-1.76-1.55-.82-.9-1.38-1.63-1.23-1.63.15 0-.03-.32-.39-.72-.36-.4-.61-.78-.56-.86.28-.45-.06-.87-1.07-1.29-2.94-1.23-4.66-4.27-5.54-9.82-.31-1.98-.9-4.26-1.3-5.06l-.74-1.46-2.24-.04c-5.37-.1-7.75-1.22-8.14-3.84a96.83 96.83 0 0 1-.6-5.32 26.4 26.4 0 0 0-1.08-4.97 56.89 56.89 0 0 1-1.5-5.7c-.38-1.85-.9-3.46-1.24-3.77-.35-.33-.48-.36-.32-.08.14.25-.37.04-1.15-.47-.77-.52-1.33-1.05-1.24-1.19.08-.14-.95-.66-2.3-1.16-4.04-1.49-5.32-3.63-6.1-10.17-.61-5-2.18-9.54-3.4-9.8-.86-.2-2.34-.8-4.15-1.7-1.1-.55-3.3-3.76-3.6-5.23-.11-.62-.53-1.86-.91-2.75-.88-2-1.51-5.8-2.2-13.1-.29-3.12-.92-7.6-1.4-9.95-.7-3.53-.82-4.87-.66-7.55.11-1.8.2-3.6.2-4.03 0-.43.17-.77.38-.77.28 0 .28-.13 0-.46-.5-.6-.08-1.03.52-.53.33.27.59.28.9.02.26-.21 3.1-.45 6.78-.56 3.48-.1 6.8-.27 7.36-.36 1.57-.26 11.06-.82 20.41-1.2 9.46-.4 72.16-.88 104.3-.82 11.6.03 36.68.03 55.74.02 46.66-.04 43.9-.05 90.9.4 69.54.66 73.51.8 84.23 3 3.8.77 6.7 2.41 7.1 4.01 1.2 4.9 1.2 4.64-.24 16.54-.8 6.61-2.7 11.15-4.69 11.15-2.39 0-5.54 3.73-6.08 7.19-.92 5.89-4.22 9.83-9.33 11.16-1.98.52-2.53.92-2.54 1.9-.03 1.84-1.1 10.3-1.54 12.19-.29 1.25-.6 3.7-.7 5.42-.3 5.4-.58 6.33-2.17 7.11-1.01.5-1.14.53-3.83.81-5.75.6-5.47.54-5.97 1.5-.26.52-.57 2.59-.69 4.7a73.01 73.01 0 0 1-.75 7.86c-.1.56-.71 2-1.38 3.22a17.13 17.13 0 0 0-1.34 2.9c-.08.38-.45.9-.84 1.18-.39.27-.62.62-.53.77.1.16-.39.72-1.08 1.24-.7.53-1.14.78-1 .56.32-.54-.22-.52-.8.02-.38.35-.42.33-.2-.09.22-.41.19-.43-.19-.08-.6.55-1.12.55-.79 0 .16-.26.02-.23-.36.07-.6.49-.96.6-2.53.82-1.3.18-2.2 2.86-3.14 9.31-.98 6.7-3.2 9.27-9 10.36-3.83.72-3.9.76-3.8 2.56.14 2.62.47 4.43.77 4.24.16-.1.34-.06.4.08.18.4 2.27 1.8 2.69 1.8.2 0 .46.24.57.54.11.3.42.45.68.35.25-.1.47-.04.47.13s.54.5 1.2.75c.66.23 1.2.55 1.2.7 0 .15.16.28.36.28.35 0 .8.32 2.02 1.4.33.31 1.13.85 1.76 1.2 2.29 1.3 2.34 1.4 2.46 5.3l.11 3.59.08-3.69c.06-3.23.14-3.7.67-3.74.33-.03 3.22-.02 6.43.02 3.51.04 6.04-.07 6.35-.28.44-.3.51-2.3.51-14.4 0-15.52-.11-14.56 1.68-14.07 1.86.52 11.71.27 12.29-.3.34-.35.47-3.5.55-14.11l.12-13.66 6.54-.16c8.2-.2 7.56.42 7.44-7.14-.04-3.11-.06-6-.03-6.4.06-.75.14-.76 6.73-.87 4.9-.07 6.8-.22 7.12-.55.35-.34.47-3.48.54-14.15l.1-13.7H400V7.2h-7.2V0H7.2v3.94M190.48 44.6c-1 .35-4 .9-6.7 1.2-2.68.32-6.28.95-8 1.41-1.7.46-5.04 1.2-7.4 1.63-4.45.83-5.09 1.03-5.09 1.65 0 3.18-7.36 10.23-10.68 10.23-2 0-9.04 3.58-10.8 5.48a27.17 27.17 0 0 1-4 3.45l-2.11 1.41-.98 3.15a58.51 58.51 0 0 0-1.62 8.3c-1.14 9.17-3.69 20.35-5.36 23.59-.45.87-.43 1.03.34 2.05 2.97 3.96 3.95 8.17 4.86 20.78.42 5.87.67 7.54 1.58 10.63 1.29 4.38 1.06 4.07 2.32 3.18 3.34-2.38 10.14-3.31 20.25-2.77 11.58.63 15.54 2.45 18.24 8.42 1.08 2.37 2.14 3.3 5.05 4.5 10.63 4.33 10.5 21.1-.19 25.15-1.11.42-1.68.86-1.84 1.42l-.98 3.56c-.94 3.43-3.05 7.96-4.2 9.07l-.88.84 1.6.84c1.5.8 4.1 2.65 4.52 3.22.35.49 1.33-4.7 1.52-8.09.36-6.41.57-6.57 9.44-7.09 13.67-.8 18.36-1.3 20.4-2.2l1.96-.87-.2-1.63c-1.65-13.7 1-21.5 8.17-23.94 2.2-.75 3.7-2.42 4.46-5 2.42-8.14 10.51-10.63 24.45-7.5 2.95.66 6.72-1.86 9.02-6.02 1.55-2.8 3.91-5.6 5.6-6.65 2.2-1.36 2.98-5 2.98-13.8 0-9.47-.23-10.2-4.56-14.44-4.2-4.12-4.59-5.03-5.57-13.24a408.73 408.73 0 0 0-2.1-14.55l-1.28-7.87-1.4-.8a19.73 19.73 0 0 0-4.65-1.4c-3.9-.72-6.5-1.57-7.98-2.6a55.26 55.26 0 0 1-8-7.47c-2.46-3.13-7.41-5.18-13.35-5.54-2.45-.15-6.15-.43-8.23-.63l-8.06-.74a64.6 64.6 0 0 1-5.66-.68c-1.93-.44-2.83-.37-4.9.36M9.25 90.65c.45.52.73.94.61.94-.33 0-1.62-1.45-1.62-1.83 0-.19.04-.27.09-.2.05.08.46.57.92 1.1m367.7-.03c-.27.42-.68.82-.9.89-.22.07-.05-.26.38-.75.94-1.08 1.2-1.14.52-.14M16.72 92.52c-.33.08-.87.08-1.2 0-.33-.09-.06-.16.6-.16.66 0 .93.07.6.16m347.16 22.66c-.08.52-.14.17-.15-.77 0-.94.07-1.37.15-.95.08.42.08 1.2 0 1.72m-.72 3.65a3 3 0 0 1-3.06 1.9c-.62-.03-.57-.09.24-.33a4.13 4.13 0 0 0 2.85-3.05c.19-.9.28-1.03.37-.49.06.4-.12 1.3-.4 1.97m-4.58 2.17c-.43.08-1.12.08-1.55 0-.42-.08-.07-.15.77-.15.85 0 1.2.07.78.15m-23.35 39.1c-.17 2.93-1.05 3.56-5.38 3.89l-3.1.23 3.14.05c5.44.1 5.8-.14 5.53-3.57-.08-1.02-.16-1.26-.2-.6m-28.4 3.58c-.8 1.76.35 11 1.2 9.63.2-.33.48-.26 1.18.29.81.63.92.65.92.14 0-.48.1-.5.51-.16.43.35.52.33.52-.13 0-.81.54-.67 1.35.35.7.9.7.9.7.12 0-.76.03-.77.7-.16.37.34.68.44.68.23 0-.6.9-.1 1.3.73.33.67.37.6.4-.6.02-1.54.23-1.45.89.38l.47 1.31.01-1.13c.02-1.25.78-.93 1.14.47.1.37.19-.25.21-1.37.05-2.32.42-2.29.75.08.16 1.13.24.4.27-2.49.05-4.39.65-5.19 1.1-1.46.17 1.35.24.85.27-2.07.05-3.6 0-3.86-.62-3.86-.36 0-.74-.13-.84-.3-.1-.16-1.62-.32-3.37-.34a143.5 143.5 0 0 1-6.28-.26c-3.02-.2-3.1-.2-3.47.6m-242.07 6.9c-.07.62-.14.11-.14-1.11 0-1.23.07-1.73.14-1.12.08.62.08 1.62 0 2.23m1.3 5.54c.51.78 1.47 1.25 3.43 1.7.5.1.42.16-.27.19-2.56.1-4.42-1.82-4.33-4.5.04-1.06.06-1.05.33.31.15.8.53 1.83.84 2.3m7.29 2.17c-.52.08-1.37.08-1.89 0-.52-.08-.1-.14.94-.14s1.47.06.95.14m247.43 3.38c0 .3-.16.44-.35.32-.49-.3-.42.3.09.8.48.49.6 6.12.17 7.68-.32 1.14-1.22 1.65-3.5 1.99l-1.73.25 2.25.04c3.56.07 3.56.07 3.7-6.27.08-3.7 0-5.35-.26-5.35-.2 0-.38.24-.38.54m-241.6 4.86c-.08.52-.15.18-.15-.77 0-.94.06-1.37.14-.94.08.42.09 1.19 0 1.71m241.15-.25c.27 1.48.47 1.76.46.66 0-.46-.16-1.06-.34-1.35-.24-.36-.28-.16-.12.69M80.4 190.54c.52.79 1.67 1.27 4 1.67.76.13.74.15-.18.2-2.87.12-4.61-1.12-4.83-3.45-.12-1.33-.1-1.37.16-.38.16.61.54 1.5.85 1.96m239.38-1.37c-.27.76-.9 1.54-1.54 1.93-1.12.68-.7.95.47.31.8-.42 1.79-2.22 1.64-2.97-.06-.3-.31.01-.57.73m-26 1.84c-.74.08-1.18.36-1.45.96-.49 1.07-.53 12.13-.05 14.44.2 1 .23 3.35.07 5.94l-.27 4.29-.37-2.23c-.28-1.72-.39-1.96-.44-1.03-.14 2.44-.65 2.68-.73.34-.04-1.22-.14-1.84-.24-1.37-.15.8-.18.81-.44.17-.25-.63-.28-.62-.3.14-.01.46-.12.74-.24.62s-.5.13-.84.54l-.64.76-.01-.86c-.01-.68-.09-.75-.35-.34-.28.43-.34.41-.34-.13 0-.53-.1-.57-.52-.21-.43.35-.51.31-.52-.22 0-.56-.1-.53-.68.22-.39.5-.67.66-.68.38 0-.36-.11-.38-.49-.07-.35.3-.55.3-.72.03-.16-.27-.37-.26-.71.02-.38.32-.49.3-.5-.06 0-.32-.18-.25-.51.19-.47.62-.5.62-.5.05 0-.4-.18-.55-.5-.43-.27.1-.57 0-.66-.22-.09-.22-.18-.14-.2.2 0 .35-.29.6-.69.6-.5 0-.71.29-.84 1.1l-.7 4.38c-.3 1.8-.6 4.73-.67 6.52-.16 3.9-.97 6.09-2.32 6.3-.25.03-.67.2-.92.35-.25.16-2.02.35-3.94.43-6.83.3-7.31.76-6.96 6.78.41 6.91.2 17.01-.38 18.39-.23.55-.24 1-.03 1.26.24.3 0 .47-.88.64-.67.12-1.4.44-1.62.7-.3.37-1.42.49-4.55.49-5.92 0-6.27.29-7.42 6-1.16 5.78-5.06 9.7-10.33 10.36-2.44.3-2.77.8-2.56 3.85.64 9.22.54 8.62 1.4 8.94.43.17.9.48 1.03.7.19.3.33.28.55-.06.25-.39.35-.39.6 0 .16.25.35.43.43.4.07-.03.53.1 1.03.29.49.18 1.61.4 2.49.47.88.07 1.77.3 1.98.52.28.28.59.3 1.07.03.45-.24.6-.24.46 0-.14.2.16.34.73.33 2.45-.05 2.49-.03 2.49 1.46 0 .84-.14 1.3-.34 1.18-.52-.32-.4.6.18 1.35 1.3 1.73.3 8.62-1.37 9.42-1.6.77-7.02.93-8.34.25-1.24-.64-1.58-.7-1.28-.21.13.2-.46.34-1.55.34-1.6 0-1.7-.05-1.22-.54.6-.6.72-.98.2-.66-.2.12-.82-.12-1.39-.53-.77-.54-1.15-.64-1.49-.36-.24.2-.53.28-.64.18-.23-.24-8.67-.43-9.92-.22-1.56.25-1.95 1.88-2.03 8.52-.08 5.8-.37 8.02-1.03 8.02-.2 0-.26-.16-.14-.35.12-.18.06-.34-.13-.34a.7.7 0 0 0-.53.3c-.1.16-2.7.32-5.76.36-6.64.06-6.04-.38-6.28 4.65-.11 2.42-.36 4.3-.6 4.6-.34.4-.33.46 0 .26.77-.46.46.1-.35.62-2.59 1.7-19.38 1.46-22.19-.32-1.28-.8-2.35-2.88-1.88-3.64a.32.32 0 0 0-.1-.43c-.15-.09-.3-1.22-.35-2.5-.2-5.1-2.18-8.88-4.37-8.36-.42.1-2.7.32-4.2.4-.62.03-1.12.17-1.12.3 0 .14-.5.35-1.11.46-1.69.32-1.86.38-2.45.87-.3.25-.55.37-.55.25 0-.1-.53.3-1.16.9-.64.61-1.1 1.22-1.02 1.35.08.14-.36.4-.98.6-.78.25-.87.32-.27.25l.85-.1V328c0 8.44-.77 7.64 7.57 7.77l6.67.11v7.16h28.47v-3.98c0-3.67.05-3.96.6-3.7 1.08.51 11.48.55 12.44.05 1.01-.53 1.31-4.13.74-8.88-.38-3.13.05-5.07 1.15-5.15.37-.02 3.38-.06 6.67-.08l6-.04.43-.86c.3-.6.44-2.7.44-6.9v-6.04l6.54-.16c8.34-.2 7.6.53 7.8-7.8l.17-6.5 6.5-.1c8.5-.15 7.6 1.7 7.3-14.95l-.24-13.47h4.96c8.07 0 9.1-.18 9.51-1.67.2-.73.35-6.58.35-14.15v-12.9l1.07-.22c.59-.12 3.49-.12 6.44 0 4.68.2 5.45.16 5.93-.32.7-.7 1.07-8.9.9-20.3l-.1-7.9h6.63c8.44 0 7.75.73 7.47-7.8l-.21-6.43h.77c.9-.02 1.88-.56 1.56-.87-.12-.12-.5-.07-.85.12-.73.4-2.6.13-2.31-.32.1-.17-.29-.33-.87-.35a4.93 4.93 0 0 1-1.82-.27 130 130 0 0 0-9.38-.1m18.46.8c.09.28.7.5 1.5.53 1.27.07 1.29.06.29-.2a7 7 0 0 1-1.5-.54c-.3-.18-.4-.11-.3.2M93.37 202.47c-.05 5.03.1 6.28.67 5.92.17-.1.31.05.31.35s-.12.53-.27.53c-1.03 0-1.59 10.19-.63 11.49.42.57 1.12.65 6.98.8l6.52.15.18 13.42c.2 15.07.13 14.51 2.09 14.8 2.82.4 10.81.05 9.72-.43-.56-.25-.86-.6-.73-.81.17-.27.34-.24.56.08.26.36.37.37.5.04.13-.31.36-.33.84-.07.37.2.81.27.99.16.2-.12.33 5.06.34 13.42.01 7.49.12 14.01.24 14.5.41 1.74.45 1.75 7.58 1.75h6.7l1.06-1.12c.59-.6 1.2-1.07 1.35-1.02.16.06.2-.04.1-.2-.1-.17.19-.66.65-1.1.46-.42.76-.9.67-1.05-.1-.15.1-.43.44-.63.33-.19.48-.35.34-.36-.15 0 0-.41.32-.9.33-.5.61-1.21.64-1.58.03-.38.24-.8.47-.94.22-.14.44-.59.47-1 .03-.4.14-.74.25-.74.1 0 .23-.4.27-.88.04-.5.18-1.07.32-1.29.53-.86.33-1.31-.92-2.1-2.53-1.6-3.73-4.24-4.6-10.05a36.16 36.16 0 0 0-1.28-5.6l-.76-2.07-2.43.04c-1.34.03-2.55.02-2.7-.01-.13-.03-1.4-.1-2.82-.15a26.03 26.03 0 0 1-2.83-.18 5.35 5.35 0 0 0-1.12-.14c-.53-.02-.82-.21-.76-.5.07-.3-.09-.4-.41-.28-.29.11-.61.05-.72-.13-.12-.18.06-.33.38-.33.55 0 .55-.04.01-.63a2.7 2.7 0 0 1-.55-1.63c.01-.55.02-5.43 0-10.86v-9.86l-2.32-.03c-9.72-.12-11.67-.3-11.22-1.03.11-.18.02-.29-.2-.24-.32.07-.45-1.42-.51-5.9-.13-8.87-.12-8.84-.67-9.33-1.48-1.33-1.55-1.37-1.77-.8-.16.43-.3.45-.7.12-.38-.3-.57-.31-.75-.03-.15.26-.41.28-.74.07-.73-.45-1.02-.4-1.02.19 0 .67-.26.65-.97-.06-.54-.54-.58-.54-.7.03-.1.55-.2.53-.94-.17l-.82-.78-.02 1-.02 1-.54-.77c-.75-1.07-1.13-.96-1.16.35-.03 1.1-.03 1.1-.4.26a59.65 59.65 0 0 1-1.4-3.44c-.1-.28-.22.73-.25 2.23l-.07 2.75-.3-1.89c-.17-1.04-.44-3.12-.6-4.63-.28-2.63-.3-2.54-.34 2.29m213.17.12c-.39 3.1-2.27 4.38-6.29 4.24-.9-.03-.65-.13.9-.33 3.73-.48 5.07-1.84 5.2-5.29.04-.75.14-1.17.24-.92.1.25.08 1.28-.05 2.3M94.4 212.45c-1.95 2.37-.2 7.34 2.87 8.12l1.36.34-1.47-.13c-2.9-.27-4.24-2.56-3.69-6.26.27-1.77.95-3.48 1.15-2.88.07.21-.03.58-.22.8m2.04 4.27c.39.62.62 1.13.52 1.13-.31 0-1.94-2.94-1.91-3.46 0-.27.17-.1.36.35.18.47.65 1.35 1.03 1.98m.67 2.8c1.27.67 1.35.76.49.58-1.17-.25-3.26-2.29-3.26-3.18 0-.36.26-.11.63.6a5.36 5.36 0 0 0 2.14 2m4.1.59a4.1 4.1 0 0 1-1.88.37c-.58-.11-.55-.15.16-.19.47-.03 1.09-.2 1.37-.38a2.2 2.2 0 0 1 1.03-.33c.28 0-.02.24-.68.53m2.65.38c-.4.39-1.27.6-2.73.66l-2.16.09 2.14-.35c1.18-.2 2.15-.5 2.15-.67 0-.17.26-.31.59-.31.55 0 .55.03 0 .57m3.95.24c.33.25.5.56.37.68-.4.4-.76.24-1.14-.46-.42-.79-.1-.88.77-.22m95.95.56c-1.97.24-2.54.49-4.53 2a47.53 47.53 0 0 1-4.48 2.95c-2.38 1.34-3.34 2.86-4.34 6.88l-.57 2.28c-.23.88 2.28 1.26 10.01 1.5 10.68.33 11.47-.01 11.48-5.03 0-2.5.94-6.81 1.87-8.6.46-.9.73-1.68.6-1.76-.54-.31-7.96-.48-10.04-.22m-95.18 15.33c0 .04-.2-.05-.44-.2-.32-.2-.36-1.67-.16-6.4l.26-6.16.17 6.35.17 6.41m183.96-8.73c-.08.62-.14.12-.14-1.11s.06-1.73.14-1.12c.08.62.08 1.62 0 2.23m-.58 4.7c-.47 1.74-1.45 2.4-3.83 2.59-1.01.07-1.46.06-.98-.03 3.14-.64 4.4-1.69 4.73-3.96.13-.9.27-1.2.34-.75.06.4-.06 1.38-.26 2.14m-183.27 6.82c-.34.4-.34.48-.02.29.24-.14.43-.13.42.02-.02.44-1.01 1.64-1.06 1.28-.03-.17-.16.22-.3.88-.22 1.02-.26.88-.3-.98-.04-1.8.04-2.15.47-1.98.28.1.52.04.52-.16 0-.19.16-.25.36-.13.24.15.2.4-.1.78m.69 1.53c.07.82.28 1.61.5 1.82.12.12.12.46 0 .76-.13.35-.06.45.2.29.27-.17.32-.06.17.34s-.1.5.17.34c.25-.15.33-.06.21.25-.11.3.09.55.52.67.39.1.7.43.7.73s.24.54.52.54.51.28.5.6c0 .52-.04.53-.33.1-.18-.3-.33-.37-.34-.19 0 .18-.24 0-.53-.43-.8-1.12-2.07-1.76-1.53-.77.76 1.43 2.94 2.43 3.2 1.47.11-.46.16-.41.2.17.01.42.18.77.36.77.19 0 .25-.22.15-.49-.16-.42.25-.5 1.15-.22h.29c.11-.01.43.26.71.6.28.34.43.47.34.27-.1-.2.12-.36.49-.36.36 0 .66.13.66.27 0 .15-.22.27-.49.27s-.55.2-.63.43c-.21.64-5.26.52-6.84-.17-2-.87-2.4-3.19-1.23-7.2.37-1.27.8-1.7.88-.86m-.52 1.04a16 16 0 0 1-.46 2.04c-.52 1.87.03 3.58 1.48 4.52 2.07 1.36 6.87.86 5.16-.53-.5-.4-.54-.39-.36.1.2.54-1.63 1.26-2.08.8-.1-.09.04-.17.3-.17s-.21-.34-1.06-.77a5.6 5.6 0 0 1-2.32-2.14c-.52-.9-.71-1.08-.56-.52.29 1.07 1.04 1.96 2.38 2.82.94.6.95.65.17.43-2.45-.69-4.29-5.3-2.11-5.31.45 0 .48-.06.1-.3-.26-.17-.38-.47-.26-.66.13-.2.1-.44-.07-.54-.16-.1-.3 0-.3.23m169.34 15.45c-.03 2.03-.19 1.83-.42-.53-.08-.9-.02-1.54.15-1.44.16.1.28.99.27 1.97m-.69 4.42c-.47 1.15-2.09 2.01-3.65 1.95-.9-.03-.89-.05.2-.3 1.67-.4 2.9-1.44 3.3-2.79.23-.8.37-.97.46-.53.07.34-.07 1.1-.3 1.67m-6.84 2.01l1.89.22-1.94.05c-1.5.04-2.11-.1-2.74-.66l-.81-.7.86.44c.47.24 1.7.53 2.74.65M135.9 290.07c-.08 2.14.5 2.66 3.08 2.76 2.15.09 2.16.08.47-.18-2.87-.44-2.96-.52-3.37-3.11-.09-.53-.16-.33-.18.53m19.33 1.94c-1.32.14-3.07.35-3.88.46l-1.49.2.11 13.9c.13 16.14-.19 14.9 3.87 14.83l2.42-.05-1.89-.26c-3.98-.54-3.94-.44-3.94-12.07 0-6.87.1-9.26.43-9.59.34-.34.43-.26.46.42.02.58.17.37.48-.7.42-1.45.45-1.48.48-.46.06 2.03.35 2.3 1.36 1.27l.9-.9.22 1.15.21 1.16.09-1.03c.05-.63.14-.8.24-.43.18.7.5.76 1.06.2.32-.33.42-.27.44.25.02.6.05.58.33-.1.3-.75 1.02-1.08 1.02-.47 0 .18.52.2 1.2.04.83-.19 1.2-.15 1.21.12 0 .22.2.13.45-.19.41-.54.48-.53.93.09.57.8 1.01.86 1.01.15 0-.28.23-.51.52-.51.28 0 .5.18.5.4 0 1.38.36-.42.66-3.27.54-5.35-.02-5.62-9.4-4.62m93.76 6.98c-.14.13-.15.71-.03 1.28.15.76.1.98-.2.8-.3-.2-.35 0-.18.68.14.57.1.86-.1.73-.18-.11-.32.13-.3.54 0 .42-.14.75-.33.76-.2 0-.8.35-1.34.78-.53.42-.85.77-.7.77.16 0 .64-.34 1.08-.75.44-.4.8-.56.8-.34 0 .66-2.15 1.8-3 1.6-.46-.1-.78-.02-.78.2 0 .4-.83.32-2.23-.19-.5-.17-.55-.15-.22.09.4.28.4.36 0 .52-.88.35 2.07.24 3.86-.14 2.31-.5 3.22-1.44 3.72-3.85.41-1.97.38-3.92-.05-3.48m-14.9 20.3c-.38.5-.88.98-1.11 1.06-.24.08-.03-.25.45-.73.48-.49.88-1.07.88-1.3 0-.23.1-.3.23-.18.13.13-.07.65-.45 1.15m-13.5 13.1c-.59 2.19-3.16 3.47-6.1 3.03-.87-.13-.85-.15.2-.2 3.76-.17 5.37-1.36 5.8-4.29.17-1.22.29-1.48.36-.84.07.5-.05 1.54-.26 2.3m-1.88.65l-.98.93.82-1.07c.46-.59.9-1 .99-.93.08.08-.3.56-.83 1.07"/><path fill="#585404" d="M127.96 11.37c-1.6.16-15.34.44-30.53.63-29.52.35-51.52.82-56.26 1.2-29.33 2.32-28.62 1.9-28.4 16.48.17 11.62 1.6 15.6 7.18 19.86 1.53 1.16 4.97 9.59 6.82 16.66 1.04 4 3.57 7.2 7 8.9 2.84 1.39 3.46 2.3 4.65 6.81 1 3.76 2.57 7.9 3.74 9.81.35.6.75 1.54.87 2.1.66 3 3.25 5.75 6.07 6.46.5.13 1.18.65 1.52 1.17a30.88 30.88 0 0 1 3.56 7.14c1.63 5.29 4.16 8.54 8.15 10.5 2.75 1.36 3.06 1.74 3.72 4.58.79 3.39 2.51 8.66 3.43 10.48.43.86 1.05 3 1.37 4.76.38 2.06.82 3.43 1.23 3.84.36.36.65.76.64.9 0 .35 3.35 2.12 3.58 1.9.1-.11.44.02.76.28.32.27.63.44.7.4.62-.45 2.86 3.2 2.86 4.67 0 1.34 2 8.54 3.12 11.2.63 1.5 1.16 2.81 1.18 2.9.4 2.13 2.28 5.86 2.8 5.55.1-.06.3.04.4.22.3.45 3.3 1.78 4.06 1.79.58 0 2.36 2.44 3.63 4.98.3.6.62 2.55.76 4.6.12 1.95.34 3.88.48 4.28.14.4.23.95.2 1.23-.14 1.67 2.57 3.01 6.65 3.29 3.32.23 4.85 1.13 4.85 2.86 0 .49.37 3.27.83 6.2a424.1 424.1 0 0 1 1.7 12.05c.42 3.62 3.69 5.79 8.7 5.79 2.08 0 4.01 2.7 4.37 6.08.72 6.72 5 13.37 9.93 15.4 1.75.73 3.21 3.7 5.46 11.16 2.1 6.93 3.92 9.58 8.02 11.64 3.2 1.61 3.5 2.03 3.52 4.95.01 2.45.91 11.35 1.19 11.8.08.14.25 1.01.38 1.94.13.93.4 1.8.6 1.93.22.13.3.34.17.46-.62.62 2.44 2.84 4.25 3.09 1.87.25 5.2.61 5.88.63 1.03.03 3.23 5 3.66 8.29 1.05 8.01 2.95 10.62 8.58 11.8 1.03.2 2.06.5 2.28.63.37.24 5.58 14.2 6.09 16.32 1.17 4.9 7.77 7.04 14.04 4.53 2.5-1 3.22-1.84 4.2-4.92 1.02-3.16 3.2-4.73 7.05-5.05 3.18-.26 5.22-.71 5.38-1.18.07-.2.25-.28.4-.19.9.55 2.16-3.44 2.55-8.06.26-2.96 2.97-10.3 3.82-10.3 1.53 0 6.67-3.77 6.67-4.89 0-.2.4-.87.88-1.5 1.54-2.02 2.15-3.94 2.9-9.04.9-6.2 1.77-7.84 5.17-9.64 4.04-2.16 6.16-4.72 8.19-9.87 2.25-5.71 4.37-9.47 5.6-9.92a7.53 7.53 0 0 0 2.47-1.88c.69-.8 1.85-2.07 2.58-2.82 2.27-2.33 3.57-5.8 4.3-11.5.42-3.24 3.14-8.91 4.27-8.91.68 0 4.43-1.84 5.38-2.64 1.44-1.21 4.4-8.98 5.57-14.61 1.26-6.07 1.68-6.58 5.7-6.91 1.64-.13 3.38-.41 3.89-.62.5-.2 1-.36 1.12-.34.12.03.57-.34 1-.8.44-.46.7-.84.59-.84-.12 0-.06-.5.13-1.12.39-1.28.49-1.94.8-5.23.27-2.98.62-4.1 2.29-7.45l1.32-2.65 2.49-.75c3.89-1.18 4.66-1.98 6.77-6.97.99-2.34 1.63-5.48 2.06-10.08.53-5.5 2.56-9.68 4.56-9.36.14.03 1.45-.2 2.91-.5l2.97-.6c1.05-.19 2.78-2.49 3.15-4.18l.45-1.88c.2-.85.47-4.76.58-8.68l.21-7.14 1.28-1.61a5.95 5.95 0 0 1 3.04-2.22c5.62-1.95 7.42-5.08 10.4-18.09 1.64-7.15 1.51-6.9 4.07-7.72 5.24-1.67 7-3.83 8.56-10.43 1.18-5.04 3.5-9.64 4.84-9.64 2.19 0 6.12-4.14 6.17-6.5 0-.29.24-.83.52-1.2.78-1.03 2.4-6.41 3.22-10.61.86-4.46 2.61-8.08 4.3-8.89 2.14-1.02 4.52-3.59 6.03-6.5a74.47 74.47 0 0 1 2.69-4.72c.66-1.04 2.03-3.35 3.05-5.13 1-1.78 2.12-3.44 2.47-3.69 1.8-1.25 2.19-2.86 3.75-15.27.53-4.26-2.09-6.28-10.47-8.04-6.44-1.36-6.07-1.34-40.96-2.16a474.3 474.3 0 0 1-18-.67c-2.08-.19-14.05-.35-26.6-.36-15.23-.01-24.12-.16-26.75-.43-5.2-.55-29.78-.44-51.39.22-11.8.37-18.21.42-22.3.19-16.97-.96-51.66-1.33-58.73-.63M171 12.72c4.53.2 11.4.55 15.27.79 4.63.29 9.37.35 13.9.18 37.8-1.42 48.85-1.59 56.87-.86 4.82.43 10.63.55 27.62.55 18.57 0 22.58.1 29.4.68 4.75.42 10.88.7 15.43.7 4.15 0 10.4.23 13.9.5 3.49.28 9.53.5 13.42.51 7.85.01 10.58.4 18.02 2.56 2.72.8 4.26 1.43 4.84 2.02l.85.85-.55 3.9c-1.58 11.13-1.5 10.77-2.96 13.35a38.44 38.44 0 0 0-1.38 2.55c0 .16-3.46 5.69-5.9 9.43a32.83 32.83 0 0 1-4.1 4.97c-2.96 2.8-4.85 6.45-6.33 12.25-1.12 4.4-2.65 8.13-4.13 10.08-.44.59-.8 1.23-.8 1.44 0 .55-3.31 3.85-3.87 3.85-.94 0-4.07 6.18-5.41 10.69-1.7 5.69-3.68 8.31-7.74 10.25a11 11 0 0 0-3.02 2.06c-.97 1.16-1.1 1.57-2.6 8.2-2.26 9.94-4.07 13.15-8.78 15.56-3.8 1.94-5.54 4.67-6 9.36-.38 3.97-1.41 8.75-2.33 10.76-1.3 2.88-2.31 3.72-7.22 5.98-1.73.8-4.04 6.3-5.48 13.05-1.2 5.64-4.8 11.1-8.24 12.53-1.96.81-5.96 9.09-6.42 13.28-.52 4.8-2.3 6.95-6.5 7.82-3.52.74-5.28 2.83-6.56 7.77-1.85 7.15-4.94 12.88-7.9 14.68-3.26 1.98-6.03 6.81-7.3 12.73-1.22 5.77-3.47 9.3-7.36 11.56-1.87 1.08-3.27 3.41-6.36 10.56-3.07 7.12-4.63 9.3-8.75 12.18-2.6 1.82-4.84 5.38-5.51 8.79-1.4 6.94-3.5 10.24-8.62 13.53-1.63 1.05-5.48 10.25-6.08 14.56-.78 5.53-1.83 6.72-7.03 7.93-4.19.98-7.63 3.36-8.98 6.22-1.7 3.63-6.3 5.72-9.43 4.31-3.28-1.48-4.05-2.6-6.71-9.83a400.4 400.4 0 0 0-3.15-8.29l-1.1-2.74-3.18-1.57c-4.92-2.43-6.24-4.12-7.63-9.75-1.1-4.44-3.9-10.52-5.14-11.18-.28-.15-1.29-.55-2.23-.89-1.61-.57-4.63-2.92-4.63-3.6 0-.16-.38-.88-.84-1.58-1.37-2.1-2.69-6.78-3.44-12.2-.27-1.9-2.17-4.3-4.14-5.23-3.46-1.64-5.72-5.13-8.26-12.79-3.04-9.13-4.32-11.6-6.52-12.6-3.78-1.73-6.37-5.28-7.76-10.63-1.26-4.87-3.75-8.4-6.27-8.87-3.53-.66-5.53-2.47-6.47-5.85-1.02-3.61-2.96-14.1-2.96-15.97 0-1.32-3.26-4.79-4.51-4.79-.92 0-3.31-.73-4.66-1.43-1.27-.66-2.2-2.67-2.72-5.9-.72-4.48-4.42-11.3-6.62-12.22-3.19-1.32-7.64-9.53-9.45-17.43-.8-3.5-3.69-9.2-4.8-9.47-1.37-.34-3.5-2.79-4.3-4.95a31.53 31.53 0 0 0-1.69-3.66 58.36 58.36 0 0 1-3.98-10.12c-.8-2.97-2.22-4.87-5.02-6.73-3.04-2.02-4.52-3.79-6.18-7.33l-2.39-5.15c-1.14-2.45-3.95-6.86-4.38-6.86-.52 0-3.3-2.67-3.79-3.65-.27-.54-.9-1.6-1.4-2.35a40.6 40.6 0 0 1-4.45-9.78c-1.34-4.3-3-6.95-5.27-8.46-4.5-2.97-5.16-4.09-9.15-15.55-3-8.57-3.32-9.25-5.78-11.84-4.02-4.24-5.71-8.56-5.37-13.7.75-11.4 1.3-12.8 5.7-14.52 3.54-1.39 22.98-3.14 35.33-3.17 4.87-.02 9.96-.24 12.86-.56 3.64-.41 11.17-.61 31.22-.84 19.32-.21 27.6-.43 30.87-.8 5-.56 25.4-.48 40.48.17m19.76 21.25a30.4 30.4 0 0 0-2.91 1.82c-1.8 1.36-4.1 2.59-7.1 3.8-1.6.64-4.2 1.73-5.8 2.42-1.6.7-4.87 1.86-7.26 2.58-5.8 1.75-8.67 3.31-12.29 6.69-3.94 3.67-10.33 7.47-17.04 10.12-4.5 1.78-4.77 2.32-8.31 16.34-1.88 7.44-3.12 10.88-4.92 13.64a44.06 44.06 0 0 0-5.16 12.26l-.83 3.63.89 1.86c.49 1.02 1.7 2.86 2.7 4.08 1 1.23 2.45 3.48 3.2 5l1.4 2.78.5 6.83.52 6.83 2.51 7.89c1.95 6.1 2.68 9.01 3.26 12.86.41 2.74.94 5.9 1.18 7.04l.43 2.05.42-1.54c.23-.85 1.28-4.14 2.33-7.32l1.91-5.78 1.76-1.4c.96-.76 3.06-2 4.67-2.76l2.91-1.38 6.86.77c8.16.9 8.96 1.2 11.76 4.41 3.74 4.3 5.82 6.19 8.35 7.58a15.82 15.82 0 0 1 6.25 5.86l.88 1.53-1.08 2.03c-1.38 2.6-3.75 5.24-4.97 5.54-1.83.45-8.52 3.42-11 4.89l-2.5 1.48-6.91-.54c-6.72-.52-8.49-.49-10.81.23-1.44.45-1.4.74.17 1.3.7.26 1.7.76 2.22 1.12.51.36 1.84.81 2.96 1 4.11.73 5 1.96 5.7 7.84l.41 3.62 3.13 4.11c2.1 2.78 3.77 4.6 5.11 5.56 5.07 3.67 6.05 5.57 6.99 13.47.54 4.55.75 5.43 2.49 10.3.83 2.36 1.8 5.48 2.14 6.94.7 3 .04 2.53 6.33 4.56 10.93 3.53 22.07 3.43 34.36-.32 3.66-1.12 3.43-.81 4.87-6.38.66-2.54 1.54-5.84 1.95-7.33.7-2.59.72-3 .4-9.77l-.35-7.07.87-2.15c1.94-4.85 4.33-6.5 14-9.68l7.01-2.3-.77-.73c-1.43-1.35-6.39-2.81-9.5-2.81-5.3 0-12.32-4.35-14.76-9.13-.47-.93-1.19-2.07-1.6-2.54-1.88-2.15-4.92-10.21-4.91-13.03 0-1.3 3.2-5.31 5.43-6.83a19.56 19.56 0 0 0 6.9-7.9c1.03-2.02 3.95-4.9 6.04-5.95l1.69-.85 4.12.95c2.26.52 5.46 1.5 7.1 2.16 1.65.66 3.77 1.37 4.72 1.57 3.74.8 6.76 3.09 11.19 8.44l1.4 1.7.8-3.77c.76-3.62.78-4.03.45-10.97l-.35-7.2 1.34-3.94c2.7-7.98 2.97-9.59 3.04-18.19l.06-7.72-1.1-3.6c-.6-1.98-1.77-5-2.61-6.72-1.49-3.04-1.54-3.28-2.38-10.12-.62-5.1-1.35-8.99-2.67-14.34l-1.82-7.33-2.4-1.76c-2.34-1.7-4.31-2.77-10.49-5.67-2.93-1.38-4.15-2.38-8.06-6.6-1.06-1.16-2.2-1.88-4.46-2.85-1.66-.7-5.03-2.3-7.49-3.52a40.64 40.64 0 0 0-9.6-3.54c-2.83-.72-7-2.02-9.26-2.89-3.36-1.28-13.61-4.31-14.52-4.3-.13.01-1.07.48-2.09 1.04m4.01 2.35c4.34 2.2 16.22 5.4 24.26 6.55 1.77.25 3.34.81 6.01 2.16 1.99 1 5.2 2.44 7.16 3.18l3.54 1.36 1.52 2.28a18.1 18.1 0 0 0 10.37 7.34c2.33.64 3.21 1.09 6.59 3.32l2.6 1.72.42 2.5c.23 1.37.93 4.78 1.56 7.59.63 2.8 1.5 8.17 1.94 11.93l.8 6.83 1.5 1.74c1.67 1.94 2.7 4 4.27 8.61l1.05 3.09-.06 7.72c-.07 7.5-.1 7.81-1.1 11.15-1.48 4.88-2.71 8.12-3.4 8.92a4.95 4.95 0 0 0-1.38 3.66c0 1.77-.8 4.57-1.5 5.27-1.82 1.81-9.63 1.92-16.1.22-7.3-1.92-8.98-2.05-11.4-.89a16.94 16.94 0 0 0-6.84 6.81c-1.24 2.45-4.11 5.65-6.14 6.84-6.95 4.07-7.92 10.55-3.27 21.74.42 1 .4 1.25-.19 2.34-1.06 1.97-1.65 2.13-11.5 3.06-18.87 1.78-20.23 2.6-23.33 14.15-.74 2.79-1.65 6.14-2.02 7.46-1.29 4.57.27 9.86 3.5 11.95 3.7 2.39 7.26 2.53 22.88.93 10.57-1.08 13.03-4.5 13.04-18.12.01-10.92.76-14.95 2.43-13.15 2.13 2.29 5.48 3.61 12.14 4.8 2.08.37 4.27.88 4.87 1.14l1.1.47-2.47.72c-1.36.4-3.32.91-4.35 1.14-8.27 1.85-10.32 5.94-9.61 19.22l.4 7.37-1.37 5.32c-1.44 5.64-2.97 8.75-4.6 9.37a50.63 50.63 0 0 1-31.21 1.1l-4.28-1.28-.37-1.6a14.79 14.79 0 0 0-2.68-5.85c-1.98-2.35-2.62-5.48-2.85-13.96l-.2-7.58-2.35-2.62c-2.16-2.42-6.4-5.64-8.9-6.77-.53-.24-1.64-1.38-2.46-2.53-2.22-3.11-1.72-5.03 2.7-10.43a53.76 53.76 0 0 0 3.5-4.72c.9-1.55 1.57-1.95 8.22-4.94 3.6-1.62 6.12-4.46 7.69-8.67l.7-1.87-.7-1.6c-1.34-3.16-3.33-5.27-6.86-7.32a24.82 24.82 0 0 1-4.46-3.63c-7.76-8.14-7.17-7.81-15.3-8.59-8.04-.77-8.9-.74-12.18.46-5.47 2-8.18 4.44-9.56 8.63l-.83 2.53-.57-2.92c-.65-3.37-1.19-5.28-3.25-11.66-1.4-4.36-1.53-5.05-2.05-11.66-.8-10.22-2.22-14.11-6.8-18.63-2.29-2.24-2.36-2.36-2.13-3.6.25-1.36.27-1.4 2.49-5.26a37.3 37.3 0 0 0 2.35-5.1 61.7 61.7 0 0 1 2.1-5.06c1.07-2.25 1.61-4.2 3.91-14.16.37-1.6 1.37-5.1 2.21-7.77l1.53-4.86 1.63-.58c9.92-3.52 18.17-8.25 20.85-11.97 1.78-2.46 5-4.3 9.25-5.28 1.7-.39 4.86-1.35 7.03-2.12s5-1.7 6.3-2.05c4.37-1.2 7.57-2.71 9.86-4.65 2.48-2.1 2.6-2.13 4.35-1.24m140.46 121.83c0 .66.07.93.16.6a2.8 2.8 0 0 0 0-1.2c-.09-.33-.16-.06-.16.6m-.71 3.59c-.24.65-.74 1.27-1.12 1.4-.39.12-.62.3-.51.4.37.38 1.84-.92 2.07-1.81.33-1.35.05-1.35-.44.01m-10.42 2.49c.61.07 1.54.07 2.05 0 .52-.08.01-.15-1.12-.14-1.13 0-1.55.06-.93.14m-2.88 12.1c0 2.73.06 3.85.12 2.49.07-1.37.07-3.61 0-4.98-.06-1.37-.12-.25-.12 2.49m-108.28 9.69c3.97 1.58 4.73 4.02 4.45 14.36-.26 9.72-1.66 12.27-8.14 14.88-2.24.9-16.06 1.95-18 1.36-4.22-1.27-6.89-3.46-8.48-6.96l-1-2.17 1.75-6.4c3.5-12.8 4.4-13.64 16.64-15.4 7.58-1.1 9.34-1.05 12.78.33m107.46 4.18c0 .27-.4.8-.9 1.2-.5.39-.73.71-.52.71.57 0 1.76-1.28 1.76-1.89 0-.28-.07-.51-.17-.51s-.17.22-.17.49m-6.6 2.5c.43.08 1.05.07 1.37-.01.33-.09-.02-.15-.77-.15-.76 0-1.03.07-.6.16m-177.87 91.7c0 .84.07 1.19.15.76.08-.42.08-1.12 0-1.54-.08-.43-.15-.08-.15.77m.6 6.1c0 .63 1.29 1.8 1.97 1.77.48-.02.45-.08-.14-.32-.4-.16-.98-.65-1.28-1.08-.3-.44-.56-.6-.56-.37m9.01 2.38c.52.08 1.37.08 1.89 0 .52-.08.1-.14-.95-.14-1.03 0-1.46.06-.94.14m102.66 12.79c-.34.38-.46.69-.27.69.43 0 1.29-.98 1.06-1.22-.1-.09-.45.15-.79.53m-97.59 12.63c-.03 1 1.09 2.46 1.88 2.45.19 0 .06-.17-.3-.37a3.6 3.6 0 0 1-1.1-1.45c-.25-.6-.47-.88-.48-.63m6.08 3.05c.43.08 1.05.08 1.38 0 .32-.1-.03-.16-.78-.16s-1.02.08-.6.16"/><path fill="#766e04" d="M130.53 12.55c-3.26.37-11.55.59-30.87.8-20.05.23-27.58.43-31.22.84-2.9.32-8 .54-12.86.56-12.35.03-31.8 1.78-35.34 3.17-4.39 1.72-4.94 3.13-5.7 14.52-.33 5.14 1.37 9.46 5.38 13.7 2.46 2.6 2.79 3.27 5.78 11.84 4 11.46 4.65 12.58 9.15 15.55 2.28 1.5 3.93 4.16 5.27 8.46a40.6 40.6 0 0 0 4.45 9.78c.5.75 1.13 1.81 1.4 2.35.5.98 3.27 3.65 3.8 3.65.42 0 3.23 4.4 4.37 6.86l2.4 5.15c1.65 3.54 3.13 5.3 6.17 7.33 2.8 1.86 4.21 3.76 5.02 6.73a58.36 58.36 0 0 0 3.98 10.12c.53.95 1.3 2.6 1.7 3.66.8 2.16 2.92 4.6 4.3 4.95 1.1.28 3.98 5.98 4.79 9.47 1.81 7.9 6.26 16.11 9.45 17.43 2.2.91 5.9 7.74 6.62 12.22.52 3.23 1.45 5.25 2.72 5.9 1.35.7 3.74 1.43 4.66 1.43 1.25 0 4.51 3.47 4.51 4.8 0 1.86 1.94 12.35 2.96 15.96.94 3.38 2.94 5.19 6.47 5.85 2.52.47 5.01 4 6.27 8.87 1.39 5.35 3.98 8.9 7.76 10.63 2.2 1 3.48 3.47 6.52 12.6 2.54 7.66 4.8 11.15 8.26 12.8 1.97.93 3.88 3.33 4.14 5.21.75 5.43 2.07 10.11 3.44 12.21.46.7.84 1.42.84 1.59 0 .67 3.02 3.02 4.63 3.6.94.33 1.94.73 2.23.88 1.25.66 4.04 6.74 5.14 11.18 1.4 5.63 2.71 7.32 7.63 9.75l3.18 1.57 1.1 2.74c.61 1.51 2.03 5.24 3.15 8.29 2.66 7.23 3.43 8.35 6.7 9.83 3.14 1.41 7.73-.69 9.44-4.3 1.35-2.87 4.8-5.25 8.98-6.23 5.2-1.21 6.25-2.4 7.03-7.93.6-4.31 4.45-13.5 6.08-14.56 5.13-3.29 7.23-6.59 8.62-13.53.67-3.4 2.91-6.97 5.5-8.79 4.13-2.89 5.7-5.06 8.76-12.18 3.09-7.15 4.49-9.48 6.36-10.56 3.9-2.27 6.14-5.79 7.37-11.56 1.26-5.92 4.03-10.75 7.29-12.73 2.96-1.8 6.05-7.53 7.9-14.68 1.28-4.94 3.04-7.03 6.56-7.77 4.2-.87 5.98-3.03 6.5-7.82.46-4.2 4.46-12.47 6.43-13.28 3.44-1.43 7.03-6.9 8.23-12.53 1.44-6.74 3.75-12.26 5.48-13.05 4.9-2.26 5.92-3.1 7.22-5.98.92-2 1.95-6.8 2.33-10.76.46-4.7 2.2-7.42 6-9.36 4.7-2.4 6.52-5.62 8.78-15.56 1.5-6.63 1.63-7.05 2.6-8.2a11 11 0 0 1 3.02-2.06c4.06-1.94 6.04-4.56 7.74-10.25 1.34-4.5 4.47-10.7 5.41-10.7.56 0 3.86-3.29 3.86-3.84 0-.2.37-.85.8-1.44 1.49-1.95 3.02-5.69 4.14-10.08 1.48-5.8 3.37-9.46 6.33-12.25a32.83 32.83 0 0 0 4.1-4.97c2.44-3.74 5.9-9.27 5.9-9.42 0-.07.63-1.22 1.38-2.56 1.46-2.58 1.38-2.22 2.96-13.36l.55-3.9-.85-.85c-.58-.58-2.12-1.21-4.84-2-7.44-2.17-10.17-2.56-18.02-2.57-3.9 0-9.93-.23-13.42-.5-3.5-.28-9.75-.5-13.9-.51-4.55 0-10.68-.28-15.44-.7-6.8-.58-10.82-.68-29.4-.68-16.98 0-22.79-.12-27.61-.55-8.02-.73-19.08-.56-56.88.86-4.52.17-9.25.1-13.9-.18-21.2-1.3-48.54-1.77-55.74-.96m41.2 2.7c4.36.28 10.61.77 13.9 1.07 6.21.58 15.16.5 23.66-.2 16.64-1.4 40.91-1.72 48.34-.64 4.98.72 6.88.79 30.02 1 22.7.2 25.1.29 29.67.96 3.9.57 6.64.73 12.7.73 5.44.01 9.48.21 13.72.7 4.14.47 8.23.68 13.2.68 10.37 0 13.37.84 15.62 4.33.9 1.42 1.97 5.79 2.26 9.28l.23 2.8-2.48 4.14c-2.59 4.34-6.45 9.84-9.2 13.13-2.4 2.85-4.07 6.09-5.73 11.1-2.45 7.36-3.76 9.86-7.07 13.4-2.97 3.2-5.93 8.72-7.37 13.76-1.25 4.4-3.27 7.09-7.93 10.56-3.77 2.8-4.43 4.04-6.35 11.92-2.1 8.6-3.73 11.54-7.5 13.49-2.77 1.42-6.44 6.93-7.16 10.72-.93 4.92-3.02 8.96-5.86 11.36-3.37 2.84-5.73 7.23-8.35 15.5-2.16 6.83-3.7 9.12-8.37 12.46-2.78 1.99-5 6.46-6.78 13.68-1.17 4.7-2.6 6.67-6.07 8.29-3.07 1.44-5.76 5.03-7.5 10.03a31.05 31.05 0 0 1-7.04 11.8c-3.28 3.51-5.44 7.6-7.02 13.27-1.62 5.82-3.5 8.82-7.6 12.05-3.71 2.95-4.2 3.77-8 13.14-2.2 5.43-2.78 6.28-6.11 9-2.75 2.25-5.56 6.65-6.92 10.83-1.44 4.46-2.54 6.22-6 9.6-4.18 4.09-5.4 6.46-7.9 15.35-1.91 6.81-2.86 8.14-6.95 9.71-5.51 2.13-7.67 3.6-10.78 7.36a13.57 13.57 0 0 1-2.93 2.72l-1.23.67-1.38-.96c-1.91-1.32-2.02-1.52-5.06-9.74-3.05-8.24-3.75-9.26-8.43-12.3-3.67-2.38-5.23-4.68-7.32-10.78-1.85-5.4-4.36-10.25-6.26-12.12l-3.25-3.21c-2-1.98-3.67-5.1-4.88-9.07-1.1-3.64-3-6.32-6.4-9.07-3.9-3.16-5.28-5.4-7-11.4-2.7-9.45-3.63-11.2-7.74-14.48a19.9 19.9 0 0 1-6.44-8.63c-2.1-5.73-4.95-9.5-8.95-11.91-2.64-1.59-4.9-7.57-6.37-16.82-.57-3.58-3.49-7.22-7.43-9.27-2.46-1.27-3.48-2.62-4.9-6.43-2.17-5.84-4.25-9.38-7.9-13.46-4.25-4.74-5.68-7.3-8.3-14.9-2.22-6.42-4.56-11.2-6.52-13.23-2.33-2.43-5.44-7.7-7.1-12-2.1-5.45-2.55-6.12-6.94-10.47-4.41-4.37-5.35-5.63-6.64-8.92-2.14-5.46-4.22-8.84-8.5-13.85-2.71-3.16-5.65-8.13-6.61-11.2-1.3-4.08-3.04-6.74-7.02-10.64-3.83-3.77-5.53-7.27-8.99-18.51-.74-2.4-2.53-5.63-5.25-9.43-4.29-6.03-4.26-5.88-2.41-13.22 1.12-4.46 2.27-7.28 3.05-7.52 4.05-1.21 28.1-3.61 36.4-3.62 5.31-.01 8.83-.2 12.53-.69 4.5-.59 8-.7 27.96-.86 22.5-.2 27.37-.43 34.3-1.69 1.83-.33 31.12.16 38.63.65m16.5 15.06a61.66 61.66 0 0 0-6.7 3.9c-4.9 3.59-9.02 5.65-16.33 8.2-6.4 2.25-9.67 4.07-13.74 7.65-3.5 3.09-13.23 8.95-14.85 8.95-.62 0-3.56 2.48-4.55 3.84-1.12 1.55-2.11 4.61-3.9 12.02-1.9 7.85-3.66 11.81-7.25 16.21-1.33 1.64-2.24 4.45-3.58 11.07l-1 4.9.66 1.9c.86 2.49 2.91 6.5 4.1 8.03 2.75 3.52 2.79 3.66 3.46 11.34.6 7 .64 7.17 2.3 11.69 3.58 9.66 4.07 12.16 5.94 30.14 1.02 9.81.88 9.53 5.5 11.35 5.49 2.17 10.55 6.07 13.07 10.07.6.96 1.9 2.62 2.88 3.7 2.79 3.05 8.46 10.8 8.96 12.24.1.3 1.02 2.35 2.02 4.55 1 2.2 2.19 5.2 2.62 6.68a27.36 27.36 0 0 0 2.2 5.1 49.14 49.14 0 0 1 4.27 9.71c1.55 4.89 4.1 6.27 15.62 8.47 4.2.8 18 .74 22.25-.1 10.81-2.16 12.75-3.33 14.06-8.47.33-1.32 1.2-4.49 1.93-7.03l1.33-4.63V207.16l1-1.45c2.6-3.8 3.95-4.57 13.41-7.72 5.32-1.77 6.6-2.33 7.93-3.47l1.59-1.36.23-3.18c.13-1.75.47-5.1.77-7.43.4-3.23.44-4.45.14-5.1a8.11 8.11 0 0 0-3.35-3.7l-1.24-.59-1.12 1.33c-.62.73-1.49 1.91-1.92 2.63-2.28 3.73-2.93 4.52-4.6 5.59-.99.63-2.91 1.46-4.28 1.83l-2.49.7-1.99-1.07a18.57 18.57 0 0 1-7.4-7.24c-.7-1.34-2.08-3.3-3.05-4.35a15.27 15.27 0 0 1-3.73-6.46l-.59-1.8 1.1-1.38a9.13 9.13 0 0 1 2.94-2.25c3.58-1.7 6.67-5.37 8.02-9.52 1.02-3.17 3.96-5.27 6.59-4.7 3.85.82 9.12 3.39 10.2 4.96.56.8 3.14 3.6 5.75 6.24 2.6 2.63 5.05 5.4 5.42 6.15 1.12 2.22 2.41 3.72 3.9 4.51l1.4.75.67-1.1c2.73-4.45 4.26-13.91 3.95-24.58-.22-7.62-.2-7.76.67-10.81 3.76-12.98 3.78-26.26.04-36.88-.67-1.91-1.12-4.46-1.73-9.93-1.57-13.91-3.3-21.03-5.6-23.05-2.82-2.48-5.9-4.43-10.88-6.88-4.24-2.08-5.28-2.77-7.94-5.22-4-3.71-5-4.36-12.1-7.83-3.3-1.62-6.88-3.49-7.97-4.15a19.69 19.69 0 0 0-3.95-1.78 68.16 68.16 0 0 1-7.11-3.08c-5.17-2.51-6.6-2.97-13.92-4.46-2.18-.45-4.34-.9-4.81-1.02-.63-.16-1.96.35-5.22 2m9.95 3.98c2.8.75 6.93 2.07 9.2 2.94 2.26.87 6.43 2.17 9.26 2.9a40.64 40.64 0 0 1 9.6 3.53c2.46 1.23 5.83 2.81 7.5 3.52 2.25.97 3.39 1.7 4.45 2.84 3.91 4.23 5.13 5.23 8.06 6.6 6.18 2.91 8.15 3.98 10.49 5.68l2.4 1.76 1.82 7.33c1.32 5.35 2.05 9.24 2.67 14.34.84 6.84.9 7.08 2.38 10.12a54.74 54.74 0 0 1 2.61 6.72l1.1 3.6-.06 7.72c-.07 8.6-.34 10.2-3.04 18.2l-1.34 3.93.35 7.2c.33 6.94.3 7.35-.46 10.97l-.8 3.76-1.4-1.69c-4.42-5.35-7.44-7.64-11.18-8.44-.95-.2-3.07-.91-4.71-1.57a58.18 58.18 0 0 0-7.11-2.16l-4.12-.95-1.69.85c-2.09 1.05-5.01 3.93-6.04 5.95a19.56 19.56 0 0 1-6.9 7.9c-2.24 1.52-5.43 5.53-5.44 6.83 0 2.82 3.04 10.88 4.92 13.03.41.47 1.13 1.61 1.6 2.54 2.44 4.78 9.46 9.13 14.76 9.13 3.11 0 8.07 1.46 9.5 2.81l.77.73-7 2.3c-9.68 3.17-12.07 4.82-14.01 9.68l-.87 2.15.35 7.07c.32 6.76.3 7.18-.4 9.77-.41 1.49-1.29 4.79-1.95 7.33-1.44 5.57-1.2 5.26-4.87 6.38-12.3 3.75-23.43 3.85-34.36.32-6.29-2.03-5.63-1.56-6.33-4.56a82.87 82.87 0 0 0-2.14-6.94c-1.74-4.87-1.95-5.75-2.5-10.3-.93-7.9-1.91-9.8-6.98-13.47-1.34-.97-3.01-2.78-5.12-5.56l-3.12-4.11-.42-3.62c-.69-5.88-1.58-7.1-5.7-7.83a9.24 9.24 0 0 1-2.95-1.01 11.2 11.2 0 0 0-2.22-1.12c-1.58-.56-1.62-.85-.17-1.3 2.32-.72 4.1-.75 10.8-.23l6.92.54 2.5-1.48c2.48-1.47 9.17-4.44 11-4.9 1.22-.3 3.59-2.94 4.97-5.53l1.08-2.03-.88-1.53a15.82 15.82 0 0 0-6.25-5.86c-2.53-1.4-4.61-3.28-8.35-7.57-2.8-3.21-3.6-3.51-11.76-4.42l-6.86-.77-2.91 1.38c-1.6.75-3.7 2-4.67 2.77l-1.76 1.4-1.9 5.77a246.5 246.5 0 0 0-2.34 7.32l-.42 1.54-.43-2.05c-.24-1.14-.77-4.3-1.18-7.04-.58-3.85-1.31-6.75-3.26-12.86l-2.5-7.9-.52-6.82-.52-6.83-1.38-2.77a32.44 32.44 0 0 0-3.2-5c-1-1.23-2.22-3.07-2.71-4.1l-.9-1.85.84-3.63a44.06 44.06 0 0 1 5.16-12.26c1.8-2.76 3.04-6.2 4.92-13.64 3.54-14.02 3.81-14.56 8.3-16.34 6.72-2.65 13.11-6.45 17.05-10.12 3.62-3.38 6.5-4.94 12.29-6.7a83.14 83.14 0 0 0 7.26-2.57c1.6-.69 4.2-1.78 5.8-2.42 3-1.21 5.3-2.44 7.1-3.8 4.09-3.09 4.27-3.11 10.32-1.5m-41.75 114.42c2.93.47 5.86.94 6.53 1.06 1.1.2 1.31.43 2.5 2.9a16.51 16.51 0 0 0 11.47 8.95c2.55.6 3.82 2.32 2.85 3.89-.85 1.37-1.6 1.72-5.5 2.6-1.8.41-4.97 1.37-7.04 2.13-10.42 3.82-21.46 3.28-24.74-1.2-2.26-3.1-2.3-4.16-.34-9.42 4.6-12.27 4.8-12.42 14.27-10.9m43.74 36.97c-12.23 1.76-13.13 2.6-16.63 15.4l-1.76 6.4 1 2.17c1.6 3.5 4.26 5.7 8.48 6.96 1.94.59 15.76-.46 18-1.37 6.49-2.6 7.88-5.15 8.14-14.87.4-14.74-2.1-16.87-17.23-14.69m8.92 2.86c1.13.54 2.47 1.55 3.29 2.5l1.37 1.57-.22 7.38-.23 7.38-1.42 1.48c-.78.82-2.11 1.98-2.96 2.57l-1.54 1.08-7.36.4-7.35.4-1.4-.88c-1.84-1.16-5-4.42-5-5.16 0-.32.8-3.67 1.77-7.44 2.45-9.51 1.84-9 13.33-11.17 6.21-1.18 5.48-1.17 7.72-.1"/><path fill="#a19604" d="M133.1 14.6c-6.93 1.26-11.8 1.5-34.3 1.69-19.96.16-23.46.27-27.96.86-3.7.49-7.22.68-12.52.69-8.31 0-32.36 2.4-36.41 3.63-.79.23-1.93 3.05-3.05 7.51-1.85 7.34-1.88 7.2 2.41 13.22 2.72 3.8 4.51 7.03 5.25 9.43 3.46 11.24 5.16 14.74 9 18.5 3.97 3.91 5.72 6.57 7 10.66.97 3.06 3.9 8.03 6.61 11.2 4.3 5 6.37 8.38 8.5 13.84 1.3 3.29 2.24 4.55 6.65 8.92 4.4 4.35 4.83 5.02 6.94 10.46 1.66 4.31 4.77 9.58 7.1 12.01 1.96 2.04 4.3 6.8 6.52 13.23 2.62 7.6 4.05 10.16 8.3 14.9 3.65 4.08 5.73 7.62 7.9 13.46 1.42 3.81 2.44 5.16 4.9 6.43 3.94 2.05 6.86 5.7 7.43 9.27 1.47 9.25 3.73 15.23 6.37 16.82 4 2.4 6.85 6.18 8.95 11.9a19.9 19.9 0 0 0 6.44 8.64c4.11 3.28 5.05 5.03 7.75 14.48 1.71 6 3.08 8.24 7 11.4 3.4 2.75 5.3 5.43 6.4 9.07 1.2 3.97 2.88 7.1 4.87 9.07l3.25 3.2c1.9 1.88 4.4 6.73 6.26 12.13 2.1 6.1 3.65 8.4 7.32 10.78 4.69 3.04 5.38 4.06 8.43 12.3 3.04 8.22 3.15 8.42 5.06 9.74l1.38.96 1.23-.67c.68-.36 2-1.58 2.93-2.72 3.1-3.76 5.27-5.23 10.78-7.36 4.1-1.57 5.04-2.9 6.96-9.7 2.5-8.9 3.71-11.27 7.89-15.36 3.46-3.38 4.56-5.14 6-9.6 1.36-4.18 4.17-8.58 6.92-10.83 3.33-2.72 3.9-3.57 6.1-9 3.8-9.37 4.3-10.19 8.02-13.14 4.08-3.23 5.97-6.23 7.59-12.05 1.58-5.67 3.74-9.76 7.02-13.28a31.05 31.05 0 0 0 7.03-11.8c1.75-5 4.44-8.58 7.51-10.02 3.47-1.62 4.9-3.59 6.07-8.3 1.78-7.2 4-11.68 6.78-13.67 4.67-3.34 6.21-5.63 8.37-12.45 2.62-8.28 4.98-12.67 8.35-15.5 2.84-2.4 4.93-6.45 5.86-11.38.72-3.78 4.4-9.28 7.16-10.71 3.77-1.95 5.4-4.88 7.5-13.49 1.92-7.88 2.58-9.12 6.35-11.92 4.66-3.47 6.68-6.16 7.93-10.56 1.44-5.04 4.4-10.56 7.37-13.75 3.31-3.55 4.62-6.05 7.07-13.42 1.66-5 3.33-8.24 5.73-11.1 2.75-3.28 6.61-8.78 9.2-13.12l2.48-4.14-.23-2.8a42.08 42.08 0 0 0-.9-5.5c-1.7-6.82-4.39-8.1-16.97-8.1-4.98 0-9.07-.22-13.21-.7-4.24-.48-8.28-.68-13.72-.69-6.06 0-8.8-.16-12.7-.73-4.57-.67-6.97-.75-29.67-.96-23.14-.21-25.04-.28-30.02-1-7.43-1.08-31.7-.77-48.34.63-8.5.71-17.45.8-23.66.21-13.94-1.3-48.55-2.44-52.53-1.72m38.72 2.88a515.4 515.4 0 0 1 15.1 1.4c6.52.76 9.54.69 23.89-.54 26.23-2.24 41.8-2.2 52.05.18.87.2 10.33.34 23.42.34l21.95.01 5.66.9c4.64.74 7.44.95 15.44 1.15 7.13.18 10.38.4 12 .8 4.67 1.15 9.2 1.6 16.1 1.6h6.83l1.77 1.4c2.21 1.75 3.98 4.5 5.23 8.1l.96 2.79-2.17 3.55c-2.74 4.48-5.42 8.25-7.25 10.24-3.24 3.51-4.78 6.5-7 13.55-1.73 5.5-3.83 9.23-7.1 12.61-3.61 3.74-6.03 8.62-7.57 15.3-.83 3.56-3.09 6.61-6.52 8.8-4.02 2.58-6.11 5.72-7.42 11.15-2.85 11.8-2.87 11.82-7.16 14.76-3.52 2.41-6.35 6.5-7.64 11.02-1.28 4.47-3.46 8.14-6.42 10.82-3.15 2.84-5.73 8.17-7.69 15.85-1.23 4.85-4.01 8.9-7.3 10.66-5.3 2.84-7.21 6.18-8.5 14.94-.76 5.13-1.52 6.4-4.93 8.19-4.13 2.17-6.8 5.38-7.78 9.34-.87 3.54-3.86 8.52-7.22 12-3.88 4.02-5.58 7.5-7.17 14.67-1.19 5.34-3.64 9.3-6.74 10.9-4.21 2.14-7.08 6.77-11.08 17.9-.75 2.1-1.24 2.9-2.18 3.6a24.65 24.65 0 0 0-8.44 12.24c-1.3 3.97-2.66 6.07-6.22 9.6-4.97 4.93-5.58 6.14-8.06 16.03-1.65 6.58-2.62 7.73-8.06 9.55-5.06 1.68-8.63 4.4-10.47 7.96-1.32 2.56-1.61 2.17-4.6-6.09-3.35-9.33-4.76-11.51-9.22-14.29-4.04-2.52-6.3-5.5-7.38-9.74-1.81-7.16-4.23-11.81-8.23-15.85-3.2-3.23-4.38-5.03-6.4-9.86-1.59-3.77-3.16-6.08-5.37-7.9-5.71-4.68-6.51-5.76-7.32-9.8-2-9.94-4.42-14.72-8.97-17.65-2.92-1.89-5.21-5.19-7.13-10.3-1.27-3.36-3.71-6.83-6.13-8.68-1.13-.88-2.42-1.9-2.87-2.28-.98-.83-2.07-4-3.9-11.29-2.09-8.28-3.69-10.92-8.25-13.63-3.06-1.82-4.2-3.22-5.32-6.62-2.11-6.38-4.8-11-8.67-14.85-4-4.01-6-7.65-8.09-14.67-1.62-5.5-4.06-10.4-6.5-13.1-2.68-2.96-5.23-7.15-7.22-11.89-2.04-4.84-4.34-8.03-7.15-9.94-2.82-1.92-4.43-4.21-5.9-8.45-2.2-6.33-4.4-10-8.38-14.07-2.91-2.96-4.6-5.73-7.25-11.89-2.28-5.3-3.89-7.6-7.04-10.08-2.92-2.3-2.95-2.34-5.97-11.25-4.13-12.17-4.9-13.81-8.63-18.12C20 35.98 20.02 36 20.8 33.21c1.34-4.77 8.45-8.96 17.62-10.4 1.98-.32 4.53-.8 5.66-1.1 1.44-.35 5.06-.59 12-.78 8.12-.21 11-.43 15.62-1.16 5.38-.85 6.34-.9 19.55-.93 21.76-.06 31.8-.45 37.74-1.49 6.44-1.12 27.55-1.06 42.83.13m16.92 8.07c-7.56 2.75-11 4.9-13.46 8.4-1.69 2.4-5.24 4.3-12.84 6.87-7.15 2.4-10.72 4.41-14.07 7.9-2.07 2.17-5.44 4.43-10.18 6.87-8.48 4.34-9.5 5.95-12.32 19.54-.9 4.29-3.06 9.21-5.01 11.37-4.3 4.78-4.58 5.5-6.27 16.3l-.7 4.5 1.17 3.6c1.38 4.2 2.54 6.63 4.3 9 1.38 1.84 2.04 5 2.6 12.52.2 2.48.52 3.62 2.2 7.72 3.86 9.36 4.8 14.9 5.38 31.9l.22 6.52 1.05 1.46c1.23 1.72 3.8 3.75 6.3 4.98 4.97 2.45 8.78 5.93 16.07 14.66 4.57 5.47 5.33 6.75 7.1 11.95 2.3 6.79 3.42 9.25 5.4 11.91a54.9 54.9 0 0 1 5.7 10.61 15.86 15.86 0 0 0 4.5 6.06c5.7 4.55 26.55 6.02 42.28 2.99 6.14-1.18 9.48-4.02 10.82-9.18.3-1.18 1.25-4.39 2.1-7.13l1.55-5 .2-7.4.21-7.41 1.24-1.3c1.26-1.33 1.77-1.54 12.48-5.25 7.65-2.66 9.97-4.89 11.38-10.97 1.7-7.33 3.38-10.97 6.12-13.31 5-4.28 7.74-16.82 7.22-33.12-.22-6.84-.2-7.22.66-10.86a87.11 87.11 0 0 0 .42-36.71c-.45-2.08-1.14-6.55-1.53-9.95-1.11-9.6-2.68-19.05-3.5-21.18-1.14-2.9-9.24-8.58-15.65-10.95-1.82-.67-5.9-3.2-5.92-3.68-.02-.38-2.55-2.98-3.95-4.06-.77-.6-3.8-2.23-6.75-3.63-7.44-3.56-11.52-6.05-12.79-7.8-1.76-2.45-11.45-6.8-18.22-8.17-10-2.04-11.32-2.09-15.5-.57m9.51 3.78c7.32 1.49 8.75 1.95 13.92 4.46a68.16 68.16 0 0 0 7.11 3.08c1.09.31 2.86 1.11 3.95 1.78 1.09.66 4.68 2.53 7.98 4.15 7.1 3.48 8.08 4.12 12.1 7.83 2.65 2.45 3.7 3.14 7.93 5.22 4.97 2.45 8.06 4.4 10.87 6.88 2.3 2.02 4.04 9.14 5.6 23.05.62 5.47 1.07 8.02 1.74 9.93 3.74 10.63 3.72 23.9-.04 36.88-.88 3.05-.89 3.19-.67 10.8.3 10.68-1.22 20.14-3.95 24.6l-.68 1.09-1.4-.75c-1.48-.8-2.77-2.29-3.89-4.52-.37-.75-2.82-3.51-5.42-6.14a82.65 82.65 0 0 1-5.74-6.24c-1.09-1.57-6.36-4.14-10.21-4.96-2.63-.57-5.57 1.53-6.6 4.7-1.34 4.15-4.43 7.83-8.01 9.52a9.13 9.13 0 0 0-2.95 2.25l-1.09 1.38.6 1.8c.92 2.85 1.82 4.4 3.72 6.46.97 1.05 2.34 3.01 3.05 4.35a18.57 18.57 0 0 0 7.4 7.24l2 1.06 2.48-.69c1.37-.37 3.3-1.2 4.28-1.83 1.67-1.07 2.31-1.86 4.6-5.6.43-.7 1.3-1.9 1.92-2.62l1.12-1.33 1.24.59a8.11 8.11 0 0 1 3.35 3.7c.3.65.26 1.87-.14 5.1-.3 2.33-.64 5.68-.77 7.43l-.23 3.18-1.59 1.36c-1.33 1.14-2.6 1.7-7.93 3.47-9.46 3.15-10.8 3.93-13.41 7.72l-1 1.45V221.79l-1.33 4.63c-.73 2.54-1.6 5.7-1.93 7.03-1.3 5.14-3.25 6.3-14.06 8.46-4.25.85-18.04.92-22.25.11-11.52-2.2-14.07-3.58-15.62-8.47a49.14 49.14 0 0 0-4.28-9.7 27.36 27.36 0 0 1-2.2-5.1 62.51 62.51 0 0 0-2.6-6.7c-1.01-2.2-1.92-4.24-2.03-4.54-.5-1.44-6.17-9.19-8.96-12.24a32.5 32.5 0 0 1-2.88-3.7c-2.52-4-7.58-7.9-13.06-10.07-4.63-1.82-4.5-1.54-5.51-11.35-1.87-17.98-2.36-20.48-5.93-30.14-1.67-4.52-1.7-4.69-2.31-11.69-.67-7.68-.71-7.82-3.46-11.34-1.19-1.52-3.24-5.54-4.1-8.02l-.65-1.9.99-4.9c1.34-6.63 2.25-9.44 3.58-11.08 3.59-4.4 5.36-8.36 7.25-16.21 1.79-7.4 2.78-10.47 3.9-12.02.99-1.36 3.93-3.84 4.55-3.84 1.62 0 11.35-5.86 14.85-8.95 4.07-3.58 7.34-5.4 13.74-7.64 7.31-2.56 11.42-4.62 16.33-8.2 3.41-2.5 10.85-6.18 11.92-5.91.47.11 2.63.57 4.81 1.02m-50.4 119.64c-2.04 1.24-2.48 2.06-5.7 10.65-1.96 5.26-1.92 6.32.34 9.42 3.28 4.48 14.32 5.02 24.74 1.2a69.72 69.72 0 0 1 7.03-2.12c3.9-.89 4.66-1.24 5.5-2.61.98-1.57-.3-3.3-2.84-3.89a16.51 16.51 0 0 1-11.47-8.96c-1.19-2.46-1.4-2.7-2.5-2.9-12.44-2.14-12.82-2.16-15.1-.79m91.12.62c1.16.5 1.48.84 1.68 1.76.78 3.7 3.9 7.83 8.02 10.63 3.53 2.4 3.53 2.7.02 4.55-3.7 1.94-7.29 6.84-8.07 10.97-.23 1.27-3.5 3.97-4.78 3.97-.93 0-4.29-2.78-4.29-3.56 0-4.08-3.95-10.38-7.86-12.51l-1.86-1.02 1.51-.4c6.11-1.57 8.97-4.76 10-11.12.68-4.2 1.85-4.89 5.63-3.27m-85.07 4.56a63.96 63.96 0 0 1 6.98 5.4c2.17 1.93 4.63 3.81 5.47 4.19l1.52.67-2.44.62c-1.34.34-2.88.84-3.4 1.1-1.27.63-5.35 1.8-9.11 2.62l-3 .65-1.48-.95c-1.68-1.06-3.68-3.32-3.68-4.14 0-.77 3.1-8.36 4.62-11.29.67-1.3.56-1.32 4.52 1.13m47.46 34.5c-11.5 2.19-10.88 1.67-13.33 11.18a113.6 113.6 0 0 0-1.76 7.44c0 .74 3.15 4 5 5.16l1.39.88 7.35-.4 7.36-.4 1.54-1.08c.85-.6 2.18-1.75 2.96-2.57l1.42-1.48.23-7.38.22-7.38-1.37-1.58c-1.28-1.47-4.57-3.44-5.61-3.36-.24.02-2.66.46-5.4.98m8.42 3.47l.84.88-.4 7-.4 7.02-1.27 1.23-1.27 1.23-7.33.23-7.32.23-1.38-1.38-1.38-1.37 1.43-5.64c1.05-4.15 1.7-6.02 2.45-7.13l1.04-1.5 5.09-1.14c2.8-.63 5.55-1.25 6.11-1.4 1.16-.27 2.42.3 3.8 1.74"/><path fill="#f9f704" d="M133.82 21.02c-1.2.28-1.92.64-2.06 1.03-.53 1.52-4.03 4.49-7.03 5.95l-3.07 1.5H99.98c-17.75 0-22.18.1-24.39.51-5.62 1.07-11.97 1.54-20.7 1.56-4.81 0-11.11.15-14 .32-5.6.33-5.7.35-8.5 2.61l-1.4 1.13.99 2.96a52.7 52.7 0 0 1 1.64 7.32c.91 6.18 1.74 8.3 3.64 9.3 2.12 1.13 4.77 4.08 6.08 6.78a47.4 47.4 0 0 0 2.23 4.05c1.34 2.08 2.2 4.72 2.95 9.2.73 4.25 1.04 4.94 2.38 5.23 6.73 1.48 10.15 6.12 13.02 17.64.11.47 1.18 1.88 2.36 3.12a21.58 21.58 0 0 1 3.12 4.18c.53 1.06 1.25 2.02 1.61 2.14 2.55.8 4.84 5.3 5.85 11.49.56 3.37 1.45 5.02 2.86 5.29 4.45.85 7.76 4.28 9.3 9.63l1.04 3.66c.26.89.8 3.74 1.2 6.35 1.1 7.01 1.17 7.22 2.48 7.5 6.17 1.33 9.68 5.2 12.23 13.47.94 3.05 1.22 3.58 2.02 3.89 4.24 1.65 6.93 3.13 8.24 4.51l1.98 2.08c2.11 2.2 2.2 2.63 2.43 10.69.22 8.32.25 8.4 2.77 9.16 4.5 1.33 6.39 3.83 7 9.23.23 2.07.53 3.06 1.34 4.32 1.23 1.95 2.52 6.06 3.1 9.88.5 3.35.57 3.43 3.65 3.87 6.7.96 8.68 3.08 10.04 10.7 1.5 8.48 1.38 8.01 2.5 8.75 1.39.91 3.14 3.51 4.05 6.01.55 1.51 1.05 2.24 2 2.9 3.02 2.09 4.5 4.65 5.56 9.64 1.1 5.14 1.07 5.1 3.32 5.8 6.1 1.9 8.1 4.5 10.16 13.29.67 2.85 2.25 12.16 2.26 13.35 0 .11 1.12.48 2.49.81 6.82 1.65 9.95 4.38 11.38 9.93.51 1.96 1.05 2.74 1.64 2.38.15-.1.88-.23 1.61-.3.74-.06 2-.21 2.83-.33 3.3-.46 3.96-.54 5.6-.7 3.26-.33 3.16-.25 3.6-3 2.6-16.06 5-20.32 12.4-21.91 1.89-.4 1.89-.4 2.39-4.52.45-3.68 1.34-7.4 2.3-9.53.38-.84 1.03-2.96 1.45-4.71 1-4.15 2.9-8.1 4.72-9.73 1-.91 1.29-1.36 1-1.59-1.55-1.22-7.54-1.67-14.33-1.08-6.78.59-25.28.47-32.9-.2-13.32-1.2-16.87-3.26-18.53-10.8-.58-2.63-1.8-4.45-3-4.47-1.87-.03-5.67-1.56-6.89-2.76-2.23-2.22-3.39-6.39-5.64-20.34-.27-1.7-.63-2.82-.94-2.99-.28-.15-1.74-.84-3.24-1.53-4.4-2.05-7.32-5.58-8.96-10.84-.75-2.42-1.07-2.59-5.69-3-9.1-.8-10.52-3.85-9.46-20.32.58-8.88.36-21.47-.4-22.98-.27-.54-1.14-1.21-2.19-1.68-5.72-2.59-7.67-6.74-8.36-17.83-.26-4.25-.71-8.96-1-10.47-.78-4.12-1.45-11.35-1.3-14.06 1.02-17.4 1.81-20.8 5.76-24.7.95-.95 2.18-2.38 2.72-3.18.55-.8 1.67-2.07 2.5-2.83l1.5-1.39 1.2-5.9c2.3-11.36 3.9-13.52 10.86-14.71 3.3-.56 4.16-1.24 5.05-3.93 2.04-6.23 6.13-9.05 16.45-11.34 3.47-.77 3.64-1 4.13-5.72.29-2.86.54-3.71 1.86-6.35l1.52-3.04-4.5-.22c-9.83-.49-22.3-.55-24.2-.13m103.36.16l-3.47.11.16 7.1c.2 8.44-.07 7.95 4.86 8.78 3.88.65 7.48 1.95 9.66 3.49.86.6 2.63 1.62 3.93 2.26 2.4 1.18 6.75 5.08 7.18 6.42.23.73 2.88 2.03 7.12 3.5 7.32 2.54 9.08 6.34 10.4 22.46.41 4.95 1.54 11.93 2 12.32.6.51 2.05 2.88 2.6 4.24.65 1.59-.14 15.9-1.17 21.52a363.34 363.34 0 0 0-1.88 10.63c-.8 5.23-1.12 11.76-1.29 25.63-.18 14.77-.1 16.23.93 18.95l.34.9 1.8-1.2c2.19-1.45 5.19-2.4 9.45-2.98 2.77-.38 3.2-.53 3.32-1.14.07-.39.38-2.79.7-5.34.53-4.29 2.01-11.17 2.9-13.52 1.22-3.18 4.24-5.77 8.2-7.04 2.76-.89 2.9-1.1 3.47-5.03.73-5.04 2.42-9.16 4.45-10.87a12.4 12.4 0 0 0 2.07-2.9c1.13-2.14 4.06-5.33 5.63-6.16 1.03-.54 1.29-1.3 2.77-8.16 1.66-7.73 3.95-10.3 10.24-11.46 2.66-.49 2.51-.28 2.78-3.83 1.06-14.1 4.33-20.8 11.23-23.03 2.9-.93 3.15-1.3 3.7-5.6 1.81-14.08 4.6-20.04 10.36-22.1 5.95-2.14 5.35-5.6-1.07-6.2-7.92-.71-15.55-1.08-28.65-1.37-13.04-.28-16.24-.52-22.64-1.7-.94-.17-11.53-.33-23.52-.34l-21.81-.02-3.06-1.5c-2.99-1.45-7.35-5.16-7.35-6.24 0-.8-4.45-.96-16.34-.58m11.88 185.77l-.86.44-.25 8.4c-.14 4.62-.41 8.75-.6 9.18a5.2 5.2 0 0 0-.35 1.76c0 1.25-2.37 3.97-3.87 4.45-1.24.38-2.58.62-5.47.94l-1.96.22-.57 1.73c-.45 1.35-.53 2.47-.38 5.18.19 3.47.88 6.28 1.18 4.83.9-4.37 4.05-6.6 10.63-7.51 3.91-.54 3.4.42 3.85-7.24 1.15-19.55 1.7-20.95 8.6-21.67 3.02-.31 2.87-.8-.24-.82-1.47 0-4.07-.09-5.77-.18-2.16-.12-3.34-.03-3.94.28"/><path fill="#4c4c04" d="M0 7.55c0 .2 1.43.34 3.6.34 2.18 0 3.6-.14 3.6-.34 0-.21-1.42-.35-3.6-.35-2.17 0-3.6.14-3.6.35m127.61 1.47c-.1.1-17 .28-37.56.39-20.57.1-41.17.35-45.8.54-9.35.38-18.84.94-20.4 1.2-.57.09-3.89.25-7.37.36-3.68.11-6.52.35-6.78.56-.31.26-.57.25-.9-.02-.6-.5-1.02-.07-.52.53.28.33.28.46 0 .46-.21 0-.38.34-.38.77 0 .42-.09 2.24-.2 4.03-.16 2.68-.04 4.02.67 7.55.47 2.35 1.1 6.83 1.4 9.94.68 7.31 1.31 11.1 2.19 13.11.38.9.8 2.13.92 2.75.29 1.47 2.5 4.68 3.59 5.23 1.8.9 3.29 1.5 4.15 1.7 1.22.26 2.79 4.8 3.4 9.8.78 6.54 2.07 8.68 6.1 10.17 1.35.5 2.38 1.02 2.3 1.16-.1.14.47.67 1.24 1.19.78.5 1.3.72 1.15.47-.16-.28-.03-.25.32.08.33.31.86 1.92 1.24 3.77a56.89 56.89 0 0 0 1.5 5.7c.46 1.35.95 3.6 1.08 4.97.23 2.45.38 3.8.6 5.32.39 2.62 2.77 3.75 8.14 3.84l2.24.04.74 1.46c.4.8.99 3.08 1.3 5.06.88 5.55 2.6 8.59 5.54 9.82.64.26 1.15.63 1.15.82 0 .71.07.87.6 1.45.3.33.42.6.27.6-.15 0 .4.73 1.23 1.63.83.9 1.62 1.6 1.76 1.55.14-.05.26.09.26.31s.1.3.21.19c.5-.5 1.23.98 2.38 4.76l1.22 4.04-.21 5.34c-.12 2.94-.21 5.68-.2 6.1.01.4-.14.84-.33.96-.18.12-.23.4-.1.62.12.22.1.3-.04.16-1.12-1-1.37 4-.32 6.42.43.98.45.92.5-1.38.06-1.97.11-2.18.32-1.2.14.66.28 1.05.3.86.04-.19.29.05.56.52l.49.85.02-1.03c.02-.92.07-.97.48-.42.57.75.9.76.9.04 0-.45.09-.48.5-.13.33.26.52.29.52.07 0-.66 1.2-.64 2.18.04.76.52 1.04.58 1.25.24.15-.24.44-.33.65-.2.21.13.4.03.4-.22.02-.24.16-.14.33.24.16.38.3.5.31.27.02-.3.26-.33.89-.1.56.22.85.21.85-.02 0-.28 1.04.06 1.63.53.05.04.25.98.45 2.1.2 1.11.64 3.42 1 5.11.37 1.7.73 4.87.8 7.05.15 3.88.43 4.96 1.7 6.53.57.72 2.06 1 6.6 1.21 4.28.2 4.46.31 4.78 2.82.28 2.15-.03 10.23-.47 12.1-.49 2.12-.4 20.5.08 18.75.2-.7.5-1.29.65-1.29.15 0 .28-.24.28-.53 0-.3-.14-.45-.3-.35-.59.36-.73-.9-.68-5.92.04-4.83.06-4.92.34-2.29.16 1.51.43 3.6.6 4.63l.3 1.89.07-2.75c.03-1.5.15-2.5.24-2.22.2.57.84 2.14 1.4 3.43.38.85.38.84.4-.26.04-1.3.42-1.42 1.17-.34l.54.77.02-1 .02-1 .82.77c.75.7.84.72.95.17.1-.57.15-.57.69-.03.71.7.97.73.97.06 0-.6.3-.64 1.02-.19.33.21.59.19.74-.06.18-.3.38-.28.74.02.4.33.55.3.72-.13.17-.46.29-.48.7-.1l1.04.9c.57.48.56.38.69 9.34.06 4.48.19 5.97.5 5.9.23-.05.32.06.21.24-.45.73 1.5.91 11.22 1.03l2.31.03.02 9.86-.01 10.86a2.7 2.7 0 0 0 .55 1.63c.54.6.54.63 0 .63-.33 0-.5.15-.4.33.12.18.44.24.73.13.32-.12.48-.02.41.27-.06.3.23.49.76.51.47.02.98.08 1.12.14.14.05 1.41.14 2.83.19 1.41.04 2.69.1 2.83.14.14.03 1.35.04 2.69.01l2.43-.04.76 2.08c.42 1.14 1 3.66 1.28 5.6.87 5.8 2.07 8.44 4.6 10.03 1.25.8 1.45 1.25.92 2.11-.14.22-.28.8-.32 1.29-.04.48-.16.88-.27.88-.1 0-.22.34-.25.75-.03.4-.25.85-.47 1-.23.13-.44.55-.47.93a4.2 4.2 0 0 1-.64 1.57c-.32.5-.47.9-.32.91.14 0-.01.17-.34.37-.34.19-.54.47-.44.62.09.15-.21.63-.67 1.06-.46.43-.76.92-.65 1.09.1.16.06.25-.1.2-.16-.05-.77.42-1.37 1.04l-1.08 1.14.03 5.13c.02 2.81.17 5.12.33 5.12s.2.5.1 1.12c-.3 1.74 1.06 2.89 2.94 2.47.57-.12 1.22-.06 1.45.13.53.44 8.23.26 12.07-.27 1.51-.21 4.69-.46 7.06-.56l4.31-.17.39.84c.35.8-.03 7.3-.46 7.72-.08.09-.15-.02-.15-.24s-.23-.4-.51-.4a.52.52 0 0 0-.52.51c0 .71-.44.64-1.01-.15-.45-.62-.52-.63-.93-.09-.24.32-.44.4-.45.19 0-.27-.38-.3-1.21-.12-.68.15-1.2.14-1.2-.04 0-.61-.72-.29-1.02.47-.28.68-.31.7-.33.1-.02-.52-.12-.58-.44-.26-.57.57-.88.52-1.06-.19-.1-.36-.2-.2-.25.43l-.08 1.03-.21-1.16-.22-1.15-.9.9c-1.01 1.02-1.3.76-1.36-1.27-.03-1.02-.06-1-.48.45-.31 1.08-.46 1.3-.48.7-.03-.64-.13-.74-.44-.43-.54.54-.8 16-.26 15.67.25-.15.3.17.14.99-.59 3.14 1.04 4.78 4.96 4.97 5.01.25 8.89.24 8.73-.02-.1-.15 0-.26.22-.26.2 0 .31-.12.23-.26-.09-.14.37-.76 1-1.37.64-.6 1.17-1 1.17-.9 0 .12.24 0 .55-.25.59-.5.76-.55 2.45-.87.61-.11 1.11-.32 1.11-.46 0-.13.5-.27 1.12-.3 1.5-.08 3.78-.3 4.2-.4 2.2-.52 4.17 3.26 4.37 8.35.04 1.3.2 2.42.35 2.51.15.1.2.29.1.43-.47.76.6 2.83 1.88 3.64 2.81 1.78 19.6 2.02 22.2.32.8-.53 1.11-1.08.35-.62-.34.2-.34.15-.01-.26.24-.3.49-2.18.6-4.6.24-5.03-.36-4.59 6.28-4.66 3.07-.03 5.66-.19 5.76-.35a.7.7 0 0 1 .53-.3c.19 0 .25.16.13.34-.12.2-.05.35.14.35.66 0 .95-2.23 1.03-8.02.08-6.64.47-8.27 2.03-8.52 1.25-.2 9.69-.02 9.92.22.11.1.4.02.64-.18.34-.28.72-.19 1.5.36.56.41 1.19.65 1.38.53.52-.32.4.05-.2.66-.49.5-.38.54 1.22.54 1.09 0 1.68-.13 1.55-.34-.3-.48.19-.41 1.2.17a6.5 6.5 0 0 0 2.75.45l1.88-.04-1.54-.24c-.85-.13-1.31-.27-1.03-.3.46-.05.46-.1 0-.42-.41-.3-.38-.33.17-.13 1.4.5 2.23.58 2.23.2 0-.23.32-.32.77-.2.86.2 3-.94 3-1.6 0-.23-.35-.08-.79.33-.44.41-.92.75-1.07.75-.16 0 .16-.35.7-.77a3.97 3.97 0 0 1 1.33-.78c.2 0 .34-.34.32-.76-.01-.4.13-.65.31-.54.2.13.24-.16.1-.73-.17-.69-.13-.87.17-.69.3.19.36-.03.2-.81-.12-.59-.07-1.16.1-1.26.17-.1.37.39.44 1.1.1 1 .15.87.2-.62.03-1.22-.13-2.14-.45-2.57-.58-.76-.7-1.67-.18-1.35.2.13.34-.34.34-1.18 0-1.49-.04-1.51-2.5-1.46-.56.01-.86-.12-.72-.33.14-.24 0-.24-.46 0-.48.26-.79.25-1.07-.03-.21-.21-1.1-.45-1.98-.52-.88-.07-2-.29-2.5-.47-.49-.2-.95-.32-1.02-.3-.08.04-.27-.14-.43-.4-.25-.38-.35-.38-.6.01-.22.34-.36.36-.55.06-.13-.22-.6-.53-1.04-.7-.85-.32-.75.28-1.39-8.94-.2-3.04.13-3.54 2.56-3.85 5.27-.67 9.17-4.58 10.33-10.36 1.15-5.71 1.5-6 7.42-6 3.13 0 4.25-.12 4.56-.49.21-.26.94-.58 1.6-.7.88-.17 1.13-.34.89-.64-.21-.26-.2-.71.03-1.26.58-1.38.8-11.48.38-18.39-.35-6.02.13-6.49 6.96-6.78 1.92-.08 3.7-.27 3.94-.43.25-.16.67-.32.92-.35 1.35-.21 2.16-2.4 2.32-6.3.07-1.8.37-4.73.67-6.52l.7-4.37c.13-.82.35-1.12.84-1.12.4 0 .68-.24.7-.6.01-.33.1-.41.2-.19.08.23.38.32.65.22.32-.12.5.03.5.43 0 .57.03.57.5-.05.33-.44.5-.51.51-.2.01.37.12.39.5.07.34-.28.55-.3.71-.02.17.27.37.26.72-.03.38-.3.49-.3.5.07 0 .28.28.11.67-.38.58-.75.67-.78.68-.22 0 .53.1.57.52.22.43-.36.52-.32.52.21 0 .54.06.56.34.13.26-.41.33-.34.35.34l.01.86.64-.76c.34-.41.72-.66.84-.54s.23-.16.24-.62c.02-.76.05-.77.3-.14.26.64.29.63.44-.17.1-.47.2.15.24 1.37.08 2.34.6 2.1.73-.34.05-.93.15-.7.45 1.03l.38 2.23.22-3.6c.12-1.98.24-4.1.26-4.7.04-.91.2-1.12.99-1.24.8-.12.77-.13-.14-.1-1.4.07-1.48-.42-1.49-8.27 0-6.72.21-7.62 1.85-7.7a193 193 0 0 1 9.38.08c.2.13.84.23 1.82.27.58.02.97.18.87.35-.28.45 1.58.71 2.31.32.77-.41 1.28-.04.57.42-.34.2.35.31 2.07.31 1.91 0 2.42-.1 1.97-.35-.9-.53-.74-1.1.17-.61 3.93 2.13 8.26-.46 7.53-4.51-.39-2.18-.27-2.65.25-.98.32 1 .34.88.22-1.04-.07-1.2-.3-2.35-.5-2.55-.46-.45-.5-1.04-.08-.77.9.55 1.1-12.9.22-14.07-.45-.6-.5-.25-.56 3.45-.04 2.93-.12 3.65-.28 2.5-.33-2.36-.7-2.4-.75-.06-.02 1.11-.12 1.73-.2 1.36-.37-1.4-1.13-1.72-1.15-.47l-.01 1.13-.47-1.3c-.66-1.84-.87-1.93-.9-.38-.02 1.2-.06 1.26-.38.59-.4-.83-1.31-1.34-1.31-.73 0 .21-.3.1-.69-.23-.66-.6-.68-.6-.68.16 0 .78 0 .78-.71-.12-.81-1.02-1.35-1.16-1.35-.34 0 .45-.1.47-.51.13-.43-.36-.52-.33-.52.15 0 .51-.11.5-.92-.14-.7-.55-.98-.62-1.18-.28-.58.93-.94-.38-1.25-4.54-.45-6.02-.49-5.97 3.68-5.7 1.8.12 4.58.23 6.19.26 1.6.02 3.07.15 3.26.3 1 .73 11.52.45 13.27-.36 1.48-.68 1.99-2.52 2.23-8.1.24-5.5.3-5.33-2.27-6.77-.63-.36-1.43-.9-1.76-1.2-1.22-1.1-1.67-1.41-2.02-1.41-.2 0-.36-.13-.36-.28 0-.15-.54-.47-1.2-.7-.66-.24-1.2-.58-1.2-.75 0-.17-.21-.23-.47-.13s-.57-.06-.68-.35c-.11-.3-.37-.54-.57-.54-.42 0-2.51-1.4-2.69-1.8-.06-.14-.24-.18-.4-.08-.3.19-.63-1.62-.77-4.24-.1-1.8-.03-1.84 3.8-2.56 5.8-1.1 8.02-3.66 9-10.36.94-6.45 1.84-9.13 3.14-9.3 1.57-.22 1.93-.34 2.53-.83.38-.3.52-.33.36-.07-.14.23-.13.43.04.43.16 0 .5-.2.75-.43.38-.35.41-.33.2.08-.23.42-.2.44.18.09.59-.54 1.13-.56.8-.02-.13.22.32-.03 1.01-.56.69-.52 1.18-1.08 1.08-1.24-.1-.15.14-.5.53-.77s.76-.8.84-1.19c.07-.38.68-1.68 1.34-2.9a14.68 14.68 0 0 0 1.38-3.2c.33-2.03.54-4.18.75-7.87.12-2.11.43-4.18.7-4.7.5-.96.21-.9 5.96-1.5 2.69-.28 2.82-.31 3.83-.8 1.59-.8 1.87-1.72 2.17-7.12.1-1.72.41-4.17.7-5.42.44-1.9 1.5-10.35 1.54-12.2.01-.97.56-1.37 2.54-1.89 5.11-1.33 8.4-5.27 9.33-11.16.54-3.46 3.7-7.19 6.08-7.19 1.98 0 3.9-4.54 4.7-11.15 1.43-11.9 1.43-11.63.22-16.54-.97-3.97-10.86-5.79-34.2-6.28a7157.7 7157.7 0 0 0-122.64-.99c-31.43.19-38.1.17-72.72-.17-16.04-.16-29.24-.2-29.34-.1m42.72 2.3c5.85.2 13.21.5 16.36.68 4.09.23 10.5.18 22.3-.19 21.61-.66 46.18-.77 51.39-.22 2.63.27 11.52.42 26.76.43 12.54.01 24.5.17 26.58.36 2.08.18 10.18.48 18.01.67 34.9.82 34.52.8 40.96 2.16 8.38 1.76 11 3.78 10.47 8.04-1.56 12.41-1.95 14.02-3.75 15.27-.35.25-1.46 1.9-2.47 3.7-1.02 1.77-2.39 4.08-3.05 5.12a74.47 74.47 0 0 0-2.69 4.72c-1.5 2.91-3.9 5.48-6.03 6.5-1.69.8-3.44 4.43-4.3 8.89-.81 4.2-2.44 9.58-3.22 10.6-.28.38-.51.92-.52 1.22-.05 2.35-3.98 6.5-6.17 6.5-1.35 0-3.66 4.59-4.84 9.63-1.56 6.6-3.32 8.76-8.56 10.42-2.56.82-2.43.58-4.07 7.73-2.99 13-4.79 16.14-10.4 18.09a5.95 5.95 0 0 0-3.04 2.22l-1.28 1.61-.2 7.14c-.12 3.92-.39 7.83-.6 8.68l-.44 1.88c-.37 1.7-2.1 4-3.15 4.18l-2.97.6c-1.46.3-2.77.53-2.91.5-2-.32-4.03 3.86-4.56 9.36-.43 4.6-1.07 7.74-2.06 10.08-2.1 5-2.88 5.8-6.77 6.97l-2.49.75-1.32 2.65c-1.67 3.34-2.02 4.47-2.3 7.45-.3 3.29-.4 3.94-.8 5.23-.18.62-.24 1.12-.12 1.12.11 0-.15.38-.59.84-.43.46-.88.82-1 .8-.12-.02-.62.13-1.12.34-.5.2-2.25.49-3.89.62-4.02.33-4.44.84-5.7 6.9-1.17 5.64-4.13 13.4-5.57 14.62-.95.8-4.7 2.64-5.38 2.64-1.13 0-3.85 5.67-4.27 8.92-.73 5.7-2.03 9.16-4.3 11.49-.73.75-1.9 2.02-2.58 2.82-.69.8-1.8 1.64-2.46 1.88-1.24.45-3.36 4.2-5.61 9.92-2.03 5.15-4.15 7.71-8.2 9.87-3.39 1.8-4.27 3.45-5.17 9.64-.74 5.1-1.35 7.02-2.89 9.03a4.85 4.85 0 0 0-.88 1.51c0 1.12-5.14 4.9-6.67 4.9-.85 0-3.56 7.32-3.82 10.3-.39 4.61-1.65 8.6-2.54 8.05-.16-.1-.34 0-.4.2-.16.46-2.2.9-5.4 1.17-3.84.32-6.02 1.89-7.03 5.05-.99 3.08-1.7 3.92-4.21 4.92-6.27 2.5-12.87.38-14.04-4.53-.51-2.12-5.72-16.08-6.1-16.32-.2-.13-1.24-.42-2.27-.64-5.63-1.17-7.53-3.78-8.58-11.8-.43-3.28-2.63-8.25-3.66-8.28-.67-.02-4-.38-5.88-.63-1.8-.25-4.87-2.47-4.25-3.09.12-.12.05-.33-.16-.46-.21-.13-.48-1-.61-1.93-.13-.93-.3-1.8-.38-1.94-.28-.45-1.18-9.35-1.2-11.8-.01-2.92-.3-3.34-3.5-4.95-4.11-2.06-5.94-4.71-8.03-11.64-2.25-7.45-3.7-10.43-5.46-11.16-4.92-2.03-9.2-8.68-9.93-15.4-.36-3.39-2.3-6.08-4.36-6.08-5.02 0-8.29-2.17-8.7-5.8l-.3-2.26-.37-2.75c-.12-.94-.6-4.1-1.05-7.03a93.16 93.16 0 0 1-.82-6.2c0-1.73-1.53-2.63-4.85-2.86-4.08-.28-6.79-1.62-6.65-3.29a3.7 3.7 0 0 0-.2-1.23c-.14-.4-.36-2.33-.48-4.28-.14-2.05-.46-4-.75-4.6-1.28-2.54-3.06-4.98-3.64-4.98-.75 0-3.76-1.34-4.05-1.8-.12-.17-.3-.27-.4-.2-.53.3-2.41-3.43-2.8-5.55-.03-.1-.56-1.4-1.2-2.91-1.1-2.66-3.11-9.86-3.11-11.2 0-1.47-2.24-5.13-2.87-4.67-.06.04-.37-.13-.69-.4-.32-.26-.66-.39-.76-.29-.23.23-3.58-1.54-3.58-1.89 0-.14-.28-.54-.64-.9-.4-.4-.85-1.78-1.23-3.84a22.8 22.8 0 0 0-1.37-4.76c-.92-1.82-2.64-7.09-3.43-10.48-.66-2.84-.97-3.22-3.72-4.57-4-1.97-6.52-5.22-8.15-10.5a30.88 30.88 0 0 0-3.56-7.15 3.08 3.08 0 0 0-1.52-1.17c-2.82-.7-5.41-3.47-6.07-6.45a8.37 8.37 0 0 0-.87-2.1c-1.17-1.92-2.74-6.06-3.73-9.82-1.2-4.5-1.82-5.42-4.65-6.81a13.53 13.53 0 0 1-7.01-8.9c-1.85-7.08-5.3-15.5-6.82-16.66-5.57-4.26-7.01-8.24-7.18-19.86-.22-14.57-.93-14.16 28.4-16.49 4.74-.37 26.74-.84 56.26-1.2 15.19-.18 28.92-.46 30.53-.62 4.25-.42 30.03-.45 42.37-.04m20.1 26.23c-2.3 1.94-5.49 3.44-9.87 4.65-1.29.35-4.12 1.27-6.29 2.05a78.14 78.14 0 0 1-7.03 2.12c-4.26.99-7.47 2.82-9.25 5.28-2.68 3.72-10.93 8.45-20.85 11.97l-1.63.57-1.53 4.87c-.84 2.67-1.84 6.17-2.2 7.77-2.31 9.96-2.85 11.91-3.92 14.16a61.7 61.7 0 0 0-2.1 5.06 37.3 37.3 0 0 1-2.35 5.1c-2.22 3.87-2.24 3.9-2.5 5.26-.22 1.24-.15 1.36 2.14 3.6 4.58 4.52 6 8.41 6.8 18.63.52 6.61.64 7.3 2.05 11.66 2.06 6.38 2.6 8.3 3.25 11.66l.57 2.92.83-2.53c1.38-4.19 4.09-6.63 9.56-8.63 3.28-1.2 4.14-1.23 12.18-.46 8.13.78 7.54.45 15.3 8.59a24.82 24.82 0 0 0 4.46 3.63c3.53 2.05 5.52 4.16 6.87 7.32l.69 1.6-.7 1.87c-1.57 4.2-4.1 7.05-7.7 8.67-6.64 3-7.3 3.4-8.21 4.94-.49.83-2.06 2.95-3.5 4.72-4.42 5.4-4.92 7.32-2.7 10.42.82 1.16 1.93 2.3 2.45 2.54 2.5 1.13 6.75 4.35 8.9 6.77l2.35 2.62.2 7.58c.24 8.48.88 11.6 2.86 13.96a14.79 14.79 0 0 1 2.68 5.85l.37 1.6 4.28 1.28a50.63 50.63 0 0 0 31.2-1.1c1.64-.62 3.17-3.73 4.61-9.37l1.36-5.32-.4-7.38c-.7-13.27 1.35-17.36 9.62-19.2 1.03-.24 3-.75 4.35-1.15l2.47-.72-1.1-.47c-.6-.26-2.8-.77-4.87-1.14-6.66-1.19-10-2.51-12.14-4.8-1.67-1.8-2.42 2.23-2.43 13.15-.01 13.62-2.47 17.04-13.04 18.12-15.62 1.6-19.18 1.46-22.87-.93-3.24-2.09-4.8-7.38-3.51-11.95.37-1.32 1.28-4.67 2.03-7.46 3.1-11.55 4.45-12.37 23.32-14.15 9.85-.93 10.44-1.09 11.5-3.06.59-1.09.6-1.34.2-2.34-4.66-11.19-3.7-17.67 3.26-21.74 2.03-1.19 4.9-4.39 6.14-6.84a16.94 16.94 0 0 1 6.85-6.8c2.41-1.17 4.1-1.04 11.4.88 6.46 1.7 14.27 1.6 16.09-.22.7-.7 1.5-3.5 1.5-5.27 0-1.54.37-2.5 1.37-3.66.7-.8 1.93-4.04 3.4-8.92 1.01-3.34 1.04-3.65 1.1-11.15l.07-7.72-1.05-3.09c-1.57-4.6-2.6-6.67-4.27-8.6l-1.5-1.75-.8-6.83a142.2 142.2 0 0 0-1.94-11.93c-.63-2.8-1.33-6.22-1.56-7.6l-.42-2.5-2.6-1.7c-3.38-2.24-4.26-2.69-6.6-3.33a18.1 18.1 0 0 1-10.36-7.34l-1.52-2.28-3.54-1.36a92.93 92.93 0 0 1-7.16-3.18c-2.67-1.35-4.24-1.91-6.01-2.16-8.04-1.15-19.92-4.35-24.26-6.55-1.75-.89-1.87-.85-4.35 1.24m4.94 6.68c.75.17 3.3.48 5.66.68 2.36.2 5.98.54 8.06.74 2.08.2 5.78.48 8.23.63 5.94.36 10.89 2.4 13.34 5.54a55.26 55.26 0 0 0 8 7.47c1.5 1.03 4.08 1.88 8 2.6 1.79.34 3.88.97 4.65 1.4l1.39.8 1.29 7.87c.71 4.32 1.65 10.87 2.1 14.55.97 8.2 1.36 9.12 5.56 13.24 4.33 4.25 4.56 4.97 4.56 14.44 0 8.8-.79 12.44-2.98 13.8-1.69 1.04-4.05 3.85-5.6 6.65-2.3 4.16-6.06 6.68-9.02 6.02-13.94-3.13-22.03-.64-24.45 7.5-.76 2.58-2.25 4.25-4.46 5-7.16 2.43-9.82 10.24-8.17 23.94l.2 1.63-1.95.86c-2.05.9-6.74 1.41-20.41 2.22-8.87.51-9.08.67-9.44 7.08-.2 3.4-1.17 8.58-1.52 8.09-.41-.57-3.02-2.43-4.53-3.22l-1.59-.84.88-.84c1.16-1.1 3.26-5.64 4.2-9.07l.98-3.56c.16-.56.73-1 1.84-1.42 10.7-4.06 10.82-20.82.2-25.15-2.92-1.2-3.98-2.13-5.06-4.5-2.7-5.97-6.66-7.8-18.25-8.42-10.1-.54-16.9.39-20.24 2.77-1.26.9-1.03 1.2-2.32-3.18-.91-3.09-1.16-4.76-1.58-10.63-.9-12.6-1.9-16.82-4.86-20.78-.77-1.02-.8-1.18-.34-2.05 1.67-3.24 4.22-14.42 5.36-23.6a58.51 58.51 0 0 1 1.62-8.3l.98-3.14 2.1-1.4a27.17 27.17 0 0 0 4-3.46c1.77-1.9 8.82-5.48 10.81-5.48 3.32 0 10.68-7.05 10.68-10.23 0-.62.64-.82 5.09-1.65 2.36-.43 5.7-1.17 7.4-1.63 1.72-.46 5.32-1.1 8-1.4 2.7-.31 5.7-.86 6.7-1.2 2.06-.74 2.96-.8 4.89-.37m182.76 36.9c0 .75.07 1.02.16.59.08-.43.08-1.05-.01-1.37-.09-.33-.15.02-.15.77M8.23 89.76c0 .38 1.29 1.83 1.62 1.83.12 0-.16-.42-.61-.94-.46-.52-.87-1-.92-1.09-.05-.07-.09.01-.09.2m368.19 1.01c-.43.49-.6.82-.38.75.37-.12 1.56-1.65 1.27-1.63-.07 0-.47.4-.9.88M15.53 92.52c.33.08.87.08 1.2 0 .33-.09.06-.16-.6-.16-.66 0-.93.07-.6.16m348.21 21.89c0 .94.07 1.29.15.77.08-.53.08-1.3 0-1.72-.08-.42-.15 0-.15.95m-.54 2.95a4.13 4.13 0 0 1-2.85 3.04c-.81.24-.86.3-.24.32a3.47 3.47 0 0 0 3.46-3.86c-.09-.54-.19-.4-.37.5m-13.28 3.73c0 .2.5.35 1.1.35 1.24 0 1.2-.15-.15-.47-.56-.14-.95-.09-.95.12m7.12-.1c.43.09 1.12.09 1.55 0 .42-.07.07-.14-.78-.14-.85 0-1.2.07-.77.15m-7.31 9.02c0 4.05.05 5.71.1 3.69.07-2.03.07-5.35 0-7.38-.05-2.03-.1-.37-.1 3.69m-288.4 19.8c.43.08 1.05.07 1.38-.01.32-.09-.02-.16-.78-.15-.75 0-1.02.07-.6.15m276.16 0c.43.09 1.05.08 1.38 0 .32-.09-.03-.16-.78-.15-.76 0-1.02.07-.6.15M64.6 169.47c0 1.22.07 1.73.14 1.11.08-.61.08-1.61 0-2.23-.07-.61-.14-.1-.14 1.12m.28 4.04c-.1 2.68 1.76 4.6 4.32 4.5.7-.03.77-.09.27-.2-2.94-.66-3.77-1.43-4.27-3.99-.27-1.36-.29-1.38-.33-.31m6.57 4.78c.52.08 1.37.08 1.89 0 .52-.08.1-.14-.95-.14-1.03 0-1.46.06-.94.14m7.56 7.47c0 .95.07 1.3.15.77.08-.52.07-1.3 0-1.72-.09-.42-.15.01-.15.95m.4 3.2c.2 2.33 1.95 3.57 4.82 3.44.92-.04.94-.06.17-.19-3.32-.57-4.21-1.24-4.84-3.63-.26-1-.28-.95-.16.38m240.52 1.06c-.54 1.04-1.47 1.75-2.3 1.74-.25 0 .03-.3.63-.66a4.04 4.04 0 0 0 1.54-1.93c.26-.72.5-1.04.57-.73a3.3 3.3 0 0 1-.44 1.58m-232 2.68c.7.08 1.86.08 2.57 0 .7-.07.13-.13-1.29-.13-1.41 0-1.99.06-1.28.13m218.9 2.33c0 1.32.06 1.81.13 1.1.07-.7.07-1.79 0-2.4-.08-.6-.14-.02-.14 1.3m-.45 6.17c-.14 3.45-1.48 4.8-5.21 5.3-1.55.2-1.8.29-.9.32 4.54.15 7.71-3.11 6.34-6.54-.1-.25-.2.17-.23.92M94.1 212.1c-1.89 4.13-.4 8.36 3.06 8.68l1.47.13-1.36-.34c-3.07-.78-4.82-5.75-2.87-8.12.2-.23.29-.6.22-.81-.08-.22-.3-.01-.52.46m.95 2.28c-.03.52 1.6 3.46 1.9 3.46.1 0-.13-.51-.51-1.13-.38-.63-.85-1.51-1.03-1.98-.19-.46-.35-.62-.36-.35m-.71 2.53c0 .9 2.08 2.93 3.26 3.18.86.18.78.09-.5-.59a5.36 5.36 0 0 1-2.13-2c-.37-.7-.63-.95-.63-.6m6.52 3c-.28.18-.9.35-1.38.38-.7.04-.73.08-.15.2a4.1 4.1 0 0 0 1.88-.38c.66-.29.96-.52.68-.53-.29 0-.75.14-1.03.33m2.4.31c0 .17-.97.47-2.15.67l-2.14.35 2.16-.09c2-.08 4.55-1.24 2.72-1.24-.33 0-.6.14-.6.31m3.78.72c.38.7.75.85 1.14.46.23-.23-.74-1.12-1.23-1.14-.15 0-.1.3.1.68m106.75.56c.13.08-.14.87-.6 1.76-.93 1.78-1.87 6.1-1.87 8.6-.01 5.02-.8 5.36-11.48 5.03-7.73-.24-10.24-.62-10-1.5l.56-2.28c1-4.02 1.96-5.54 4.34-6.88 1.21-.67 3.23-2 4.48-2.95 2-1.51 2.56-1.76 4.53-2 2.08-.26 9.5-.1 10.04.22M107.97 230c-.2 4.74-.16 6.22.16 6.42.24.14.43.23.44.2l-.16-6.42-.18-6.35-.26 6.16m184.42-3.24c0 1.23.06 1.73.14 1.11.08-.61.08-1.61 0-2.23-.08-.61-.14-.1-.14 1.12m-.52 4.4c-.33 2.28-1.6 3.33-4.73 3.97-.48.1-.03.1.98.03 2.92-.23 4.5-2.07 4.09-4.74-.07-.45-.2-.15-.34.75m-11 4.41c.6.08 1.69.08 2.4 0 .71-.07.21-.13-1.1-.13-1.33 0-1.91.06-1.3.13m-172.47 3.15c0 .2-.23.27-.51.16-.43-.16-.5.17-.47 1.98.04 1.86.08 2 .3.98.14-.66.27-1.05.3-.88.05.36 1.04-.84 1.06-1.28 0-.15-.18-.16-.42-.02-.32.2-.31.12.02-.3.3-.36.33-.62.08-.77-.2-.12-.36-.06-.36.13m.08 3.04c-1.17 4.01-.77 6.33 1.23 7.2 1.58.69 6.63.81 6.84.17.08-.24.36-.43.63-.43s.49-.12.49-.27c0-.14-.3-.27-.66-.27-.37 0-.59.16-.5.36.1.2-.05.07-.33-.27s-.6-.61-.71-.6a.98.98 0 0 1-.29 0c-.9-.28-1.31-.2-1.15.22.1.27.04.49-.15.49-.18 0-.35-.35-.37-.77-.03-.58-.08-.63-.2-.17-.25.96-2.43-.04-3.2-1.47-.53-1 .75-.35 1.54.77.29.42.53.61.53.43s.16-.1.34.18c.29.44.34.43.34-.08 0-.33-.23-.6-.51-.6s-.52-.25-.52-.55c0-.3-.31-.63-.7-.73-.43-.12-.63-.38-.52-.67.12-.31.04-.4-.2-.25-.28.17-.33.06-.18-.34.15-.4.1-.5-.17-.34-.26.16-.33.06-.2-.3.12-.29.12-.63 0-.75-.22-.21-.43-1-.5-1.82-.08-.84-.5-.41-.88.86m.74.49c-.12.2 0 .49.26.66.38.24.35.3-.1.3-2.18.02-.34 4.63 2.11 5.3.78.23.77.19-.17-.42-1.34-.86-2.1-1.75-2.38-2.82-.15-.56.04-.38.56.52a5.6 5.6 0 0 0 2.32 2.14c.85.43 1.32.77 1.06.77s-.4.08-.3.18c.45.45 2.29-.27 2.08-.81-.18-.49-.13-.5.36-.1 1.71 1.39-3.1 1.89-5.16.53-1.45-.94-2-2.65-1.48-4.52a16 16 0 0 0 .47-2.04c0-.22.14-.33.3-.23.16.1.2.34.07.54m9 6.39c-.24.4 1.62 1.44 2.57 1.44.39 0 .59-.24.56-.67-.03-.36-.17-.58-.32-.5-.14.1-.56 0-.93-.19-.48-.26-.7-.24-.83.07-.14.33-.25.32-.5-.04-.21-.3-.4-.34-.55-.11m159.55 8.22c.23 2.36.39 2.56.42.53.01-.98-.1-1.87-.27-1.97-.17-.1-.23.54-.15 1.44m-.42 3.81c-.4 1.35-1.63 2.4-3.3 2.78-1.09.26-1.1.28-.2.31 2.29.09 4.32-1.78 3.96-3.62-.09-.44-.23-.27-.46.54m-9.47 2.75c.63.56 1.23.7 2.74.66l1.94-.05-1.9-.22a10.52 10.52 0 0 1-2.74-.65l-.85-.44.8.7m-3.92 7.4c0 3.59.05 5 .11 3.16.07-1.85.06-4.79 0-6.52-.06-1.74-.1-.22-.1 3.36m-125.59 21.1c.59.24.62.3.14.32-.68.02-1.97-1.13-1.97-1.77 0-.23.24-.06.55.37.3.43.88.92 1.28 1.08m110.56 10.92c-.3 1.87-1.16 2.79-3.15 3.36l-1.7.48 1.7-.18c2.39-.25 4.8-3.56 3.53-4.83-.09-.1-.26.44-.38 1.17m-14.63 15.45c0 .23-.39.81-.87 1.3-.48.48-.69.8-.45.73.62-.2 1.84-1.93 1.56-2.21-.13-.13-.23-.05-.23.18m-11.06 3.03c.42.08 1.04.08 1.37 0 .33-.1-.02-.16-.78-.16-.75 0-1.02.08-.6.16m-2.41 1.92c-.1.24-.05 1.36.09 2.48l.26 2.05.04-2.49c.05-2.44-.05-2.94-.4-2.04m-.34 7.66c-.42 2.93-2.03 4.12-5.8 4.3-1.04.04-1.06.06-.18.19 3.9.59 6.78-1.84 6.35-5.33-.07-.64-.19-.38-.37.84m-1.93 1.97l-.82 1.07.98-.93c.54-.51.91-1 .83-1.07-.09-.08-.53.34-.99.93m-11.35 2.62c0 .19.43.33.95.31.83-.02.86-.05.25-.31-.93-.4-1.2-.4-1.2 0"/><path fill="#b4a904" d="M128.99 17.35c-5.94 1.04-15.98 1.43-37.74 1.49-13.21.03-14.17.08-19.55.93-4.62.73-7.5.95-15.61 1.16-6.95.19-10.57.43-12 .79-1.14.28-3.69.77-5.67 1.08-9.18 1.45-16.28 5.64-17.62 10.4-.78 2.8-.79 2.78 1.44 5.35 3.72 4.31 4.5 5.95 8.63 18.12 3.02 8.9 3.05 8.96 5.97 11.25C40 70.4 41.6 72.7 43.88 78c2.65 6.16 4.34 8.93 7.25 11.9 3.98 4.05 6.17 7.73 8.38 14.05 1.47 4.25 3.08 6.54 5.9 8.46 2.81 1.9 5.1 5.1 7.15 9.94 1.99 4.74 4.54 8.93 7.22 11.89 2.44 2.7 4.88 7.6 6.5 13.1 2.08 7.02 4.09 10.66 8.1 14.67 3.85 3.86 6.55 8.47 8.66 14.85 1.13 3.4 2.25 4.8 5.32 6.62 4.56 2.71 6.16 5.36 8.24 13.63 1.84 7.3 2.93 10.46 3.91 11.3.44.37 1.74 1.4 2.87 2.27 2.42 1.85 4.86 5.32 6.13 8.69 1.92 5.1 4.2 8.4 7.13 10.29 4.55 2.93 6.98 7.71 8.97 17.65.8 4.04 1.6 5.12 7.32 9.8 2.21 1.82 3.78 4.13 5.36 7.9 2.03 4.83 3.2 6.63 6.41 9.86 4 4.04 6.42 8.69 8.23 15.85 1.08 4.24 3.34 7.22 7.38 9.74 4.46 2.78 5.87 4.96 9.23 14.3 2.98 8.25 3.27 8.64 4.6 6.08 1.83-3.56 5.4-6.28 10.46-7.96 5.44-1.82 6.41-2.97 8.06-9.55 2.48-9.89 3.09-11.1 8.06-16.03 3.56-3.53 4.93-5.63 6.22-9.6 1.65-5.1 4.59-9.34 8.44-12.23.94-.71 1.43-1.5 2.18-3.6 4-11.14 6.87-15.77 11.08-17.92 3.1-1.58 5.55-5.55 6.74-10.9 1.59-7.16 3.29-10.64 7.17-14.67 3.36-3.47 6.35-8.45 7.22-11.99.98-3.96 3.65-7.17 7.78-9.34 3.41-1.8 4.17-3.06 4.93-8.2 1.29-8.75 3.2-12.1 8.5-14.93 3.29-1.76 6.07-5.81 7.3-10.66 1.96-7.68 4.55-13 7.7-15.85 2.95-2.68 5.13-6.35 6.4-10.82 1.3-4.52 4.13-8.6 7.65-11.02 4.3-2.94 4.3-2.96 7.16-14.76 1.3-5.43 3.4-8.57 7.42-11.14 3.43-2.2 5.7-5.25 6.52-8.8 1.54-6.7 3.96-11.57 7.57-15.3 3.27-3.4 5.37-7.12 7.1-12.62 2.22-7.05 3.76-10.04 7-13.55 1.83-1.99 4.5-5.77 7.25-10.24l2.17-3.55-.96-2.8c-1.25-3.6-3.02-6.34-5.23-8.09l-1.77-1.4h-6.83c-6.9 0-11.44-.45-16.1-1.6-1.62-.4-4.87-.62-12-.8-8-.2-10.8-.41-15.44-1.15l-5.66-.9h-21.95c-13.1-.01-22.55-.16-23.42-.36-10.25-2.36-25.82-2.41-52.05-.17-14.35 1.23-17.37 1.3-23.9.55-20.58-2.37-48.84-3.12-57.92-1.54m29.5.48c9.08.38 16.9 1.04 27.2 2.3l7.48.91 9-.78c4.94-.43 10.37-.92 12.07-1.08 6.08-.57 14.58-1.02 25.04-1.31 11.49-.32 12.92-.22 21.57 1.54 4.06.83 4.17.83 25.9.83 24.02 0 25.76.12 31.2 2.07 2.81 1 2.9 1.02 10.13 1.02 5.84 0 8.04.14 11.05.69a96.76 96.76 0 0 0 17.75 1.9l7.48.25 1.63 1.84c1.7 1.9 4.16 6.37 4.16 7.54 0 .94-5.6 9.33-7 10.48-3.63 3-7.3 9.99-8.8 16.75a20.32 20.32 0 0 1-6.04 10.45c-4.84 4.6-6.96 9.13-8.5 18.2-.46 2.67-2.95 5.73-5.68 6.97-4.82 2.2-6.75 5.5-9.24 15.83-1.91 7.98-1.96 8.08-4.8 9.68-4.65 2.63-6.36 4.88-8.72 11.5-1.93 5.4-2.77 6.77-6.42 10.36-3.75 3.7-5.23 6.56-6.85 13.25-2.25 9.35-3.1 10.71-8.22 13.24-7.38 3.64-8.2 5.24-9.12 17.75-.3 4.02-.85 4.76-4.54 6.02-4.26 1.46-6.44 3.97-7.65 8.8-.94 3.77-3.15 7.98-4.92 9.37-5.62 4.4-8.64 10.56-9.63 19.6a11.03 11.03 0 0 1-6.22 8.73c-4.84 2.33-7.22 5.76-10.58 15.27-1.68 4.78-2.84 6.8-4.3 7.56-2.55 1.31-5.24 5.54-7 10.97-1.52 4.69-3.5 7.97-5.38 8.94-4.36 2.26-7.16 7.72-9.03 17.64-1.22 6.46-2.2 7.66-7.15 8.67-5.53 1.14-9.2 3.44-10.75 6.75l-.7 1.5-1.81-5.46c-3.22-9.72-5.2-12.69-10.2-15.32-4.43-2.32-5.72-4.2-7.22-10.54-1.64-6.88-3.73-11.23-6.83-14.24l-2.82-2.7c-1.47-1.42-3.18-4.4-4.78-8.33-1.8-4.4-4.46-7.45-8.13-9.3-2.27-1.15-3.56-3.09-4.11-6.17-2.3-12.97-4-16.35-9.84-19.64-2.58-1.45-5.07-4.72-5.97-7.85-1.64-5.65-4.85-10.06-8.8-12.08-1.47-.75-1.78-1.58-4.52-12.32-2.38-9.32-3.6-11.3-8.45-13.66-3.44-1.68-4.12-2.54-5.29-6.75-2.11-7.61-6.7-14.78-10.67-16.69-1.72-.82-4.77-7.08-6-12.3-1.56-6.65-4.02-11.6-7.23-14.53-2.54-2.33-5.55-7.34-6.83-11.37-1.25-3.96-4.11-7.62-7.41-9.48-1.86-1.05-4.25-3.61-4.25-4.54 0-1.31-2.81-8.9-4.33-11.68-1.59-2.9-3.21-4.8-7.25-8.48-1.58-1.43-4.34-6.27-5.21-9.14-1.41-4.65-4.5-9-7.74-10.9-2.23-1.3-2.31-1.47-5.32-11.3-3.34-10.92-4.85-14.25-7.89-17.35l-2.06-2.1 1.24-1.69c3.37-4.6 9.34-7.78 16.64-8.87 2.52-.37 5.9-.91 7.51-1.2 2-.36 5.2-.52 10.17-.52 6.94 0 7.37-.04 9.78-.9 5.56-1.96 7.36-2.09 32.2-2.32 14.48-.14 23.37-.36 24.35-.6 8.4-2.02 16.79-2.43 34.65-1.68m31.22 4.97c-9.87 2.75-14.01 5.3-17.15 10.59-1.73 2.9-5.37 5.08-10.12 6.06-6.87 1.42-13.44 4.97-16.65 9.01-1.52 1.91-4.93 4.21-9.91 6.7-7.32 3.65-9.3 7.3-11.35 20.82-.56 3.7-2.45 7.42-4.64 9.17-3.77 3-5.34 6.29-6.35 13.3-1.35 9.4-.87 13.11 2.6 20.08 1.44 2.86 1.63 3.6 2.76 10.29 1.04 6.17 1.33 7.32 2.03 8.06.45.47 1.88 3.56 3.2 6.86l2.37 6 .56 7.2c.3 3.97.56 10.45.56 14.41v7.2l1 1.72c1.34 2.32 3.13 3.96 6.2 5.7 4.35 2.44 6.34 3.94 8.62 6.53 1.2 1.37 3.43 3.73 4.95 5.25 4.96 4.96 7.92 9.01 8.7 11.9 2.17 7.92 3.82 11.65 6.12 13.8 1.96 1.84 4.15 5.47 6.62 11 4.26 9.51 9.15 11.32 30.68 11.32 23.88 0 27.47-1.57 30.7-13.53.6-2.17 1.53-5.4 2.1-7.2.95-3.04 1.03-3.74 1.23-10.54.26-8.8-.76-7.59 9.1-10.87 13.28-4.4 14.56-5.48 17.3-14.5 1.76-5.83 2.88-8.03 4.66-9.2 3.85-2.54 5.1-4.74 5.89-10.46 1.56-11.25 1.75-14.05 1.66-24.28-.08-9.43-.03-10.33.78-14.92 1.75-9.84 1.88-23.72.31-33.67-.27-1.72-1.02-7.52-1.67-12.9-2.53-20.8-2.21-19.07-3.95-21.43-2.64-3.57-8.28-7.14-15.45-9.78l-4.28-1.57-1.75-2.34c-2.45-3.28-8.44-7.41-10.75-7.41-.47 0-2.87-1.19-7.16-3.54-2.62-1.44-3.35-2.02-4.16-3.34-2.58-4.19-4.47-5.35-14.26-8.78-2.5-.88-8.87-2.19-13.9-2.86-1.6-.22-3.22-.45-3.6-.53-.38-.07-2 .24-3.6.68m7.78 2.1c11.64 1.84 22.47 5.92 24.98 9.38 1.27 1.76 5.35 4.25 12.8 7.8 2.94 1.41 5.97 3.05 6.74 3.64 1.4 1.08 3.93 3.68 3.95 4.06.02.47 4.1 3 5.92 3.68 6.41 2.37 14.51 8.04 15.64 10.95.83 2.13 2.4 11.58 3.51 21.18.4 3.4 1.08 7.88 1.53 9.95a87.11 87.11 0 0 1-.42 36.7c-.85 3.65-.88 4.03-.66 10.87.52 16.3-2.21 28.84-7.22 33.11-2.74 2.35-4.42 6-6.12 13.32-1.41 6.08-3.73 8.31-11.38 10.97-10.7 3.7-11.22 3.92-12.48 5.25l-1.24 1.3-.2 7.4-.2 7.41-1.56 5c-.85 2.74-1.8 5.95-2.1 7.13-1.34 5.16-4.68 8-10.82 9.18-12.97 2.5-33.9 1.73-40.06-1.47-2.73-1.42-5.7-4.77-6.73-7.58a54.9 54.9 0 0 0-5.68-10.6c-1.99-2.67-3.11-5.13-5.41-11.92-1.77-5.2-2.53-6.48-7.1-11.95-7.29-8.73-11.1-12.2-16.07-14.66-2.5-1.23-5.07-3.26-6.3-4.98l-1.05-1.46-.22-6.52c-.59-17-1.52-22.54-5.38-31.9-1.68-4.1-2-5.24-2.2-7.72-.56-7.51-1.22-10.68-2.6-12.52-1.76-2.37-2.92-4.8-4.3-9l-1.18-3.6.71-4.5c1.7-10.8 1.97-11.52 6.27-16.3 1.95-2.16 4.11-7.08 5-11.37 2.84-13.59 3.85-15.2 12.33-19.54 4.74-2.44 8.1-4.7 10.18-6.87 3.35-3.49 6.92-5.5 14.07-7.9 7.6-2.56 11.15-4.46 12.84-6.87 2.46-3.5 5.9-5.65 13.46-8.4 3.7-1.34 4.22-1.38 8.75-.66m37.12 124.58c-.63.7-.98 1.63-1.26 3.39-1.03 6.36-3.89 9.55-10 11.13l-1.51.4 1.86 1c3.9 2.15 7.86 8.44 7.86 12.52 0 .78 3.36 3.56 4.3 3.56 1.28 0 4.54-2.7 4.77-3.97.78-4.13 4.38-9.03 8.07-10.97 3.51-1.85 3.51-2.15-.02-4.55-4.13-2.8-7.24-6.92-8.02-10.63-.45-2.1-4.65-3.4-6.05-1.88m2.27 2.25c.7 5.1 3.06 9.99 5.7 11.73l1.37.9-1.27.87c-2.94 2-5.25 7.33-5.28 12.17-.01 1.3-1.16 2.24-2.17 1.78-.7-.32-.85-.77-1.24-3.73-.56-4.32-1.46-7.2-2.9-9.28l-1.14-1.67 1.31-1.03c2.23-1.74 3.42-5.07 3.91-10.89.29-3.4 1.3-3.9 1.72-.85m-87.5 1.3c-1.52 2.93-4.62 10.52-4.62 11.29 0 .82 2 3.08 3.68 4.14l1.49.95 2.99-.66c3.76-.81 7.84-1.99 9.1-2.61.53-.26 2.07-.76 3.41-1.1l2.44-.62-1.52-.67c-.84-.38-3.3-2.26-5.47-4.2-3.3-2.93-8.68-6.76-10.47-7.45-.27-.1-.7.28-1.03.93m6.66 8.5c1.63 1.4 3 2.63 3.04 2.76.1.24-4.38 1.8-7.58 2.64l-1.66.45-1.52-1.4c-1.74-1.6-1.75-1.32.28-6.02l1.38-3.17 1.55 1.11c.85.62 2.88 2.25 4.5 3.64M206 190.4l-6.11 1.39-5.1 1.14-1.03 1.5c-.76 1.1-1.4 2.98-2.45 7.13l-1.43 5.64 1.38 1.37 1.38 1.38 7.32-.23 7.33-.23 1.27-1.23 1.26-1.23.4-7.01.41-7.02-.84-.87c-1.37-1.44-2.63-2.01-3.79-1.73m2.57 2.22c.37.44.38 1.27.07 4.4-.21 2.1-.48 5.17-.6 6.8-.32 4.2.3 3.88-7.88 4.01-7.97.13-8.16.08-7.65-1.92.3-1.13.55-1.37 2.28-2.07 1.07-.44 2.33-.98 2.8-1.2 1.03-.51 2.14-3.12 2.97-6.97l.6-2.8 2.94-.67c2.96-.69 3.6-.63 4.47.42"/><path fill="#dccc04" d="M129.85 19.54c-2.65.53-5.5 1.16-6.35 1.4-1.12.31-7.65.5-23.67.67l-22.13.24-3.43 1.28c-6.73 2.51-9.23 2.94-17.05 2.94-18.03 0-25.91 2.07-30.96 8.11L25 35.7l.99 1.28c1.7 2.22 2.72 4.26 3.84 7.8 5.37 16.82 6.4 19.42 7.95 19.91 2.7.86 6.55 6.27 7.99 11.22.93 3.24 1.03 3.48 2.86 6.65.8 1.39 1.58 2.28 2.3 2.63 4.5 2.14 9 9.61 11.51 19.11.88 3.31 1.27 3.88 3.43 4.98 4.11 2.1 6.57 5.1 8.07 9.89 1.42 4.51 4 8.83 6.15 10.31 4.13 2.85 6.68 7.85 8.87 17.41 1.08 4.7 3.13 8.71 4.99 9.78 5.18 2.99 9.13 9.44 11.72 19.16.75 2.83 1.41 3.94 2.36 3.94.84 0 4.53 1.84 5.75 2.87 1.77 1.5 2.83 3.83 4.23 9.3 2.69 10.5 3.87 12.9 8.38 17.02 2.34 2.14 4.3 5.52 5.54 9.58 1.51 4.93 2.52 6.3 5.86 7.94 5.7 2.8 7.63 6.47 10.18 19.35.98 4.91 1.27 5.53 2.9 6.21 4.11 1.72 6.91 4.7 8.66 9.2 2.44 6.28 3.46 7.86 6.4 9.98 4.87 3.5 7.68 9.5 9.87 21.07.36 1.92 2.19 3.73 5.27 5.2 5.1 2.43 7.14 5 9.84 12.43a368.1 368.1 0 0 0 1.52 4.1l.38.98 1.3-1.17c.72-.65 2.45-1.65 3.85-2.23 2.27-.93 3.62-1.25 8.24-1.97 2.12-.33 2.9-1.55 3.7-5.85 2.23-11.77 4.55-16.45 9.7-19.58a11.35 11.35 0 0 0 5.08-7.18c1.03-4.77 4.28-11.28 5.95-11.92.25-.1.94-1.16 1.53-2.36.6-1.2 1.62-2.81 2.28-3.59.75-.87 1.86-3.05 2.94-5.77 3.55-8.89 5.5-11.23 10.93-13.11 2.82-.98 3.91-2.88 4.65-8.07 1.56-11.05 4.33-16.72 9.39-19.28 2.66-1.35 4.23-3.97 4.86-8.1 1.06-7 3.13-9.62 8.55-10.85 3.3-.75 3.06-.43 3.3-4.25.7-11.09 1.01-12.21 4.44-15.63 1.96-1.97 6.48-4.61 7.87-4.61 1.87 0 3.78-3.4 4.9-8.74 2.05-9.76 4.93-15.11 9.69-18.02 1.69-1.03 3.83-4.83 4.9-8.68 1.59-5.75 4.22-9.25 8.48-11.25 1.25-.59 2.31-1.1 2.36-1.15.04-.04 1-3.53 2.12-7.76 3.3-12.47 5.2-15.45 11.11-17.46 1.93-.66 3.18-2.8 4-6.88 2.06-10.27 4.49-14.9 9.65-18.48 2.77-1.92 4.14-4.61 5.58-10.93 1.82-7.99 4.57-12.91 9.37-16.77 2.03-1.63 5.38-7.1 5.09-8.29-.26-1.02-2.1-4.14-3.36-5.68l-.8-.99-8.9-.46c-4.9-.25-11.34-.77-14.32-1.16a90.5 90.5 0 0 0-12.56-.7c-6.08 0-7.57-.1-10.02-.71-3.8-.94-8.11-2.33-9.4-3.02-.9-.5-3.63-.58-23.15-.73l-22.13-.17-6.18-1.35c-7.16-1.56-10.56-1.65-27.44-.7-10.2.58-24.83 2-22.4 2.18.91.07 8.06 2.3 11.12 3.46 4.4 1.68 7.44 4.77 9.2 9.34.67 1.72 4.53 4.1 9.17 5.66 5.7 1.91 10.12 5.08 11.87 8.52.64 1.25.93 1.45 3.22 2.18 6.7 2.15 14.63 6.9 17.2 10.31 2.01 2.68 2.03 2.75 3.5 13.92.66 5.1 1.43 10.65 1.7 12.35 1.93 12.23 2.18 31.36.53 41.16-.6 3.58-.8 6.7-1.03 15.78a332.8 332.8 0 0 1-.7 15.78 91.72 91.72 0 0 0 .35 16.98c.43 2.95-1.89 7.21-3.93 7.21-.12 0-.88.3-1.7.68-.81.37-2.11.77-2.88.9l-1.4.22-1.24 3.3c-2.4 6.43-2.69 7.1-3.68 8.5-1.61 2.28-3.6 3.45-8.57 5.06-5.31 1.72-11.63 4-12.03 4.33-.15.13-.56 3.35-.92 7.16-.6 6.35-.72 7-1.49 7.92-.81.97-3.12 7.6-4.71 13.56-2.1 7.83-5.08 9.43-20.22 10.8-5.6.5-16.9.43-21.95-.14-14.52-1.63-16.44-2.71-21.1-11.86-3.06-6-3.43-6.56-5.16-7.83-4.08-2.98-5.45-5.82-7.84-16.3a17.65 17.65 0 0 0-6.56-9.84 20.76 20.76 0 0 1-5.53-5.88 19.05 19.05 0 0 0-3.45-3.84c-1.84-1.46-2.98-2.1-7.14-4.03a13.2 13.2 0 0 1-5.77-5.87l-.92-1.94-.02-8.86c-.05-18.28-1.43-26-5.45-30.47-3.28-3.64-3.12-3.1-4.16-13.55a23.12 23.12 0 0 0-1.73-7.13c-3.14-8.07-3.41-11-2.05-22.03.89-7.18 3.25-11.84 7.58-14.95 2.06-1.48 2.34-2.19 3.96-9.92 2.53-12.05 4.58-15.44 10.79-17.8 2.35-.9 7.82-4.25 8.04-4.93 1.27-4 8.55-8.52 17.82-11.06 5.34-1.47 7.76-2.46 7.76-3.19 0-4.3 6.56-10.48 13.53-12.73l3.45-1.11-4.97-.57c-21.9-2.53-41.9-3.03-50.6-1.28m28.17 1.6l4.5.23-1.52 3.04a14.14 14.14 0 0 0-1.86 6.35c-.49 4.72-.66 4.95-4.13 5.72-10.32 2.3-14.41 5.11-16.45 11.34-.89 2.69-1.75 3.37-5.05 3.93-6.96 1.19-8.56 3.35-10.86 14.7l-1.2 5.91-1.5 1.39c-.83.76-1.95 2.04-2.5 2.83-.54.8-1.77 2.23-2.72 3.18-3.95 3.9-4.74 7.3-5.75 24.7-.16 2.7.5 9.94 1.3 14.07.28 1.5.73 6.21 1 10.46.68 11.09 2.63 15.24 8.35 17.83 1.05.47 1.92 1.14 2.2 1.68.75 1.51.97 14.1.4 22.98-1.07 16.47.35 19.53 9.45 20.33 4.62.4 4.94.57 5.7 2.99 1.63 5.26 4.55 8.79 8.95 10.83 1.5.7 2.96 1.4 3.24 1.54.31.17.67 1.3.94 2.99 2.25 13.95 3.4 18.12 5.64 20.34 1.22 1.2 5.02 2.73 6.88 2.76 1.2.02 2.43 1.84 3 4.48 1.67 7.53 5.22 9.6 18.53 10.78 7.63.68 26.13.8 32.9.2 6.8-.58 12.8-.13 14.33 1.09.3.23.02.68-1 1.59-1.8 1.63-3.72 5.58-4.7 9.72a34.89 34.89 0 0 1-1.45 4.72c-.96 2.14-1.86 5.85-2.31 9.53-.5 4.11-.5 4.12-2.39 4.52-7.4 1.59-9.8 5.85-12.4 21.91-.44 2.75-.34 2.67-3.6 3-1.64.16-2.3.24-5.6.7-.82.12-2.1.27-2.83.33a6.4 6.4 0 0 0-1.61.3c-.59.36-1.13-.42-1.64-2.38-1.43-5.55-4.56-8.28-11.38-9.93-1.37-.33-2.5-.7-2.5-.81 0-1.19-1.58-10.5-2.25-13.35-2.07-8.79-4.05-11.38-10.16-13.3-2.25-.7-2.22-.65-3.32-5.79-1.06-5-2.54-7.55-5.55-9.64-.96-.66-1.46-1.39-2.01-2.9-.91-2.5-2.66-5.1-4.05-6-1.13-.75-1-.28-2.5-8.75-1.36-7.63-3.35-9.75-10.04-10.7-3.08-.45-3.16-.53-3.66-3.88-.57-3.82-1.86-7.93-3.1-9.88-.8-1.26-1.1-2.25-1.34-4.31-.6-5.41-2.5-7.91-6.99-9.24-2.52-.75-2.55-.84-2.77-9.16-.22-8.06-.32-8.5-2.43-10.69-.4-.4-1.28-1.34-1.98-2.08-1.31-1.38-4-2.86-8.24-4.51-.8-.31-1.08-.84-2.02-3.9-2.55-8.26-6.06-12.13-12.22-13.46-1.32-.28-1.39-.49-2.48-7.5-.41-2.6-.95-5.46-1.2-6.34L89 133.96c-1.53-5.35-4.84-8.78-9.29-9.63-1.4-.27-2.3-1.92-2.86-5.3-1.01-6.18-3.3-10.67-5.85-11.48-.36-.12-1.08-1.08-1.61-2.14a21.58 21.58 0 0 0-3.12-4.18c-1.18-1.24-2.25-2.65-2.36-3.12-2.87-11.52-6.3-16.16-13.02-17.64-1.34-.29-1.65-.98-2.38-5.23-.76-4.47-1.6-7.12-2.95-9.2a47.4 47.4 0 0 1-2.23-4.05c-1.31-2.7-3.96-5.65-6.08-6.78-1.9-1-2.73-3.12-3.64-9.3a52.7 52.7 0 0 0-1.64-7.32l-1-2.96 1.41-1.13c2.8-2.26 2.9-2.28 8.5-2.61 2.89-.17 9.19-.31 14-.32 8.73-.02 15.08-.5 20.7-1.56 2.21-.42 6.64-.5 24.39-.5h21.68l3.06-1.5c3-1.47 6.5-4.44 7.04-5.96.5-1.41 9.6-1.73 26.26-.9m94.21 0c.7.11 1.29.39 1.29.61 0 1.08 4.36 4.8 7.35 6.25l3.06 1.5 21.8.01c12 .01 22.59.17 23.53.34 6.4 1.18 9.6 1.42 22.64 1.7 13.1.3 20.73.66 28.65 1.38 6.42.58 7.02 4.05 1.07 6.19-5.76 2.06-8.55 8.02-10.36 22.1-.55 4.3-.8 4.67-3.7 5.6-6.9 2.22-10.17 8.93-11.23 23.03-.27 3.55-.12 3.34-2.78 3.83-6.29 1.17-8.58 3.73-10.24 11.46-1.48 6.87-1.74 7.62-2.77 8.16-1.57.83-4.5 4.02-5.63 6.16a12.4 12.4 0 0 1-2.07 2.9c-2.03 1.71-3.72 5.83-4.45 10.87-.57 3.93-.71 4.14-3.47 5.03-3.96 1.27-6.98 3.86-8.2 7.04-.89 2.35-2.37 9.23-2.9 13.52-.32 2.55-.63 4.95-.7 5.34-.12.61-.55.76-3.32 1.14-4.26.59-7.26 1.53-9.45 2.98l-1.8 1.2-.34-.9c-1.04-2.72-1.1-4.18-.93-18.95.17-13.87.5-20.4 1.29-25.63.3-1.94.7-4.27 1.88-10.63 1.03-5.61 1.82-19.93 1.18-21.52-.56-1.36-2.01-3.73-2.62-4.24-.45-.4-1.58-7.37-1.99-12.32-1.32-16.11-3.08-19.91-10.4-22.46-4.24-1.47-6.89-2.77-7.12-3.5-.43-1.34-4.78-5.24-7.18-6.42a35.92 35.92 0 0 1-3.93-2.26c-2.18-1.54-5.78-2.84-9.66-3.49-4.93-.83-4.66-.34-4.86-8.77l-.16-7.1 3.47-.12c7.08-.22 13.8-.24 15.05-.03M149.57 163.3c-.6 1.45.03 2.08 1.65 1.64 1.33-.37 1.29-.77-.16-1.9l-1.06-.8-.43 1.06m109.2 43.53c3.1.02 3.26.5.25.82-6.9.72-7.46 2.13-8.61 21.67-.45 7.66.06 6.7-3.85 7.24-6.58.9-9.73 3.14-10.63 7.51-.3 1.45-.99-1.36-1.18-4.83-.15-2.7-.07-3.83.38-5.18l.57-1.73 1.96-.22c2.89-.32 4.23-.56 5.47-.94 1.5-.48 3.87-3.2 3.87-4.45 0-.53.16-1.32.35-1.76.19-.43.46-4.56.6-9.18l.25-8.4.86-.44c.6-.32 1.78-.4 3.94-.29 1.7.1 4.3.18 5.77.18"/><path fill="#c4ac04" d="M129.85 18.35c-2.46.44-5.16.96-6 1.17-.99.23-9.88.45-24.36.59-24.84.23-26.64.36-32.2 2.33-2.4.85-2.84.89-9.78.89-4.98 0-8.17.16-10.17.52-1.6.29-4.99.83-7.52 1.2-7.29 1.09-13.26 4.27-16.63 8.87l-1.24 1.68 2.06 2.1c3.04 3.11 4.55 6.44 7.9 17.36 3 9.83 3.07 10 5.31 11.3 3.24 1.9 6.33 6.25 7.74 10.9.87 2.87 3.63 7.71 5.2 9.14 4.05 3.67 5.67 5.57 7.26 8.48 1.52 2.78 4.33 10.37 4.33 11.68 0 .93 2.4 3.5 4.25 4.53 3.3 1.87 6.16 5.53 7.41 9.5 1.28 4.02 4.29 9.03 6.83 11.36 3.2 2.94 5.67 7.88 7.23 14.53 1.23 5.22 4.28 11.48 6 12.3 3.97 1.9 8.56 9.08 10.67 16.7 1.17 4.2 1.85 5.06 5.3 6.74 4.83 2.36 6.06 4.34 8.44 13.66 2.75 10.74 3.05 11.57 4.52 12.32 3.94 2.02 7.16 6.43 8.8 12.08.9 3.13 3.39 6.4 5.97 7.85 5.84 3.3 7.53 6.67 9.84 19.64.55 3.08 1.84 5.02 4.1 6.17 3.68 1.85 6.34 4.9 8.14 9.3 1.6 3.93 3.31 6.91 4.78 8.32l2.82 2.71c3.1 3 5.19 7.36 6.83 14.24 1.5 6.33 2.8 8.22 7.21 10.54 5.01 2.63 7 5.6 10.21 15.32l1.8 5.46.7-1.5c1.57-3.31 5.24-5.61 10.76-6.75 4.94-1.01 5.93-2.21 7.15-8.67 1.87-9.92 4.67-15.38 9.03-17.64 1.89-.97 3.86-4.25 5.38-8.94 1.76-5.43 4.45-9.65 7-10.97 1.47-.76 2.62-2.78 4.3-7.56 3.36-9.51 5.74-12.94 10.58-15.27a11.03 11.03 0 0 0 6.22-8.74c.98-9.03 4-15.18 9.63-19.6 1.77-1.38 3.98-5.59 4.92-9.36 1.2-4.83 3.39-7.34 7.65-8.8 3.69-1.26 4.24-2 4.54-6.02.92-12.51 1.74-14.11 9.12-17.75 5.13-2.53 5.97-3.89 8.22-13.24 1.62-6.7 3.1-9.56 6.85-13.25 3.65-3.6 4.49-4.96 6.42-10.36 2.36-6.62 4.07-8.88 8.72-11.5 2.84-1.6 2.89-1.7 4.8-9.68 2.49-10.32 4.42-13.64 9.24-15.83 2.73-1.24 5.22-4.3 5.67-6.98 1.55-9.06 3.67-13.6 8.51-18.2a20.32 20.32 0 0 0 6.05-10.44c1.49-6.76 5.16-13.75 8.8-16.75 1.4-1.15 7-9.54 7-10.48 0-1.17-2.47-5.64-4.17-7.54l-1.63-1.84-7.48-.24a96.76 96.76 0 0 1-17.75-1.91c-3-.55-5.21-.7-11.05-.7-7.22 0-7.32 0-10.14-1.01-5.43-1.95-7.17-2.07-31.19-2.07-21.73 0-21.84 0-25.9-.83-8.65-1.76-10.08-1.86-21.57-1.54-10.46.3-18.96.74-25.04 1.31-1.7.16-7.14.65-12.08 1.08l-8.99.78-7.47-.91c-21.96-2.68-46.5-3.46-55.85-1.78m27.46.52c7.46.36 14.62.96 23.14 1.95l4.97.57-3.45 1.11c-6.97 2.25-13.53 8.42-13.53 12.73 0 .73-2.42 1.72-7.76 3.19-9.27 2.54-16.55 7.06-17.82 11.06-.22.68-5.7 4.03-8.04 4.93-6.21 2.36-8.26 5.75-10.8 17.8-1.61 7.73-1.9 8.44-3.95 9.92-4.33 3.11-6.7 7.77-7.58 14.95-1.36 11.03-1.09 13.96 2.05 22.03a23.12 23.12 0 0 1 1.73 7.13c1.04 10.46.88 9.91 4.16 13.55 4.02 4.46 5.4 12.19 5.45 30.47l.02 8.86.92 1.94a13.2 13.2 0 0 0 5.77 5.87c4.16 1.93 5.3 2.57 7.14 4.03 1.1.87 2.61 2.56 3.45 3.84a20.76 20.76 0 0 0 5.53 5.88 17.65 17.65 0 0 1 6.56 9.84c2.39 10.47 3.76 13.32 7.84 16.3 1.73 1.27 2.1 1.83 5.16 7.83 4.66 9.15 6.58 10.23 21.1 11.86 5.04.57 16.35.64 21.95.13 15.14-1.36 18.12-2.96 20.22-10.8 1.59-5.95 3.9-12.58 4.71-13.55.77-.92.9-1.57 1.49-7.92.35-3.8.77-7.03.92-7.16.4-.33 6.72-2.6 12.03-4.33 4.98-1.61 6.96-2.78 8.57-5.06 1-1.4 1.28-2.07 3.68-8.5l1.23-3.3 1.4-.23c.78-.12 2.08-.52 2.9-.9.8-.37 1.57-.67 1.69-.67 2.04 0 4.36-4.26 3.93-7.2a91.72 91.72 0 0 1-.34-16.99c.23-2.45.54-9.55.7-15.78.22-9.08.42-12.2 1.02-15.78 1.65-9.8 1.4-28.93-.53-41.16-.27-1.7-1.04-7.26-1.7-12.35-1.47-11.17-1.49-11.24-3.5-13.92-2.57-3.41-10.5-8.16-17.2-10.3-2.29-.74-2.58-.94-3.22-2.19-1.75-3.44-6.16-6.6-11.87-8.52-4.64-1.56-8.5-3.94-9.17-5.66-1.76-4.57-4.8-7.66-9.2-9.34-3.06-1.17-10.2-3.4-11.12-3.46-2.43-.18 12.2-1.6 22.4-2.18 16.88-.95 20.28-.86 27.44.7l6.18 1.35 22.13.17c19.52.15 22.24.24 23.15.73 1.29.7 5.6 2.08 9.4 3.02 2.45.6 3.94.71 10.02.71 5.2 0 8.61.2 12.56.7 2.98.39 9.42.91 14.32 1.16l8.9.46.8.99c1.26 1.54 3.1 4.66 3.36 5.68.3 1.2-3.06 6.66-5.09 8.29-4.8 3.85-7.55 8.78-9.37 16.77-1.44 6.32-2.81 9-5.58 10.93-5.16 3.58-7.58 8.21-9.65 18.48-.82 4.07-2.07 6.22-4 6.88-5.92 2.01-7.8 4.99-11.11 17.46a271.2 271.2 0 0 1-2.12 7.76c-.05.05-1.11.56-2.36 1.15-4.26 2-6.89 5.5-8.48 11.25-1.07 3.85-3.21 7.65-4.9 8.68-4.76 2.9-7.64 8.26-9.7 18.02-1.11 5.34-3.02 8.74-4.9 8.74-1.38 0-5.9 2.64-7.87 4.6-3.42 3.43-3.74 4.55-4.43 15.64-.24 3.82 0 3.5-3.3 4.25-5.42 1.23-7.49 3.85-8.55 10.84-.63 4.14-2.2 6.76-4.86 8.1-5.06 2.57-7.83 8.24-9.4 19.29-.73 5.2-1.82 7.09-4.64 8.07-5.43 1.88-7.38 4.22-10.93 13.1-1.08 2.73-2.2 4.91-2.94 5.78-.66.78-1.69 2.39-2.28 3.59-.59 1.2-1.28 2.26-1.53 2.36-1.67.64-4.92 7.15-5.95 11.93a11.35 11.35 0 0 1-5.07 7.17c-5.16 3.13-7.48 7.81-9.7 19.58-.81 4.3-1.59 5.52-3.7 5.85-4.63.72-5.98 1.04-8.25 1.97-1.4.58-3.13 1.58-3.85 2.23l-1.3 1.17-.38-.98c-.21-.53-.9-2.38-1.52-4.1-2.7-7.43-4.74-10-9.84-12.43-3.08-1.47-4.91-3.28-5.27-5.2-2.19-11.56-5-17.58-9.87-21.07-2.94-2.12-3.96-3.7-6.4-9.97-1.75-4.52-4.55-7.49-8.66-9.2-1.63-.69-1.92-1.3-2.9-6.22-2.55-12.88-4.48-16.55-10.18-19.35-3.34-1.65-4.35-3.01-5.86-7.94-1.25-4.06-3.2-7.44-5.54-9.58-4.5-4.11-5.7-6.52-8.38-17.01-1.4-5.48-2.46-7.82-4.23-9.3-1.22-1.04-4.9-2.88-5.75-2.88-.95 0-1.61-1.1-2.36-3.94-2.59-9.72-6.54-16.17-11.72-19.16-1.87-1.07-3.91-5.08-4.99-9.78-2.2-9.56-4.74-14.56-8.87-17.4-2.16-1.49-4.73-5.8-6.15-10.32-1.5-4.78-3.95-7.79-8.07-9.9-2.16-1.1-2.55-1.66-3.43-4.97-2.52-9.5-7.02-16.97-11.5-19.11-.73-.35-1.51-1.24-2.31-2.63-1.83-3.17-1.93-3.4-2.86-6.65-1.44-4.95-5.29-10.36-7.99-11.22-1.55-.5-2.59-3.09-7.95-19.91-1.12-3.54-2.13-5.59-3.84-7.8l-1-1.28 1.27-1.5c5.05-6.05 12.93-8.11 30.96-8.12 7.82 0 10.32-.43 17.05-2.94l3.43-1.28 22.13-.24c16.02-.18 22.55-.36 23.67-.67 8.54-2.38 16.84-2.89 33.8-2.07m39.61 3.78c5.03.67 11.4 1.98 13.9 2.86 9.79 3.43 11.68 4.6 14.26 8.78.8 1.32 1.54 1.9 4.16 3.34 4.29 2.35 6.69 3.54 7.16 3.54 2.31 0 8.3 4.13 10.75 7.41l1.75 2.34 4.28 1.57c7.17 2.64 12.8 6.2 15.45 9.78 1.74 2.36 1.42.63 3.95 21.43.65 5.38 1.4 11.18 1.67 12.9 1.57 9.95 1.44 23.83-.3 33.67-.82 4.59-.87 5.5-.79 14.92.1 10.23-.1 13.03-1.66 24.28-.8 5.72-2.04 7.92-5.89 10.46-1.78 1.17-2.9 3.37-4.67 9.2-2.73 9.02-4.01 10.1-17.28 14.5-9.87 3.28-8.85 2.06-9.1 10.87-.21 6.8-.3 7.5-1.25 10.54-.56 1.8-1.5 5.03-2.08 7.2-3.24 11.96-6.83 13.54-30.7 13.53-21.54 0-26.43-1.8-30.69-11.32-2.47-5.53-4.66-9.16-6.62-11-2.3-2.15-3.95-5.88-6.11-13.8-.8-2.89-3.75-6.94-8.71-11.9a142.22 142.22 0 0 1-4.95-5.25c-2.28-2.59-4.27-4.1-8.62-6.54-3.07-1.73-4.86-3.37-6.2-5.69l-1-1.71v-7.2c0-3.97-.25-10.45-.56-14.41l-.56-7.2-2.38-6.01c-1.3-3.3-2.74-6.39-3.2-6.86-.7-.74-.98-1.9-2.02-8.06-1.13-6.69-1.33-7.43-2.76-10.3-3.47-6.96-3.95-10.67-2.6-20.06 1.01-7.02 2.58-10.31 6.35-13.31 2.2-1.75 4.08-5.48 4.64-9.17 2.05-13.53 4.03-17.17 11.35-20.82 4.98-2.49 8.4-4.79 9.9-6.7 3.22-4.04 9.79-7.59 16.66-9 4.75-1 8.4-3.17 10.12-6.07 1.73-2.92 4.41-5.57 6.93-6.84 3.7-1.87 12.47-4.69 13.82-4.43.38.08 2 .31 3.6.53m38.26 129.92c-.49 5.82-1.68 9.15-3.9 10.9l-1.32 1.02 1.15 1.67c1.43 2.08 2.33 4.96 2.9 9.28.38 2.96.53 3.4 1.23 3.72 1.01.47 2.16-.47 2.17-1.77.03-4.84 2.34-10.18 5.28-12.17l1.27-.86-1.37-.91c-2.64-1.74-5-6.63-5.7-11.73-.4-3.06-1.42-2.55-1.71.85m-86.56 7.38c-2.03 4.7-2.02 4.41-.28 6.02l1.52 1.4 1.66-.45c3.2-.84 7.68-2.4 7.59-2.63-.14-.35-5.76-5.1-7.56-6.4l-1.55-1.1-1.38 3.16m3.62 4.3c.2.61-2.05 1.1-2.62.56-.4-.37-.41-.62-.04-1.5l.44-1.06 1.05.8c.57.45 1.1.99 1.17 1.2m51.87 27.95l-2.94.68-.6 2.79c-.83 3.85-1.94 6.46-2.98 6.96-.46.23-1.72.77-2.79 1.2-1.73.71-1.98.94-2.28 2.08-.5 2-.32 2.05 7.66 1.92 8.17-.13 7.55.19 7.87-4.02.12-1.62.39-4.68.6-6.8.54-5.39.08-5.88-4.54-4.81"/></g></svg>]]
local svg_explosion =
[[<svg xmlns="http://www.w3.org/2000/svg" version="1" viewBox="0 0 512 512"><path d="M411 123a16 16 0 1 0-22-22l-32 32-10 9-20-21a32 32 0 0 0-46 0l-16 16-3 4a192 192 0 1 0 109 109l4-3 16-16c12-13 12-33 0-46l-21-20 9-10 32-32zM192 224c-53 0-96 43-96 96a16 16 0 0 1-32 0c0-71 57-128 128-128a16 16 0 0 1 0 32zM459 149a16 16 0 1 0-23 23l16 16a16 16 0 0 0 23 0c6-7 6-17 0-23l-16-16zM340 76a16 16 0 0 0 23 0c6-7 6-17 0-23l-16-16a16 16 0 1 0-23 23l16 16zM400 64c9 0 16-7 16-16V16a16 16 0 1 0-32 0v32c0 9 7 16 16 16zM496 97h-32a16 16 0 1 0 0 32h32a16 16 0 1 0 0-32zM437 76a16 16 0 0 0 23 0l32-32a16 16 0 1 0-23-23l-32 32c-6 6-6 16 0 23z"/></svg>]]
local imgRGBA, imgWidth, imgHeight = common.RasterizeSVG(svg_charge, 0.05)
local charge_image = {
	["texture"] = draw.CreateTexture(imgRGBA, imgWidth, imgHeight),
	["width"] = imgWidth,
	["height"] = imgHeight
}

imgRGBA, imgWidth, imgHeight = common.RasterizeSVG(svg_explosion, 0.1)
local barrel_image = {
	["texture"] = draw.CreateTexture(imgRGBA, imgWidth, imgHeight),
	["width"] = imgWidth,
	["height"] = imgHeight
}

local rbvec = {}
local bavec = {}
local mapglassplace = {
	["dz_blacksite"] = "detail/detailsprites_survival",
	["dz_sirocco"] = "detail/dust_massive_detail_sprites",
	["dz_frostbite"] = "ski/detail/detailsprites_overgrown_ski",
	["dz_county"] = "detail/county/detailsprites_county"
}
local bestRemoteBombDistance = math.huge


local function RemoteBombDetector()
	if plocallive and remotebombmaster:GetValue() then
		rbvec = {}
		bestRemoteBombDistance = math.huge
		local rbs = entities.FindByClass("CBreachChargeProjectile")
		if rbs == nil then return end
		for i = 1, #rbs do
			local rb = rbs[i]
			local rbabs = rb:GetProp("m_vecOrigin")
			local Distance = (localabs - rbabs):Length()
			if Distance < 1599 then
				if bestRemoteBombDistance > Distance then bestRemoteBombDistance = Distance end
				local x, y = client.WorldToScreen(rbabs)
				if x ~= nil and y ~= nil then
					table.insert(rbvec, { x, y, rb:GetProp("m_bShouldExplode") == 1 })
				end
			end
		end
	end
end

local function BarrelsDetector()
	if plocallive and barrelmaster:GetValue() then
		bavec = {}
		local barrels = entities.FindByClass("CPhysicsProp")
		if barrels == nil then return end
		for i = 1, #barrels do
			local barrel = barrels[i]
			local baabs = barrel:GetProp("m_vecOrigin")
			local modelid = barrel:GetProp("m_nModelIndex")
			local Distance = (localabs - baabs):Length()

			if modelid == 1039 or modelid == 1448 or modelid == 1079 or modelid == 996 then
				if Distance < 1599 then
					local maxvec = barrel:GetMaxs()
					local x, y = client.WorldToScreen(baabs + Vector3(0, 0, maxvec.z))
					if x ~= nil and y ~= nil then
						table.insert(bavec, { x, y })
					end
				end
			end
		end
	end
end


callbacks.Register("CreateMove", "RemoteBombDetector", RemoteBombDetector)
callbacks.Register("CreateMove", "BarrelsDetector", BarrelsDetector)
callbacks.Register("Draw", "DrawRB", function()
	if plocallive and visualenabled then
		for _, v in pairs(rbvec) do
			draw.SetTexture(charge_image.texture)
			draw.Color(255, 255, 255, 255)
			draw.FilledRect(v[1], v[2], v[1] + charge_image.width, v[2] + charge_image.height)
			draw.OutlinedRect(v[1], v[2], v[1] + charge_image.width, v[2] + charge_image.height)
			if v[3] then
				draw.SetFont(font)
				draw.TextShadow(v[1], v[2] + 20, "explore!")
			end
		end
		if barrelmaster:GetValue() and bestRemoteBombDistance < 1599 then
			draw.SetFont(fontA)
			draw.Color(255, 0, 0, 255);
			if ENDdistance ~= 0 then
				draw.Text(screenCenterX - 680, screenH / 2 + 50,
					"RemoteBomb Distance:" .. math.floor(bestRemoteBombDistance));
			end
		end
		for _, v in pairs(bavec) do
			draw.SetTexture(barrel_image.texture)
			draw.Color(255, 255, 255, 255)
			draw.FilledRect(v[1], v[2], v[1] + barrel_image.width, v[2] + barrel_image.height)
			draw.OutlinedRect(v[1], v[2], v[1] + barrel_image.width, v[2] + barrel_image.height);
		end
	end
end)

client.AllowListener("client_disconnect");
client.AllowListener("begin_new_match");
client.AllowListener("round_prestart")
client.AllowListener("round_poststart")
client.AllowListener("round_start")
client.AllowListener("player_death")
callbacks.Register("FireGameEvent", function(e)
	local eventName = e:GetName()
	if (eventName == "client_disconnect") or (eventName == "begin_new_match") then
		drawxy = {}
		drawespxy = {}
		dronetable = {}
		ENDdistance = 0
		BestMDistance = math.huge
		plocallive = false
		player_respawn_times = {}
	elseif eventName == "round_prestart" or eventName == "round_poststart" or eventName == "round_start" then
		local map_name = engine.GetMapName()
		if mapglassplace[map_name] then
			materials.Find(mapglassplace[map_name]):SetMaterialVarFlag(4, removegrassmaster:GetValue())
		end
	elseif eventName == "player_death" and ingame() then
		if (entities.GetByUserID(e:GetInt("userid"))):IsPlayer() then
			local teamid = (entities.GetByUserID(e:GetInt("userid"))):GetPropInt("m_nSurvivalTeam")
			if teamid == -1 or teamid == nil then return end
			local playername = (entities.GetByUserID(e:GetInt("userid"))):GetName()
			if player_respawn_times[playername] then
				player_respawn_times[playername] = { globals.CurTime(), player_respawn_times[playername][2] + 10 }
			else
				player_respawn_times[playername] = { globals.CurTime(), 10 }
			end
		end
	end
end)
