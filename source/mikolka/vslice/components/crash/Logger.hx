package mikolka.vslice.components.crash;

import haxe.ds.StringMap;
import flixel.system.debug.log.LogStyle;
import mikolka.compatibility.VsliceOptions;
#if sys
import haxe.PosInfos;
import openfl.display.Sprite;
import haxe.Log;

class Logger {
    private static var file:FileOutput;
    public static function startLogging() {
        #if LEGACY_PSYCH
            file = File.write("latest.log");
        #else
            file = File.write(StorageUtil.getStorageDirectory()+"/latest.log");
            #if PROFILE_BUILD
                LogStyle.WARNING.onLog.add(log);
            #end
            LogStyle.ERROR.onLog.add(log);
        #end
        Log.trace = log;
    }
    
    public static var logType(default, null) = 0;

    public static function updateLogType() {
        logType = switch (VsliceOptions.LOGGING) {
            case "Console & File": 3;
            case "File": 2;
            case "Console": 1;
            case _: 0;
        }
        Sys.println('Updated Logging Type: ${VsliceOptions.LOGGING}');
    }

    private static function log(v:Dynamic, ?infos:PosInfos):Void {
        if (logType == 0) return;
        var str = Log.formatOutput(v,infos);
        if (logType & 1 != 0) Sys.println(str);
        if (logType & 2 != 0) {
            if (file != null) {
                file.writeString(str+"\n");
                file.flush();
            }
        }
    }
}
#end