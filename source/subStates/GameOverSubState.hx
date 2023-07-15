package subStates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import data.GameData.MusicBeatSubState;
import gameObjects.Character;
import states.*;

class GameOverSubState extends MusicBeatSubState
{
	var waitIsOver = false;
	public var ended:Bool = false;
	var sprite:FlxSprite;
	public function new()
	{
		super();

		sprite = new FlxSprite();
		sprite.frames = Paths.getSparrowAtlas("hud/base/gameover");
		sprite.animation.addByPrefix('start', 		'gameover', 24, false);
		sprite.animation.addByPrefix('idle', 		'gameover0136', 24, true);
		sprite.animation.play('start');
		sprite.scale.set(0.7, 0.7);
		sprite.updateHitbox();
		sprite.screenCenter();
		sprite.x -= 70;
		add(sprite);

		FlxG.camera.follow(sprite, LOCKON, FlxG.elapsed * 1);

		var countTimer = new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			waitIsOver = true;
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(sprite.animation.curAnim.name == "start" && sprite.animation.curAnim.finished)
			sprite.animation.play("idle");

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

		new FlxTimer().start(1.0, function(tmr:FlxTimer)
		{
			FlxG.camera.fade(FlxColor.BLACK, 1.0, false, null, true);

			new FlxTimer().start(2.0, function(tmr:FlxTimer)
			{
				Main.skipClearMemory = true;
				Main.switchState(new PlayState());
			});

		});
	}
}