package states;

import data.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import data.*;
import data.SongData.SwagSong;
import data.GameData.MusicBeatState;
import data.GameData.Utils;
import gameObjects.*;
import gameObjects.hud.*;
import gameObjects.hud.note.*;
import subStates.*;
import states.menus.*;
import openfl.filters.ShaderFilter;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	// song stuff
	public static var SONG:SwagSong;
	public static var isStory:Bool;
	public static var diff:String = 'NORMAL';
	public var inst:FlxSound;
	public var vocals:FlxSound;
	public var musicList:Array<FlxSound> = [];
	public var daSong:String = "prismatic";
	// 
	public static var assetModifier:String = "base";
	public static var health:Float = 5;
	// score, misses, accuracy and other stuff
	// are on the Timings.hx class!!

	// objects
	public var stageBuild:Stage;

	public var characters:Array<Character> = [];
	public var dad:Character;
	public var boyfriend:Character;
	public var juke:Character;

	// strumlines
	public var strumlines:FlxTypedGroup<Strumline>;
	public var bfStrumline:Strumline;
	public var dadStrumline:Strumline;
	var strumPos:Array<Float> = [];

	// hud
	public var hudBuild:HudClass;

	// cameras!!
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camVignette:FlxCamera;
	public var camOther:FlxCamera; // used so substates dont collide with camHUD.alpha or camHUD.visible
	public static var defaultCamZoom:Float = 1.0;
	var zoomAdd:Float = 0;

	public var camFollow:FlxObject = new FlxObject();
	public var charFollow:FlxObject = new FlxObject();

	public static var paused:Bool = false;

	var camDisplaceX:Float;
	var camDisplaceY:Float;
	var cameraMoveItensity:Float = 25;

	var mustHit:Bool = true;
	var vgblack:FlxSprite;
	var vhs:FlxSprite;
	var thetimesthattick:FlxSprite;

	var prismaticisover:Bool = false;
	var isflashback:Bool = false;
	private var meta:SongMetaTags;

	function resetStatics()
	{
		health = 5;
		defaultCamZoom = 1.0;
		assetModifier = "base";
		SplashNote.resetStatics();
		Timings.init();
		paused = false;
	}

	override public function create()
	{
		super.create();
		resetStatics();

		if(SONG == null)
			SONG = SongData.loadFromJson("echo");

		daSong = SONG.song.toLowerCase();

		if(daSong == "collision")
			assetModifier = "pixel";

		Conductor.setBPM(SONG.bpm);
		Conductor.mapBPMChanges(SONG);



		// setting up the cameras
		camGame = new FlxCamera();
		
		camHUD = new FlxCamera();
		camHUD.bgColor.alphaFloat = 0;

		camVignette = new FlxCamera();
		camVignette.bgColor.alphaFloat = 0;

		camOther = new FlxCamera();
		camOther.bgColor.alphaFloat = 0;

		// adding the cameras
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camVignette, false);
		FlxG.cameras.add(camOther, false);

		// default camera
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		//camGame.zoom = 0.6;

		stageBuild = new Stage();
		stageBuild.reloadStageFromSong(SONG.song);
		add(stageBuild);
		
		camGame.zoom = defaultCamZoom;

		dad = new Character();
		dad.reloadChar(SONG.player2, false);
		dad.setPosition(stageBuild.dadData[0], stageBuild.dadData[1]);
		dad.y -= dad.height;

		boyfriend = new Character();
		boyfriend.reloadChar(SONG.player1, true);
		boyfriend.setPosition(stageBuild.bfData[0], stageBuild.bfData[1]);
		boyfriend.y -= boyfriend.height;

		if(daSong == 'echo') {
			juke = new Character();
			juke.reloadChar("juke", false);
			juke.setPosition(stageBuild.gfData[0], stageBuild.gfData[1]);
			juke.y -= juke.height;

			characters.push(juke);
		}
		else if(daSong == 'introspection') {
			dad.reloadChar("boss", false);
			boyfriend.reloadChar("minami-3b", true);
			dad.reloadChar("narratorb", false);
			boyfriend.reloadChar("minami-3c", true);
			dad.reloadChar(SONG.player2, false);
			boyfriend.reloadChar(SONG.player1, true);
		}

		characters.push(dad);
		characters.push(boyfriend);

		for(char in characters)
		{
			char.x += char.globalOffset.x;
			char.y += char.globalOffset.y;
		}

		for(item in characters)
			add(item);

		add(stageBuild.foreground);

		followCamera(dad);
		camFollow.setPosition(charFollow.x, charFollow.y);
		FlxG.camera.follow(camFollow, LOCKON, 1);
		FlxG.camera.focusOn(camFollow.getPosition());

		if(daSong == 'introspection') {
			vhs = new FlxSprite();
			vhs.frames = Paths.getSparrowAtlas("backgrounds/final/vhs");
			vhs.animation.addByPrefix("idle", 'idle', 16, true);
			vhs.animation.play('idle');
			vhs.scale.set(3, 3);
			vhs.updateHitbox();
			vhs.screenCenter();
			vhs.alpha = 0;
			vhs.blend = LAYER;
			vhs.cameras = [camHUD];
			add(vhs);

			thetimesthattick = new FlxSprite();
			thetimesthattick.frames = Paths.getSparrowAtlas("hud/base/TIMESATICKIN");
			thetimesthattick.animation.addByPrefix("idle", 'piece of paper', 16, false);
			thetimesthattick.scale.set(0.5, 0.5);
			thetimesthattick.updateHitbox();
			thetimesthattick.screenCenter();
			thetimesthattick.alpha = 0;
			thetimesthattick.x += 270;
			thetimesthattick.y += 270;
			thetimesthattick.cameras = [camHUD];
			add(thetimesthattick);
		}

		var overlay = new FlxSprite(0, 0).loadGraphic(Paths.image("hud/overlays/" + SaveData.data.get("Mania Overlay")));
		overlay.screenCenter();
		overlay.cameras = [camHUD];
		if(diff != 'MANIA')
			overlay.alpha = 0;
		add(overlay);

		strumlines = new FlxTypedGroup();
		strumlines.cameras = [camHUD];
		add(strumlines);


		
		hudBuild = new HudClass();
		hudBuild.cameras = [camHUD];
		add(hudBuild);

		vgblack = new FlxSprite().loadGraphic(Paths.image("vignette"));
		vgblack.screenCenter();
		vgblack.cameras = [camVignette];
		vgblack.alpha = 0;
		add(vgblack);

		meta = new SongMetaTags(0, 144, daSong);
		meta.cameras = [camVignette];
		add(meta);

		// strumlines
		//strumline.scrollSpeed = 4.0; // 2.8

		strumPos = [FlxG.width / 2, FlxG.width / 4];
		var posBF:Float;
		var posOpp:Float;
		if(diff == 'MANIA') {
			posBF = strumPos[0] + strumPos[1];
			posOpp = strumPos[0] - strumPos[1];
		}
		else {
			posBF = strumPos[0] - strumPos[1];
			posOpp = strumPos[0] + strumPos[1];
		}
		var downscroll:Bool = SaveData.data.get("Downscroll");

		dadStrumline = new Strumline(posOpp, dad, downscroll, false, true, assetModifier);
		dadStrumline.ID = 0;
		strumlines.add(dadStrumline);

		bfStrumline = new Strumline(posBF, boyfriend, downscroll, true, SaveData.data.get("Botplay"), assetModifier);
		bfStrumline.ID = 1;
		strumlines.add(bfStrumline);

		if(diff == 'MANIA')
		{
			dadStrumline.x -= (strumPos[0] + 300); // goes offscreen
			bfStrumline.x  -= strumPos[1]; // goes to the middle
		}

		for(strumline in strumlines.members)
		{
			strumline.scrollSpeed = SONG.speed;
			strumline.updateHitbox();
		}

		hudBuild.updateHitbox(bfStrumline.downscroll);

		inst = new FlxSound();
		inst.loadEmbedded(Paths.inst(daSong), false, false);
		

		vocals = new FlxSound();
		if(SONG.needsVoices)
		{
			vocals.loadEmbedded(Paths.vocals(daSong), false, false);
		}

		FlxG.sound.list.add(inst);
		FlxG.sound.list.add(vocals);

		musicList.push(inst);
		musicList.push(vocals);

		for(music in musicList)
		{
			music.play();
			music.pause();
		}

		//Conductor.setBPM(160);
		Conductor.songPos = -Conductor.crochet * 5;

		var unspawnNotesAll:Array<Note> = ChartLoader.getChart(SONG);

		for(note in unspawnNotesAll)
		{
			var thisStrumline = dadStrumline;
			for(strumline in strumlines)
			{
				if(note.strumlineID == strumline.ID)
					thisStrumline = strumline;
			}

			//var direc = NoteUtil.getDirection(note.noteData);
			var thisStrum = thisStrumline.strumGroup.members[note.noteData];
			var thisChar = thisStrumline.character;

			note.reloadNote(note.songTime, note.noteData, note.noteType, assetModifier);

			note.onHit = function()
			{
				// when the player hits notes
				vocals.volume = 1;
				if(thisStrumline.isPlayer)
				{
					popUpRating(note, false);
				}

				if(!note.isHold)
				{
					var noteDiff:Float = Math.abs(note.songTime - Conductor.songPos);
					if(noteDiff <= Timings.timingsMap.get("sick")[0] || !thisStrumline.isPlayer)
					{
						thisStrumline.playSplash(note);
					}
				}

				// anything else
				note.gotHit = true;
				if(note.holdLength > 0)
					note.gotHold = true;

				if(!note.isHold)
				{
					//note.alpha = 0;
					note.visible = false;
					thisStrum.playAnim("confirm");
				}

				if(thisChar != null && !note.isHold)
				{
					thisChar.playAnim(thisChar.singAnims[note.noteData], true);
					thisChar.holdTimer = 0;

					/*if(note.noteType != 'none')
						thisChar.playAnim('hey');*/
				}
			};
			note.onMiss = function()
			{
				if(thisStrumline.botplay) return;

				vocals.volume = 0;

				note.gotHit = false;
				note.gotHold= false;
				note.canHit = false;
				note.alpha = 0.1;

				var onlyOnce:Bool = false;

				if(!note.isHold)
					onlyOnce = true;

				if(note.isHold && !note.isHoldEnd && note.parentNote.gotHit)
					onlyOnce = true;

				if(onlyOnce)
				{
					if(thisChar != null)
					{
						thisChar.playAnim(thisChar.missAnims[note.noteData], true);
						thisChar.holdTimer = 0;
					}

					// when the player misses notes
					if(thisStrumline.isPlayer)
					{
						popUpRating(note, true);
					}
				}
			};
			// only works on long notes!!
			note.onHold = function()
			{
				vocals.volume = 1;
				note.gotHold = true;

				// if not finished
				if(note.holdHitLength < note.holdLength - Conductor.stepCrochet)
				{
					thisStrum.playAnim("confirm");

					thisChar.playAnim(thisChar.singAnims[note.noteData], true);
					thisChar.holdTimer = 0;
				}
			}

			//if(thisStrumline.isPlayer)
			//{
				thisStrumline.addSplash(note);
			//}

			thisStrumline.unspawnNotes.push(note);
		}

		if (SaveData.data.get('Shaders')) {
			var antiFishLens:FlxRuntimeShader = new FlxRuntimeShader(File.getContent(Paths.shader('afl')));
			FlxG.camera.setFilters([new ShaderFilter(antiFishLens)]);
		}

		// Updating Discord Rich Presence
		DiscordClient.changePresence("Playing: " + SONG.song.toUpperCase().replace("-", " "), null);

		switch(daSong) {
			case 'prismatic':
				if(diff != 'MANIA') {
					vgblack.alpha = 0.4;
					dad.alpha = 0;
					camHUD.alpha = 0;
					FlxG.camera.fade(0x00000000, 0.1, false);
				}
			case 'echo' | 'introspection':
				if(diff != 'MANIA') {
					camHUD.alpha = 0;
					FlxG.camera.fade(0x00000000, 0.1, false);
				}
		}

		startCountdown();
	}

	public var startedSong:Bool = false;

	public function startCountdown()
	{
		var daCount:Int = 0;

		var countTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			Conductor.songPos = -Conductor.crochet * (4 - daCount);

			if(daCount == 4)
			{
				startSong();
			}

			if(daCount == 0) {
				if(meta != null){
					meta.start();
				}
			}

			if(daCount != 4)
			{
				var which:String = ["3", "2", "1", "GO"][daCount];
				var hehe = new FlxText(0, 0, which, true);
				FlxG.sound.play(Paths.sound(which));
				hehe.setFormat(Main.gFont, 60, 0xFFFFFFFF);
				hehe.setBorderStyle(OUTLINE, 0xFF000000, 3);
				hehe.updateHitbox();
				hehe.cameras = [camVignette];
				hehe.screenCenter();
				add(hehe);

				new FlxTimer().start(Conductor.stepCrochet * 3.8 / 1000, function(tmr:FlxTimer)
				{
					hehe.destroy();
				});
			}

			////trace(daCount);

			daCount++;
		}, 5);
	}

	public function startSong()
	{
		startedSong = true;
		for(music in musicList)
		{
			music.stop();
			music.play();

			if(paused) {
				music.pause();
			}
		}
	}

	override function openSubState(state:FlxSubState)
	{
		super.openSubState(state);
		if(startedSong)
		{
			for(music in musicList)
			{
				music.pause();
			}
		}
	}

	override function closeSubState()
	{
		activateTimers(true);
		super.closeSubState();
		if(startedSong)
		{
			for(music in musicList)
			{
				music.play();
			}
			syncSong(true);
		}
	}

	// for pausing timers and tweens
	function activateTimers(apple:Bool = true)
	{
		FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
		{
			if(!tmr.finished)
				tmr.active = apple;
		});

		FlxTween.globalManager.forEach(function(twn:FlxTween)
		{
			if(!twn.finished)
				twn.active = apple;
		});
	}

	public function popUpRating(note:Note, miss:Bool = false)
	{
		var noteDiff:Float = Math.abs(note.songTime - Conductor.songPos);
		if(note.isHold && !miss)
			noteDiff = 0;

		var judge:Float = Timings.diffToJudge(noteDiff);
		if(miss) {
			health -= 0.5;
			judge = Timings.timingsMap.get('miss')[1];
			FlxG.sound.play(Paths.sound('miss_' + FlxG.random.int(1, 3)));
		}
		else {
			health += 0.5;
		}


		if(!SaveData.data.get("Botplay")) {
			Timings.score += Math.floor(100 * judge);
			Timings.addAccuracy(judge);
		}


		if(miss && !SaveData.data.get("Botplay"))
		{
			Timings.misses++;
		}
		else
		{
			if(judge <= Timings.timingsMap.get('shit')[1])
			{
				////trace("that was shit");
				note.onMiss();
			}
		}

		hudBuild.updateText();
	}

	// if youre holding a note
	public var isSinging:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		camGame.followLerp = elapsed * 3;

		if(Controls.justPressed("PAUSE"))
		{
			pauseSong();
		}

		if(Controls.justPressed("RESET"))
			startGameOver();

		if(FlxG.keys.justPressed.ONE && SaveData.data.get('Munchlog') == 398)
		{
			endSong();
		}

		//strumline.scrollSpeed = 2.8 + Math.sin(FlxG.game.ticks / 500) * 1.5;

		//if(song.playing)
		//	Conductor.songPos = song.time;
		// syncSong
		Conductor.songPos += elapsed * 1000;

		var pressed:Array<Bool> = [
			Controls.pressed("LEFT"),
			Controls.pressed("DOWN"),
			Controls.pressed("UP"),
			Controls.pressed("RIGHT")
		];
		var justPressed:Array<Bool> = [
			Controls.justPressed("LEFT"),
			Controls.justPressed("DOWN"),
			Controls.justPressed("UP"),
			Controls.justPressed("RIGHT")
		];
		var released:Array<Bool> = [
			Controls.released("LEFT"),
			Controls.released("DOWN"),
			Controls.released("UP"),
			Controls.released("RIGHT")
		];

		isSinging = false;

		// strumline handler!!
		for(strumline in strumlines.members)
		{
			for(strum in strumline.strumGroup)
			{
				if(strumline.isPlayer && !strumline.botplay)
				{
					if(pressed[strum.strumData])
					{
						if(!["pressed", "confirm"].contains(strum.animation.curAnim.name))
							strum.playAnim("pressed");
						
						if(strum.animation.curAnim.name == "confirm")
							isSinging = true;
					}
					else
						strum.playAnim("static");
				}
				else
				{
					// how botplay handles it
					if(strum.animation.curAnim.name == "confirm"
					&& strum.animation.curAnim.finished)
						strum.playAnim("static");
				}
			}

			for(unsNote in strumline.unspawnNotes)
			{
				var spawnTime:Float = 1000;

				if(unsNote.songTime - Conductor.songPos <= spawnTime
				&& unsNote.canHit && !unsNote.gotHit && !unsNote.gotHold)
					strumline.addNote(unsNote);
			}
			for(note in strumline.allNotes)
			{
				var despawnTime:Float = 300;

				if(Conductor.songPos >= note.songTime + note.holdLength /*+ Conductor.stepCrochet*/ + despawnTime)
				{
					if(!note.gotHit || !note.gotHold) note.canHit = false;

					strumline.removeNote(note);
				}
			}

			// downscroll
			var downMult:Int = (strumline.downscroll ? -1 : 1);

			for(note in strumline.noteGroup)
			{
				var thisStrum = strumline.strumGroup.members[note.noteData];

				note.x = thisStrum.x + note.noteOffset.x;
				note.y = thisStrum.y + (thisStrum.height / 12 * downMult) + (note.noteOffset.y * downMult);

				/*note.scale.set(
					1 + Math.sin(FlxG.game.ticks / 64) * 0.3,
					1 - Math.sin(FlxG.game.ticks / 64) * 0.3
				);*/
				//note.angle = flixel.math.FlxMath.lerp(note.angle, FlxG.random.int(-360, 360), elapsed * 8);

				note.y += downMult * ((note.songTime - Conductor.songPos) * (strumline.scrollSpeed * 0.45));

				if(Conductor.songPos >= note.songTime + Timings.timingsMap.get("good")[0] && !note.gotHit && note.canHit)
				{
					////trace("too late");
					note.onMiss();
				}

				if(strumline.botplay)
				{
					if(note.songTime - Conductor.songPos <= 0 && !note.gotHit)
						note.onHit();
				}

				// whatever
				if(note.scrollSpeed != strumline.scrollSpeed)
					note.scrollSpeed = strumline.scrollSpeed;
			}

			for(hold in strumline.holdGroup)
			{
				if(hold.scrollSpeed != strumline.scrollSpeed)
				{
					hold.scrollSpeed = strumline.scrollSpeed;

					if(!hold.isHoldEnd)
					{
						var newHoldSize:Array<Float> = [
							hold.frameWidth * hold.scale.x,
							(hold.holdLength - (Conductor.stepCrochet / 2)) * (strumline.scrollSpeed * 0.45)
						];

						hold.setGraphicSize(
							Math.floor(newHoldSize[0]),
							Math.floor(newHoldSize[1])
						);
					}

					hold.updateHitbox();
				}

				hold.flipY = strumline.downscroll;

				if(hold.parentNote != null)
				{
					var thisStrum = strumline.strumGroup.members[hold.noteData];
					var holdParent = hold.parentNote;

					if(!hold.isHoldEnd)
					{
						hold.x = (holdParent.x + holdParent.width / 2 - hold.width / 2) + hold.noteOffset.x;
						hold.y = holdParent.y + holdParent.height / 2;
					}
					else
					{
						hold.x = holdParent.x;
						hold.y = holdParent.y + (strumline.downscroll ? 0 : holdParent.height) + (-downMult * 0.5);

						hold.y -= 5 * hold.scrollSpeed * downMult;
					}

					if(strumline.downscroll)
						hold.y -= hold.height;

					// input!!
					if(!holdParent.canHit && hold.canHit)
						hold.onMiss();

					var pressedCheck:Bool = (pressed[hold.noteData] && holdParent.gotHold && hold.canHit);

					if(!strumline.isPlayer || strumline.botplay)
						pressedCheck = (holdParent.gotHold && hold.canHit);

					if(hold.isHoldEnd)
						pressedCheck = (holdParent.gotHold && holdParent.canHit);

					if(pressedCheck)
					{
						hold.holdHitLength = Conductor.songPos - hold.songTime;
						////trace('${hold.holdHitLength} / ${hold.holdLength}');
						
						var daRect = new FlxRect(
							0,
							0,
							hold.frameWidth,
							hold.frameHeight
						);

						var center:Float = (thisStrum.y + thisStrum.height / 2);

						if(!strumline.downscroll)
						{
							if(hold.y < center)
								daRect.y = (center - hold.y) / hold.scale.y;
						}
						else
						{
							if(hold.y + hold.height > center)
								daRect.y = ((hold.y + hold.height) - center) / hold.scale.y;
						}

						hold.clipRect = daRect;

						hold.onHold();
					}

					if(strumline.isPlayer && !strumline.botplay)
					{
						if(released.contains(true))
						{					
							if(released[hold.noteData] && hold.canHit && holdParent.gotHold && !hold.isHoldEnd)
							{
								thisStrum.playAnim("static");

								if(hold.holdHitLength >= hold.holdLength - Conductor.stepCrochet)
									hold.onHit();
								else
									hold.onMiss();
							}
						}
					}
					else
					{
						if(holdParent.gotHold && !hold.isHoldEnd)
						{
							if(hold.holdHitLength >= hold.holdLength - Conductor.stepCrochet)
								hold.onHit();
							else
							{
								hold.onHold();
								//thisStrum.playAnim("confirm");
							}
						}
					}
				}
			}

			if(justPressed.contains(true) && !strumline.botplay && strumline.isPlayer)
			{
				for(i in 0...justPressed.length)
				{
					if(justPressed[i])
					{
						var possibleHitNotes:Array<Note> = []; // gets the possible ones
						var canHitNote:Note = null;

						for(note in strumline.noteGroup)
						{
							var noteDiff:Float = (note.songTime - Conductor.songPos);

							if(noteDiff <= Timings.minTiming && note.canHit && !note.gotHit && note.noteData == i)
							{
								possibleHitNotes.push(note);
								canHitNote = note;
							}
						}

						// if the note actually exists then you got it
						if(canHitNote != null)
						{
							for(note in possibleHitNotes)
							{
								if(note.songTime < canHitNote.songTime)
									canHitNote = note;
							}

							canHitNote.onHit();
						}
						else
						{
							// ghost tapped lol
							if(!SaveData.data.get("Ghost Tapping"))
							{
								vocals.volume = 0;
								var thisChar = strumline.character;
								if(thisChar != null)
								{
									thisChar.playAnim(thisChar.missAnims[i], true);
									thisChar.holdTimer = 0;
								}

								if(!SaveData.data.get("Botplay"))
								{
									var missJudge:Float = Timings.timingsMap.get("miss")[1];
									health -= 0.5;
									Timings.score += Math.floor(100 * missJudge);
									Timings.addAccuracy(missJudge);
									Timings.misses++;
								}
								//hudBuild.updateText();
							}
						}
					}
				}
			}

			// dumb stuff!!!
			if(daSong == "disruption")
			{
				for(strum in strumline.strumGroup)
				{
					var daTime:Float = (FlxG.game.ticks / 1000);

					var strumMult:Int = (strum.strumData % 2 == 0) ? 1 : -1;

					strum.x = strum.initialPos.x + Math.sin(daTime) * 20 * strumMult;
					strum.y = strum.initialPos.y + Math.cos(daTime) * 20 * strumMult;

					strum.scale.x = strum.strumSize + Math.sin(daTime) * 0.4;
					strum.scale.y = strum.strumSize - Math.sin(daTime) * 0.4;

					//strum.x -= strum.scaleOffset.x / 2;
				}
				for(note in strumline.allNotes)
				{
					var thisStrum = strumline.strumGroup.members[note.noteData];

					note.scale.x = thisStrum.scale.x;
					if(!note.isHold)
						note.scale.y = thisStrum.scale.y;
				}
			}
			/*else
			{
				var daPos = (Conductor.songPos);

				while(daPos > Conductor.crochet * 1.5)
				{
					daPos -= Conductor.crochet * 1.5;
				}

				var strumY:Float = strumline.downscroll ? FlxG.height : -NoteUtil.noteWidth();
				if(Conductor.songPos > 0)
					strumY += (daPos * downMult * (strumline.scrollSpeed * 0.45));

				for(strum in strumline.strumGroup)
				{
					strum.y = strumY;
				}
			}*/
		}

		var curSection = PlayState.SONG.notes[Std.int(curStep / 16)];

		if(curSection != null)
		{
			if(daSong != 'prismatic')
				mustHit = curSection.mustHitSection;

			if(mustHit) {
				if(daSong == 'introspection' && !isflashback)
					defaultCamZoom = 0.8;
				followCamera(boyfriend);
				switch (boyfriend.animation.curAnim.name)
				{
					case 'singLEFT':
						camDisplaceX = - cameraMoveItensity;
						camDisplaceY = 0;
					case 'singRIGHT':
						camDisplaceX = cameraMoveItensity;
						camDisplaceY = 0;
					case 'singUP':
						camDisplaceX = 0;
						camDisplaceY = -cameraMoveItensity;
					case 'singDOWN':
						camDisplaceX = 0;
						camDisplaceY = cameraMoveItensity;
					default:
						camDisplaceX = 0;
						camDisplaceY = 0;
				}
			}

			else {
				if(daSong == 'introspection' && !isflashback)
					defaultCamZoom = 0.5;
				followCamera(dad);
				switch (dad.animation.curAnim.name)
				{
					case 'singLEFT':
						camDisplaceX = - cameraMoveItensity;
						camDisplaceY = 0;
					case 'singRIGHT':
						camDisplaceX = cameraMoveItensity;
						camDisplaceY = 0;
					case 'singUP':
						camDisplaceX = 0;
						camDisplaceY = -cameraMoveItensity;
					case 'singDOWN':
						camDisplaceX = 0;
						camDisplaceY = cameraMoveItensity;
					default:
						camDisplaceX = 0;
						camDisplaceY = 0;
				}
			}
		}

		FlxG.camera.followLerp = Utils.camLerp(0.04);
		camFollow.setPosition(charFollow.x + camDisplaceX, charFollow.y + camDisplaceY);

		if(health <= 0)
		{
			startGameOver();
		}

		camGame.zoom = FlxMath.lerp(camGame.zoom, defaultCamZoom + zoomAdd, elapsed * 6);
		camHUD.zoom  = FlxMath.lerp(camHUD.zoom,  1.0, elapsed * 6);

		health = FlxMath.bound(health, 0, 5); // bounds the health
	}

	public function followCamera(?char:Character, ?offsetX:Float = 0, ?offsetY:Float = 0)
	{
		charFollow.setPosition(0,0);

		if(char != null)
		{
			var playerMult:Int = (char.isPlayer ? -1 : 1);
			var which:Array<Float> = (char.isPlayer ? stageBuild.bfData : stageBuild.dadData);

			charFollow.setPosition(char.getMidpoint().x + (200 * playerMult), char.getMidpoint().y - 20);

			charFollow.x += (char.cameraOffset.x * playerMult) + which[2];
			charFollow.y += char.cameraOffset.y + which[3];
		}

		charFollow.x += offsetX;
		charFollow.y += offsetY;
	}

	override function beatHit()
	{
		super.beatHit();
		
		hudBuild.beatHit(curBeat);

		if(curBeat % 4 == 0)
		{
			camGame.zoom += 0.05;
			camHUD.zoom += 0.025;
			Utils.bang(camVignette, 0.5);
		}
		if(curBeat % 2 == 0)
		{
			for(char in characters)
			{
				var canIdle = (char.holdTimer >= char.holdLength);

				if(char.isPlayer)
				{
					if(isSinging)
						canIdle = false;
				}

				if(!prismaticisover) {
					if(canIdle)
						char.dance();
				}

			}
		}
	}

	override function stepHit()
	{
		super.stepHit();
		syncSong();

		if(diff != 'MANIA') {
			switch (daSong) {
				case 'introspection':
					switch (curStep) {
						case 1:
							FlxTween.tween(camHUD, {alpha: 1}, 2, {ease: FlxEase.sineInOut});
						case 48:
							FlxG.camera.fade(0x00000000, 4, true);
						case 256:
							Utils.flash(camHUD);
							zoomAdd = 0.1;
						case 478:
							zoomAdd = 0.15;
						case 486:
							zoomAdd = 0.2;
						case 494:
							zoomAdd = 0.1;
						case 640:
							Utils.flash(camHUD);
							zoomAdd = 0;
						case 704:
							Utils.flash(camHUD);
							zoomAdd = 0.1;
						case 960:
							zoomAdd = 0.13;
						case 1024:
							Utils.flash(camHUD);
							zoomAdd = 0;
						case 1280: // 1280
							FlxG.camera.fade(0x00000000, 0.5, false);
							thetimesthattick.alpha = 1;
							thetimesthattick.animation.play('idle');
							var noteTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
							{
								FlxTween.tween(thetimesthattick, {alpha: 0}, 0.5, {ease: FlxEase.sineInOut});
							});
						// 1284 - time, 1288 - is, 1292, - ticking, 1297 - minami, 1301 - char change
						case 1301: //1301
							dad.reloadChar("boss", false);
							boyfriend.reloadChar("minami-3b", true);
							stageBuild.objectMap.get("office").alpha = 1;
							FlxTween.tween(vhs, {alpha: 0.5}, 1, {ease: FlxEase.sineInOut});
							isflashback = true;
							defaultCamZoom = 0.6;

							dad.setPosition(stageBuild.dadData[0], stageBuild.dadData[1]);
							boyfriend.setPosition(stageBuild.bfData[0], stageBuild.bfData[1]);
					
							for(char in characters)
							{
								char.x += char.globalOffset.x;
								char.y += char.globalOffset.y;
							}
						case 1312:
							Utils.flash(camHUD);
							FlxG.camera.fade(0x00000000, 0.1, true);
						case 1696: //1696
							//char change back
							Utils.flash(camHUD);
							
							vhs.alpha = 0;

							dad.reloadChar("narratorb", false);
							boyfriend.reloadChar("minami-3c", true);

							dad.setPosition(stageBuild.dadData[0], stageBuild.dadData[1]);
							boyfriend.setPosition(stageBuild.bfData[0], stageBuild.bfData[1]);

							for(char in characters)
							{
								char.x += char.globalOffset.x;
								char.y += char.globalOffset.y;
							}
							stageBuild.objectMap.get("office").alpha = 0;
							stageBuild.objectMap.get("sky").alpha = 0;
							stageBuild.objectMap.get("sun").alpha = 0;
							isflashback = false;
						case 1952:
							Utils.flash(camHUD);
							zoomAdd = 0.1;
						case 2096:
							Utils.flash(camHUD);
							zoomAdd = 0;
						case 2336:
							FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
							FlxG.camera.fade(0x00000000, 1, false);
					}
				case 'echo':
					switch (curStep) {
						case 16:
							FlxG.camera.fade(0x00000000, 7, true);
						case 272:
							FlxTween.tween(camHUD, {alpha: 1}, 5, {ease: FlxEase.sineInOut});
						case 528:
							Utils.flash(camHUD);
							defaultCamZoom = 0.73;
							for (strum in strumlines) {
								//strum.scrollSpeed = 3.3;

								FlxTween.tween(strum, {scrollSpeed: 3.3}, 0.4, {ease: FlxEase.linear});
							}
						case 784:
							Utils.flash(camHUD);
							defaultCamZoom = 0.8;
						case 912:
							defaultCamZoom = 0.67;
						case 976:
							Utils.flash(camHUD);
							defaultCamZoom = 0.73;
						case 1232:
							defaultCamZoom = 0.6;
						case 1238:
							defaultCamZoom = 0.8;
						case 1244:
							defaultCamZoom = 0.7;
						case 1360:
							defaultCamZoom = 0.6;
						case 1442:
							FlxG.camera.fade(0x00000000, 3, false);
						case 1552:
							FlxG.camera.fade(0x00000000, 4, true);
						case 1680:
							defaultCamZoom = 0.73;
						case 1808:
							defaultCamZoom = 0.86;
						case 1872: //1872
							// shader and middlescroll
							Utils.flash(camHUD);

							if(SaveData.data.get("Shaders")) {
								var epicShader:FlxRuntimeShader = new FlxRuntimeShader('
								#pragma header
								vec2 uv = openfl_TextureCoordv.xy;
								vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
								vec2 iResolution = openfl_TextureSize;
								uniform float iTime;
								#define iChannel0 bitmap
								#define texture flixel_texture2D
								#define fragColor gl_FragColor
								#define mainImage main
								
								int sampleCount = 50;
								float blur = 0.25; 
								float falloff = 3.0; 
								
								// use iChannel0 for video, iChannel1 for test grid
								#define INPUT iChannel0
								
								void mainImage()
								{
									vec2 destCoord = fragCoord.xy / iResolution.xy;
								
									vec2 direction = normalize(destCoord - 0.5); 
									vec2 velocity = direction * blur * pow(length(destCoord - 0.5), falloff);
									float inverseSampleCount = 1.0 / float(sampleCount); 
									
									mat3x2 increments = mat3x2(velocity * 1.0 * inverseSampleCount,
															   velocity * 2.0 * inverseSampleCount,
															   velocity * 4.0 * inverseSampleCount);
								
									vec3 accumulator = vec3(0);
									mat3x2 offsets = mat3x2(0); 
									
									for (int i = 0; i < sampleCount; i++) {
										accumulator.r += texture(INPUT, destCoord + offsets[0]).r; 
										accumulator.g += texture(INPUT, destCoord + offsets[1]).g; 
										accumulator.b += texture(INPUT, destCoord + offsets[2]).b; 
										
										offsets -= increments;
									}
								
									fragColor = vec4(accumulator / float(sampleCount), 1.0);
								}'); // lmao?
								FlxG.camera.setFilters([new ShaderFilter(epicShader)]);
							}
							defaultCamZoom = 0.66;
							
							dadStrumline.doSplash = false;

							for (strum in strumlines) {
								//strum.scrollSpeed = 3.3;
								strum.updatePls = true;
								FlxTween.tween(strum, {x: strumPos[0]}, 1, {ease: FlxEase.circInOut, onComplete: function(twn:FlxTween)
								{
									strum.updatePls = false;
								}});
							}

							for (thing in dadStrumline.strumGroup) {
								FlxTween.tween(thing, {alpha: 0}, 1, {ease: FlxEase.circOut});
							}

							for (thing in dadStrumline.allNotes) {
								FlxTween.tween(thing, {alpha: 0.14}, 1, {ease: FlxEase.circOut});
							}
							dadStrumline.noteAlpha = 0.14;
						case 2384:
							Utils.flash(camHUD);
							FlxTween.tween(camHUD, {alpha: 0}, 6, {ease: FlxEase.sineInOut});
							FlxG.camera.setFilters([]);
						case 2640:
							FlxG.camera.fade(0x00000000, 4, false);
						}
				case 'prismatic':
					switch(curStep) {
						case 1:
							FlxG.camera.fade(0x00000000, 7, true);
						case 200 | 338 | 471 | 739 | 1009:
							mustHit = false;
						case 136 | 269 | 406 | 537 | 944 | 1075:
							mustHit = true;
						case 67:
							// enter clown minami
							FlxTween.tween(camHUD, {alpha: 1}, 2, {ease: FlxEase.sineInOut});
							Utils.flash(camVignette);
							dad.alpha = 1;
							defaultCamZoom = 0.67;
							mustHit = false;
						case 605:
							defaultCamZoom = 0.77;
							Utils.flash(camHUD);
						case 874:
							defaultCamZoom = 0.67;
							Utils.flash(camHUD);
						case 1213:
							FlxTween.tween(camHUD, {alpha: 0}, 5, {ease: FlxEase.sineInOut});
							mustHit = false;
						case 1304: //1304
							//bow down
							dad.playAnim('bow', true);
							prismaticisover = true;
					}
			}
		}
	}

	public function syncSong(?forced:Bool = false):Void
	{
		if(!startedSong) return;

		for(music in musicList)
		{
			if(music.playing && music.length > 0 && Conductor.songPos < music.length)
			{
				if(Math.abs(Conductor.songPos - music.time) >= 40 || forced)
				{
					// makes everyone sync to the instrumental
					//trace("synced song");
					Conductor.songPos = inst.time;
					
					if(music != inst)
					{
						music.time = inst.time;
						music.play();
					}
				}
			}
		}

		checkEndSong();
	}

	public function checkEndSong():Void
	{
		var smallerLength:Float = inst.length;
		for(music in musicList)
		{
			if(music.length < smallerLength)
				smallerLength = music.length;
		}

		if(Conductor.songPos >= smallerLength)
		{
			endSong();
		}
	}

	function endSong() {
		if(!SaveData.data.get("Downscroll")) {
			Highscore.addScore(daSong + diff, {
				score: 		Timings.score,
				accuracy: 	Timings.accuracy,
				misses: 	Timings.misses,
			});
		}

		switch (daSong) {
			case 'prismatic':
				if(isStory) {
					SaveData.progress(3);
					SideState.lvlId = 'village';
					if(!SaveData.data.get('Video Cutscenes'))
						Main.switchState(new SideState());
					else
						Main.switchState(new VideoState('video', new SideState()));
				}
				else {
					Main.switchState(new SideState());
					SideState.lvlId = 'park';
				}
			case 'echo':
				if(isStory) {
					Main.switchState(new SideState());
					SideState.lvlId = 'park';
					SaveData.progress(5);
				}
				else {
					Main.switchState(new SideState());
					SideState.lvlId = 'park';
				}
			case 'introspection':
				if(isStory) {
					Main.switchState(new Ending());
				}
				else {
					Main.switchState(new SideState());
					SideState.lvlId = 'park';
				}
			default:
				Main.switchState(new MenuState());
		}
	}

	override public function onFocusLost():Void
	{
		if(!paused && !isDead) pauseSong();
		super.onFocusLost();
	}

	public function pauseSong()
	{
		paused = true;
		activateTimers(false);
		openSubState(new PauseSubState());
	}

	public var isDead:Bool = false;

	public function startGameOver()
	{
		if(isDead) return;
		
		isDead = true;
		activateTimers(false);
		persistentDraw = false;
		openSubState(new GameOverSubState());
	}
}