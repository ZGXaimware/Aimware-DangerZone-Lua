local warning = gui.Checkbox(gui.Reference("Visuals", "Overlay", "Enemy"), "vis.dzesp", "DangerZoneESP", 1)

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
		--if string.find(recstr,"weapon_tablet") == nil then
		--	print("notablet")
		--end
	end
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
	[70] = "RemoteBomb"
}

local function get_weapon_class(weapon_id)
	return weaponClasses[weapon_id] or "shared"
end

local playerdata = {}
local abuseteam = {}

callbacks.Register("CreateMove", function()
	local pLocal = entities.GetLocalPlayer()
	if pLocal == nil or not pLocal:IsAlive() then return end
	local players = entities.FindByClass("CCSPlayer")
	playerdata = {}
	abuseteam = {}

	if players ~= nil then
		for i, player in ipairs(players) do
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
	end
end)


local function drawEspHook(builder)
	if not warning:GetValue() then return end

	local pLocal = entities.GetLocalPlayer()
	if pLocal == nil or not pLocal:IsAlive() then return end

	local builder_entity = builder:GetEntity()
	if builder_entity == nil then return end
	if not builder_entity:IsPlayer() or not builder_entity:IsAlive() then return end

	local current_weapon = builder_entity:GetPropEntity("m_hActiveWeapon")
	if current_weapon:GetProp("m_iClip1") ~= nil then
		builder:Color(0, 150, 240, 255)
		builder:AddTextBottom(tostring(current_weapon:GetProp("m_iClip1") ..
			"/" .. current_weapon:GetProp("m_iPrimaryReserveAmmoCount")))
	end
	local lpabs = builder_entity:GetAbsOrigin()
	local Distance = math.floor((lpabs - pLocal:GetAbsOrigin()):Length())
	if Distance ~= nil then
		builder:AddTextLeft("D:" .. Distance)
	end

	-- local velocity = 0
	-- local vx = builder_entity:GetPropFloat('localdata', 'm_vecVelocity[0]')
	-- local vy = builder_entity:GetPropFloat('localdata', 'm_vecVelocity[1]')
	-- if vx ~= nil then
	-- 	velocity = math.floor(math.min(10000, math.sqrt(vx * vx + vy * vy) + 0.5))
	-- end
	-- if velocity ~= nil then
	-- 	builder:AddTextRight("V:" .. math.floor(velocity))
	-- end
	builder:Color(255, 255, 255, 255)

	local righttext = ""
	local teamstr = "team" .. builder_entity:GetPropInt("m_nSurvivalTeam")
	local ischeater = entities.GetPlayerResources():GetPropInt("m_bHasCommunicationAbuseMute", builder_entity:GetIndex())
	--print(playerdata["team0"][1][2])

	if teamstr == "team-1" then
		if ischeater == 1 then
			righttext = "Cheater Solo"
		else
			righttext = "Solo"
		end
	else
		if playerdata[teamstr] ~= nil and #playerdata[teamstr] > 1 then
			for i, data in ipairs(playerdata[teamstr]) do
				if data[1] ~= builder_entity:GetIndex() then
					if abuseteam[teamstr] then
						if ischeater == 1 then
							righttext = data[4] and "(M)(Cheater) " .. math.abs((lpabs - data[3]):Length()) .. " " .. data[2] or "(M)(Cheater)(Dead) " .. data[2]
						else
							righttext = data[4] and "(Cheater) " .. math.abs((lpabs - data[3]):Length()) .. " " .. data[2] or "(Cheater)(Dead) " .. data[2]
						end
					else
						righttext = data[4] and math.abs((lpabs - data[3]):Length()) .. " " .. data[2] or "(Dead) "  .. data[2]
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

	builder:Color(255, 0, 0, 255)
	local guntype = get_weapon_class(builder_entity:GetWeaponID())
	if string.find(returnweaponstr(builder_entity), "shield") ~= nil and guntype ~= "SHIELD" then
		builder:AddTextTop("(S)" .. guntype)
	else
		builder:AddTextTop(guntype)
	end
end


callbacks.Register('DrawESP', "drawEspHook", drawEspHook)
