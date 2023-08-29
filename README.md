# Aimware-DangerZone-Lua<br />
**Last Updated 2023/8/25 1.1.8(Beta)(New Version)**<br />

（&nbsp;）Tips1:Use low aastep/aimstep angle and not enable unsafe function that u will never been banned<br />

（&nbsp;）Tips2:if your suffer performance issue you should consider turn off some function<br />
（&nbsp;）Like part of snapline ,ESP,distance visual,etc <br />

EZ KILLED NOOB Bilibili Streamer<br />
![Alt text](/imgs/punchkill.png)<br />

[My Bilibili Profile](https://space.bilibili.com/3494352856812225) <br />
![Alt text](/imgs/biliprofile.png)




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



DZe_rage.lua:<br />
![Alt text](/imgs/dze1.png)
![Alt text](/imgs/dze2.png)
  （&nbsp;）Aimstep by Distance(AutoLock & SmoothAim)<br />
  （&nbsp;）Anti-Aim step by step (For safety)<br />
  （&nbsp;）NotHitShield(by detect shieldguy's eyeangle)<br />
  （&nbsp;）HitShieldguyLeg(in target distance that autoaim enemy's calf (can damage) who hold shield)<br />
  （&nbsp;）AutoShield(auto inject healthshot when low hp and has shield)<br />
  （&nbsp;）ShieldReturn(when reload switch aa to backward shield)<br />
  （&nbsp;）exojump SpeedHack(FastHop) with anti-hit aa direction if has shield<br />
  （&nbsp;）ShieldHit(when recent shieldguy switch to another weapon instant change aa from 180 to normal)<br />
  （&nbsp;）AimDrone(press key to autoaim recent Drone(Manual controlled or Has Cargo)<br />
  （&nbsp;）LegitAA(Desync) and roll AA switch<br />
  （&nbsp;）ShieldBot (function as kniefbot but support all dz items)<br />
  （&nbsp;）Anti-teammate (function anti-teammate breach you)<br />
  （&nbsp;）ForcehitTeammate (press key to force baim teammate)<br />

<br />
DZe_visual.lua:<br />
![Alt text](/imgs/dzev.png)

  （&nbsp;）worldtoscreen Hostage,Boxes,Healthshot,Ammobox,Cash,Shield,Armor,Piston(include Boxes and p2000 and glock),light weapon box<br />
  （&nbsp;）show Endcircle Distance & worldtoscreen it<br />
  （&nbsp;）show Recent Drone (will show Manual Drone Distance in screen,and Draw text on it entity) <br />
  （&nbsp;）show weapon class on top(when this one has shield,add"(S)" to string<br />
  （&nbsp;）show distance on left (localplayer to enemy Distance)<br />
  （&nbsp;）show Enemy's Teammate and between two guy's distance, if his auto muted (probably cheating) then add "(Cheating)" (Example "(M)(Cheater)  1000 will11801") in right<br />
  （&nbsp;）show ammo status on bottom<br />
  （&nbsp;）Show Barrel,RemoteBomb on screen by draw extra photo on it<br />
<br />

DZe_sniffer.lua:<br />
![Alt text](/imgs/dzes.png)
  （&nbsp;）reveal player tablebuy event and print on cheat console or partyapi (Example "菲尼克斯老张 purchased scout")<br />
  （&nbsp;）check player who disconnected and print on cheat console or partyapi(Example "Warmup Escaped 特训飓风JF" ,"Defeat Exit 尼古拉斯老王")<br />
  （&nbsp;）Check Player who is respawnor partyapi (Example Respawn: Bilibili主播风云错爱)<br />
  （&nbsp;）reveal player team and print it on cheat console or partyapi <br />
  （&nbsp;）reveal paradrop create or destroy <br />
  （&nbsp;）reveal players' respawn status<br />

<br />


<br />


Updated 1.1.2:<br />
(ALL)lua set merged<br />
<DZe_rage.lua>add some new function,Updated GUI,fixed potential bugs<br />
<DZe_visual.lua>Updated GUI controller,fixed bug<br />
<DZe_sniffer.lua>Updated GUI controller,fixed bug<br />
<br />

Updated 1.1.3:<br />
<DZe_visual.lua>add grass remove<br />
<DZe_sniffer.lua>add paradrop sniffer<br />
<DZe_sniffer.lua>add dronedispatch sniffer<br />
<br />
Updated 1.1.4:<br />
<DZe_rage.lua>add GotvSwitch(will sync with another two scripts<br />
<DZe_visual.lua>add GotvSwitch<br />
<DZe_sniffer.lua>add GotvSwitch<br />
<br />
Updated 1.1.5:<br />
<DZe_rage.lua>Now lua script will not set force HeadShot,removed rifle hardcode<br />
<DZe_rage.lua>Cut down desync angle when backward mode<br />
<DZe_rage.lua>Removed desync mode selector (Useless)<br />
<DZe_rage.lua>Fixed AimShield angle is not int<br />
<DZe_visual.lua>Drone Detecter fixed<br />
GOTVswitch is unavaible due to some reason,wait for next version fix up
<br />
Updated 1.1.5(bugfix):<br />
<DZe_rage.lua>Fixed for speedhack direction error<br />
<br />

Updated 1.1.5(bugfix2):<br />
<DZe_rage.lua>Fixed for speedhack direction error<br />
<DZe_visual.lua>Fixed for Survivial team respawn time not correct<br />
<br />

Updated 1.1.5(bugfix3):<br />
<DZe_rage.lua>Fixed for desync error<br />
<DZe_visual.lua>Fixed for Survival team respawn time not correct<br />
<DZe_sniffer.lua>Updated for new purchase sniffer,Respawn got next time<br />
<br />

Updated 1.1.6:<br />
<DZe_rage.lua>add new indicator for teammate,and show big font /Red color when use RemoteBomb<br />
<DZe_rage.lua>add new function Annti-Teammate to prevent teammate use Remotebomb kill you<br />
<DZe_rage.lua>Aimleg Bug fixup(when only 2 shield guy in and aimleg not working)<br />
<DZe_rage.lua>backward switch used independent key instead of spectator list switch<br />
<DZe_visual.lua>guideline Color Updated<br />
<DZe_sniffer.lua>Used drone_dispatched event to listen on player purchase event.Next version will remove old detect way<br />
<br />

Updated 1.1.7:<br />
Provided Chinese Version<br />
<DZe_sniffer.lua> Updated NewFunction That you cant listen on teammate exit/join<br />
<DZe_sniffer.lua> Removed old detect purchase way<br />
<br />
Updated 1.1.8:<br />
<DZe_rage.lua> New function to auto anti teammate's remotebomb <br />
<DZe_rage.lua> add function that you can force hit your teammate's chest by press a key<br />
<DZe_visual.lua>add new remotebomb distance indicator<br />
<DZe_sniffer.lua> Bug for purchase sniffer fixed<br />
<DZe_rage.lua>when use Granade etc will disable desync now<br />
<br />



OLDVERSION Update:<br />
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
Update 1.0.6:<br />
(rage.lua) fixed bug for shield jumper will not smoothaim<br />
(rage.lua) now Legaim need not enable NohitShield<br />
(rage.lua) Updated Jumper TextView<br />
(etc)Fixed some bugs that has no another function changed<br />
<br />
Update 1.0.7:<br />
(rage.lua) ShieldHit function Updated ,now shieldguy distance < 130 and hold shield will auto enable backward shield to prevent plocal get hurt from enemy<br />
(rage.lua) Updated shieldguy textview style for notice<br />
Update 1.0.8:<br />
(rage.lua) (VERY USEFUL) when any (not affect with nothitshield ) shield guy distance < 800 then auto lock its leg and autoattack,he cant protect himself but only crouch and holdshield<br />
BUT IT IS VERY SLOW SO YOU CAN KILL HIM ANY WAY LOL<br /> 
<br />
Update 1.0.9:<br />
(rage.lua) hitshield enable for rifle,piston,smg,lmg in different distance(experiment function)<br />
(rage.lua) add new indicater show bestshield<br />
(rage.lua) use new color set<br />
(tablechecker.lua) print out when game started(not warmup) enemy respawn<br />
<br />
Update 1.1.0:<br />
(rage.lua) fixed shieldprotect use and get kicked when no enemy alive<br />
(rage.lua) add new detector to prevent '+attack' command not stop when no target<br />
(snapline.lua) changed color set for piston/smg line<br />
(tablechechker.lua)disable ffi print due to crash <br />
<br />
Updated 1.1.1:<br />
(tabletcheck.lua)huge updated for partyApi say<br />
(RandomNameChanger.lua) new lua released<br />
(rage.lua) update aimleg lmg -> 1800,rifle ->1200<br />
<br />