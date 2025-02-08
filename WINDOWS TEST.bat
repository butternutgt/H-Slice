@echo off
echo You have to done setup for Windows Build

haxelib set lime 8.1.3 --global
haxelib set openfl 9.3.3 --global
haxelib set flixel-addons 3.2.2 --global
haxelib set flixel-tools 1.5.1 --global
haxelib set hscript-iris 1.1.0 --global
haxelib set tjson 1.4.0 --global
haxelib set hxdiscord_rpc 1.2.4 --global
haxelib set hxvlc 1.8.2 --global
haxelib git flixel https://github.com/Psych-Slice/p-slice-1.0-flixel.git 4cb4b8a51ef00abb4a7881bb869b13e399e82577 --always
haxelib git flxanimate https://github.com/Psych-Slice/FlxAnimate.git 18091dfeb629ba2805a5f3e10f5de80433080359 --always
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit 1906c4a96f6bb6df66562b3f24c62f4c5bba14a7 --always
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90 --always
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666 --always
haxelib git FlxPartialSound https://github.com/FunkinCrew/FlxPartialSound.git f986332ba5ab02abd386ce662578baf04904604a --always

lime test windows