package debug;

import haxe.Timer;
import cpp.vm.Gc;
import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System as OpenFlSystem;
import lime.system.System as LimeSystem;

#if flash
import openfl.Lib;
#end
import external.memory.Memory;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if cpp
#if windows
@:cppFileCode('#include <windows.h>')
#elseif (ios || mac)
@:cppFileCode('#include <mach-o/arch.h>')
#else
@:headerInclude('sys/utsname.h')
#end
#end
class FPSCounter extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public static var instance:FPSCounter;
	public var currentFPS(default, null):Int;
	public var fpsFontSize:Int = 16;
	public var fpsTextLength:Int = 0;
	var fps:Int = 0;
	var curTime:Float = 0;
	var frameTime:Float = 0;
	var multipleRate:Float = 1.0;
	var updateRate:Float = 50;

	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var gcRam(get, never):Float;
	inline function get_gcRam():Float
		return Gc.memInfo64(Gc.MEM_INFO_USAGE);

	@:noCompletion private var cacheCount:Float;
	@:noCompletion private var times:Array<Int>;

	public var os:String = '';

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		if (LimeSystem.platformName == LimeSystem.platformVersion || LimeSystem.platformVersion == null)
			os = '\nOS: ${LimeSystem.platformName}' #if cpp + ' ${getArch() != 'Unknown' ? getArch() : ''}' #end;
		else
			os = '\nOS: ${LimeSystem.platformName}' #if cpp + ' ${getArch() != 'Unknown' ? getArch() : ''}' #end + ' - ${LimeSystem.platformVersion}';

		positionFPS(x, y);

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(Paths.font("fps.ttf"), fpsFontSize, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";
		fps = ClientPrefs.data.framerate;
		updateRate = ClientPrefs.data.fpsRate;

		cacheCount = 0;
		times = [];
	}

	var deltaTimeout:Float = 0.0;

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		updateRate = ClientPrefs.data.fpsRate;
		final now:Int = Std.int(Timer.stamp() * 1000);
		times.push(now);
		while (times[0] < now - 1000) times.shift();

		// prevents the overlay from updating every frame, why would you need to anyways @crowplexus
		deltaTimeout += deltaTime;
		if (deltaTimeout < 1 / updateRate) return;
		// Literally the stupidest thing i've done for the FPS counter but it allows it to update correctly when on 60 FPS??
		currentFPS = Math.round((times.length + cacheCount) / 2) - 1;
		updateText();
		deltaTimeout = 0.0;
	}

	public dynamic function updateText():Void { // so people can override it in hscript
		text = "FPS: " + currentFPS
		+ "\nRAM: " + CoolUtil.formatBytes(Memory.getCurrentUsage(), 2, true)
		+ (" / " + CoolUtil.formatBytes(Gc.memInfo64(Gc.MEM_INFO_USAGE), 2, true))
		+ (" / " + CoolUtil.formatBytes(Memory.getPeakUsage(), 2, true))
		+ os;

		textColor = Std.int(
			0xFFFF0000 + 
			(Std.int(CoolUtil.normalize(currentFPS, 1, fps >> 1, true) * 255) << 8) + 
			Std.int(CoolUtil.normalize(currentFPS, fps >> 1, fps, true) * 255)
		);

		text += "\n";
		fpsTextLength = text.length;
		cacheCount = times.length;
	}

	public inline function positionFPS(X:Float, Y:Float, ?scale:Float = 1){
		scaleX = scaleY = #if android (scale > 1 ? scale : 1) #else (scale < 1 ? scale : 1) #end;
		x = FlxG.game.x + X;
		y = FlxG.game.y + Y;
	}

	#if cpp
	#if windows
	@:functionCode('
		SYSTEM_INFO osInfo;

		GetSystemInfo(&osInfo);

		switch(osInfo.wProcessorArchitecture)
		{
			case 9:
				return ::String("x86_64");
			case 5:
				return ::String("ARM");
			case 12:
				return ::String("ARM64");
			case 6:
				return ::String("IA-64");
			case 0:
				return ::String("x86");
			default:
				return ::String("Unknown");
		}
	')
	#elseif (ios || mac)
	@:functionCode('
		const NXArchInfo *archInfo = NXGetLocalArchInfo();
    	return ::String(archInfo == NULL ? "Unknown" : archInfo->name);
	')
	#else
	@:functionCode('
		struct utsname osInfo{};
		uname(&osInfo);
		return ::String(osInfo.machine);
	')
	#end
	@:noCompletion
	private function getArch():String
	{
		return "Unknown";
	}
	#end
}
