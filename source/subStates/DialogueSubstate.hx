package subStates;

import sys.db.Sqlite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.addons.text.FlxTypeText;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;
import data.Conductor;
import data.GameData.MusicBeatSubState;
import gameObjects.menu.AlphabetMenu;
import gameObjects.DialogueChar;
import sys.io.File;
import data.*;
import states.*;

using StringTools;

typedef Dialogue =
{
	var characters:Array<String>;
	var lines:Array<DialogueLine>;
	var finisher:Null<String>;
}

typedef DialogueLine =
{
	var character:String;
	var frame:String;
	var text:String;
	var delay:Null<Float>;
	var voiceline:Null<String>;
}

class DialogueSubstate extends MusicBeatSubState
{
	var box:FlxSprite;
	var tex:FlxTypeText;
	var label:FlxText;

	var left:DialogueChar;
	var right:DialogueChar;
	var log:Dialogue;

	var curLine:Int = 0;

	var loaded:Bool = false;
	var hasScrolled:Bool = false;
	var clickSfx:FlxSound;
	public static var dialog:String = 'log';
	public static var voiceline:FlxSound;
	
	public function new()
	{
		super();
		var banana = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		banana.alpha = 0;
		add(banana);

		trace('started substate');

		try
		{
			log = haxe.Json.parse(File.getContent('assets/data/log/' + dialog + '.json').trim());
			
			trace('loaded log');
			left = new DialogueChar(log.characters[0], false);
			left.loadJson();
			left.enterFrame('neutral');
			add(left);
	
			right = new DialogueChar(log.characters[1], true);
			right.loadJson();
			right.enterFrame('neutral');
			add(right);

			loaded = true;
		}
		catch (e)
		{
			trace('Uncaught Error: $e');
			close();
		}

		box = new FlxSprite().loadGraphic(Paths.image("hud/dialog/dialog"));
		box.screenCenter(X);
		box.y = FlxG.height - box.height - 20;
		box.alpha = 0;
		add(box);

		label = new FlxText(box.x + 25, box.y + 18, 170, "");
		label.alpha = 1;
		label.setFormat(Main.gFont, 30, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		label.borderSize = 2;
		add(label);

		clickSfx = new FlxSound();
		clickSfx.loadEmbedded(Paths.sound('beep'), false, false);
		FlxG.sound.list.add(clickSfx);

		tex = new FlxTypeText(box.x + 25, box.y + 70, 830, 'placeholder', true);
		tex.alpha = 1;
		tex.setFormat(Main.gFont, 30, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		tex.borderSize = 2;
		tex.skipKeys = [FlxKey.SPACE];
		tex.delay = 0.05;
		tex.sounds = [clickSfx];
		tex.finishSounds = false;
		add(tex);

		voiceline = new FlxSound();
		FlxG.sound.list.add(voiceline);

		FlxTween.tween(banana, {alpha: 0.4}, 0.1);
		FlxTween.tween(box, {alpha: 1}, 0.5, {
			ease: FlxEase.sineInOut,
			onComplete: function(twn:FlxTween)
			{
				if(loaded)
					textbox();
			}
		});
	}

	override function close()
	{
		SideState.paused = false;
		super.close();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var lastCam = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		for(item in members)
		{
			if(Std.isOfType(item, FlxBasic))
				cast(item, FlxBasic).cameras = [lastCam];
		}

		if(FlxG.keys.justPressed.SPACE && hasScrolled) {
			FlxG.sound.play(Paths.sound('click'));

			if(curLine == log.lines.length) {
				if(log.finisher != null) {
					switch (log.finisher) {
						case 'song2':
							PlayState.SONG = SongData.loadFromJson("echo");
							PlayState.isStory = true;
							PlayState.diff = 'NORMAL';
							Main.switchState(new PlayState());
						case 'introspection':
							PlayState.SONG = SongData.loadFromJson("introspection");
							PlayState.isStory = true;
							PlayState.diff = 'NORMAL';
							Main.switchState(new PlayState());
						case 'proglexi':
							SaveData.clowns.set('lexi', true);
							SaveData.saveButTechnically();
							close();
						case 'progjuke':
							SaveData.clowns.set('juke', true);
							SaveData.saveButTechnically();
							close();
						case 'progpete':
							SaveData.clowns.set('pete', true);
							SaveData.saveButTechnically();
							close();
						default:
							close();
					}
				}
				else
					close();
			}
			else
				textbox();
		}
	}

	function textbox()
	{
		hasScrolled = false;
		if (log.lines[curLine].delay != null)
			tex.delay = log.lines[curLine].delay;
		tex.resetText(log.lines[curLine].text);

		switch (log.lines[curLine].character) {
			case 'left':
				right.tweenAlpha(0.7, 0.1);
				left.enterFrame(log.lines[curLine].frame);
				label.text = left.charData.name;
				clickSfx.volume = 1;
			case 'right':
				left.tweenAlpha(0.7, 0.1);
				right.enterFrame(log.lines[curLine].frame);
				label.text = right.charData.name;
				clickSfx.volume = 1;
			case 'narrator':
				right.tweenAlpha(0.7, 0.1);
				left.tweenAlpha(0.7, 0.1);
				label.text = "Narrator";
				clickSfx.volume = 0;
		}

		if(log.lines[curLine].voiceline != null) {
			voiceline.loadEmbedded(Paths.sound('lines/' + log.lines[curLine].voiceline), false, false);
			voiceline.play();
		}

		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			tex.start(false, function()
				{
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						hasScrolled = true;
					});
				});
		});

		curLine ++;
	}
}