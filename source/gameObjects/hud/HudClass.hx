package gameObjects.hud;

import cpp.Stdio;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import data.Timings;
import states.PlayState;

class HudClass extends FlxGroup
{
	public var infoTxt:FlxText;

	// health bar
	public var healthBar:FlxSprite;

	// icon stuff
	public var iconBf:HealthIcon;
	var downscroll:Bool = false;

	public function new() 
	{
		super();

		downscroll = SaveData.data.get("Downscroll");
		healthBar = new FlxSprite();
		healthBar.frames = Paths.getSparrowAtlas("hud/base/health_bar");
		for (i in [0, 1, 2, 3, 4]) {
			healthBar.animation.addByPrefix(Std.string(i), 'Health bar000' + Std.string(i), 24, false);
		}
		healthBar.animation.play('4');
		healthBar.scale.set(0.6, 0.6);
		healthBar.updateHitbox();
		if(!downscroll)
			healthBar.y = FlxG.height - healthBar.height;
		else
			healthBar.flipY = true;
		healthBar.x -= 5;
		add(healthBar);

		iconBf = new HealthIcon();
		iconBf.setIcon(PlayState.SONG.player1, false);
		iconBf.x = 9;
		if(!downscroll)
			iconBf.y = healthBar.y + 20;
		else
			iconBf.y = healthBar.y;
		add(iconBf);

		infoTxt = new FlxText(0, 0, 0, "nothing");
		infoTxt.setFormat(Main.gFont, 18, 0xFFFFFFFF);
		infoTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		add(infoTxt);

		updateHitbox();
	
	}
	
	public final separator:String = " || ";

	public function updateText(step:Int)
	{
		infoTxt.text = Std.string(step);

		/*
		infoTxt.text += 			'Score: '		+ Timings.score;
		infoTxt.text += separator + 'Accuracy: '	+ Timings.accuracy + "%" + ' [${Timings.getRank()}]';
		infoTxt.text += separator + 'Misses: '		+ Timings.misses;
		*/

		infoTxt.screenCenter(X);
	}

	public function updateHitbox(downscroll:Bool = false)
	{
		updateText(0);
		infoTxt.screenCenter(X);
		infoTxt.y = (downscroll ? 50 : FlxG.height - 30 - 50) + 30;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		healthBar.animation.play(Std.string(Std.int(PlayState.health)));
		updateIconPos();
	}

	public function beatHit(curBeat:Int = 0)
	{
		if(curBeat % 2 == 0)
		{
			iconBf.scale.set(1.17,1.17);
			iconBf.updateHitbox();
			updateIconPos();
		}
	}
	public function updateIconPos()
	{
		iconBf.scale.set(
			FlxMath.lerp(iconBf.scale.x, 1, FlxG.elapsed * 6),
			FlxMath.lerp(iconBf.scale.y, 1, FlxG.elapsed * 6)
		);
		iconBf.updateHitbox();
		iconBf.screenCenter();
		/*
		iconBf.x = 9;
		if(!downscroll)
			iconBf.y = healthBar.y + 20;
		else
			iconBf.y = healthBar.y;
		*/
		var awesomeDiferentiator:Int = 7;

		if(downscroll)
			awesomeDiferentiator = -10;

		iconBf.x = (healthBar.x + healthBar.width / 2 - iconBf.width / 2) - 213;
		iconBf.y = (healthBar.y + healthBar.height/ 2 - iconBf.height/ 2) + awesomeDiferentiator;

		iconBf.setAnim(PlayState.health);
	}
}