package states.othershit;

import openfl.events.TextEvent;
import flixel.FlxG;
import flixel.FlxSprite;
import data.GameData.MusicBeatState;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import data.*;

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