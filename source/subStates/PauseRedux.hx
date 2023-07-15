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
import data.Conductor;
import data.GameData.MusicBeatSubState;
import gameObjects.menu.AlphabetMenu;
import states.*;

class PauseRedux extends MusicBeatSubState
{
	var optionShit:Array<String> = ["Resume", "Exit to Menu"];

	var curSelected:Int = 0;

	var optionsGrp:FlxTypedGroup<AlphabetMenu>;

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

		changeSelection();
	}

	override function close()
	{
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
					SideState.paused = false;
					close();

				case "exit to menu":
					Main.switchState(new MenuState());
			}
		}

		// works the same as resume
		if(Controls.justPressed("BACK"))
		{
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