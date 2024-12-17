package objects;

import flixel.math.FlxRandom;

class SustainSplash extends FlxSprite
{
	public static var startCrochet:Float;
	public static var frameRate:Int;

	public var note:Note;

	var rnd:FlxRandom;
	var timer:FlxTimer;
	var killing:Bool = false;
	var endAnim:Bool = false;

	public function new():Void
	{
		super();

		x = -50000;
		rnd = new FlxRandom();

		frames = Paths.getSparrowAtlas('holdCovers/holdCover-' + ClientPrefs.data.holdSkin);

		animation.addByPrefix('hold', 'holdCover0', 24, true);
		animation.addByPrefix('end', 'holdCoverEnd0', 24, false);
	}

	var killCnt:Int = 0;
	override function update(elapsed)
	{
		super.update(elapsed);

		if (note.strum != null)
		{
			setPosition(note.strum.x, note.strum.y);
			visible = note.strum.visible;
			alpha = ClientPrefs.data.holdSplashAlpha - (1 - note.strum.alpha);
			// trace(animation.curAnim.name, note.strum.animation.curAnim.name);

			// why do i need this stupid function
			if (note.strum.animation.curAnim.name == "static")
			{
				// if (animation.curAnim.name == "hold") ++killCnt;
				// if (!killing && killCnt > 2 && animation.curAnim.name != "end") {
				// 	showEndSplash();
				// }

			} else if (note.missed) {
				// kill immediately when missed, and timer stops forcely
				timer.cancel();
				timer.destroy();
				kill(); 
			} else killCnt = 0;
		}
	}

	public function setupSusSplash(daNote:Note, ?playbackRate:Float = 1):Void
	{
		killing = endAnim = false; visible = true; y = -50000;
		final lengthToGet:Int = !daNote.isSustainNote ? daNote.tail.length : daNote.parent.tail.length;
		final timeToGet:Float = !daNote.isSustainNote ? daNote.strumTime : daNote.parent.strumTime;
		final timeThingy:Float = (startCrochet * lengthToGet + (timeToGet - Conductor.songPosition + ClientPrefs.data.ratingOffset)) / playbackRate * .001;

		// trace(lengthToGet, timeToGet, timeThingy);

		var tailEnd:Note = !daNote.isSustainNote ? daNote.tail[daNote.tail.length - 1] : daNote.parent.tail[daNote.parent.tail.length - 1];

		animation.play('hold', true, false, 0);
		animation.curAnim.frameRate = frameRate;
		animation.curAnim.looped = true;

		clipRect = new flixel.math.FlxRect(0, !PlayState.isPixelStage ? 0 : -210, frameWidth, frameHeight);

		if (daNote.shader != null)
		{
			shader = new objects.NoteSplash.PixelSplashShaderRef().shader;
			shader.data.r.value = daNote.shader.data.r.value;
			shader.data.g.value = daNote.shader.data.g.value;
			shader.data.b.value = daNote.shader.data.b.value;
			shader.data.mult.value = daNote.shader.data.mult.value;
		}

		note = daNote;
		alpha = ClientPrefs.data.holdSplashAlpha - (1 - note.strum.alpha);
		offset.set(PlayState.isPixelStage ? 112.5 : 106.25, 100);

		if (timer != null)
			timer.cancel();

		if (ClientPrefs.data.holdSplashAlpha != 0) {
			timer = new FlxTimer().start(timeThingy, (idk:FlxTimer) ->
			{
				if (
					!(daNote.isSustainNote ? daNote.parent.noteSplashData.disabled : daNote.noteSplashData.disabled) && 
					(daNote.isSustainNote ? daNote.parent.sustainLength : daNote.sustainLength) > 150 && 
					animation != null)
				{
					showEndSplash(); return;
				}
				kill();
			});
		}
	}

	function showEndSplash() {
		if (killing || endAnim) return;
		killing = true;
		if (animation != null)
		{
			alpha = ClientPrefs.data.holdSplashAlpha - (1 - note.strum.alpha);
			animation.play('end', true, false, 0);
			endAnim = true;
			animation.curAnim.looped = false;
			animation.curAnim.frameRate = rnd.int(22, 26);
			clipRect = null;
			animation.finishCallback = idkEither -> kill();
			// trace("hi");
			return;
		} else kill();
	}

	override function kill() {
		visible = false;
		super.kill();
	}
}
