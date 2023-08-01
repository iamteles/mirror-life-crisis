package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.addons.text.FlxTypeText;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.side.Level;
import gameObjects.side.Player;
import data.GameData.MusicBeatState;
import data.*;
import openfl.filters.ShaderFilter;
import flixel.system.FlxSound;
import subStates.*;
import states.menus.*;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class SideState extends MusicBeatState
{
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var lvlConstruct:Level;
	public var camFollow:FlxObject = new FlxObject();

	public static var inTextBox:Bool = false;
	public static var hasScrolled:Bool = false;
	public static var lvlId:String = 'street';
	public static var player:Player;
	public static var subtitle:FlxTypeText;
	public static var paused:Bool = true;
	public static var ret:Bool = false;

	var currentStyle:FlxCameraFollowStyle = FlxCameraFollowStyle.PLATFORMER;

	var spawn:Array<Int> = [400, 0];
	var preloadedSounds:Array<String> = ["running", "footsteps", "click", "beep"];
	public static var voiceline:FlxSound;
	public static var ambience:FlxSound;

	var lines:Array<Array<String>> = [];
	public static var curLine:Int = 0;

	function resetVariables()
	{
		inTextBox = false;
		hasScrolled = false;
		paused = false;
		curLine = 0;
	}

	override public function create()
	{
		super.create();

		resetVariables();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(80,80,80));
		bg.screenCenter();
		add(bg);

		lvlConstruct = new Level();
		lvlConstruct.loadJson();
		if(ret)
			spawn = lvlConstruct.retPoint;
		else
			spawn = lvlConstruct.spawnPoint;
		add(lvlConstruct);
		add(lvlConstruct.hbxLayer);
		add(lvlConstruct.warpLayer);

		FlxG.camera.zoom = lvlConstruct.zoom;

		player = new Player(spawn[0], spawn[1]);
		add(player);
		if(ret)
			player.facing = LEFT;
		add(lvlConstruct.foregroundLayer);

		subtitle = new FlxTypeText(0, 530, 800, 'placeholder', true);
		subtitle.alpha = 0;
		subtitle.setFormat(Main.gFont, 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		subtitle.screenCenter(X);
		subtitle.borderSize = 2;
		subtitle.cameras = [camHUD];
		subtitle.skipKeys = [FlxKey.SPACE];
		subtitle.delay = 0.05;
		add(subtitle);

		camFollow.setPosition(player.getMidpoint().x + lvlConstruct.camPos[0], player.getMidpoint().y + lvlConstruct.camPos[1]);
		FlxG.camera.follow(camFollow, currentStyle, 1);
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.camera.setScrollBoundsRect(Level.boundaries[0], Level.boundaries[1], Level.boundaries[2], Level.boundaries[3], true);

		if (SaveData.data.get('Shaders')) {
			var antiFishLens:FlxRuntimeShader = new FlxRuntimeShader(File.getContent(Paths.shader('afl')));
			FlxG.camera.setFilters([new ShaderFilter(antiFishLens)]);
		}

		for(sound in preloadedSounds) {
			Paths.preloadSound(sound);
		}

		ambience = new FlxSound();

		if(lvlConstruct.lvlData.music != null)
		{
			ambience.loadEmbedded(Paths.music(lvlConstruct.lvlData.music), true, false);
			FlxG.sound.list.add(ambience);
			ambience.volume = 0;
			ambience.play();
			ambience.fadeIn(0.32, 0, 0.5);
		}

		voiceline = new FlxSound();
		FlxG.sound.list.add(voiceline);

		switch(lvlId.toLowerCase()) {
			case 'street':
				if(SaveData.progression <= 0) {
					SaveData.progress(1);
					lines = [
						['One day in particular, as Minami was heading home to partake in her depressing activities, she came across a strange alleyway.', '12'],
						['Use the ARROW KEYS to move, SPACE to interact and SHIFT to run.', 'nan']
					];
					textbox(lines[curLine][0], lines[curLine][1]);
				}

			case 'alley':
				if(SaveData.progression <= 1) {
					SaveData.progress(2);
					textbox('In there, she found herself a strange vintage mirror, and decided to approach it.', '13');
				}

			case 'park':
				if(SaveData.progression == 5) {
					paused = true;
					DialogueSubstate.dialog = "echo";
					openSubState(new DialogueSubstate());
				}
			case 'village': 
				if(SaveData.progression <= 3) {
					SaveData.progress(4);
					lines = [
						['And, just like that, Minami found herself in the wonderfull world of Fooltopia!', '30'],
						['Everyone is dressed like clowns, there is no sadness here.', '31'],
						['Now Minami, remember, these clowns are here to make you happier and less depressed.', '32'],
						['This is your second chance.', '33'],
						["If you aren't happy after this, I might have to do a bit of intervening.", '34'],
						['And we dont want that now, do we.', '35'],
						['Go carry on, then. Go talk to the locals.', '36']
					];
					textbox(lines[curLine][0], lines[curLine][1]);
				}
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.collide(lvlConstruct.hbxLayer, player);
		FlxG.overlap(lvlConstruct.clickableLayer, player);
		camFollow.setPosition(player.getMidpoint().x + lvlConstruct.camPos[0], player.getMidpoint().y + lvlConstruct.camPos[1]);

		if(FlxG.keys.justPressed.SPACE) {
			if(inTextBox && hasScrolled) {
				if(voiceline.playing) voiceline.stop();
				FlxG.sound.play(Paths.sound('click'));
				FlxTween.tween(subtitle, {alpha: 0}, 0.4, {
					ease: FlxEase.sineInOut,
					onComplete: function(twn:FlxTween)
					{
						hasScrolled = false;

						if(curLine >= lines.length) {
							paused = false;
							inTextBox = false;
							curLine = 0;
						}
	
						else {
							textbox(lines[curLine][0], lines[curLine][1]);
						}
					}
				});
			}
			else if (!inTextBox) {
				interact();
			}
		}

		for (obj in lvlConstruct.warpMap)
		{
			if (player.overlaps(obj[0]) && !SideState.inTextBox)
			{
				switch (obj[1])
				{
					default:
						warp(obj[1], obj[2]);
				}
			}
		}

		if (FlxG.keys.justPressed.R)
			FlxG.resetState();
	
		if(Controls.justPressed("PAUSE"))
		{
			pause();
		}
	}

	override public function onFocusLost():Void
	{
		if(!paused) pause();
		super.onFocusLost();
	}

	public function pause()
	{
		if(paused || inTextBox) return;
		player.walkingSound.stop();
		player.runningSound.stop();
		paused = true;
		openSubState(new PauseRedux());
	}

	public static function textbox(text:String, ?sound:String = 'nan', ?delay:Float = 0.05)
	{
		subtitle.delay = delay;
		subtitle.resetText(text);
		subtitle.alpha = 1;
		inTextBox = true;
		paused = true;

		curLine++;

		if(sound != "nan") {
			voiceline.loadEmbedded(Paths.sound('lines/' + sound), false, false);
			voiceline.play();
		}
		subtitle.start(false, function()
		{
			new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				hasScrolled = true;
			});
		});
	}

	function interact()
	{
		for (obj in lvlConstruct.clickableMap)
		{
			if (player.overlaps(obj[0]) && !SideState.inTextBox)
			{
				var add:String = '';
				if(SaveData.progression >= 6)
					add = 'F';
				switch (obj[1])
				{
					case 'test':
						FlxG.resetState();
					case 'test2':
						SideState.textbox('pull worked!');
					case 'ONE':
						Main.switchState(new Prism());
					case 'dialogc1' | 'dialogpete':
						player.walkingSound.stop();
						player.runningSound.stop();
						paused = true;
						DialogueSubstate.dialog = obj[1] + add;
						openSubState(new DialogueSubstate());
					case 'dialogjuke':
						if(SaveData.progression >= 6) {
							player.walkingSound.stop();
							player.runningSound.stop();
							paused = true;
							openSubState(new FreeplayState());
						}
						else {
							player.walkingSound.stop();
							player.runningSound.stop();
							paused = true;
							DialogueSubstate.dialog = obj[1];
							openSubState(new DialogueSubstate());
						}
					case 'dialogclown':
						if(!SaveData.clownCheck()) {
							textbox('You should probably talk to all the locals first.');
						}
						else {
							player.walkingSound.stop();
							player.runningSound.stop();
							paused = true;
							DialogueSubstate.dialog = obj[1] + add;
							openSubState(new DialogueSubstate());
						}
				}
			}
		}
	}

	function warp(?location:String = 'street', ?ret:Bool = false) {
		lvlId = location;
		states.SideState.ret = ret;
		ambience.fadeOut(0.32);
		Main.switchState(new SideState());
	}
}
