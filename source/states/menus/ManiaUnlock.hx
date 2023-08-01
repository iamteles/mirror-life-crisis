package states.menus;

import flixel.FlxSprite;
import data.GameData.MusicBeatState;

using StringTools;

class ManiaUnlock extends MusicBeatState
{
    var bg:FlxSprite;
    override function create()
    {
        super.create();
        bg = new FlxSprite(0, 0).loadGraphic(Paths.image("mania"));
		add(bg);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

		if(Controls.justPressed("BACK") || Controls.justPressed("ACCEPT")) {
			Main.switchState(new Credits());
		}

    }
}