package states.menus;

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

using StringTools;

class Intro extends MusicBeatState
{
    var voiceline:FlxSound;
    var ambience:FlxSound;
    var bg:FlxSprite;
    var tex:FlxTypeText;
    var hasScrolled:Bool = false;

    var lines:Array<String> = ['This is Minami.\n(Press SPACE to continue)', "She's quite the unhappy individual, you see.", "Everyday, she goes to work and returns, no time for entertainment or fun.", "I think its time for a change."];
    var curLine:Int;
    override function create()
    {
        super.create();

        SaveData.progress(0);

        bg = new FlxSprite(0, 0).loadGraphic(Paths.image("panels/intro"));
		add(bg);

		tex = new FlxTypeText(0, 530, 800, 'placeholder', true);
		tex.alpha = 0;
		tex.setFormat(Main.gFont, 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tex.screenCenter(X);
		tex.borderSize = 2;
		tex.skipKeys = [FlxKey.SPACE];
		tex.delay = 0.05;
		add(tex);

        voiceline = new FlxSound();
		FlxG.sound.list.add(voiceline);

        textbox(lines[curLine]);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.SPACE && hasScrolled) {
                if(voiceline.playing) voiceline.stop();
                FlxG.sound.play(Paths.sound('click'));
                FlxTween.tween(tex, {alpha: 0}, 0.4, {
                    ease: FlxEase.sineInOut,
                    onComplete: function(twn:FlxTween)
                    {
                        hasScrolled = false;

                        if(curLine > 3) {
                            SideState.lvlId = 'street';
							Main.switchState(new SideState());
                        }

                        else {
                            textbox(lines[curLine]);
                        }

                    }
                });
        }
    }

    function textbox(text:String, ?delay:Float = 0.05)
    {
        tex.delay = delay;
        tex.resetText(text);
        tex.alpha = 1;

        voiceline.loadEmbedded(Paths.sound('lines/0' + Std.string(curLine)), false, false);
        voiceline.play();

        curLine ++;

        tex.start(false, function()
        {
            new FlxTimer().start(0.1, function(tmr:FlxTimer)
            {
                hasScrolled = true;
            });
        });
    }
}