package backend;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;

#if windows
@:cppFileCode('
	#include <stdlib.h>
	#include <stdio.h>
	#include <iostream>
	#include <string>
	#include <windows.h>
')
#else
@:cppFileCode('
	#include <stdlib.h>
	#include <string>
')
#end

class CoolUtil
{
	public static final MIN_VALUE_DOUBLE = 2.225073858507201383090232717332404064219215980462331830553327416887204434813918195854283159012511020564067339731035811005152434161553460108856012385377718821130777993532002330479610147442583636071921565046942503734208375250806650616658158948720491179968591639648500635908770118304874799780887753749949451580451605050915399856582470818645113537935804992115981085766051992433352114352390148795699609591288891602992641511063466313393663477586513029371762047325631781485664350872122828637642044846811407613911477062801689853244110024161447421618567166150540154285084716752901903161322778896729707373123334086988983175067838846926092773977972858659654941091369095406136467568702398678315290680984617210924625396728515625e-308;

	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		//trace(snap);
		return (m / snap);
	}

	inline public static function capitalize(text:String)
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();

	inline public static function coolTextFile(path:String):Array<String>
	{
		var daList:String = null;
		#if (sys && MODS_ALLOWED)
		if(FileSystem.exists(path)) daList = File.getContent(path);
		#else
		if(Assets.exists(path)) daList = Assets.getText(path);
		#end
		return daList != null ? listFromString(daList) : [];
	}

	/**
	 * Return string with first character uppercase'd, rest lowercase'd
	 * @param	str
	 * @return
	 */
	 inline public static function FUL(str:String):String
		{
			return str.substr(0, 1).toUpperCase() + str.substr(1, str.length - 1).toLowerCase();
		}

	inline public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if(colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	inline public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}
	
	/**
	 * Fill numbers with a specified number of digits and right-align with the number.
	 * @param value Floating-point number
	 * @param digits Integer
	 * @param code Integer (use fastCodeAt)
	 */
	static var format:StringBuf = new StringBuf();
	inline public static function fillNumber(value:Float, digits:Int, code:Int) {
		var length:Int = Std.string(value).length;
		var str:String = null;
		format = new StringBuf();

		if(length < digits) {
			for (i in 0...(digits - length))
				format.addChar(code);
			format.add(Std.string(value));
		} else format.add(Std.string(value));

		str = format.toString(); format = null;
		return str;
	}

	inline public static function logX(value:Float, exp:Float) {
		return Math.log(value) / Math.log(exp);
	}

	inline public static function interpolate(a:Float, b:Float, m:Float, e:Float = 1) {
		m = FlxMath.bound(m, 0, 1);
		return FlxMath.lerp(a, b, Math.pow(m, e));
	}

	inline public static function normalize(x:Float, min:Float, max:Float, isBound:Bool = true) {
		return isBound ? FlxMath.bound((x - min) / (max - min), 0, 1) : (x - min) / (max - min);
	}

	inline public static function bool(value:Dynamic):Null<Bool> {
		if (value is Int || value is Float) {
			return (value >= 1);
		}
		return null;
	}

	inline public static function int(value:Dynamic):Null<Int> {
		if (value is Int || value is Float) {
			return Std.int(value);
		} else if (value is Bool) {
			return value ? 1 : 0;
		} else if (value is String) {
			return Std.parseInt(value);
		}
		return null;
	}

	inline public static function hex2bin(str:String) {
		var returnVal:String = "";
		var tmpStr:String = "";
		var hex:Int = 0;
		for (i in 0...str.length) {
			hex = Std.parseInt("0x"+str.charAt(i));
			tmpStr = "";
			for (j in 0...4) {
				tmpStr = ((hex & 1<<j) == 1<<j ? "1" : "0") + tmpStr;
			}
			returnVal += tmpStr + " ";
		}
		return returnVal.substr(0, returnVal.length-1);
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if(decimals < 1)
			return Math.floor(value);

		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;

		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}
	
	inline public static function decimal(value:Float, decimals:Int, mode:Int = 1):Float
	{
		var up:Float = Math.pow(10, decimals);
		var down:Float = Math.pow(10, -decimals);
		var mod:Float = value * up;

		switch (mode) {
			case 0: // floor
				value = Math.ffloor(mod);
			case 2: // ceil
				value = Math.fround(mod);
			case 1 | _: // round
				value = Math.fceil(mod);
		}

		return value * down;
	}
	
	inline public static function floatToStringPrecision(number:Float, prec:Int, exponent:Bool = false){
		var str:String;
		var abs:Float = Math.abs(number);
		var len:Null<Int>;
		var result:String;
		var negative:Bool = false;
		if(!exponent || (abs >= Math.pow(0.1, prec) && abs < Math.pow(10, 6))) {
			negative = number < 0;
			str = Std.string(Math.fround(abs * Math.pow(10, prec)));
			len = str.length;
			if(len <= prec){
				// Smaller than 1
				while(len < prec){
					str = '0'+str;
					len++;
				}
				result = '0.'+str;
			} else {
				// Larger than 1
				if (str.length == prec) result = str;
				else result = str.substr(0, str.length-prec) + (prec > 0 ? '.'+str.substr(str.length-prec) : '');
			}
		} else {
			str = ''+Math.fround(
				abs * Math.pow(10, Math.floor( -logX(abs, 10) ) ) * Math.pow(10, prec) * 10
			);
			result = (number > MIN_VALUE_DOUBLE ? str.substr(0,1) + '.' + str.substr(1) : '0') + 'e' + Math.floor(logX(abs, 10));
		}
		str = null; len = null;
		return (negative ? "-" : "") + result;
	}

	public static function sortAlphabetically(list:Array<String>):Array<String> {
		// This moster here fixes order of scrips to match the windows implementation
		// Why? because some people use this quirk (like me)

		list.sort((a,b) -> { 
				a = a.toUpperCase();
				b = b.toUpperCase();
			  
				if (a < b) {
				  return -1;
				}
				else if (a > b) {
				  return 1;
				} else {
				  return 0;
				}
			  });
		return list;
	}
	
	// stolen and modded from FlxStringUtil
	public static function formatTime(seconds:Float, precision:Int = 0):String
	{
		var timeString:String = Std.int(seconds / 60) + ":";
		var timeStringHelper:Int = Std.int(seconds) % 60;

		if (timeStringHelper < 10)
		{
			timeString += "0";
		}
		timeString += timeStringHelper;
		if (precision > 0)
		{
			timeString += ".";
			timeStringHelper = Std.int((seconds - Std.int(seconds)) * Math.pow(10, precision));
			timeString += timeStringHelper;
		}

		return timeString;
	}

	// stolen and modded from FlxStringUtil
	public static function formatMoney(amount:Float, showDecimal:Int = 0, englishStyle:Bool = true):String
	{
		var isNegative = amount < 0;
		amount = Math.abs(amount);

		var string:String = "";
		var comma:String = "";
		var amount:Float = Math.ffloor(amount);
		while (amount > 0)
		{
			if (string.length > 0 && comma.length <= 0)
				comma = (englishStyle ? "," : ".");

			var zeroes = "";
			var helper = amount - Math.ffloor(amount / 1000) * 1000;
			amount = Math.ffloor(amount / 1000);
			if (amount > 0)
			{
				if (helper < 100)
					zeroes += "0";
				if (helper < 10)
					zeroes += "0";
			}
			string = zeroes + helper + comma + string;
		}

		if (string == "")
			string = "0";

		if (showDecimal > 0)
		{
			var power = Math.pow(10, showDecimal);
			amount = Math.ffloor(amount * power) - (Math.ffloor(amount) * power);
			string += (englishStyle ? "." : ",");
			if (amount < 10)
				string += "0";
			string += amount;
		}

		if (isNegative)
			string = "-" + string;
		return string;
	}

	// stolen and modded from FlxStringUtil
	public static function formatBytes(Bytes:Float, Precision:Int = 2, keepPrec:Bool = false, fixedSI:Int = -1):String
	{
		var units:Array<String> = ["Bytes", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
		var curUnit = 0;
		if(fixedSI < 0) {
			while (Bytes >= 1024 && curUnit < units.length - 1)
			{
				Bytes /= 1024;
				curUnit++;
			}
		} else {
			while (curUnit < fixedSI && curUnit < units.length - 1)
			{
				Bytes /= 1024;
				curUnit++;
			}
		}
		if(keepPrec) {
			if(fixedSI < 0) {
				Precision = 5 - Std.int(logX(Bytes, 10) + 1);
			}
			return CoolUtil.floatToStringPrecision(Bytes, Precision) + units[curUnit];
		}
		else
			return CoolUtil.floorDecimal(Bytes, Precision) + units[curUnit];
	}

	inline public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth)
		{
			for(row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:FlxColor = sprite.pixels.getPixel32(col, row);
				if(colorOfThisPixel.alphaFloat > 0.05)
				{
					colorOfThisPixel = FlxColor.fromRGB(colorOfThisPixel.red, colorOfThisPixel.green, colorOfThisPixel.blue, 255);
					var count:Int = countByColor.exists(colorOfThisPixel) ? countByColor[colorOfThisPixel] : 0;
					countByColor[colorOfThisPixel] = count + 1;
				}
			}
		}

		var maxCount = 0;
		var maxKey:Int = 0; //after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
		for(key => count in countByColor)
		{
			if(count >= maxCount)
			{
				maxCount = count;
				maxKey = key;
			}
		}
		countByColor = [];
		return maxKey;
	}

	inline public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max) dumbArray.push(i);

		return dumbArray;
	}

	inline public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	inline public static function openFolder(folder:String, absolute:Bool = false) {
		#if sys
			if(!absolute) folder =  Sys.getCwd() + '$folder';

			folder = folder.replace('/', '\\');
			if(folder.endsWith('/')) folder.substr(0, folder.length - 1);

			#if linux
			var command:String = '/usr/bin/xdg-open';
			#else
			var command:String = 'explorer.exe';
			#end
			Sys.command(command, [folder]);
			trace('$command $folder');
		#else
			FlxG.error("Platform is not supported for CoolUtil.openFolder");
		#end
	}

	/**
		Helper Function to Fix Save Files for Flixel 5

		-- EDIT: [November 29, 2023] --

		this function is used to get the save path, period.
		since newer flixel versions are being enforced anyways.
		@crowplexus
	**/
	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String {
		final company:String = FlxG.stage.application.meta.get('company');
		// #if (flixel < "5.0.0") return company; #else
		return '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
		// #end
	}

	public static function setTextBorderFromString(text:FlxText, border:String)
	{
		switch(border.toLowerCase().trim())
		{
			case 'shadow':
				text.borderStyle = SHADOW;
			case 'outline':
				text.borderStyle = OUTLINE;
			case 'outline_fast', 'outlinefast':
				text.borderStyle = OUTLINE_FAST;
			default:
				text.borderStyle = NONE;
		}
	}
}
