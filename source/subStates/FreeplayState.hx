package subStates;

import data.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import data.GameData.MusicBeatSubState;
import data.SongData;
import data.Highscore;
import data.Highscore.ScoreData;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import states.*;

using StringTools;

class FreeplayState extends MusicBeatSubState
{
	var optionShit:Array<String> = ["prismatic", "echo", 'introspection'];
	static var curSelected:Int = 0;
	var bg:FlxBackdrop;
	var curDiff = 0;
	var possibleDiffs = ["NORMAL", "MANIA"];

	var optionGroup:FlxTypedGroup<FlxText>;
	var scoreCounter:ScoreCounter;

	override function create()
	{
		super.create();

		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Song Selection", null);

		bg = new FlxBackdrop(Paths.image("menu/grid"), XY, 0, 0);
        bg.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
       	bg.screenCenter();
        bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.4}, 0.1);
        add(bg);

		optionGroup = new FlxTypedGroup<FlxText>();
		add(optionGroup);

		for(i in 0...optionShit.length)
		{
			var item = new FlxText(0, 0, 0, optionShit[i].toUpperCase());
			item.setFormat(Main.gFont, 60, 0xFFFFFFFF);
			item.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
			item.ID = i;
			item.alignment = CENTER;
			item.y = 50 + ((item.height + 100) * i);
			item.updateHitbox();
			item.screenCenter(X);
			optionGroup.add(item);
			item.alpha = 0;
			FlxTween.tween(item, {alpha: 1}, 0.1);
		}

		scoreCounter = new ScoreCounter();
		add(scoreCounter);

		scoreCounter.diff = possibleDiffs[curDiff];
		changeSelection();
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

		if(Controls.justPressed("UI_UP"))
			changeSelection(-1);
		if(Controls.justPressed("UI_DOWN"))
			changeSelection(1);

		if(Controls.justPressed("UI_LEFT"))
			changeDiff(-1);
		if(Controls.justPressed("UI_RIGHT"))
			changeDiff(1);

		if(Controls.justPressed("BACK")) {
			close();
		}

		if(Controls.justPressed("ACCEPT"))
		{
			PlayState.SONG = SongData.loadFromJson(optionShit[curSelected], possibleDiffs[curDiff]);
			PlayState.diff = possibleDiffs[curDiff];
			Main.switchState(new PlayState());
		}
	}

	public function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.length - 1);

		FlxG.sound.play(Paths.sound("beep"));

		for (item in optionGroup) {
			var daText:String = optionShit[item.ID].toUpperCase().replace("-", " ");

			if(curSelected == item.ID) {
				item.text = '> ' + daText + ' <';
			}
			else {
				item.text = daText;
			}
			item.screenCenter(X);
		}

		scoreCounter.updateDisplay(optionShit[curSelected] + possibleDiffs[curDiff]);
	}

	public function changeDiff(change:Int = 0)
	{
		curDiff += change;
		curDiff = FlxMath.wrap(curDiff, 0, possibleDiffs.length - 1);
		scoreCounter.diff = possibleDiffs[curDiff];
		scoreCounter.updateDisplay(optionShit[curSelected] + possibleDiffs[curDiff]);
	}

	override function close()
	{
		super.close();
		SideState.paused = false;
	}
}

class ScoreCounter extends FlxGroup
{
	public var bg:FlxSprite;

	public var text:FlxText;
	public var text2:FlxText;

	public var realValues:ScoreData;
	public var lerpValues:ScoreData;

	public var diff:String = 'NORMAL';

	public function new()
	{
		super();
		bg = new FlxSprite().makeGraphic(32, 43, 0xFF000000);
		bg.alpha = 0.4;
		add(bg);

		text = new FlxText(0, 0, 0, "");
		text.setFormat(Main.gFont, 28, 0xFFFFFFFF, LEFT);
		text.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		add(text);

		text2 = new FlxText(0, 32, 0, "");
		text2.setFormat(Main.gFont, 28, 0xFFFFFFFF, CENTER);
		text2.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		add(text2);


		realValues = {score: 0, accuracy: 0, misses: 0};
		lerpValues = {score: 0, accuracy: 0, misses: 0};
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		text.text = "";

		text.text +=   "HIGHSCORE: " + Math.floor(lerpValues.score);
		text.text += "\nACCURACY:  " +(Math.floor(lerpValues.accuracy * 100) / 100) + "%";
		text.text += "\nBREAKS:    " + Math.floor(lerpValues.misses);

		text2.text = '< ' + diff + ' >';

		lerpValues.score 	= FlxMath.lerp(lerpValues.score, 	realValues.score, 	 elapsed * 8);
		lerpValues.accuracy = FlxMath.lerp(lerpValues.accuracy, realValues.accuracy, elapsed * 8);
		lerpValues.misses 	= FlxMath.lerp(lerpValues.misses, 	realValues.misses, 	 elapsed * 8);

		if(Math.abs(lerpValues.score - realValues.score) <= 10)
			lerpValues.score = realValues.score;
		if(Math.abs(lerpValues.accuracy - realValues.accuracy) <= 0.4)
			lerpValues.accuracy = realValues.accuracy;
		if(Math.abs(lerpValues.misses - realValues.misses) <= 0.4)
			lerpValues.misses = realValues.misses;

		bg.scale.x = ((text.width + 8) / 32);
		bg.scale.y = ((text.height+ 8) / 32);
		bg.updateHitbox();

		bg.y = 0;
		bg.x = FlxG.width - bg.width;

		text.x = FlxG.width - text.width - 4;
		text2.x = bg.x + ((bg.width / 2) - (text2.width / 2));
		text.y = 4;
		text2.y = 4 + text.height;
	}

	public function updateDisplay(song:String)
	{
		realValues = Highscore.getScore(song);
	}
}
