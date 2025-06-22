package states;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;
	var toInt = CoolUtil.int;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		
		var operates = [
			["ENTER", "ESCAPE", "BACKSPACE", "Engine"],
			["A", "B", "C", "Port"]
		];

		var guh:String;
		final bro:String = #if mobile 'kiddo' #else 'bro' #end;
		final escape:String = (controls.mobileC) ? 'B' : 'ESCAPE';

		guh = "Sup "+bro+", looks like you're running an   \n
		outdated version of H-Slice Engine (" + MainMenuState.hrkVersion + ",\n
		please update to " + TitleState.updateVersion + "!\n
		Press "+escape+" to proceed anyway.\n
		\n
		Thank you for using the Engine!";

		warnText = new FlxText(0, 0, FlxG.width, guh, 32);
		warnText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		warnText.antialiasing = ClientPrefs.data.antialiasing;
		add(warnText);
		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('NONE', 'A_B');
		#end
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				CoolUtil.browserLoad("https://github.com/HRK-EXEX/H-Slice/releases");
			}
			else if(#if TOUCH_CONTROLS_ALLOWED touchPad.buttonB.justPressed #else FlxG.keys.justPressed.ESCAPE #end) {
				leftState = true;
			}
			else if(#if TOUCH_CONTROLS_ALLOWED touchPad.buttonC.justPressed #else FlxG.keys.justPressed.BACKSPACE #end) {
				leftState = true;
				ClientPrefs.data.checkForUpdates = false;
			}

			if(leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.sfxVolume);
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new MainMenuState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}
