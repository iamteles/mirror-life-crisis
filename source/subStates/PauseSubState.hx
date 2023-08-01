package subStates;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import data.Conductor;
import data.GameData.MusicBeatSubState;
import gameObjects.menu.AlphabetMenu;
import states.*;
import states.menus.*;

class PauseSubState extends MusicBeatSubState
{
	var optionShit:Array<String> = ["Resume", "Restart Song", "Exit to Options", "Exit to Menu"];

	var curSelected:Int = 0;

	var optionsGrp:FlxTypedGroup<AlphabetMenu>;

	var pauseSong:FlxSound;

	public function new()
	{
		super();
		var banana = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(banana);

		banana.alpha = 0;
		FlxTween.tween(banana, {alpha: 0.4}, 0.1);

		optionsGrp = new FlxTypedGroup<AlphabetMenu>();
		add(optionsGrp);

		for(i in 0...optionShit.length)
		{
			var newItem = new AlphabetMenu(0, 0, optionShit[i], true);
			newItem.ID = i;
			newItem.focusY = i - curSelected;
			newItem.updatePos();
			optionsGrp.add(newItem);

			newItem.x = 0;
		}

		pauseSong = new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song.toLowerCase()), true, false);
		if(Conductor.songPos > 0)
		{
			pauseSong.play(Conductor.songPos);
			pauseSong.pitch = 0.9;
			pauseSong.volume = 0;
			FlxTween.tween(pauseSong, {volume: 0.45}, 3, {startDelay: 1});
		}
		FlxG.sound.list.add(pauseSong);

		changeSelection();
	}

	override function close()
	{
		pauseSong.stop();
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

		if(Controls.justPressed("UI_UP"))
			changeSelection(-1);
		if(Controls.justPressed("UI_DOWN"))
			changeSelection(1);

		if(Controls.justPressed("ACCEPT"))
		{
			switch(optionShit[curSelected].toLowerCase())
			{
				case "resume":
					PlayState.paused = false;
					close();

				case "restart song":
					Main.switchState();

				case "exit to options":
					Main.switchState(new OptionsState(new PlayState()));

				case "exit to menu":
					if(SaveData.progression <= 2) {
						SideState.lvlId = 'alley';
						Main.switchState(new SideState());
					}
					else {
						SideState.lvlId = 'park';
						Main.switchState(new SideState());
					}
			}
		}

		// works the same as resume
		if(Controls.justPressed("BACK"))
		{
			PlayState.paused = false;
			close();
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.length - 1);

		FlxG.sound.play(Paths.sound("beep"));

		for(item in optionsGrp)
		{
			item.focusY = item.ID - curSelected;

			item.alpha = 0.4;
			if(item.ID == curSelected)
				item.alpha = 1;
		}
	}
}