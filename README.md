# Aimware-DangerZone-Lua<br />
Dont sell my code on NL/SK/Pri market.It is opensource<br />

Ref:I have used code from<br />
[url=https://aimware.net/forum/thread/147031][Release] Danger Zone Speedhack | AIMWARE.net[/url] (Has fixed by me) @Zerdos Thanks for your origin code<br />
[url=https://aimware.net/forum/thread/168455][Release] UpperHook Semi Rage Helper (Updated 21/7/2022) | AIMWARE.net[/url] (Used its ui design) @RDX_K3LL3R<br />
[url=https://aimware.net/forum/thread/100971][Release] Dangerzone Tweaks[/url] (used for extraesp) @ambien55<br />

Note:I have hard coded <br />
1.smg hitchance, due to smg need different value(like bizon,mac10 need low,and mp9,mp7 for high hitchance)<br />
2.static fov 23,For your acc safety,i'm highly recommend you not change the value,and keep "SmoothAim" on (Aimstep).I have banned for lots of acc due to high fov.<br />
WARNING:IF YOU WANT USE HIGH FOV you can turn off AimSmooth and FOV will be dynamic that you could always hit cloest ENEMY.(abandon function but still work)<br />




rage.lua:<br />
  （&nbsp;）Aimstep by Distance(AutoLock & SmoothAim)<br />
  （&nbsp;）NotHitShield(by detect shieldguy's eyeangle)<br />
  （&nbsp;）HitShieldguyLeg(press key to autoaim enemy's calf (can damage) who hold shield)<br />
  （&nbsp;）AutoShield(auto inject healthshot when low hp and has shield)<br />
  （&nbsp;）ShieldReturn(when reload switch aa to backward shield)<br />
  （&nbsp;）exojump SpeedHack<br />
  （&nbsp;）ShieldHit(when recent shieldguy switch to another weapon instant change aa from 180 to normal)<br />
  （&nbsp;）AimDrone(press key to autoaim recent Drone(Manual controlled or Has Cargo)<br />
  <br />
snapline.lua:<br />
  （&nbsp;）worldtoscreen Hostage,Boxes,Healthshot,Ammobox,Cash,Shield,Armor,Piston(include Boxes and p2000 and glock) , light weapon box<br />
  （&nbsp;）show Endcircle Distance & worldtoscreen it<br />
  （&nbsp;）show Recent Drone (will show Manual Drone Distance in screen,and Draw text on it entity) <br />
<br />
ESP.lua:<br />
  （&nbsp;）DZ special ESP<br />
  （&nbsp;）show weapon class on top(when this one has shield,add"(S)" to string<br />
  （&nbsp;）show distance on left (localplayer to enemy Distance)<br />
  （&nbsp;）show Enemy's Teammate and between two guy's distance, if his auto muted (probably cheating) then add "(Cheating)" (Example "(M)(Cheater)  will11801") in right<br />
  （&nbsp;）show ammo status on bottom<br />
  <br />
extraesp.lua:<br />
  （&nbsp;）Show Barrel,RemoteBomb on screen by draw extra photo on it<br />
<br />
tablechecker.lua:<br />
  （&nbsp;）reveal player tablebuy event and print on cheat console (Example "菲尼克斯老张 has brought scout")<br />
  （&nbsp;）check player who disconnected and print on cheat console (Example "Warmup Escaped 特训飓风JF" ,"Defeat Exit 尼古拉斯老王")<br />
<br />
teamchecker.lua: (once run script)<br />
  （&nbsp;）reveal player team and print it on cheat console (Same as ESP.lua righttext do)<br />

  
[url=https://www.bilibili.com/video/BV1a8411m7HR/]SpeedHack[/url][/font][/size][/color]
[url=https://www.bilibili.com/video/BV1mP411r7F7/][/url][url=https://www.bilibili.com/video/BV1mP411r7F7/]NoHitShield[/url]
[url=https://www.bilibili.com/video/BV1n14y1X7hq]AimDrone&DroneDetect[/url]
[url=https://www.bilibili.com/video/BV1A94y1B7iZ/]Shieldbot[/url]


Update 1.0.1:<br />
(rage.lua)When aa 180 backward enable desync(some cheater (legit with ssg08) will shot you calf/foot when you back shield)

Update 1.0.2:<br />
(rage.lua)Removed rifle hitchance hardcode,use right calf as first target when HitShieldguyLeg (You can hit rcalf even this enemy used any angle Desync)