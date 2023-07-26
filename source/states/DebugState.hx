package states;

import data.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import data.SongData;

using StringTools;

class DebugState extends MusicBeatState
{
	var optionShit:Array<String> = ["intro", "clown"];
	static var curSelected:Int = 1;

	var optionGroup:FlxTypedGroup<FlxText>;

	override function create()
	{
		super.create();

		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Song Selection", null);

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(80,80,80));
		bg.screenCenter();
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
		}

		var warn = new FlxText(0, 0, 0, "WARNING\npress numbers to change progression");
		warn.setFormat(Main.gFont, 27, 0xFFFF0000);
		warn.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
		warn.alignment = CENTER;
		warn.updateHitbox();
		warn.y = FlxG.height - warn.height - 8;
		warn.screenCenter(X);
		add(warn);

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(Controls.justPressed("UI_UP"))
			changeSelection(-1);
		if(Controls.justPressed("UI_DOWN"))
			changeSelection(1);

		if(FlxG.keys.justPressed.O)
		{
			Main.switchState(new states.menu.OptionsState());
		}

		if(FlxG.keys.justPressed.ZERO)
		{
			SaveData.progress(0);
			FlxG.sound.play(Paths.sound("beep"));
		}

		if(FlxG.keys.justPressed.ONE)
		{
			SaveData.progress(1);
			FlxG.sound.play(Paths.sound("beep"));
		}
		if(FlxG.keys.justPressed.TWO)
		{
			SaveData.progress(2);
			FlxG.sound.play(Paths.sound("beep"));
		}
		if(FlxG.keys.justPressed.THREE)
		{
			SaveData.progress(3);
			FlxG.sound.play(Paths.sound("beep"));
		}
		if(FlxG.keys.justPressed.FOUR)
		{
			SaveData.progress(4);
			FlxG.sound.play(Paths.sound("beep"));
		}
		if(FlxG.keys.justPressed.FIVE)
		{
			SaveData.progress(5);
			FlxG.sound.play(Paths.sound("beep"));
		}

		if(Controls.justPressed("BACK")) {
			Main.switchState(new MenuState());
		}

		if(Controls.justPressed("ACCEPT"))
		{
			if(optionShit[curSelected] == 'intro') {
				SideState.lvlId = 'street';
				Main.switchState(new SideState());
			}
			else if (optionShit[curSelected] == 'clown') {
				SideState.lvlId = 'village';
				Main.switchState(new SideState());
			}
			else {
				PlayState.SONG = SongData.loadFromJson(optionShit[curSelected]);
				PlayState.diff = 'NORMAL';
				Main.switchState(new PlayState());
			}
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
	}
}
