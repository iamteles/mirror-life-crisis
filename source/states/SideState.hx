package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.addons.effects.FlxTrail;
import flixel.addons.text.FlxTypeText;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tile.FlxTileblock;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.side.Level;
import gameObjects.side.Player;
import data.GameData.MusicBeatState;
import data.SongData;

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

	var currentStyle:FlxCameraFollowStyle = FlxCameraFollowStyle.PLATFORMER;

	var spawn:Array<Int> = [400, 0];

	function resetVariables()
	{
		inTextBox = false;
		hasScrolled = false;
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
		spawn = lvlConstruct.spawnPoint;
		add(lvlConstruct);
		add(lvlConstruct.hbxLayer);
		add(lvlConstruct.warpLayer);

		FlxG.camera.zoom = lvlConstruct.zoom;

		player = new Player(spawn[0], spawn[1]);
		add(player);
		add(lvlConstruct.foregroundLayer);

		subtitle = new FlxTypeText(0, 600, 1000, 'placeholder', true);
		subtitle.alpha = 0;
		subtitle.setFormat(Main.gFont, 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		subtitle.screenCenter(X);
		subtitle.borderSize = 1.5;
		subtitle.cameras = [camHUD];
		subtitle.skipKeys = [FlxKey.SPACE];
		subtitle.delay = 0.04;
		add(subtitle);

		camFollow.setPosition(player.getMidpoint().x + lvlConstruct.camPos[0], player.getMidpoint().y + lvlConstruct.camPos[1]);
		FlxG.camera.follow(camFollow, currentStyle, 1);
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.camera.setScrollBoundsRect(Level.boundaries[0], Level.boundaries[1], Level.boundaries[2], Level.boundaries[3], true);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.collide(lvlConstruct.hbxLayer, player);
		FlxG.overlap(lvlConstruct.clickableLayer, player);
		camFollow.setPosition(player.getMidpoint().x + lvlConstruct.camPos[0], player.getMidpoint().y + lvlConstruct.camPos[1]);

		if(FlxG.keys.justPressed.SPACE) {
			if(inTextBox && hasScrolled) {
				FlxTween.tween(subtitle, {alpha: 0}, 0.4, {
					ease: FlxEase.sineInOut,
					onComplete: function(twn:FlxTween)
					{
						player.stopped = false;
						inTextBox = false;
						hasScrolled = false;
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
						warp(obj[1]);
				}
			}
		}

		if (FlxG.keys.justPressed.BACKSPACE)
		{
			Main.switchState(new MenuState());
		}
		if (FlxG.keys.justPressed.R)
			FlxG.resetState();
	}

	public static function textbox(text:String)
	{
		subtitle.resetText(text);
		subtitle.alpha = 1;
		inTextBox = true;
		player.stopped = true;
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
				switch (obj[1])
				{
					case 'test':
						FlxG.resetState();
					case 'test2':
						SideState.textbox('pull worked!');
					case 'ONE':
						PlayState.SONG = SongData.loadFromJson("ugh");
						Main.switchState(new PlayState());
				}
			}
		}
	}

	function warp(?location:String = 'street') {
		lvlId = location;
		Main.switchState(new SideState());
	}
}
