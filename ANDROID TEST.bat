@echo off
echo You have to done setup for Android Build

haxelib set openfl 9.3.3 --global
haxelib set flixel-addons 3.2.2 --global
haxelib set flixel-tools 1.5.1 --global
haxelib set hscript-iris 1.1.0 --global
haxelib set tjson 1.4.0 --global
haxelib set hxvlc 1.8.2 --global
haxelib git hxcpp https://github.com/mcagabe19-stuff/hxcpp --always
haxelib git lime https://github.com/mcagabe19-stuff/lime --always
haxelib git flixel https://github.com/Psych-Slice/p-slice-1.0-flixel.git 4cb4b8a51ef00abb4a7881bb869b13e399e82577 --always
haxelib git flxanimate https://github.com/Psych-Slice/FlxAnimate.git 18091dfeb629ba2805a5f3e10f5de80433080359 --always
haxelib git linc_luajit https://github.com/MobilePorting/linc_luajit --always
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc f9353b9edce10f4605d125dd1bda24ac36898bfb --always
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90 --always
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666 --always
haxelib git FlxPartialSound https://github.com/FunkinDroidTeam/FlxPartialSound.git 2b7943ba50eb41cf8f70e1f2089a5bd7ef242947 --always
haxelib git extension-androidtools https://github.com/MAJigsaw77/extension-androidtools --always

lime test android