#if desktop
package backend;

import lime.math.Rectangle;
import haxe.io.Bytes;
import haxe.ds.Vector;
import lime.app.Application;
import lime.graphics.Image;
import flixel.FlxG;
import lime.ui.Window;
import sys.FileSystem;
import options.GameRendererSettingsSubState;

class FFMpeg {
    var x:Int;
    var y:Int;
    var w:Int;
    var h:Int;
    var width:Int;
    var height:Int;
    var image:Image;
    var bytes:Bytes;
    var window:Window = null;
    var buffer:Vector<Rectangle> = new Vector(2, null);

    public var target = "render_video";
    public var fileName = '';
    public var fileExts = '.mp4';
    public var wentPreview:String = null;
    public var process:Process;

    public static var instance:FFMpeg;

    public function new() {}

    public function init() {
        if (FileSystem.exists(target)) {
            if (!FileSystem.isDirectory(target)) {
                FileSystem.deleteFile(target);
                FileSystem.createDirectory(target);
            }
        } else FileSystem.createDirectory(target);

        window = Application.current.window;

        x = Std.int(FlxG.scaleMode.offset.x);
        y = Std.int(FlxG.scaleMode.offset.y);
        w = Std.int(FlxG.scaleMode.gameSize.x);
        h = Std.int(FlxG.scaleMode.gameSize.y);
    }

    public function setup(testMode:Bool = false) {
        if (!FileSystem.exists(#if linux 'ffmpeg' #else 'ffmpeg.exe' #end)) {
            if (testMode) {
                throw "not found ffmpeg";
            } else {
                trace('"ffmpeg.exe" not found, turning on preview mode...');
                ClientPrefs.data.previewRender = true;

                FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.sfxVolume);
                wentPreview = #if linux 'ffmpeg' #else 'ffmpeg.exe' #end + " was not found";
                return;
            }
        }
        var curCodec:String = ClientPrefs.data.codec;

        if (!testMode) {
            FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.sfxVolume);
            fileName = target + '/' + Paths.formatToSongPath(testMode ? "test" : PlayState.SONG.song);
            if (FileSystem.exists(fileName + fileExts)) {
                var millis = CoolUtil.fillNumber(Std.int(haxe.Timer.stamp() * 1000.0) % 1000, 3, 48);
                fileName += "-" + DateTools.format(Date.now(), "%Y-%m-%d_%H-%M-%S-") + millis;
            }
        } else {
            fileName = target + '/test-codec-' + curCodec;
        }
        var isGPU:Bool = curCodec.contains('QSV') || curCodec.contains('NVENC') || curCodec.contains('AMF') || curCodec.contains('VAAPI');
        if (curCodec.contains('VP')) fileExts = ".webm";

        var arguments:Array<String> = [
            '-y', '-f', 'rawvideo', '-pix_fmt', 'rgba', '-s', x + 'x' + y,
            '-r', Std.string(ClientPrefs.data.targetFPS), '-i', '-',
            '-c:v', GameRendererSettingsSubState.codecMap[curCodec]
        ];
        switch (ClientPrefs.data.encodeMode) {
            case "CRF/CQP":
                arguments.push('-b:v');
                arguments.push('0');
                arguments.push(isGPU ? '-qp' : '-crf');
                arguments.push(Std.string(ClientPrefs.data.constantQuality));
            case 'VBR', 'CBR':
                arguments.push('-b:v');
                arguments.push(Std.string(ClientPrefs.data.bitrate * 1_000_000));
                if (ClientPrefs.data.encodeMode == 'CBR') {
                    arguments.push('-maxrate');
                    arguments.push(Std.string(ClientPrefs.data.bitrate * 1_000_000));
                    arguments.push('-minrate');
                    arguments.push(Std.string(ClientPrefs.data.bitrate * 1_000_000));
                }
        }
        arguments.push(fileName + fileExts);
        
        if (!ClientPrefs.data.previewRender && !testMode) trace("running " + arguments);
        process = new Process('ffmpeg', arguments);

        buffer[0] = new Rectangle(x, y, w, h);
        buffer[1] = new Rectangle(0, 0, w, h);
        FlxG.autoPause = false;
    }

    public function pipeFrame():Void
    {
        var frameBuffer = buffer[1];
        image = window.readPixels(buffer[0]);

        w = image.width;
        h = image.height;

        if(w != frameBuffer.width || h != frameBuffer.height)
            frameBuffer.setTo(0, 0, w, h);

        bytes = image.getPixels(frameBuffer);
        process.stdin.writeBytes(bytes, 0, bytes.length);
    }

    public function destroy():Void
    {        
        if (process != null){
            if (process.stdin != null)
                process.stdin.close();
            process.close();
            process.kill();
        }

        FlxG.autoPause = ClientPrefs.data.autoPause;
    }
}
#end