# Aimware-DangerZone-Lua<br />
Last Updated 2023/8/5 1.0.5
Dont sell my code on NL/SK/Pri market.It is opensource<br />
But you can transfer to another cheat as free version to spilit out is allowed<br />
<br />
Ref:I have used code from<br />
[[Release] Danger Zone Speedhack | AIMWARE.net](https://aimware.net/forum/thread/147031) (Has fixed by me) @Zerdos Thanks for your origin code<br />
[[Release] UpperHook Semi Rage Helper (Updated 21/7/2022) | AIMWARE.net](https://aimware.net/forum/thread/168455) (Used its ui design) @RDX_K3LL3R<br />
[[Release] Dangerzone Tweaks](https://aimware.net/forum/thread/100971) (used for extraesp) @ambien55<br />

Note:I have hard coded <br />
1.smg hitchance, due to smg need different value(like bizon,mac10 need low,and mp9,mp7 for high hitchance)<br />
2.static fov 23,For your acc safety,i'm highly recommend you not change the value,and keep "SmoothAim" on (Aimstep).I have banned for lots of acc due to high fov.<br />
3.force set shotgun baim(Headshot is very hard before you being killed)<br />
4.force set sniper baim (this mode awp cant get too much ammo and HS miss will LOSE your winner chance rate)<br />
WARNING:IF YOU WANT USE HIGH FOV you can turn off AimSmooth and FOV will be dynamic that you could always hit cloest ENEMY.(abandon function but still work)<br />

Main showcase:<br />
https://youtu.be/rttTZmpphz4 <br />
part of function showcase:<br />
[SpeedHack](https://www.bilibili.com/video/BV1a8411m7HR/) <br />
[NotHitShield](https://www.bilibili.com/video/BV1mP411r7F7/) <br />
[AimDrone&DroneDetect](https://www.bilibili.com/video/BV1n14y1X7hq) <br />
[Shieldbot](https://www.bilibili.com/video/BV1A94y1B7iZ/) <br />



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
  （&nbsp;）show Enemy's Teammate and between two guy's distance, if his auto muted (probably cheating) then add "(Cheating)" (Example "(M)(Cheater)  1000 will11801") in right<br />
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




Update 1.0.1:<br />
(rage.lua)When aa 180 backward enable desync(some cheater (legit with ssg08) will shot you calf/foot when you back shield)

Update 1.0.2:<br />
(rage.lua)Removed rifle hitchance hardcode,use right calf as first target when HitShieldguyLeg (You can hit rcalf even this enemy used any angle Desync)

Update 1.0.3:<br />
(rage.lua) Provided switch that you can disable LegitAA(Desync), Fakelag, DistanceBased Visual.GUI changed<br />
(snapline.lua)Changed the color of piston/light weapon,used async function to draw line that no much performance cost<br />
(extraesp.lua)used async function to draw line that no much performance cost<br />
(tablechecker.lua) fixed bug that partyapi say not show enemy's name<br />
config changed fakelag 7 -> 3<br />
<br />
Update 1.0.4:<br />
(ESP.lua)fixed incorrect Enemy team distance calc way.<br />
(snapline.lua)drawESP function back old mode due to some problem<br />
<br />
Update 1.0.5:<br />
(all)fixed potential bug when select jump spot makes game crash<br />
(rage.lua) add extra switch to disable some setprop function<br />
(rage.lua) press key 'USE' will suspend autoshield/shieldreturn due to conflict<br />
(esp.lua/snapline.lua) used correct detection<br />
(tablechecker.lua) now will not check localplayer's profile<br />
<br />