package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.addons.display.FlxBackdrop;
import flixel.input.keyboard.FlxKey;
import data.GameData.MusicBeatState;
import data.Conductor;
import data.GameData.Utils;

using StringTools;

class MenuState extends MusicBeatState
{
	public static var curSelected:Int = 0;	
	public var itemListing:Array<String> = ['Play', 'Credits', 'Settings'];
	var itemGroup:FlxTypedGroup<FlxSprite>;
	var bg:FlxBackdrop;
	var box:FlxSprite;
	var left:FlxSprite;
	var right:FlxSprite;
	var logo:FlxSprite;
	override function create()
	{
		super.create();

		if(FlxG.sound.music == null) {
			FlxG.sound.playMusic(Paths.music('menu'), 1);
			Conductor.setBPM(280);
		}

		Utils.flash(FlxG.camera, 0.5);

		bg = new FlxBackdrop(Paths.image("menu/grid"), XY, 0, 0);
        bg.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
       	bg.screenCenter();
        //bg.alpha = 0.4;
        add(bg);

		box = new FlxSprite(0, 0).loadGraphic(Paths.image("menu/box"));
		box.x = FlxG.width - box.width;
		box.y = FlxG.height - box.height;
		add(box);

		itemGroup = new FlxTypedGroup<FlxSprite>();
		add(itemGroup);

		for (i in 0...itemListing.length) {
			var item:FlxSprite = new FlxSprite();
			item.frames = Paths.getSparrowAtlas("menu/menu_buttons");
			item.animation.addByPrefix('idle', itemListing[i] + ' button', 24, false);
			item.animation.play("idle", true);
			item.updateHitbox();
			item.screenCenter(X);
			//item.x += i * 700;
			item.y = box.y + 45;
			item.ID = i;
			itemGroup.add(item);
		}
		left = new FlxSprite();
		left.frames = Paths.getSparrowAtlas("menu/menuArrows");
		left.animation.addByPrefix('idle', 'arrow left', 24, false);
		left.animation.addByPrefix('push', 'arrow push left', 24, false);
		left.animation.play("idle", true);
		left.x = box.x + 100;
		left.y = box.y + 100;
		add(left);

		right = new FlxSprite();
		right.frames = Paths.getSparrowAtlas("menu/menuArrows");
		right.animation.addByPrefix('idle', 'arrow right', 24, false);
		right.animation.addByPrefix('push', 'arrow push right', 24, false);
		right.animation.play("idle", true);
		right.x = box.x + box.width - 150;
		right.y = box.y + 100;
		add(right);

		logo = new FlxSprite(0, 0);
		logo.frames = Paths.getSparrowAtlas("menu/logoBump");
		logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logo.animation.play("bump", true);
		logo.updateHitbox();
		logo.screenCenter();
		logo.y -= 150;
		add(logo);

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPos = FlxG.sound.music.time;

		if(Controls.justPressed("UI_LEFT"))
			changeSelection(-1);
		if(Controls.justPressed("UI_RIGHT"))
			changeSelection(1);

		if(Controls.pressed("UI_LEFT"))
			left.animation.play("push");
		else
			left.animation.play("idle");

		if(Controls.pressed("UI_RIGHT"))
			right.animation.play("push");
		else
			right.animation.play("idle");

		if(Controls.justPressed("ACCEPT"))
		{
			itemGroup.forEach(function(spr:FlxSprite)
			{
				FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
				{
					switch(itemListing[curSelected]) {
						case 'Play':
							SideState.lvlId = 'street';
							Main.switchState(new SideState());
							FlxG.sound.music.volume = 0;
						case 'Credits':
							Main.switchState(new DebugState());
						case 'Settings':
							Main.switchState(new states.menu.OptionsState());
					}
				});
			});
		}
	}

	var lerpVal:Float = 0.2;

	public function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, itemListing.length - 1);

		if(change != 0) FlxG.sound.play(Paths.sound("beep"));

		for (item in itemGroup) {
			if(item.ID < curSelected)
			{
				item.x = -700;
			}
			if(item.ID > curSelected)
			{
				item.x = 1700;
			}
			if(item.ID == curSelected){
				item.x = (FlxG.width - item.width) / 2;
			}
		}
	}

	private override function beatHit() {
		logo.animation.play('bump');
	}
}
