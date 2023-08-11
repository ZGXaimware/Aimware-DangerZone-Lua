-- local Kill_BM_Spams = {
--     "so ez",
--     "get clapped",
--     "did that hurt?",
--     "do you want me to blow on that?",
--     "btw you are supposed to shoot me.",
--     "sry I didn't know you were retarded",
--     "Is your screen even on?",
--     "CSGO->Game->Game->TurnOnInstructorMessages that might help you",
--     "better luck next time",
--     "bro how did you hit the accept button with that aim???",
--     "ff?",
--     "I can teach you if you want.",
--     "xD my cat killed you",
--     "better do you homework",
--     "Which controller are you using???",
--     "Did you ever think about suicide? It would make things quicker.",
--     "is that a decoy, or are you trying to shoot somebody?",
--     "If this guy was the shooter harambe would still be alive",
--     "CS:GO is too hard for you m8 maybe consider a game that requires less skill, like idk.... solitaire"
-- };
-- local Death_BM_Spams = {
--     "nice luck",
--     "sry my brother was playing",
--     "doesn't count my mom came in",
--     "ok now I start playing",
--     "I think you should be in bed already",
--     "welcome to the scoreboard",
--     "Theres more silver here than in the cutlery drawer",
--     "I'm not trash talking, I'm talking to trash.",
--     "We may have loose the game, but at the end of the day we, unlike you, are not russians.",
--     "Dude you're so fat you run out of breath rushing B",
--     "Rest in spaghetti never forgetti",
--     "LISTEN HERE YOU LITTLE FUCKER, WHEN I WAS YOUR AGE, PLUTO WAS A PLANET!"
-- };
local General_BM_Spams = {
    "我是B站UP主will118011,需要头号特训强力科技加 扣群114514",
    "bilibili uploader will118011 here, if u need almost perfect dz che@ts add qq group 114514"
};

local General_GOV_BM_Spams = {
"disabled",
"disable"
};

-- Better Spam Tab
local ref = gui.Tab(gui.Reference("Misc"), "RandomSpam", "RandomSpam/Name")

--Kill BM Spam
local Kill_BM_Group = gui.Groupbox(ref, "Kill Message", 15, 15, 294);
-- local Kill_BM_Act = gui.Combobox(Kill_BM_Group, "lua_combobox", "Enable", "off", "standard", "custom");
-- local Kill_BM_Edit = gui.Editbox(Kill_BM_Group, "lua_editbox", "custom message:");
-- local Kill_BM_STAN_NAME = gui.Checkbox(Kill_BM_Group, "lua_checkbox", "activate @player name", false);

--Death BM Spam
local Death_BM_Group = gui.Groupbox(ref, "Death Message", 327, 15, 294);
-- local Death_BM_Act = gui.Combobox(Death_BM_Group, "lua_combobox", "Enable", "off", "standard", "custom");
-- local Death_BM_Edit = gui.Editbox(Death_BM_Group, "lua_editbox", "custom message:");
-- local Death_BM_STAN_NAME = gui.Checkbox(Death_BM_Group, "lua_checkbox", "activate @player name", false);

local randommaster = gui.Checkbox(Death_BM_Group, "rnmaster", "RandomMasterSwitch")
local steamerid = gui.Editbox(Kill_BM_Group, "SteamerID", "SteamerUserName")
local manualstart = gui.Keybox(Death_BM_Group, "ManualChangeName", "ManualChangeNameKey", 119)
local staticname = gui.Editbox(Kill_BM_Group, "staticName", "staticName")
local ontimechange = gui.Checkbox(Death_BM_Group, "ontimechange", "RandomChangename", 0);
local thisname = gui.Editbox(Kill_BM_Group, "plocalname", "plocalName")













--General BM Spam
local General_BM_Group = gui.Groupbox(ref, "Spam Message", 15, 230, 607);
local waitstreamer = gui.Checkbox(General_BM_Group, "waitstreamer", "WaitForSteamer", 0);
local General_BM_Act = gui.Combobox(General_BM_Group, "lua_combobox", "Enable", "off", "standard", "custom", "banLIVE");
local General_BM_Edit = gui.Editbox(General_BM_Group, "lua_editbox", "custom message:");
local General_BM_Speed = gui.Slider(General_BM_Group, "lua_slider", "Delay in Seconds", 1, 1, 60)
local found = false

local namelist = { "James", "翻斗花园第一突破手", "Kamisama", "我永远喜欢樱岛麻衣", "CSGO大茄子",
    "WDNMD", "Selector", "-=Smart=-", "理塘最強伝説!純真丁一郎", "当爱已成往事", "Astender", "Bubbpy",
    ":D flash", "Revenger", "蜜雪冰城甜蜜蜜", "百香果果汁", "Slayer", "YaYa大D", "Cz7Teacher", "可惜悦刻没有电",
    "Aqua Minato", "和泉紗霧", "Apex顶猎", "DeagleKing", "Lê Minh", "龍が如く", "初音未来", "Rolicon",
    "对镜子倾诉心事", "Miku", "Sksleetion", "QZSekec", "雷军!金凡!", "小爱同学", "Rosetta", "Zim",
    "polak", "swissguy", "m0nsterJ", "樱岛麻衣", "百事可乐", "可口可乐", "Kawaii", "StormGamer",
    "FireDragon",
    "IceQueen",
    "ShadowHunter",
    "NightmareSlayer",
    "BlazingPhoenix",
    "MysticWizard",
    "EternalGamer",
    "SteelAssassin",
    "SavageSamurai",
    "SilentNinja",
    "CrimsonReaper",
    "LuckyCharm",
    "RapidFire",
    "FearlessWarrior",
    "GhostRider",
    "PhantomSniper",
    "RadiantStar",
    "EnigmaMaster",
    "Dragonborn",
    "Frostbite",
    "CyberPunk",
    "ThunderStorm",
    "DoomBringer",
    "SkyWalker",
    "EagleEye",
    "MoonlightShadow",
    "CrazyGamer",
    "SilverBullet",
    "CaffeineAddict",
    "SpartanWarrior",
    "GamingLegend",
    "Mastermind",
    "DigitalMage",
    "CaptainAwesome",
    "StealthyViper",
    "FrozenFury",
    "PhoenixRising",
    "SupremeCommander",
    "UltimateGamer",
    "DragonSlayer",
    "NinjaAssassin",
    "ShadowBlade",
    "StormBreaker",
    "Firestorm",
    "IceWizard",
    "LunarEclipse",
    "SpectralKnight",
    "Nightfall",
    "BladeRunner",
    "MysticDreamer",
    "EternalChampion",
    "StealthSniper",
    "SamuraiWarrior",
    "CrimsonTide",
    "LuckyStar",
    "RapidStrike",
    "FearlessHero",
    "GhostlyPresence",
    "PhantomStriker",
    "RadiantGlow",
    "EnigmaHunter",
    "DragonHeart",
    "FrostGuardian",
    "CyberHero",
    "ThunderBolt",
    "DoomDestroyer",
    "SkyHigh",
    "EagleGaze",
    "Moonshadow",
    "CrazySpartan",
    "SilverStreak",
    "CaffeineJunkie",
    "GamingPro",
    "MasterOfPuzzles",
    "DigitalNinja",
    "CaptainMarvel",
    "StealthWizard",
    "FrozenFury",
    "PhoenixFire",
    "SupremeLeader",
    "UltimateWarrior",
    "DragonFury",
    "NinjaMaster",
    "ShadowWalker",
    "StormSeeker",
    "FireBlaze",
    "IcePrince",
    "LunarGuardian",
    "SpectralReaper",
    "Nightshade",
    "BladeMaster",
    "宇智波", "四代", "柯南", "赤瞳", "幻影", "奥特曼", "维特", "白色恶魔", "诺基亚", "海绵宝宝",
    "巴斯光年", "蓝精灵", "大力水手", "史瑞克", "麦兜",
    "皮卡丘", "小樱", "路飞", "猪猪侠", "史努比", "米老鼠", "小飞象", "小猪佩奇", "哆啦A梦",
    "蜡笔小新", "睡美人", "仙履奇缘", "铁臂阿童木", "风骚侧脸", "蛇精病",
    "财神爷", "奶茶妹妹", "糖糖", "宝藏男孩", "王子殿下", "高冷女王", "唯美小公主", "帅气大叔",
    "甜蜜情人", "摩登时尚", "热血战士", "潮人一族", "宅男女神", "乐活小鲜肉",
    "超级粉丝", "小可爱", "迷人小猫咪", "游戏高手", "逗比小萌物", "学霸天团", "小资情调",
    "悍匪", "灰姑娘", "宅女大佬", "黑妞", "憨豆先生", "倔强的小牛",
    "仗剑走天涯", "绝世小妖精", "流氓兔", "二哈", "寻找幸福", "霸气总裁", "痞子", "绝命毒师",
    "草帽海贼团", "美眉杀手", "忍者神龟", "金牌咖啡师", "脑洞大开", "魔法少女",
    "战神阿瑞斯", "拼命三郎", "爱哭鬼", "熊孩子", "淘气包", "刺客信条", "神秘人", "猛男",
    "火箭少女", "气质小公举", "电竞小公主", "运动健将", "懒癌晚期", "全能剪辑师",
    "星际穿越", "超能力者", "时尚达人", "天使爱美丽", "蝙蝠侠", "绿巨人", "美猴王", "女王大人",
    "恶魔猎手", "海盗王", "双面人", "魔术师", "大力士", "黑暗骑士",
    "狙击手", "拳击手", "斗牛士", "神偷", "无敌战神", "机器人", "街头霸王", "狂野女郎", "女武神",
    "舞者", "天使之翼", "霸道总裁", "女帝", "超级英雄", "未来战士"
}

local font = draw.CreateFont("Microsoft Tai Le", 30, 1000);



local needchangename = false









local localplayername = nil

--General Spam Timer
local last_message = globals.TickCount();
function GeneralSpam()
    if (globals.TickCount() - last_message < 0) then
        last_message = 0;
    end

    if (localplayername == "󠀡󠀡" or localplayername == "?empty" or localplayername == thisname:GetValue() or localplayername == nil) or (waitstreamer:GetValue() and not found) then
        return
    end

    local spammer_speed = General_BM_Speed:GetValue() * 60;
    local current_tick = globals.TickCount()

    if General_BM_Act:GetValue() == 1 and current_tick - last_message > (math.max(22, spammer_speed)) then
        local random_spam = General_BM_Spams[math.random(1, #General_BM_Spams)]
        client.ChatSay(' ' .. tostring(random_spam))
        last_message = current_tick
    elseif General_BM_Act:GetValue() == 2 and current_tick - last_message > (math.max(22, spammer_speed)) then
        local custom_spam = General_BM_Edit:GetValue()
        client.ChatSay(custom_spam)
        last_message = current_tick
    elseif General_BM_Act:GetValue() == 3 and current_tick - last_message > (math.max(22, spammer_speed)) then
        local random_spam = General_GOV_BM_Spams[math.random(1, #General_GOV_BM_Spams)]
        client.ChatSay(' ' .. tostring(random_spam))
        last_message = current_tick
    end
end

--Kill/Death Trigger
-- local function CHAT_KillSay(Event)
--     if Event:GetName() == 'player_death' then
--         local ME = client.GetLocalPlayerIndex()
--         local INT_UID = Event:GetInt('userid')
--         local INT_ATTACKER = Event:GetInt('attacker')
--         local NAME_Victim = client.GetPlayerNameByUserID(INT_UID)
--         local INDEX_Victim = client.GetPlayerIndexByUserID(INT_UID)
--         local NAME_Attacker = client.GetPlayerNameByUserID(INT_ATTACKER)
--         local INDEX_Attacker = client.GetPlayerIndexByUserID(INT_ATTACKER)

--         if INDEX_Attacker == ME and INDEX_Victim ~= ME then
--             if Kill_BM_Act:GetValue() == 1 then
--                 local random_spam = Kill_BM_Spams[math.random(1, #Kill_BM_Spams)]
--                 if Kill_BM_STAN_NAME:GetValue() == true then
--                     client.ChatSay(' ' .. tostring(random_spam) .. ' @' .. NAME_Victim)
--                 else
--                     client.ChatSay(' ' .. tostring(random_spam))
--                 end
--             elseif Kill_BM_Act:GetValue() == 2 then
--                 local custom_spam = Kill_BM_Edit:GetValue()
--                 if Kill_BM_STAN_NAME:GetValue() == true then
--                     client.ChatSay(custom_spam .. ' @' .. NAME_Victim)
--                 else
--                     client.ChatSay(custom_spam)
--                 end
--             end
--         elseif INDEX_Victim == ME and INDEX_Attacker ~= ME and Death_BM_Act:GetValue() == 1 then
--             if Death_BM_Act:GetValue() == 1 then
--                 local random_spam = Death_BM_Spams[math.random(1, #Death_BM_Spams)]
--                 if Death_BM_STAN_NAME:GetValue() == true then
--                     client.ChatSay(' ' .. tostring(random_spam) .. ' @' .. NAME_Victim)
--                 else
--                     client.ChatSay(' ' .. tostring(random_spam))
--                 end
--             elseif Death_BM_Act:GetValue() == 2 then
--                 local custom_spam = Death_BM_Edit:GetValue()
--                 if Death_BM_STAN_NAME:GetValue() == true then
--                     client.ChatSay(custom_spam .. ' @' .. NAME_Victim)
--                 else
--                     client.ChatSay(custom_spam)
--                 end
--             end
--         end
--     end
-- end

callbacks.Register("Draw", GeneralSpam);

-- client.AllowListener('player_death');

-- callbacks.Register('FireGameEvent', CHAT_KillSay)






local function randomchangename()
    if staticname:GetValue() ~= nil and staticname:GetValue() ~= "" then
        client.SetConVar("name", staticname:GetValue() .. "­­")
    else
        local Enemies = entities.FindByClass("CCSPlayer")
        if Enemies == nil then return end
        local randomname = namelist[math.random(0, #namelist)]
        for i, Enemy in pairs(Enemies) do
            if Enemy:GetName() == randomname then
                randomchangename()
                return
            end
        end
        if randomname ~= nil then
            client.SetConVar("name", randomname .. "­­")
        end
    end
end



callbacks.Register("CreateMove", function()
    local pLocal = entities.GetLocalPlayer()
    if pLocal ~= nil then
        localplayername = pLocal:GetName()
        if randommaster:GetValue() then
            if steamerid:GetValue() ~= nil and steamerid:GetValue() ~= "" then
                local Enemies = entities.FindByClass("CCSPlayer")
                found = false
                if Enemies ~= nil then
                    for _, Enemy in pairs(Enemies) do
                        if string.find(Enemy:GetName(), steamerid:GetValue()) ~= nil then
                            found = true
                        end
                    end
                end
            end


            if needchangename and globals.TickCount() % 10 == 0 then
                randomchangename()
                needchangename = false
            end

            if localplayername == "󠀡󠀡" or localplayername == thisname:GetValue() then
                gui.SetValue("misc.stealname", 34)
                if globals.TickCount() % 64 == 0 then
                    http.Get("http://127.0.0.69:5000/")
                end
            end

            if gui.GetValue("misc.stealname") == 34 and localplayername ~= "󠀡󠀡" and localplayername ~= thisname:GetValue() then
                gui.SetValue("misc.stealname", 0)
            end

            if manualstart:GetValue() ~= nil or manualstart:GetValue() ~= 0 then
                if input.IsButtonPressed(manualstart:GetValue()) then
                    needchangename = true
                end
            end

            if localplayername == "?empty" then
                randomchangename()
            end

            if localplayername ~= "?empty" and localplayername ~= "󠀡󠀡" and globals.TickCount() % 600 == 0 and ontimechange:GetValue() then
                randomchangename()
                needchangename = false
            end
        end
    end
end)

callbacks.Register("Draw", function()
    if gui.GetValue("esp.master") and randommaster:GetValue() then
        draw.SetFont(font);
        draw.Color(255, 255, 255, 255);
        if localplayername ~= nil then
            draw.Text(100, 100, localplayername)
        end
        if found then
            draw.Text(100, 130, steamerid:GetValue() .. " in game!")
        end
    end
end)




local SetThisName = gui.Button(Death_BM_Group, "set plocalname ", function()
    if (localplayername == "󠀡󠀡" or localplayername == "?empty" or localplayername == nil) then
        return
    end
    thisname:SetValue(localplayername)
end);
SetThisName:SetWidth(268)

client.AllowListener("client_disconnect");
client.AllowListener("begin_new_match");
callbacks.Register("FireGameEvent", function(e)
    local eventName = e:GetName()
    if (eventName == "client_disconnect") or (eventName == "begin_new_match") then
        localplayername = nil
        found = false
    end
end)
