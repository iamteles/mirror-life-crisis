package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import data.GameData.MusicBeatState;
import states.SplashState;

class Init extends MusicBeatState
{
	override function create()
	{
		super.create();
		SaveData.init();
		SaveData.update();
		FlxG.fixedTimestep = false;
		FlxG.mouse.useSystemCursor = true;
		//FlxG.mouse.visible = false;
		FlxGraphic.defaultPersist = true;
		
		Main.switchState(new FlixelSplash());
	}
}