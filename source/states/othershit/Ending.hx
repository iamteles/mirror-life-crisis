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
import flixel.group.FlxGroup.FlxTypedGroup;
import data.*;

using StringTools;

class Ending extends MusicBeatState
{
    var voiceline:FlxSound;
    var ambience:FlxSound;
    var tex:FlxTypeText;
    var hasScrolled:Bool = false;
    var panelGroup:FlxTypedGroup<FlxSprite>;

    var lines:Array<String> = ["Congratulations! You beat the narrator and have gained free will!", 
                                "Hurrah! Good for you!", 
                                "Minami left the clown world to get back to her depressing... horrible...",
                                "horrible life.. I'm done I can't do this anymore. *sigh*"];
    var imgs:Array<String> = ['pe', 'pe', 'pe', 'pe'];
    var curLine:Int;
    var waitIsOver:Bool;
    override function create()
    {
        super.create();

        SaveData.progress(5);

        panelGroup = new FlxTypedGroup<FlxSprite>();
		add(panelGroup);

        for (i in 0...imgs.length) {
            var panel = new FlxSprite(0, 0).loadGraphic(Paths.image("panels/" + imgs[i]));
            panel.ID = i;
            panel.alpha = 0;
            panelGroup.add(panel);
        }


		tex = new FlxTypeText(0, 530, 800, 'placeholder', true);
		tex.alpha = 0;
		tex.setFormat(Main.gFont, 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tex.screenCenter(X);
		tex.borderSize = 2;
		tex.skipKeys = [FlxKey.SPACE];
		tex.delay = 0.05;
		add(tex);

        ambience = new FlxSound();
        ambience.loadEmbedded(Paths.music('win'), true, false);
        FlxG.sound.list.add(ambience);
        ambience.volume = 0;
        ambience.play();
        ambience.fadeIn(0.32, 0, 0.5);

        voiceline = new FlxSound();
		FlxG.sound.list.add(voiceline);

        curLine = 1;

        var countTimer = new FlxTimer().start(4, function(tmr:FlxTimer)
        {
            waitIsOver = true;
            curLine = 0;
            textbox(lines[curLine]);
        });

    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        for (panel in panelGroup) {
            if(panel.ID == curLine - 1) {
                panel.alpha = 1;
            }
            else
                panel.alpha = 0;
        }

        if(waitIsOver) {
            if(FlxG.keys.justPressed.SPACE && hasScrolled) {
                if(voiceline.playing) voiceline.stop();
                FlxG.sound.play(Paths.sound('click'));
                FlxTween.tween(tex, {alpha: 0}, 0.4, {
                    ease: FlxEase.sineInOut,
                    onComplete: function(twn:FlxTween)
                    {
                        hasScrolled = false;

                        if(curLine == lines.length) {
							PlayState.SONG = SongData.loadFromJson("prismatic");
							PlayState.isStory = true;
							PlayState.diff = 'NORMAL';
							Main.switchState(new PlayState());
                        }

                        else {
                            textbox(lines[curLine]);
                        }

                    }
                });
            }
        }
    }

    function textbox(text:String, ?delay:Float = 0.05)
    {
        tex.delay = delay;
        tex.resetText(text);
        tex.alpha = 1;

        voiceline.loadEmbedded(Paths.sound('lines/5' + Std.string(curLine)), false, false);
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