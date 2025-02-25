@echo off
cd ..
echo Making the haxelib and setuping folder in same time...
haxelib newrepo
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib git hxcpp https://github.com/mcagabe19-stuff/hxcpp
haxelib git lime https://github.com/mcagabe19-stuff/lime
haxelib git openfl https://github.com/mcagabe19-stuff/openfl 9.3.3
haxelib git flixel https://github.com/Psych-Slice/p-slice-1.0-flixel 4cb4b8a51ef00abb4a7881bb869b13e399e82577
haxelib install flixel-addons 3.2.2
haxelib install flixel-tools 1.5.1
haxelib install hscript-iris 1.1.0
haxelib install tjson 1.4.0
haxelib git flxanimate https://github.com/Psych-Slice/FlxAnimate.git 18091dfeb629ba2805a5f3e10f5de80433080359
haxelib git linc_luajit https://github.com/MobilePorting/linc_luajit
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc f9353b9edce10f4605d125dd1bda24ac36898bfb --skip-dependencies
haxelib git hxvlc https://github.com/MobilePorting/hxvlc --skip-dependencies
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90 --skip-dependencies
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666
haxelib git FlxPartialSound https://github.com/FunkinDroidTeam/FlxPartialSound.git 2b7943ba50eb41cf8f70e1f2089a5bd7ef242947
haxelib git extension-androidtools https://github.com/MAJigsaw77/extension-androidtools --skip-dependencies
echo Finished!