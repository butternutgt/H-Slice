package backend;

import options.GameplaySettingsSubState;
import flixel.FlxState;
import backend.PsychCamera;

class MusicBeatState extends FlxState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var oldStep:Float = 0;
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

	var _psychCameraInitialized:Bool = false;

	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static function getVariables()
		return getState().variables;

	override function create() {
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		#if MODS_ALLOWED Mods.updatedOnState = false; #end

		if(!_psychCameraInitialized) initPsychCamera();

		super.create();

		curStepLimit = ClientPrefs.data.updateStepLimit;

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

		if(curStep > 0)
			stepHit();

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
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Float = curSection;
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

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
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
		return cast (FlxG.state, MusicBeatState);
	}

	var maxBPM:Float = ClientPrefs.data.updateStepLimit * GameplaySettingsSubState.defaultBPM * ClientPrefs.data.framerate;
	var nextStep:Float;
	public function stepHit():Void
	{
		maxBPM = ClientPrefs.data.updateStepLimit * GameplaySettingsSubState.defaultBPM * ClientPrefs.data.framerate;
		nextStep = curStep + 1;

		if (Conductor.bpm <= maxBPM) {
			if (ClientPrefs.data.updateStepLimit != 0) {
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

				if (oldStep % 4 == 0)
					beatHit();
				
				++oldStep; ++updateCount;
				
				countJudge = (ClientPrefs.data.updateStepLimit != 0 ? oldStep < nextStep && updateCount < curStepLimit : oldStep < nextStep);
			}
		} else {
			for (i in 0...ClientPrefs.data.updateStepLimit) {
				oldStep = Std.int(FlxMath.lerp(oldStep, nextStep, i/ClientPrefs.data.updateStepLimit));
					
				stagesFunc(function(stage:BaseStage) {
					stage.curStep = oldStep;
					stage.curDecStep = oldStep;
					stage.stepHit();
				});

				if (oldStep % 4 == 0)
					beatHit();
			}
			updateCount = ClientPrefs.data.updateStepLimit;
		}
		updateMaxSteps = updateCount;

		oldStep = Std.int(Math.max(oldStep, nextStep));
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

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
