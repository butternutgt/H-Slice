package backend;

import options.GameplaySettingsSubState;
import flixel.FlxState;
import backend.PsychCamera;

class MusicBeatState extends FlxState
{
	private static var currentState:MusicBeatState;

	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var oldStep:Float = -1;
	private var curStep:Float = 0;
	private var curStepLimit:Int = 0;
	private var updateCount:Int = 0;
	private var curBeat:Float = 0;
	public var updateMaxSteps:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	public var controls(get, never):Controls;
	private function get_controls()
	{
		return Controls.instance;
	}

	#if TOUCH_CONTROLS_ALLOWED
	public var touchPad:TouchPad;
	public var hitbox:Hitbox;
	public var camControls:FlxCamera;
	public var tpadCam:FlxCamera;

	public function addTouchPad(DPad:String, Action:String)
	{
		touchPad = new TouchPad(DPad, Action);
		add(touchPad);
	}

	public function removeTouchPad()
	{
		if (touchPad != null)
		{
			remove(touchPad);
			touchPad = FlxDestroyUtil.destroy(touchPad);
		}

		if(tpadCam != null)
		{
			FlxG.cameras.remove(tpadCam);
			tpadCam = FlxDestroyUtil.destroy(tpadCam);
		}
	}

	public function addHitbox(defaultDrawTarget:Bool = false):Void
	{
		var extraMode = MobileData.extraActions.get(ClientPrefs.data.extraHints);

		hitbox = new Hitbox(extraMode);
		hitbox = MobileData.setButtonsColors(hitbox);

		camControls = new FlxCamera();
		camControls.bgColor.alpha = 0;
		FlxG.cameras.add(camControls, defaultDrawTarget);

		hitbox.cameras = [camControls];
		hitbox.visible = false;
		add(hitbox);
	}

	public function removeHitbox()
	{
		if (hitbox != null)
		{
			remove(hitbox);
			hitbox = FlxDestroyUtil.destroy(hitbox);
			hitbox = null;
		}

		if(camControls != null)
		{
			FlxG.cameras.remove(camControls);
			camControls = FlxDestroyUtil.destroy(camControls);
		}
	}

	public function addTouchPadCamera(defaultDrawTarget:Bool = false):Void
	{
		if (touchPad != null)
		{
			tpadCam = new FlxCamera();
			tpadCam.bgColor.alpha = 0;
			FlxG.cameras.add(tpadCam, defaultDrawTarget);
			touchPad.cameras = [tpadCam];
		}
	}

	override function destroy()
	{
		removeTouchPad();
		removeHitbox();
		
		super.destroy();
	}
	#end
	var _psychCameraInitialized:Bool = false;

	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static function getVariables()
		return getState().variables;

	var maxBPM:Float = 0;
	override function create() {
		currentState = this;
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		#if MODS_ALLOWED Mods.updatedOnState = false; #end

		if(!_psychCameraInitialized) initPsychCamera();

		super.create();

		curStepLimit = ClientPrefs.data.updateStepLimit;
		
		if (curStepLimit > 0) 
			maxBPM = curStepLimit * GameplaySettingsSubState.defaultBPM * ClientPrefs.data.framerate;
		else maxBPM = Math.POSITIVE_INFINITY;

		if(!skip) {
			openSubState(new CustomFadeTransition(0.5, true));
		}
		FlxTransitionableState.skipNextTransOut = false;
		timePassedOnState = 0;
	}

	public function initPsychCamera():PsychCamera
	{
		var camera = new PsychCamera();
		FlxG.cameras.reset(camera);
		FlxG.cameras.setDefaultDrawTarget(camera, true);
		_psychCameraInitialized = true;
		//trace('initialized psych camera ' + Sys.cpuTime());
		return camera;
	}

	public static var timePassedOnState:Float = 0;

	var countJudge:Bool = false;
	override function update(elapsed:Float)
	{
		//everyStep();
		timePassedOnState += elapsed;
		updateCount = 0;

		updateCurStep();
		updateBeat();

		// trace(curStep, CoolUtil.floatToStringPrecision(curDecStep, 3), curBeat);

		if(curStep > 0) stepHit();

		if(PlayState.SONG != null)
		{
			if (oldStep < curStep)
				updateSection();
			else
				rollbackSection();
		}
				
		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;
		
		stagesFunc(function(stage:BaseStage) {
			stage.update(elapsed);
		});

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			stepsToDo += Math.round(getBeatsOnSection() * 4);
			sectionHit();
		}
	}

	var lastSection:Float;
	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		lastSection = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	var lastChange:BPMChangeEvent;
	var delayToFix:Float;
	private function updateCurStep():Void
	{
		lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		delayToFix = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + delayToFix;
		curStep = lastChange.stepTime + Math.floor(delayToFix);
		if (oldStep - 1 > curDecStep) oldStep = curStep; // for looping music
	}

	public static function switchState(nextState:FlxState = null) {
		if(nextState == null) nextState = FlxG.state;
		if(nextState == FlxG.state)
		{
			resetState();
			return;
		}

		if(FlxTransitionableState.skipNextTransIn) FlxG.switchState(nextState);
		else startTransition(nextState);
		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function resetState() {
		if(FlxTransitionableState.skipNextTransIn) FlxG.resetState();
		else startTransition();
		FlxTransitionableState.skipNextTransIn = false;
	}

	// Custom made Trans in
	public static function startTransition(nextState:FlxState = null)
	{
		if(nextState == null)
			nextState = FlxG.state;

		FlxG.state.openSubState(new CustomFadeTransition(0.5, false));
		if(nextState == FlxG.state)
			CustomFadeTransition.finishCallback = function() FlxG.resetState();
		else
			CustomFadeTransition.finishCallback = function() FlxG.switchState(nextState);
	}

	public static function getState():MusicBeatState {
		if (Std.is(FlxG.state, MusicBeatState))
			return cast(FlxG.state, MusicBeatState);
		else
			return currentState;
	}

	public function stepHit():Void
	{
		var nextStep:Float = curStep + 1;
		if (curStepLimit > 0) 
			maxBPM = curStepLimit * GameplaySettingsSubState.defaultBPM * ClientPrefs.data.framerate;
		else maxBPM = Math.POSITIVE_INFINITY;

		if (Conductor.bpm <= maxBPM) {
			if (curStepLimit != 0) {
				countJudge = oldStep < nextStep && updateCount < curStepLimit;
			} else {
				countJudge = oldStep < nextStep;
			}
			
			while (countJudge) {
				stagesFunc(function(stage:BaseStage) {
					stage.curStep = oldStep;
					stage.curDecStep = oldStep;
					stage.stepHit();
				});

				if (oldStep % 4 == 0) beatHit();
				
				++oldStep; ++updateCount;
				
				countJudge = (curStepLimit != 0 ? oldStep < nextStep && updateCount < curStepLimit : oldStep < nextStep);
			}
		} else {				
			stagesFunc( stage -> {
				stage.curStep = curStep;
				stage.curDecStep = curStep;
				stage.stepHit();
			});

			if (curStep % 4 == 0) beatHit();
			updateCount = curStepLimit;
			oldStep = curStep;
		}
		updateMaxSteps = updateCount;
	}

	public var stages:Array<BaseStage> = [];
	public function beatHit():Void
	{
		//trace('Beat: ' + curBeat);
		stagesFunc(function(stage:BaseStage) {
			stage.curBeat = curBeat;
			stage.curDecBeat = curDecBeat;
			stage.beatHit();
		});
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
		stagesFunc(function(stage:BaseStage) {
			stage.curSection = curSection;
			stage.sectionHit();
		});
	}

	function stagesFunc(func:BaseStage->Void)
	{
		for (stage in stages)
			if(stage != null && stage.exists && stage.active)
				func(stage);
	}

	var sectionBeat:Null<Float> = 4;
	function getBeatsOnSection()
	{
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null)
			sectionBeat = PlayState.SONG.notes[curSection].sectionBeats;
		return sectionBeat ?? 4;
	}
}
