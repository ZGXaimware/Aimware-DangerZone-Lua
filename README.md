﻿# Aimware-DangerZone-Lua
For Valve CS:GO and aimware.net ,Game mode DangerZone
Dont sell my code on NL/SK/Pri market.It is opensource

rage.lua:
  Aimstep by Distance(AutoLock & SmoothAim)
  NotHitShield(by detect shieldguy's eyeangle)
  HitShieldguyLeg(press key to autoaim enemy's calf (can damage) who hold shield)
  AutoShield(auto inject healthshot when low hp and no hp)
  ShieldReturn(when reload switch aa to backward shield)
  exojump SpeedHack
  ShieldHit(when recent shieldguy switch to another weapon instant change aa from 180 to normal)
  AimDrone(press key to autoaim recent Drone(Manual controlled or Has Cargo)
  
snapline.lua:
  worldtoscreen Hostage,Boxes,Healthshot,Ammobox,Cash,Shield,Armor,Piston(include Boxes and p2000 and glock) , light weapon box
  show Endcircle Distance & worldtoscreen it
  show Recent Drone (will show Manual Drone Distance in screen,and Draw text on it entity) 

ESP.lua
  DZ special ESP
  show weapon class on top(when this one has shield,add"(S)" to string
  show distance on right(localplayer to enemy Distance)
  show Enemy's Teammate and between two guy's distance (Example "(M)(Cheater) 1000 尼古拉司老王") in right
  show ammo status on bottom
  
extraesp.lua
  Show Barrel,RemoteBomb on screen by draw extra photo on it

tablechecker.lua
  reveal player tablebuy event and print on cheat console (Example "菲尼克斯老张 has brought scout")
  check player who disconnected and print on cheat console (Example "Warmup Escaped 特训飓风JF" ,"Defeat Exit 斗罗士")

teamchecker.lua (once run script)
  reveal player team and print it on cheat console (Same as ESP.lua righttext do)

  