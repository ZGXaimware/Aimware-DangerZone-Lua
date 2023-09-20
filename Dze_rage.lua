-- Aimware-DangerZone-Lua
--Last Updated 2023/9/15 1.1.9  (New Version)
local tab = gui.Tab(gui.Reference("Ragebot"), "DZe", "DangerZone Elite");
local main_box = gui.Groupbox(tab, "Main", 16, 16, 200, 0);
local smooth = gui.Checkbox(main_box, "main.aimsmooth", "AimSmooth", 1)
smooth:SetDescription("Aimstep like function, turn off will use fov based(Unsafe)")
local aimsmoothstep = gui.Slider(main_box, "main.aimstepsmooth", "AimSmoothStep", 3, 1, 15, 1)
local aastep        = gui.Slider(main_box, "main.aastep", "AAStep", 3, 1, 15, 1)
local aimsmoothfov  = gui.Slider(main_box, "main.fov", "AimStep Fov", 10, 20, 20, 1)
local teammatecheck = gui.Checkbox(main_box, "main.teammatecheck", "Teammate Indicater", 1)
local antiteammate  = gui.Checkbox(main_box, "main.antiteammate", "Anti-Teammate", 1)
local autoshield    = gui.Checkbox(main_box, "main.autoshield", "Autoshield", 1)
autoshield:SetDescription("Auto inject healthshot when you have shield and low hp")
local notshield = gui.Checkbox(main_box, "main.notshield", "NoHitShield", 0)
notshield:SetDescription("off aimbot when enemy who covered by shield")
local autolock = gui.Checkbox(main_box, "main.autolock", "Autolock", 1)
autolock:SetDescription("Auto switch to Enemy who close to you and visible (by Aimsmooth) ")
local shieldreturn = gui.Checkbox(main_box, "main.shieldreturn", "shieldreturn", 1)
shieldreturn:SetDescription("when weapon reload auto switch to 180 backward and when done auto reset")
local cshieldhit = gui.Checkbox(main_box, "main.shieldhit", "ShieldHit", 1)
cshieldhit:SetDescription("when shieldguy switch to another weapon or another enemy close to you then switch aimbot on")
local dzkniefbot = gui.Checkbox(main_box, "main.dzkniefbot", "DZ KniefBot", 1)
dzkniefbot:SetDescription("hammer,axe,wrench,fists enable kniefbot")
local disablefakelag = gui.Checkbox(main_box, "main.disablefakelag", "Disable FakeLag", 0)
local disabledistancevis = gui.Checkbox(main_box, "main.disabledisvis", "DisableDistanceVis", 0)
local shieldaim = gui.Checkbox(main_box, "main.shieldaim", "BunnyhopShield Attarget", 1)
disabledistancevis:SetDescription("disable distance visual function supply by che@t")
local disablevisual = gui.Checkbox(main_box, "main.disablevisual", "DisableVisual", 0)
disablevisual:SetDescription("disable all visual function supply by cheat")
local disablesound = gui.Checkbox(main_box, "main.disablesound", "Disablesound", 0)
disablesound:SetDescription("disable sound function supply by cheat")
local disablesetprop = gui.Checkbox(main_box, "main.disableprop", "DisableProp(Safe Option)", 1)
disablesetprop:SetDescription("disable all visual by setprop")
local debugaimstep = gui.Checkbox(main_box, "main.debug_reallyaimstep", "(Very Unsafe)LowDistanceaimstep", 0)
local legit_aa_box = gui.Groupbox(tab, "(Desync) Legit Anti-Aim", 232, 16, 200, 0);
local legit_aa_switch = gui.Checkbox(legit_aa_box, "aa.switch", "Master Switch", 1);
local legit_aa_key = gui.Keybox(legit_aa_box, "aa.inverter", "Inverter", 0);
local roll_aa_switch = gui.Checkbox(legit_aa_box, "aa.switch", "Roll Switch(Very Unsafe)", 0);
local switch_box = gui.Groupbox(tab, "Switch", 448, 16, 174, 0);
local switch_awall_key = gui.Keybox(switch_box, "switch.autowall", "Auto Wall", 0);
local lockmdrone = gui.Keybox(switch_box, "main.lockmdrone", "LockOnManualDrone", 17)
lockmdrone:SetDescription("lock viewangle to closet manual drone")
local lockcdrone = gui.Keybox(switch_box, "main.lockndrone", "LockOnCargoDrone", 18)
lockcdrone:SetDescription("lock viewangle to closet cargo drone")
local fasthop = gui.Keybox(switch_box, "danger.fasthop", "FastHop", 70)
fasthop:SetDescription("DZ movement exploit that makes you hop super fast.")
local hitshieldleg = gui.Keybox(switch_box, "main.hitshieldleg", "HitShieldguyLeg", 81)
hitshieldleg:SetDescription("Press key to lock you viewangle to shieldguy's foot or calf")
local backwardswitchkey = gui.Keybox(switch_box, "main.backwardkey", "BackwardKey", 0)
local forcehitteammate = gui.Keybox(switch_box, "main.forceteammate", "Force Attack Teammate", 0)
local font = draw.CreateFont("Microsoft Tai Le", 30, 1000);
local fontA = draw.CreateFont("Microsoft Tai Le", 80, 1000);
local font1 = draw.CreateFont("Verdana", 22, 400);
local needesync = true
local attacker = nil
local beaimme = false
local cbeaimme = false
local screen_w, screen_h = draw.GetScreenSize();
local needshieldprotect = false
local lowesthp = 0
local aa_side = false;
local switch_awall = false;
local targetde = 0
local healthshotinject = false
local shieldhit = false
local plocallive = false
local stargetangle = 0
local kvelocity = 0
local shieldjumper = false
local shieldjumpername = ""
local tracename = {}
local tracedistance = {}
local tracegun = {}
local tracebf = {}
local autolockmessage = ""
local normaljumper = false
local normaljumpername = ""
local normaljumpernameDistance = math.huge
local shieldjumpernameDistance = math.huge
local nvelocity = 0
local enemyalive = 0
local colorx = 255
local colory = 255
local colorz = 255
local bevisible = false
local benoscreen = false
local cvisible = false
local cnoscreen = false
local Nobest = false
local needCdisplay = false
local cname = ""
local bename = ""
local bedistance = 0
local cdistance = 0
local dronedistance = 0
local lockatdrone = false
local aimingleg = false
local beshieldistance = 0
local bestny = 0
local bestduckny = 0
local smoothon = false
local needoffaim = false
local aimstatus = ""
local bx = 0
local by = 0
local cx = 0
local cy = 0
local sx = 0
local sy = 0
local screenCenterX = screen_w * 0.5;
local loadback = false
local enemydir = true
local beshieldid = -1
local bestShieldDistance = math.huge
local bestShieldName = nil
local beshieldidname = ""
local velo = 0
local bestduckShieldDistance = math.huge
local bestduckShieldName = nil
local calledsny = false
local enemydirangle = 0
local f = 0
local n = 0
local iscommandattack1 = false
local iscommandattack2 = false
local iscommandattack3 = false
local backward = false
local teammatename = ""
local teammatedistance = math.huge
local teammateweapon = ""
local teammatehp = 0
local onlyshieldguyin = false
local aimteammate = false
local antibreachtime = 0
local isTouchingGround = true
gui.SetValue("rbot.master", true)
local weapons_table = {"asniper", "hpistol", "lmg", "pistol", "rifle", "scout", "smg", "shotgun", "sniper", "zeus","shared"};
local cachedmutedplayer = {}
local cache_weapontable = {}
for _, v in ipairs(weapons_table) do
	if v ~= "shotgun" and v ~= "sniper" then
		cache_weapontable[v] = gui.GetValue("rbot.hitscan.hitbox." .. v .. ".head.priority")
	end
end
gui.SetValue("rbot.hitscan.hitbox.shotgun.head.priority", 0)
gui.SetValue("rbot.hitscan.hitbox.sniper.head.priority", 0)
gui.SetValue("rbot.hitscan.hitbox.shotgun.body.priority", 1)
gui.SetValue("rbot.hitscan.hitbox.sniper.body.priority", 1)
local function setColors(x, y, z)
	colorx, colory, colorz = x, y, z
end
local function ingame()
	local money = entities.FindByClass("CItemCash")
	return money ~= nil and #money ~= 0
end
local function isMutedPlayerName(player)
	if cachedmutedplayer[player:GetIndex()] then
		return cachedmutedplayer[player:GetIndex()]
	else
		if entities.GetPlayerResources():GetPropInt("m_bHasCommunicationAbuseMute", player:GetIndex()) == 1 then
			cachedmutedplayer[player:GetIndex()] = player:GetName() .. "(M)"
			return player:GetName() .. "(M)"
		end
		cachedmutedplayer[player:GetIndex()] = player:GetName()
		return player:GetName()
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
	[78] = "kniefetc",
	[80] = "kniefetc",
	[70] = "RemoteBomb",
	[72] = "Tablet",
	[69] = "Fists",
}
local weaponHitable = {
	["rifle"] = 1200,
	["smg"] = 900,
	["shotgun"] = 500,
	["lmg"] = 1800,
	["pistol"] = 500,
	["hpistol"] = 500
}
local function get_weapon_class(weapon_id)
	return weaponClasses[weapon_id] or "shared"
end
local angle = 0
local pLocal = nil
local weaponstr = ""
local weaponClass = ""
local localweaponid = 0
local localabs = nil
local localindex = 0
local localheadbox = nil
local localhp = 0
local localteamid = -2

callbacks.Register("CreateMove", function()
	pLocal = entities.GetLocalPlayer()
	if pLocal == nil then
		plocallive = false
		return
	end
	weaponstr = returnweaponstr(pLocal)
	if weaponstr ~= "weapon_fists " and pLocal:IsAlive() and ingame() then
		plocallive = true
		local rab = string.sub(gui.GetValue("rbot.antiaim.base"), 2, -2)
		local r1, _ = string.find(rab, " ")
		angle = tonumber(string.sub(rab, 0, r1))
		localweaponid = pLocal:GetWeaponID() or 0
		weaponClass = get_weapon_class(localweaponid)
		localabs = pLocal:GetAbsOrigin()
		localindex = pLocal:GetIndex()
		localheadbox = pLocal:GetHitboxPosition(1)
		localhp = pLocal:GetProp("m_iHealth")
		aimstatus = gui.GetValue("rbot.aim.enable")
		local localteamidt = pLocal:GetPropInt("m_nSurvivalTeam")
		localteamid = (localteamidt == -1) and -2 or localteamidt
		local vx = pLocal:GetPropFloat('localdata', 'm_vecVelocity[0]')
		local vy = pLocal:GetPropFloat('localdata', 'm_vecVelocity[1]')
		if vx ~= nil then
			velo = math.floor(math.min(10000, math.sqrt(vx * vx + vy * vy) + 0.5))
		end
		isTouchingGround = bit.band(pLocal:GetPropInt("m_fFlags"), 1) ~= 0
	else
		plocallive = false
	end
end)
local function dynamicfov(Enemy)
	local enemy_y = (Enemy:GetHitboxPosition(1) - localheadbox):Angles().y
	local own_eye = engine.GetViewAngles().y
	local needfov = math.abs(own_eye - enemy_y)
	if math.abs(own_eye) + math.abs(enemy_y) >= (180 - math.abs(own_eye)) + (180 - math.abs(enemy_y)) then
		needfov = (180 - math.abs(own_eye)) + (180 - math.abs(enemy_y))
	end
	return math.max(needfov, 20) + 5
end
local function eyetoneedyangle(enemy_x, enemy_y, own_eyex, own_eyey)
	if enemy_x > 180 then
		enemy_x = -(360 - enemy_x)
	end
	if enemy_y > 180 then
		enemy_y = -(360 - enemy_y)
	end
	local needx = own_eyex - enemy_x
	local needy = own_eyey - enemy_y
	if needx > 180 then
		needx = needx - 360
	elseif needx < -180 then
		needx = needx + 360
	end
	if needy > 180 then
		needy = needy - 360
	elseif needy < -180 then
		needy = needy + 360
	end
	return needx, needy
end
local function detectEnemydir(Enemy)
	if Enemy == nil then return false, 180 end
	local enemy_y = ((Enemy:GetHitboxPosition(1) - pLocal:GetHitboxPosition(1)):Angles()).y
	local own_eyey = (engine.GetViewAngles()).y
	local needy = 0
	if (own_eyey >= 0 and enemy_y >= 0) or (own_eyey < 0 and enemy_y < 0) then
		needy = math.floor(math.abs(own_eyey - enemy_y))
		if enemy_y < own_eyey then
			needy = -needy
		end
	else
		if (own_eyey > 0 and enemy_y < 0) then
			if (math.abs(own_eyey) + math.abs(enemy_y)) >= ((180 - math.abs(own_eyey)) + (180 - math.abs(enemy_y))) then
				needy = math.floor(((180 - math.abs(own_eyey)) + (180 - math.abs(enemy_y))))
			else
				needy = -math.floor((math.abs(own_eyey) + math.abs(enemy_y)))
			end
		else
			if (math.abs(own_eyey) + math.abs(enemy_y)) >= ((180 - math.abs(own_eyey)) + (180 - math.abs(enemy_y))) then
				needy = -math.floor(((180 - math.abs(own_eyey)) + (180 - math.abs(enemy_y))))
			else
				needy = math.floor((math.abs(own_eyey) + math.abs(enemy_y)))
			end
		end
	end
	local backwardangle = 0
	if needy < 0 then backwardangle = needy + 180 else backwardangle = needy - 180 end
	return needy >= 0, backwardangle
end
local function stepchangeviewanglemain(own_eyex, enemy_x, own_eyey, enemy_y, step)
	local needx = nil
	local needy = nil
	local stepx = step
	local stepy = step
	local x = 0
	local y = 0
	if (own_eyex > enemy_x) then
		needx = -math.abs((own_eyex - enemy_x))
	else
		needx = math.abs((own_eyex - enemy_x))
	end
	if (own_eyey >= 0 and enemy_y >= 0) or (own_eyey < 0 and enemy_y < 0) then
		needy = math.abs(own_eyey - enemy_y)
		if enemy_y < own_eyey then
			needy = -needy
		end
	else
		if (own_eyey > 0 and enemy_y < 0) then
			if (math.abs(own_eyey) + math.abs(enemy_y)) >= ((180 - math.abs(own_eyey)) + (180 - math.abs(enemy_y))) then
				needy = ((180 - math.abs(own_eyey)) + (180 - math.abs(enemy_y)))
			else
				needy = -(math.abs(own_eyey) + math.abs(enemy_y))
			end
		else
			if (math.abs(own_eyey) + math.abs(enemy_y)) >= ((180 - math.abs(own_eyey)) + (180 - math.abs(enemy_y))) then
				needy = -((180 - math.abs(own_eyey)) + (180 - math.abs(enemy_y)))
			else
				needy = (math.abs(own_eyey) + math.abs(enemy_y))
			end
		end
	end
	if math.abs(needx) < step then
		stepx = math.abs(needx)
	end
	if needx >= 0 then
		x = stepx
	else
		x = -stepx
	end
	if math.abs(needy) < step then
		stepy = math.abs(needy)
	end
	if needy >= 0 then
		y = stepy
	else
		y = -stepy
	end
	engine.SetViewAngles(EulerAngles(own_eyex + x, own_eyey + y, 0))
end
local function smoothaim(Enemy, step, baim)
	if not (angle == 0) or Enemy == nil then return end
	if weaponClass == "shared" then return false end
	if (smooth:GetValue()) then
		gui.SetValue("rbot.aim.target.fov", aimsmoothfov:GetValue());
		local enemyangle = nil
		if weaponClass == "SHIELD" or (dzkniefbot:GetValue() and (weaponClass == "kniefetc" or weaponClass == "Fists")) or weaponClass == "RemoteBomb" then
			local Distance = math.abs((Enemy:GetAbsOrigin() - localabs):Length())
			if Distance > 450 then return false end
			enemyangle = (Enemy:GetHitboxPosition(3) - pLocal:GetHitboxPosition(1)):Angles()
		else
			if velo > 260 then return false end
			if baim then
				enemyangle = (Enemy:GetHitboxPosition(3) - pLocal:GetHitboxPosition(1)):Angles()
			else
				enemyangle = (Enemy:GetHitboxPosition(1) - pLocal:GetHitboxPosition(1)):Angles()
			end
		end
		local enemy_x = enemyangle.x
		local enemy_y = enemyangle.y
		local own_eye = engine.GetViewAngles()
		local own_eyex = own_eye.x
		local own_eyey = own_eye.y
		stepchangeviewanglemain(own_eyex, enemy_x, own_eyey, enemy_y, step)
		return true
	else
		gui.SetValue("rbot.aim.target.fov", dynamicfov(Enemy));
		return false
	end
end
local function lockteammate(Enemy, step)
	if not (angle == 0) or Enemy == nil then return end
	if weaponClass == "shared" then return false end
	if weaponClass == "kniefetc" or weaponClass == "RemoteBomb" or weaponClass == "Fists" then
		if math.abs((Enemy:GetAbsOrigin() - localabs):Length()) > 500 then
			return false
		end
	end
	if smooth:GetValue() and antiteammate:GetValue() then
		local enemyangle = nil
		if velo > 260 then return false end
		enemyangle = (Enemy:GetHitboxPosition(3) - pLocal:GetHitboxPosition(1)):Angles()
		local enemy_x = enemyangle.x
		local enemy_y = enemyangle.y
		local own_eye = engine.GetViewAngles()
		local own_eyex = own_eye.x
		local own_eyey = own_eye.y
		stepchangeviewanglemain(own_eyex, enemy_x, own_eyey, enemy_y, step)
		return true
	end
	return false
end
local function isVisible(entity)
	--checking local entity for valid
	-- local local_entity = entities.GetLocalPlayer()
	-- if not local_entity or not local_entity:IsAlive() then
	-- 	return
	-- end
	--local_eye is our view offset
	local local_eye = localabs +
		Vector3(0, 0, pLocal:GetPropFloat("localdata", "m_vecViewOffset[2]"))
	local FIRST_HITBOX_NUMBER = 0;
	local LAST_HITBOX_NUMBER = 7;
	--iterating over all hitboxes to check them to visibility
	for current_hitbox = FIRST_HITBOX_NUMBER, LAST_HITBOX_NUMBER, 1 do
		local trace_to_hitbox = engine.TraceLine(Vector3(local_eye.x, local_eye.y, local_eye.z),
			entity:GetHitboxPosition(current_hitbox))
		--checking for contents to get trace hitting something or not
		if trace_to_hitbox.contents == 0 then
			return true
		end
	end
	return false
end
local function enemyislook(Enemy)
	if Enemy == nil then return false end
	local targetDirection = localheadbox - Enemy:GetHitboxPosition(1);
	local targetAngles = targetDirection:Angles();
	local enemyeye = Enemy:GetProp("m_angEyeAngles")
	local nx, ny = eyetoneedyangle(enemyeye.x, enemyeye.y, targetAngles.x, targetAngles.y)
	if math.abs(nx) < 40 and math.abs(ny) < 30 then
		return true
	else
		return false
	end
end
local function islook(Enemy, hitboxnum)
	if Enemy == nil then return false end
	local targetDirection = Enemy:GetHitboxPosition(hitboxnum) - localheadbox
	local targetDistance = targetDirection:Length()
	local targetAngles = targetDirection:Angles()
	local myeye = engine.GetViewAngles()
	local nx, ny = eyetoneedyangle(myeye.x, myeye.y, targetAngles.x, targetAngles.y)
	if targetDistance < 400 and hitboxnum < 9 then
		return math.abs(nx) < 20 and math.abs(ny) < 15
	elseif targetDistance < 1500 then
		return math.abs(nx) < 40 and math.abs(ny) < 20
	else
		return math.abs(nx) < 40 and math.abs(ny) < 30
	end
end
local function lockonitlegprecalc(Enemy)
	if Enemy == nil then return 1 end
	if not (angle == 0) or get_weapon_class(localweaponid) == "shared" or get_weapon_class(localweaponid) == "SHIELD" then
		return 1
	end
	local Distance = (Enemy:GetAbsOrigin() - localabs):Length()
	local lcalf = engine.TraceLine(Enemy:GetHitboxPosition(9), localheadbox)
	local rcalf = engine.TraceLine(Enemy:GetHitboxPosition(10), localheadbox)
	local lfoot = engine.TraceLine(Enemy:GetHitboxPosition(11), localheadbox)
	local rfoot = engine.TraceLine(Enemy:GetHitboxPosition(12), localheadbox)
	local bestfraction = rfoot.fraction
	local tra = rfoot
	local hitboxnumber = 12
	if Distance > 300 then
		if bestfraction < rcalf.fraction then
			bestfraction = rfoot.fraction
			tra = rcalf
			hitboxnumber = 10
		end
		if bestfraction < lcalf.fraction then
			bestfraction = lcalf.fraction
			tra = lcalf
			hitboxnumber = 9
		end
		if bestfraction < lfoot.fraction then
			bestfraction = lfoot.fraction
			tra = lfoot
			hitboxnumber = 11
		end
	else
		if bestfraction < lfoot.fraction then
			bestfraction = lfoot.fraction
			tra = lfoot
			hitboxnumber = 11
		end
	end
	if tra == nil or bestfraction < 0.99 then
		return 1
	else
		return hitboxnumber
	end
end
local function lockonitlegac(Enemy, hitboxnumber, step, distance)
	if hitboxnumber ~= 1 and Enemy ~= nil then
		if get_weapon_class(pLocal:GetWeaponID()) == "shared" or get_weapon_class(pLocal:GetWeaponID()) == "SHIELD" then return end
		local enemyangle = (Enemy:GetHitboxPosition(hitboxnumber) - pLocal:GetHitboxPosition(1)):Angles()
		local enemy_x = enemyangle.x
		local enemy_y = enemyangle.y
		if distance < 101 then enemy_x = enemy_x - 5 end
		local own_eye = engine.GetViewAngles()
		local own_eyex = own_eye.x
		local own_eyey = own_eye.y
		stepchangeviewanglemain(own_eyex, enemy_x, own_eyey, enemy_y, step)
		return true
	else
		return false
	end
end
local function lockdrone(Drone, step)
	if not (angle == 0) then return end
	local tra = engine.TraceLine(Drone:GetAbsOrigin(), localheadbox)
	if tra == nil then return end
	if tra.fraction > 0.8 then
		if get_weapon_class(localweaponid) == "shared" or get_weapon_class(localweaponid) == "SHIELD" then return end
		local enemyAngles = (Drone:GetAbsOrigin() - localheadbox):Angles()
		local enemy_x = enemyAngles.x
		local enemy_y = enemyAngles.y
		local own_eye = engine.GetViewAngles()
		local own_eyex = own_eye.x
		local own_eyey = own_eye.y
		stepchangeviewanglemain(own_eyex, enemy_x, own_eyey, enemy_y, step)
	end
end
local cacheswitch = false
local function switchtobaim(switch)
	if switch == nil or switch == cacheswitch then return end
	cacheswitch = switch
	for _, v in ipairs(weapons_table) do
		if v ~= "shotgun" and v ~= "sniper" then
			if switch then
				gui.SetValue("rbot.hitscan.hitbox." .. v .. ".body.priority", 1)
				gui.SetValue("rbot.hitscan.hitbox." .. v .. ".head.priority", 0)
			else
				gui.SetValue("rbot.hitscan.hitbox." .. v .. ".body.priority", 0)
				gui.SetValue("rbot.hitscan.hitbox." .. v .. ".head.priority", cache_weapontable[v])
			end
		end
	end
end
local function autoreloadback(bedistance)
	if not shieldreturn:GetValue() or input.IsButtonDown(69) then
		return false
	end
	local pwentitie = pLocal:GetPropEntity("m_hActiveWeapon")
	if bedistance ~= nil and debugaimstep:GetValue() then
		if bedistance < 600 then
			return pwentitie:GetPropFloat("LocalActiveWeaponData", "m_flNextPrimaryAttack") - globals.CurTime() > -0.3
		end
	end
	if weaponClass ~= "sniper" and weaponClass ~= "scout" then
		return pwentitie:GetPropFloat("LocalActiveWeaponData", "m_flNextPrimaryAttack") - globals.CurTime() > 0.9
	else
		return pwentitie:GetPropFloat("LocalActiveWeaponData", "m_flNextPrimaryAttack") - globals.CurTime() > 1.3
	end
end
callbacks.Register("CreateMove", function(ucmd)
	if plocallive then
		beaimme = false
		cbeaimme = false
		kvelocity = 0
		nvelocity = 0
		Nobest = false
		aimingleg = false
		smoothon = false
		aimteammate = false
		shieldhit = false
		local Enemies = entities.FindByClass("CCSPlayer")
		if Enemies == nil then return end
		local BestEnemy = nil
		local owner = nil
		local BestDistance = math.huge
		local CBestEnemy = nil
		local Cowner = nil
		local CBestDistance = math.huge
		local totaldistance = 0
		local Closedto = false
		local shieldguy = {}
		local shieldguyny = {}
		local BestMD = nil
		local BestD = nil
		local shieldprotectenable = true
		local BestMDDistance = math.huge
		local BestDDistance = math.huge
		local bestShield = nil
		bestShieldDistance = math.huge
		bestShieldName = nil
		bestduckShieldDistance = math.huge
		bestduckShieldName = nil
		local bestduckShield = nil
		local teammate = nil
		teammatename = ""
		teammatedistance = math.huge
		teammateweapon = ""
		bx = 0
		by = 0
		cx = 0
		cy = 0
		sx = 0
		sy = 0
		if client.GetConVar("game_type") == "6" and lockmdrone:GetValue() ~= nil and lockmdrone:GetValue() ~= 0 and lockcdrone:GetValue() ~= nil and lockcdrone:GetValue() ~= 0 then
			local Drones = entities.FindByClass("CDrone")
			if Drones ~= nil then
				for i, Drone in pairs(Drones) do
					local Distance = (Drone:GetAbsOrigin() - localabs):Length()
					if Distance < 2500 then
						if Drone:GetProp("m_hCurrentPilot") ~= -1 then
							if Distance < BestMDDistance then
								BestMDDistance = Distance
								BestMD = Drone
							end
						elseif Drone:GetProp("m_hDeliveryCargo") ~= -1 then
							if Distance < BestDDistance then
								BestDDistance = Distance
								BestD = Drone
							end
						end
					end
				end
			end
		end
		lockatdrone = false
		if (BestMD ~= nil or BestD ~= nil) and (input.IsButtonDown(lockmdrone:GetValue()) or input.IsButtonDown(lockcdrone:GetValue())) and angle == 0 then
			if BestMD ~= nil and input.IsButtonDown(lockmdrone:GetValue()) then
				lockatdrone = lockdrone(BestMD, 20)
				dronedistance = BestMDDistance
			end
			if BestD ~= nil and input.IsButtonDown(lockcdrone:GetValue()) then
				lockatdrone = lockdrone(BestD, 20)
				dronedistance = BestDDistance
			end
		elseif client.GetConVar("game_type") == "6" then
			if antibreachtime + 10 > globals.CurTime() then
				if globals.TickCount() % 10 == 0 and not input.IsButtonDown(fasthop:GetValue()) then
					ucmd.buttons =
						bit.lshift(1, 5)
				end
			end
			enemyalive = 0
			for i, Enemy in pairs(Enemies) do
				if Enemy:IsAlive() then
					local btrace = engine.TraceLine(Enemy:GetHitboxPosition(1), localheadbox)
					local Distance = (Enemy:GetAbsOrigin() - localabs):Length()
					local pass = false
					if btrace.fraction > 0.09 and string.find(returnweaponstr(Enemy), "shield") ~= nil and Distance < 3001 then
						local targetDirection = localheadbox - Enemy:GetHitboxPosition(1)
						local targetAngles = targetDirection:Angles()
						local enemyeye = Enemy:GetProp("m_angEyeAngles")
						local _, ny = eyetoneedyangle(enemyeye.x, enemyeye.y, targetAngles.x, targetAngles.y)
						if (get_weapon_class(Enemy:GetWeaponID()) == "SHIELD" and math.abs(ny) < 64) or (get_weapon_class(Enemy:GetWeaponID()) ~= "SHIELD" and math.abs(ny) >= 108) then
							if Enemy:GetIndex() ~= localindex and Enemy:GetPropInt("m_nSurvivalTeam") ~= localteamid then
								table.insert(shieldguy, Enemy)
								table.insert(shieldguyny, math.abs(ny))
								if notshield:GetValue() and (math.abs(ny) < 50 or math.abs(ny) > 100) then
									pass = true
									enemyalive = enemyalive + 1
								end
							end
						end
					end
					totaldistance = totaldistance + Distance
					if returnweaponstr(Enemy) ~= "weapon_fists " and Enemy:GetIndex() ~= localindex then
						if Enemy:GetPropInt("m_nSurvivalTeam") ~= localteamid then
							if not pass then
								enemyalive = enemyalive + 1
								if Distance < CBestDistance then
									CBestDistance = Distance
									CBestEnemy = Enemy
									Cowner = isMutedPlayerName(Enemy)
								end
							end
							local btrace = engine.TraceLine(Enemy:GetHitboxPosition(1), localheadbox)
							if Distance < BestDistance and btrace.fraction > 0.99 and Distance < 5999 then
								if not pass then
									BestDistance = Distance
									BestEnemy = Enemy
									owner = isMutedPlayerName(Enemy)
								end
							end
						else
							teammate = Enemy
							teammatename = isMutedPlayerName(Enemy)
							teammatedistance = (Enemy:GetAbsOrigin() - localabs):Length()
							teammateweapon = get_weapon_class(Enemy:GetWeaponID())
							teammatehp = teammate:GetPropInt("m_iHealth")
						end
					end
				end
			end
			if #shieldguy ~= 0 and CBestEnemy == nil then
				onlyshieldguyin = true
				for _, Enemy in pairs(Enemies) do
					if Enemy:IsAlive() then
						local Distance = (Enemy:GetAbsOrigin() - localabs):Length()
						totaldistance = totaldistance + Distance
						local pass = false
						if returnweaponstr(Enemy) == "weapon_fists " or Enemy:GetIndex() == localindex then
							pass = true
						end
						if Enemy:GetPropInt("m_nSurvivalTeam") ~= localteamid and pass == false then
							enemyalive = enemyalive + 1
							if Distance < CBestDistance then
								CBestDistance = Distance
								CBestEnemy = Enemy
								Cowner = Enemy:GetName()
							end
							local btrace = engine.TraceLine(Enemy:GetHitboxPosition(1), localheadbox);
							if Distance < BestDistance and btrace.fraction
								> 0.95 and Distance < 5999 then
								BestDistance = Distance
								BestEnemy = Enemy
								owner = Enemy:GetName()
							end
						elseif Enemy:GetPropInt("m_nSurvivalTeam") == localteamid then
							teammate = Enemy
							teammatename = isMutedPlayerName(Enemy)
							teammatedistance = (Enemy:GetAbsOrigin() - localabs):Length()
							teammateweapon = get_weapon_class(Enemy:GetWeaponID())
							teammatehp = teammate:GetPropInt("m_iHealth")
						end
					end
				end
			else
				onlyshieldguyin = false
			end
			if BestEnemy == nil then
				BestDistance = CBestDistance
				BestEnemy = CBestEnemy
				owner = Cowner
				Nobest = true
			end
			if BestEnemy ~= nil then
				enemydir, enemydirangle = detectEnemydir(BestEnemy)
			else
				enemydirangle = 180
			end
			if CBestEnemy ~= nil or BestEnemy ~= nil then
				shieldjumper = false
				if shieldguy then
					for _, shield in pairs(shieldguy) do
						local Distance = (localabs - shield:GetAbsOrigin()):Length()
						local kvx = shield:GetPropFloat('localdata', 'm_vecVelocity[0]')
						local kvy = shield:GetPropFloat('localdata', 'm_vecVelocity[1]')
						if kvx then
							kvelocity = math.floor(math.min(10000, math.sqrt(kvx * kvx + kvy * kvy) + 0.5))
						end
						if Distance < 3000 and kvelocity > 399 then
							BestEnemy = shield
							BestDistance = Distance
							shieldjumper = true
							shieldjumpername = shield:GetName()
							shieldjumpernameDistance = Distance
						end
					end
				end
				tracename = {}
				tracedistance = {}
				tracegun = {}
				tracebf = {}
				for _, Enemy in pairs(Enemies) do
					if Enemy:IsAlive() and Enemy:GetIndex() ~= localindex then
						local Distance = (Enemy:GetAbsOrigin() - localabs):Length()
						local maxDistance = math.floor(totaldistance / enemyalive)
						if Distance < maxDistance and enemyalive <= 6 then
							if enemyislook(Enemy) then
								local trace = engine.TraceLine(Enemy:GetHitboxPosition(1), localheadbox)
								if (trace.fraction > 0.09 or Distance < math.floor(maxDistance / 2)) or (trace ~= nil and trace.fraction >= 0.6) then
									if Enemy:GetIndex() == BestEnemy:GetIndex() then
										beaimme = true
									elseif Enemy:GetIndex() == CBestEnemy:GetIndex() then
										cbeaimme = true
									end
									table.insert(tracename, Enemy:GetName())
									table.insert(tracedistance, math.floor(Distance))
									table.insert(tracegun, get_weapon_class(Enemy:GetWeaponID()))
									table.insert(tracebf, trace.fraction)
								end
							end
						end
					end
				end
				if weaponClass == "SHIELD" or (dzkniefbot:GetValue() and (weaponClass == "kniefetc" or weaponClass == "Fists")) then
					if weaponClass == "SHIELD" then
						gui.SetValue("esp.chams.localweapon.visible", 2)
					elseif string.find(weaponstr, "shield") ~= nil and localhp <= 60 and CBestDistance < 1000 then
						client.Command("use weapon_shield", true)
					end
					shieldhit = (BestDistance < 76)
				else
					gui.SetValue("esp.chams.localweapon.visible", 0)
				end
				Closedto = islook(BestEnemy, 1)
				local cvelocity = 0
				local bvelocity = 0
				local cvx = CBestEnemy:GetPropFloat('localdata', 'm_vecVelocity[0]')
				local cvy = CBestEnemy:GetPropFloat('localdata', 'm_vecVelocity[1]')
				local vx = BestEnemy:GetPropFloat('localdata', 'm_vecVelocity[0]')
				local vy = BestEnemy:GetPropFloat('localdata', 'm_vecVelocity[1]')
				if cvx ~= nil then
					cvelocity = math.floor(math.min(10000, math.sqrt(cvx * cvx + cvy * cvy) + 0.5))
				end
				if vx ~= nil then
					bvelocity = math.floor(math.min(10000, math.sqrt(vx * vx + vy * vy) + 0.5))
				end
				local cvbest = cvelocity >= bvelocity
				nvelocity = cvbest and cvelocity or bvelocity
				local hascalledattack3 = false
				autolockmessage = ""
				if autolock:GetValue() then
					if antiteammate:GetValue() and teammate ~= nil then
						local trace = engine.TraceLine(teammate:GetHitboxPosition(3), localheadbox)
						if trace ~= nil and trace.fraction >= 0.9 then
							if teammateweapon == "RemoteBomb" and teammatedistance < 500 and enemyislook(teammate) then
								aimteammate = lockteammate(teammate, aimsmoothstep:GetValue())
								antibreachtime = globals.CurTime()
							end
							if forcehitteammate:GetValue() ~= 0 and input.IsButtonDown(forcehitteammate:GetValue()) then
								if not aimteammate then aimteammate = lockteammate(teammate, aimsmoothstep:GetValue()) end
								hascalledattack3 = true
								if aimteammate then
									client.Command("+attack", true);
									iscommandattack3 = true
								else
									client.Command("-attack", true);
									iscommandattack3 = false
								end
							end
							smoothon = aimteammate
						end
					end
					if localhp <= 90 and localweaponid ~= 37 then
						if attacker ~= nil then
							local trace = engine.TraceLine(attacker:GetHitboxPosition(1), localheadbox)
							if trace ~= nil and trace.fraction >= 0.2 then
								if enemyislook(attacker) then
									Closedto = islook(attacker, 1)
									gui.SetValue("rbot.aim.target.selection", 2)
									if not Closedto and not smoothon then
										smoothon = smoothaim(attacker, aimsmoothstep:GetValue(), false)
									end
								end
							end
						end
						autolockmessage = "attacker based Low HP " .. localhp
					else
						if not Nobest then
							if #shieldguy == 0 and notshield:GetValue() then
								gui.SetValue("rbot.aim.target.selection", 1)
							else
								gui.SetValue("rbot.aim.target.selection", 2)
							end
							if localhp <= 109 then
								if BestDistance < 1750 and not Closedto and not smoothon then
									smoothon = smoothaim(BestEnemy, aimsmoothstep:GetValue(), false)
									autolockmessage = "Too Close and Low HP " .. localhp
								end
							else
								if BestDistance < 1250 and not Closedto and not smoothon then
									smoothon = smoothaim(BestEnemy, aimsmoothstep:GetValue(), false)
									autolockmessage = "Extremely Close"
								end
							end
						end
					end
					normaljumper = false
					if ((CBestDistance < 3000 or BestDistance < 3000) and nvelocity > 399 and Closedto ~= true) and not shieldjumper then
						if Cowner == owner and autolock:GetValue() and not smoothon then
							smoothon = smoothaim(BestEnemy, aimsmoothstep:GetValue(), false)
						end
						normaljumper = true
						if cvbest then
							normaljumpername = CBestEnemy:GetName()
							normaljumpernameDistance = CBestDistance
						else
							normaljumpername = BestEnemy:GetName()
							normaljumpernameDistance = BestDistance
						end
					else
						normaljumper = false
					end
				end
				if hascalledattack3 == false and iscommandattack3 == true then
					client.Command("-attack", true);
					iscommandattack3 = false
				end
				bx, by = client.WorldToScreen(BestEnemy:GetAbsOrigin())
				bevisible = false
				benoscreen = false
				if bx ~= nil and by ~= nil then
					if isVisible(BestEnemy) then
						bevisible = true
					end
					benoscreen = false
				else
					benoscreen = true
				end
				cvisible = false
				cnoscreen = false
				needCdisplay = false
				if Cowner ~= owner then
					needCdisplay = true
					cdistance = math.floor(CBestDistance)
					cname = Cowner
					cx, cy = client.WorldToScreen(CBestEnemy:GetAbsOrigin())
					if cx ~= nil and cy ~= nil then
						if isVisible(CBestEnemy) then
							cvisible = true
						end
					else
						cnoscreen = true
					end
				end
				bedistance = math.floor(BestDistance)
				bename = owner
				if BestDistance < 500 then
					shieldprotectenable = false
				end
			else
				enemyalive = 0
				if engine.GetServerIP() ~= "loopback" then
					shieldprotectenable = false
				end
			end
			needoffaim = false
			local shieldids = {}
			local bestShieldisUseShield = false
			local hascalledattack1 = false
			local duckshield = {}
			local duckshieldny = {}
			if #shieldguy ~= 0 and #shieldguyny ~= 0 then
				for k, shield in pairs(shieldguy) do
					local sDistance = (localabs - shield:GetAbsOrigin()):Length()
					shieldids[shield:GetIndex()] = true
					if (shield:GetWeaponID() ~= 37 or shield:GetProp('m_flDuckAmount') < 0.1) then
						if sDistance < bestShieldDistance then
							bestShieldName = shield:GetName()
							bestShieldDistance = sDistance
							bestShield = shield
							bestny = shieldguyny[k]
						end
					else
						table.insert(duckshield, shield)
						table.insert(duckshieldny, shieldguyny[k])
					end
				end
				for k, shield in pairs(duckshield) do
					local sDistance = (localabs - shield:GetAbsOrigin()):Length()
					if sDistance < bestduckShieldDistance then
						bestduckShieldName = shield:GetName()
						bestduckShieldDistance = sDistance
						bestduckShield = shield
						bestduckny = duckshieldny[k]
					end
				end
				bestShieldisUseShield = (bestShield ~= nil and bestShield:GetWeaponID() == 37) or
					(#duckshield ~= 0 and bestduckShieldDistance < bestShieldDistance)
				if bestShield ~= nil then
					sx, sy = client.WorldToScreen(bestShield:GetAbsOrigin())
				elseif bestduckShield ~= nil then
					sx, sy = client.WorldToScreen(bestduckShield:GetAbsOrigin())
				end
				if (shieldids[beshieldid] ~= true) and (beshieldistance <= bestShieldDistance or beshieldistance <= bestduckShieldDistance) and beshieldid ~= -1 and cshieldhit:GetValue() then
					if backward then
						backward = false
					end
				end
				if bestShieldisUseShield then
					if bestShield ~= nil then
						if bestduckShield ~= nil and bestShieldDistance >= bestduckShieldDistance then
							beshieldistance = math.floor(bestduckShieldDistance)
							beshieldid = bestduckShield:GetIndex()
							beshieldidname = isMutedPlayerName(bestduckShield)
						else
							beshieldistance = math.floor(bestShieldDistance)
							beshieldid = bestShield:GetIndex()
							beshieldidname = isMutedPlayerName(bestShield)
						end
					elseif bestduckShield ~= nil then
						beshieldistance = math.floor(bestduckShieldDistance)
						beshieldid = bestduckShield:GetIndex()
						beshieldidname = isMutedPlayerName(bestduckShield)
					end
				end
				if bestShield ~= nil then
					if bestShieldDistance < 500 then
						shieldprotectenable = false
					end
					needoffaim = false
					if (bestny < 50 or bestny > 100) and angle == 0 then
						local leghitbox = lockonitlegprecalc(bestShield)
						if islook(bestShield, 1) or islook(bestShield, leghitbox) then
							calledsny = false
							if Closedto and bestShieldDistance > BestDistance and #shieldguy ~= enemyalive then
								needoffaim = false
							else
								if notshield:GetValue() then needoffaim = true end
							end
						end
						if weaponHitable[weaponClass] and velo < 150 and (not smoothon or onlyshieldguyin) and autolock:GetValue() and bestShieldDistance < weaponHitable[weaponClass] and cshieldhit:GetValue() then
							hascalledattack1 = true
							needoffaim = true
							aimingleg = lockonitlegac(bestShield, leghitbox, aimsmoothstep:GetValue(), bestShieldDistance)
							if aimingleg then
								client.Command("+attack", true);
								iscommandattack1 = true
							else
								client.Command("-attack", true);
								iscommandattack1 = false
							end
						end
					end
				end
				if bestduckShield ~= nil then
					if bestduckShieldDistance < 500 then
						shieldprotectenable = false
					end
					needoffaim = false
					if (bestduckny < 50 or bestduckny > 100) and angle == 0 then
						local leghitbox = lockonitlegprecalc(bestduckShield)
						if islook(bestduckShield, 1) or islook(bestduckShield, leghitbox) then
							calledsny = true
							if Closedto and bestduckShieldDistance > BestDistance and #shieldguy ~= enemyalive then
								needoffaim = false
							else
								if notshield:GetValue() then needoffaim = true end
							end
						end
					end
				end
				if input.IsButtonDown(hitshieldleg:GetValue()) and bestShield ~= nil and not aimingleg then
					local leghitbox = lockonitlegprecalc(bestShield)
					aimingleg = lockonitlegac(bestShield, leghitbox, aimsmoothstep:GetValue(), bestShieldDistance)
					needoffaim = true
				end
				if (bestShieldDistance < 130 or bestduckShieldDistance < 130) and cshieldhit:GetValue() and bestShieldisUseShield and not backward then
					backward = true
				end
				local needtoswitchbaim = false
				if notshield:GetValue() then
					if not calledsny then
						if islook(bestShield, 3) or islook(bestShield, 1) then
							needtoswitchbaim = true
						end
					elseif islook(bestduckShield, 3) or islook(bestduckShield, 1) then
						needtoswitchbaim = true
					end
				end
				switchtobaim(needtoswitchbaim)
			elseif BestEnemy ~= nil and beshieldid == BestEnemy:GetIndex() then
				switchtobaim(false)
				beshieldid = -1
				if backward and cshieldhit:GetValue() then
					backward = false
				end
			else
				switchtobaim(false)
			end
			if iscommandattack1 and hascalledattack1 == false then
				client.Command("-attack", true);
				iscommandattack1 = false
			end
		end
		if BestDistance <= math.floor(totaldistance / enemyalive) then
			if BestDistance <= math.floor(((totaldistance / enemyalive) * 1) / 5) or BestDistance < 1000 or CBestDistance < 1000 or bestShieldDistance < 1000 then
				setColors(220, 20, 60)
			elseif BestDistance < 2500 or CBestDistance < 2500 or bestShieldDistance < 3000 or enemyalive <= 5 then
				setColors(255, 215, 0)
			else
				setColors(0, 255, 0)
			end
		else
			setColors(255, 255, 255)
		end
		if not (angle == 0) or smoothon or needoffaim or aimteammate or (not isTouchingGround and velo > 59 )then
			gui.SetValue("rbot.antiaim.condition.use", 0)
			if not (angle == 0) or needshieldprotect then
				if weaponClass == "SHIELD" or weaponClass == "kniefetc" or weaponClass == "Fists" then
					client.Command("unbind mouse1", true)
				else
					client.Command("unbind mouse1;-attack", true)
				end
			else
				client.Command("bind mouse1 +attack", true)
			end
			if aimstatus ~= '"Off"' and not smoothon and not needoffaim and not aimteammate and gui.GetValue("esp.master") and not disablesound:GetValue() and not (not isTouchingGround and velo > 59 ) then
				client.Command("play training/light_on", true)
			end
			gui.SetValue("rbot.aim.enable", "Off")
		else
			client.Command("bind mouse1 +attack", true)
			gui.SetValue("rbot.antiaim.condition.use", 1)
			local killsoundcmd = ""
			if aimstatus ~= '"Automatic"' then
				gui.SetValue("rbot.aim.enable", "Automatic")
				if weaponClass ~= "SHIELD" and weaponClass ~= "kniefetc" or weaponClass == "Fists" then
					killsoundcmd = "-attack"
					if gui.GetValue("esp.master") and not disablesound:GetValue() then
						killsoundcmd = killsoundcmd .. ";play ui/item_drop2_uncommon"
					end
				end
			end
			if killsoundcmd ~= "" then
				client.Command(killsoundcmd, true)
			end
		end
		needshieldprotect = localhp <= 75 and string.find(weaponstr, "shield") ~= nil and
			autoshield:GetValue() and shieldprotectenable
		needesync = not input.IsButtonDown(fasthop:GetValue()) and
			(weaponClass ~= "Fists" and weaponClass ~= "kniefetc" and weaponClass ~= "SHIELD") and
			legit_aa_switch:GetValue() and (localweaponid < 43 or localweaponid > 48 or not (angle == 0))
	end
end)
local function steptotargetangle(angle, targetangle, aimstep)
	if angle == targetangle then return end
	if math.abs(angle) ~= 180 then
		if (angle >= 90 and targetangle <= -90) or (angle <= -90 and targetangle >= 90) then
			targetangle = 180
		end
	else
		if angle == -180 then
			angle = 180
		elseif angle == 180 and targetangle < 0 then
			angle = -180
		end
	end
	if targetangle == 180 and angle < 0 then
		targetangle = -180
	end
	local increment = (targetangle > angle) and aimstep or -aimstep
	angle = angle + increment
	if (increment > 0 and angle >= targetangle) or (increment < 0 and angle <= targetangle) then
		angle = targetangle
	end
	local state = angle .. "Desync"
	gui.SetValue("rbot.antiaim.base", state)
end
callbacks.Register("CreateMove", function(ucmd)
	if plocallive then
		if not disablesetprop:GetValue() then
			pLocal:SetProp("m_flHealthShotBoostExpirationTime", -1)
			local tablets = entities.FindByClass("CTablet")
			if tablets ~= nil then
				for i = 1, #tablets do
					local tablet = tablets[i]
					tablet:SetProp("m_bTabletReceptionIsBlocked", false)
				end
			end
		end
		if roll_aa_switch:GetValue() then
			gui.SetValue("misc.antiuntrusted", 0)
			gui.SetValue("rbot.antiaim.advanced.roll", 1)
		else
			gui.SetValue("misc.antiuntrusted", 1)
			gui.SetValue("rbot.antiaim.advanced.roll", 0)
		end
		if needesync then
			local sign = aa_side and 1 or -1
			targetde = 58 * sign
			if backward then
				targetde = 40 * sign
			end
			if gui.GetValue("rbot.antiaim.base.rotation") ~= targetde then
				gui.SetValue("rbot.antiaim.base.rotation", targetde)
			end
		elseif gui.GetValue("rbot.antiaim.base.rotation") ~= 0 then
			gui.SetValue("rbot.antiaim.base.rotation", 0)
		end
		if needshieldprotect then
			if lowesthp >= localhp or lowesthp == 0 then
				if string.find(weaponstr, "healthshot") ~= nil then
					healthshotinject = true
					backward = true
					if localweaponid ~= 57 and not input.IsButtonDown(69) then
						client.Command("use weapon_healthshot", true)
					elseif (pLocal:GetPropEntity("m_hActiveWeapon")):GetPropInt("m_iIronSightMode") ~= 2 then
						ucmd.buttons = 1
						lowesthp = localhp
					end
				end
			else
				healthshotinject = false
				if lowesthp ~= 0 and localhp - lowesthp > 45 then
					lowesthp = 0
				end
			end
		else
			healthshotinject = false
			lowesthp = 0
			if localweaponid > 71 or (localweaponid > 41 and localweaponid < 50) then
				gui.SetValue("esp.world.thirdperson", 0)
			end
		end
		if string.find(weaponstr, "shield") and shieldaim:GetValue() then
			if enemydir then
				stargetangle = benoscreen and (weaponClass == "SHIELD" and 135 or -45) or
					(weaponClass == "SHIELD" and 45 or -135)
			else
				stargetangle = benoscreen and (weaponClass == "SHIELD" and -135 or 45) or
					(weaponClass == "SHIELD" and -45 or 135)
			end
		else
			stargetangle = enemydir and 45 or -45
		end
		loadback = false
		if not (velo < 169 and (math.abs(angle) > 135 and math.abs(angle) < 45)) and fasthop:GetValue() ~= nil and fasthop:GetValue() ~= 0 and input.IsButtonDown(fasthop:GetValue()) then
			ucmd.buttons = f < 2 and (f == 0 and ucmd.buttons - 4 or (f == 1 and ucmd.buttons - 2 or ucmd.buttons)) or
				(n and ucmd.buttons - 6 or ucmd.buttons);
			local rappeling = pLocal:GetProp("m_bIsSpawnRappelling") == 1
			local in_water = pLocal:GetProp("m_nWaterLevel") ~= 0
			local adpressed = input.IsButtonDown(65) or input.IsButtonDown(68)
			if velo > 399 and not adpressed then
				client.Command("+duck", true);
			else
				client.Command("-duck", true);
			end
			f, n = f + 1, isTouchingGround;
			gui.SetValue("misc.strafe.enable", true)
			gui.SetValue("misc.strafe.air",
				not isTouchingGround and not rappeling and not in_water and angle == stargetangle and not adpressed and
				velo < 700);
			gui.SetValue("misc.fakelag.enable", false);
			steptotargetangle(angle, stargetangle, aastep:GetValue())
		else
			--gui.SetValue("misc.strafe.enable", false)
			if weaponClass == "smg" then
				if localweaponid == 17 or localweaponid == 26 then
					gui.SetValue("rbot.hitscan.accuracy.smg.hitchance", 10)
					gui.SetValue("rbot.hitscan.accuracy.smg.hitchanceburst", 10)
					gui.SetValue("rbot.hitscan.accuracy.smg.mindamage", 5)
				else
					gui.SetValue("rbot.hitscan.accuracy.smg.hitchance", 40)
					gui.SetValue("rbot.hitscan.accuracy.smg.hitchanceburst", 40)
					gui.SetValue("rbot.hitscan.accuracy.smg.mindamage", 15)
				end
			elseif shieldhit and (weaponClass == "SHIELD" or (dzkniefbot:GetValue() and (weaponClass == "kniefetc" or weaponClass == "Fists"))) then
				ucmd.buttons = 1
			end
			if not input.IsButtonDown(17) and pLocal:GetProp('m_flDuckAmount') >= 0.1 then
				client.Command("-duck", true);
			end
			if localweaponid ~= 9 and not disablefakelag:GetValue() then
				gui.SetValue("misc.fakelag.enable", true);
			end
			loadback = autoreloadback(bedistance)
			if (backward or loadback) and (string.find(weaponstr, "shield") ~= nil and localweaponid ~= 37) and enemydirangle ~= 0 then
				if angle ~= enemydirangle then
					if not loadback and angle == 0 then
						gui.SetValue("esp.world.thirdperson", 1)
					end
					steptotargetangle(angle, enemydirangle, aastep:GetValue())
				end
			else
				if backward then
					backward = false
				end
				if not (angle == 0) then
					steptotargetangle(angle, 0, aastep:GetValue())
				end
			end
		end
	end
end);
local function switch()
	if plocallive then
		if legit_aa_key:GetValue() ~= 0 then
			if input.IsButtonPressed(legit_aa_key:GetValue()) then
				aa_side = not aa_side
			end
		end
		if backwardswitchkey:GetValue() ~= 0 then
			if input.IsButtonPressed(backwardswitchkey:GetValue()) then
				backward = not backward
			end
		end
		f = (fasthop:GetValue() ~= nil and fasthop:GetValue() ~= 0 and input.IsButtonPressed(fasthop:GetValue())) and
			0 or f;
	end
	if disablevisual:GetValue() then
		gui.SetValue("esp.master", 0)
		gui.SetValue("misc.log.console", 0)
		return
	else
		if not gui.GetValue("esp.master") then gui.SetValue("esp.master", 1) end
		if not gui.GetValue("misc.log.console") then gui.SetValue("misc.log.console", 1) end
	end
	if plocallive then
		draw.SetFont(font1)
		draw.Color(255, 255, 255, 255)
		draw.Text(screen_w / 2 - 738, screen_h / 2, "Fov:")
		draw.Text(screen_w / 2 - 783, screen_h / 2 + 40, "Autowall:")
		draw.Text(screen_w / 2 - 783, screen_h / 2 + 60, "Resolver:")
		draw.Color(255, 0, 0, 255)
		draw.Text(screen_w / 2 - 688, screen_h / 2, gui.GetValue("rbot.aim.target.fov"))
		local switch_awall_key_value = switch_awall_key:GetValue()
		if switch_awall then
			draw.Color(0, 255, 0, 255)
			draw.Text(screen_w / 2 - 688, screen_h / 2 + 40, "On")
		else
			draw.Color(255, 0, 0, 255)
			draw.Text(screen_w / 2 - 688, screen_h / 2 + 40, "Off")
		end
		if gui.GetValue("rbot.aim.posadj.resolver") ~= 0 then
			draw.Color(0, 255, 0, 255)
			draw.Text(screen_w / 2 - 688, screen_h / 2 + 60, "On")
		else
			draw.Color(255, 0, 0, 255)
			draw.Text(screen_w / 2 - 688, screen_h / 2 + 60, "Off")
		end
		if switch_awall_key_value ~= 0 and input.IsButtonPressed(switch_awall_key_value) then
			switch_awall = not switch_awall
			local autowall_value = switch_awall and 1 or 0
			for _, v in ipairs(weapons_table) do
				gui.SetValue("rbot.hitscan.accuracy." .. v .. ".autowall", autowall_value)
			end
		end
		if not disabledistancevis:GetValue() then
			if enemyalive ~= 0 then
				draw.SetFont(fontA)
				if shieldjumper then
					draw.Color(255, 0, 0, 255);
					draw.Text(screen_w / 2, screen_h / 2 + 200,
						math.floor(shieldjumpernameDistance) .. " jumper(Shield)!Name:" .. shieldjumpername)
				elseif normaljumper then
					draw.Color(255, 255, 255, 255);
					draw.Text(screen_w / 2, screen_h / 2 + 200,
						math.floor(normaljumpernameDistance) .. " jumper!Name:" .. normaljumpername);
				end
				if #tracename ~= 0 then
					draw.SetFont(font)
					draw.Color(255, 255, 255, 255)
					local nextstep = 0
					for i = 1, #tracename do
						nextstep = nextstep + 40
						draw.Text(screen_w / 2 - 400, screen_h / 2 + nextstep,
							tracename[i] ..
							" " ..
							tracedistance[i] ..
							" " ..
							tracegun[i] ..
							" " .. string.format("%.1f", tracebf[i])
						)
					end
				end
				if autolockmessage ~= "" then
					draw.SetFont(font)
					draw.Color(255, 0, 0, 255)
					draw.Text(screen_w / 2, screen_h / 2 + 200, autolockmessage)
				end
				draw.Color(colorx, colory, colorz, 255)
				draw.SetFont(font);
				if bevisible then
					draw.Text(screen_w / 2 - 180, screen_h / 2 + 80, "Visible")
				elseif benoscreen then
					draw.SetFont(fontA)
					draw.Text(screen_w / 2 - 180, screen_h / 2 + 80, "Be NoScreen!")
				end
				draw.SetFont(font);
				if cvisible then
					draw.Text(screen_w / 2 - 180, screen_h / 2 + 140, "CVisible")
				elseif cnoscreen then
					draw.SetFont(fontA)
					draw.Text(screen_w / 2 - 180, screen_h / 2 + 140, "C NoScreen!")
				end
				if Nobest and not cbeaimme then
					draw.SetFont(font);
					draw.Text(screen_w / 2 - 400, screen_h / 2 - 250, "Safe")
				end
				if beaimme then
					draw.SetFont(fontA)
					draw.Text(screen_w / 2 - 400, screen_h / 2 - 250, "BE aim me!")
				end
				if cbeaimme then
					draw.SetFont(fontA)
					draw.Text(screen_w / 2 - 400, screen_h / 2 - 300, "CBE aim me!")
				end
				draw.SetFont(font);
				if bestShieldName ~= nil then
					draw.Text(screen_w / 2, screen_h / 2 - 300, math.floor(bestShieldDistance))
					draw.Text(screen_w / 2 + 200, screen_h / 2 - 300, bestShieldName .. "(S)")
					if sx ~= nil and sx ~= 0 then
						draw.Line(sx, sy, screenCenterX, 0)
					end
				elseif bestduckShieldName ~= nil then
					draw.Text(screen_w / 2, screen_h / 2 - 300, math.floor(bestduckShieldDistance))
					draw.Text(screen_w / 2 + 200, screen_h / 2 - 300, bestduckShieldName .. "(Sd)")
					if sx ~= nil and sx ~= 0 then
						draw.Line(sx, sy, screenCenterX, 0)
					end
				end
				if needCdisplay then
					draw.Text(screen_w / 2, screen_h / 2 - 250, cdistance)
					draw.Text(screen_w / 2 + 200, screen_h / 2 - 250, cname .. "(C)")
				end
				draw.Text(screen_w / 2, screen_h / 2 - 200, bedistance);
				draw.Text(screen_w / 2 + 200, screen_h / 2 - 200, bename .. "(B)");
				if teammatecheck:GetValue() and teammatename ~= "" then
					if teammateweapon == "RemoteBomb" and teammatedistance < 1500 then
						draw.Color(255, 0, 0, 255)
						draw.SetFont(fontA)
						draw.Text(screen_w / 2 - 500, screen_h / 2 + 50, math.floor(teammatehp))
						draw.Text(screen_w / 2 - 200, screen_h / 2 + 50, math.floor(teammatedistance))
						draw.Text(screen_w / 2 + 100, screen_h / 2 + 50, teammateweapon)
						draw.Text(screen_w / 2 + 400, screen_h / 2 + 50, teammatename .. "(T)")
					else
						draw.Text(screen_w / 2 - 100, screen_h / 2 + 50, math.floor(teammatehp))
						draw.Text(screen_w / 2, screen_h / 2 + 50, math.floor(teammatedistance))
						draw.Text(screen_w / 2 + 100, screen_h / 2 + 50, teammateweapon)
						draw.Text(screen_w / 2 + 200, screen_h / 2 + 50, teammatename .. "(T)")
					end
				end
			end
		end
		draw.SetFont(font1);
		draw.Color(255, 255, 255, 255)
		if smooth:GetValue() then
			draw.Text(screen_w / 2 - 782, screen_h / 2 + 20, smoothon and "SmoothAim Active" or "SmoothAim")
		end
		if autoshield:GetValue() then
			draw.Text(screen_w / 2 - 782, screen_h / 2 - 40,
				string.find(weaponstr, "shield") and "AutoShield" or "AutoShield NoShield")
		end
		if notshield:GetValue() then
			if math.floor(bestShieldDistance) < 2000 or math.floor(bestduckShieldDistance) < 2000 then
				local outvalue = bestShieldDistance >= bestduckShieldDistance and math.floor(bestduckShieldDistance) or
					math.floor(bestShieldDistance)
				draw.Text(screen_w / 2 - 782, screen_h / 2 - 60, "NohitShield " .. outvalue)
			else
				draw.Text(screen_w / 2 - 782, screen_h / 2 - 60, "NohitShield")
			end
		end
		draw.SetFont(font1);
		draw.Color(255, 255, 255, 255)
		if autolock:GetValue() then
			if localhp <= 90 then
				draw.Text(screen_w / 2 - 782, screen_h / 2 - 80, "AutoLockAttacker")
				if attacker ~= nil then
					draw.Text(screen_w / 2 - 550, screen_h / 2 - 80, " target: " .. attacker:GetName())
				end
			else
				draw.Text(screen_w / 2 - 782, screen_h / 2 - 80, "AutoLock")
			end
		end
		if shieldreturn:GetValue() then
			draw.Text(screen_w / 2 - 782, screen_h / 2 - 120, "Shieldreturn")
		end
		if cshieldhit:GetValue() then
			draw.Text(screen_w / 2 - 782, screen_h / 2 - 140,
				beshieldid == -1 and "ShieldHit" or "ShieldHit " .. beshieldidname)
		end
		if roll_aa_switch:GetValue() then
			draw.Text(screen_w / 2 - 782, screen_h / 2 - 160, "Roll AA")
		end
		if antiteammate:GetValue() then
			draw.Text(screen_w / 2 - 782, screen_h / 2 - 180, "Anti-Teammate")
		end
		if backward then
			draw.Text(screen_w / 2 - 782, screen_h / 2 - 200, "180 Backward")
		end
		draw.SetFont(fontA);
		if lockatdrone then
			draw.Text(screen_w / 2 - 550, screen_h / 2 - 160, "AimDrone: " .. dronedistance)
		elseif aimingleg then
			draw.Text(screen_w / 2 - 550, screen_h / 2 - 160,
				"AimLeg! " .. math.floor(bestShieldDistance))
		elseif aimteammate then
			draw.Text(screen_w / 2 - 550, screen_h / 2 - 160, "	Teammate AIM!")
		elseif smoothon then
			draw.Text(screen_w / 2 - 550, screen_h / 2 - 160, "AimLOCK!")
		elseif needoffaim and (bestny or bestduckny) then
			local ny = calledsny and bestduckny or bestny
			draw.Text(screen_w / 2 - 550, screen_h / 2 - 160, "AimShield! angle: " .. math.floor(ny))
		end
		if aimstatus == '"Off"' and not needoffaim and not smoothon and not aimteammate then
			if loadback then
				draw.Text(screen_w / 2 - 450, screen_h / 2 - 160, "AAyaw " .. angle .. " LoadBack!")
			elseif healthshotinject then
				draw.Text(screen_w / 2 - 500, screen_h / 2 - 220, "AAyaw " .. angle .. " Protecting!")
			elseif (velo > 59 and not isTouchingGround) then
				draw.Text(screen_w / 2 - 500, screen_h / 2 - 220, "AAyaw: " .. angle .. " inAir!")
			else
				draw.Text(screen_w / 2 - 450, screen_h / 2 - 160, "AAyaw " .. angle .. " Aimbot disabled!")
			end
		end
		if not disabledistancevis:GetValue() then
			draw.SetFont(fontA)
			if targetde < 0 then
				draw.Text(screen_w / 2, screen_h / 2 - 40, "<-")
			elseif targetde > 0 then
				draw.Text(screen_w / 2, screen_h / 2 - 40, "->")
			elseif not (angle == 0) then
				draw.Text(screen_w / 2, screen_h / 2 - 40, "V")
			end
			draw.Color(colorx, colory, colorz, 255)
			if not benoscreen and bx ~= 0 then
				draw.Line(bx, by, screenCenterX, 0)
			end
			if not cnoscreen and cx ~= 0 then
				draw.Line(cx, cy, screenCenterX, 0)
			end
		end
	end
end
local weaponEvents = {
	["weapon_fire"] = true,
	["bullet_impact"] = true
}
callbacks.Register("Draw", "switch", switch);
client.AllowListener("weapon_fire");
client.AllowListener("bullet_impact");
client.Command("unbind mouse3;unbind shift;unbind q", true)
client.AllowListener("client_disconnect");
client.AllowListener("begin_new_match");
callbacks.Register("FireGameEvent", function(e)
	local eventName = e:GetName()
	if plocallive then
		if weaponEvents[eventName] and localhp <= 90 and plocallive then
			if client.GetPlayerIndexByUserID(e:GetInt("userid")) ~= localindex and entities.GetByUserID(e:GetInt("userid")):GetPropInt("m_nSurvivalTeam") ~= localteamid then
				attacker = entities.GetByUserID(e:GetInt("userid"))
			end
		else
			attacker = nil
		end
	end
	if (eventName == "client_disconnect") or (eventName == "begin_new_match") then
		antibreachtime = 0
		plocallive = false
		beshieldid = -1
		cachedmutedplayer = {}
		onlyshieldguyin = false
		isTouchingGround = true
		gui.SetValue("rbot.antiaim.base", "0 Desync")
		gui.SetValue("rbot.antiaim.condition.autodir.targets", 0)
		gui.SetValue("rbot.aim.enable", "Off")
		gui.SetValue("rbot.antiaim.base.rotation", 0)
	end
end)
