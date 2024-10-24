package debug;

import haxe.Timer;
import cpp.vm.Gc;
import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;

#if flash
import openfl.Lib;
#end
import external.memory.Memory;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
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
	var updateRate:Int = 50;

	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var gcRam(get, never):Float;
	inline function get_gcRam():Float
		return Gc.memInfo64(Gc.MEM_INFO_USAGE);

	@:noCompletion private var cacheCount:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

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
		final now:Float = Timer.stamp();
		times.push(now);
		while (times[0] < now - 1) times.shift();

		// prevents the overlay from updating every frame, why would you need to anyways @crowplexus
		if (deltaTimeout < updateRate) {
			deltaTimeout += deltaTime;
			return;
		}
		// Literally the stupidest thing i've done for the FPS counter but it allows it to update correctly when on 60 FPS??
		currentFPS = Math.round((times.length + cacheCount) / 2) - 1;
		updateText();
		deltaTimeout = 0.0;
	}

	public dynamic function updateText():Void { // so people can override it in hscript
		text = "FPS: " + currentFPS;
		text += "\nRAM: " + CoolUtil.formatBytes(Memory.getCurrentUsage(), 2, true)
		+ (" / " + CoolUtil.formatBytes(Gc.memInfo64(Gc.MEM_INFO_USAGE), 2, true))
		+ (" / " + CoolUtil.formatBytes(Memory.getPeakUsage(), 2, true));

		textColor = Std.int(
			0xFFFF0000 + 
			(Std.int(CoolUtil.normalize(currentFPS, 1, fps >> 1, true) * 255) << 8) + 
			Std.int(CoolUtil.normalize(currentFPS, fps >> 1, fps, true) * 255)
		);

		text += "\n";
		fpsTextLength = text.length;
		cacheCount = times.length;
	}
}
