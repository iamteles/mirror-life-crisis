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

class Prism extends MusicBeatState
{
    var voiceline:FlxSound;
    var ambience:FlxSound;
    var tex:FlxTypeText;
    var hasScrolled:Bool = false;
    var panelGroup:FlxTypedGroup<FlxSprite>;

    var lines:Array<String> = ['But you see, this is no ordinary mirror.', "Little does minami know, this mirror was placed here by me, in attempt to make her boring life a thousand times better.", "When Minami looked in the mirror, she saw a strange reflection. It was a much more upbeat and happy version of her.", "It was also a clown, but i think thats less important to the story.", 
    "Now Minami, this is a self-reflection exercise. Im really hoping we get this done the first time, i dont wanna see you and your boring life anymore.", "Now go talk to yourself. Maybe you can learn a thing or two."];
    var imgs:Array<String> = ['p1', 'p1', 'p2', 'p2', 'p3', 'p3'];
    var curLine:Int;
    override function create()
    {
        super.create();

        SaveData.progress(0);

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
        ambience.loadEmbedded(Paths.music('all'), true, false);
        FlxG.sound.list.add(ambience);
        ambience.volume = 0;
        ambience.play();
        ambience.fadeIn(0.32, 0, 0.5);

        voiceline = new FlxSound();
		FlxG.sound.list.add(voiceline);

        textbox(lines[curLine]);
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

    function textbox(text:String, ?delay:Float = 0.05)
    {
        tex.delay = delay;
        tex.resetText(text);
        tex.alpha = 1;

        voiceline.loadEmbedded(Paths.sound('lines/2' + Std.string(curLine)), false, false);
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