package subStates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxBasic;
import data.GameData.MusicBeatSubState;
import states.*;
import states.menus.*;

class GameOverSubState extends MusicBeatSubState
{
	var waitIsOver = false;
	public var ended:Bool = false;
	var sprite:FlxSprite;
	var glass:FlxSprite;
	public function new()
	{
		super();

		glass = new FlxSprite(0, 0).loadGraphic(Paths.image("hud/base/glass"));
		glass.screenCenter();
		add(glass);

		sprite = new FlxSprite();
		sprite.frames = Paths.getSparrowAtlas("hud/base/gameover");
		sprite.animation.addByPrefix('start', 		'gameover', 24, false);
		sprite.animation.addByPrefix('idle', 		'gameover0120', 24, true);
		sprite.animation.play('start');
		sprite.scale.set(0.5, 0.5);
		sprite.updateHitbox();
		sprite.screenCenter();
		sprite.y -= 100;
		add(sprite);

		FlxG.sound.play(Paths.sound('gameover'));

		var countTimer = new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			waitIsOver = true;
		});
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

		if(sprite.animation.curAnim.name == "start" && sprite.animation.curAnim.finished) {
			sprite.animation.play("idle");
			if(!ended)
				FlxG.sound.playMusic(Paths.music('gameover'), 1);
		}


		if(!ended || waitIsOver)
		{
			if(Controls.justPressed("BACK"))
			{
				FlxG.camera.fade(FlxColor.BLACK, 0.2, false, function()
				{
					Main.switchState(new MenuState());
				}, true);
				
			}

			if(Controls.justPressed("ACCEPT"))
				endBullshit();
		}
	}

	public function endBullshit()
	{
		ended = true;

		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound('gameoverend'));

		new FlxTimer().start(1.0, function(tmr:FlxTimer)
		{
			FlxG.cameras.list[FlxG.cameras.list.length - 1].fade(FlxColor.BLACK, 1.0, false, null, true);

			new FlxTimer().start(2.0, function(tmr:FlxTimer)
			{
				Main.skipClearMemory = true;
				Main.switchState(new PlayState());
			});

		});
	}
}