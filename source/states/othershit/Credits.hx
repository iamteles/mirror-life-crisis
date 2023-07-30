package states.othershit;

import openfl.events.TextEvent;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxSprite;
import data.GameData.MusicBeatState;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import data.*;
import data.GameData;

using StringTools;

class Credits extends MusicBeatState
{
    var bg:FlxBackdrop;
    static var curSelected:Int = 0;
    var people:Array<Array<Dynamic>> = [
        ['Coco Puffs', 'coco', 'Director, Artist, Musician, Narrator. 121', 'https://twitter.com/file_corruption', 0xFFFF756E],
        ['teles', 'teles', 'Co-Director, Musician, Coder. 413', 'https://ivteles.carrd.co', 0xffff813c],
        ['CharaWhy', 'chara', 'Musician, SFX. 167', 'https://www.youtube.com/@CharaWhy/', 0xff8551f5],
        ['DiamondDiglett', 'diamond', 'Charter (NORMAL)', 'https://twitter.com/diamondiglett42', 0xff5be260],
        ['Parallax', 'parallax', 'Charter (MANIA)', 'https://www.youtube.com/@parallax6084/', 0xff006dff],
        ['YaBoiJustin', 'justin', 'Grilled Cheese fan. 312', 'https://twitter.com/YaBoiJustinGG2', 0xff43d65d],
        ['Special Thanks', 'nan', "Special Thanks", 'st', 0xffffffff]
    ];
    var textGroup:FlxTypedGroup<FlxText>;
    var iconGroup:FlxTypedGroup<FlxSprite>;
    var pleaseSpinLittleVersionsOfMyFriends:Bool = true;
    var special:FlxSprite;
    var warn:FlxText;
    override function create()
    {
        super.create();

        updateBeat();
        curStep = _curStep;
        curBeat = Math.floor(curStep / 4);
        //stepHit();

		bg = new FlxBackdrop(Paths.image("menu/grid"), XY, 0, 0);
        bg.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
       	bg.screenCenter();
        //bg.alpha = 0.4;
        add(bg);

        textGroup = new FlxTypedGroup<FlxText>();
		add(textGroup);

        iconGroup = new FlxTypedGroup<FlxSprite>();
		add(iconGroup);

        for(i in 0...people.length)
        {
            var item = new FlxText(0, 0, 0, people[i][0]);
            item.setFormat(Main.gFont, 40, 0xFFFFFFFF);
            item.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
            item.ID = i;
            item.alignment = CENTER;
            item.y = 150 + ((item.height + 10) * i);
            item.updateHitbox();
            item.screenCenter(X);
            textGroup.add(item);

            var icon = new FlxSprite(0,0).loadGraphic(Paths.image("credits/" + people[i][1]));
            icon.updateHitbox();
            icon.screenCenter(X);
            icon.x += (250 * (FlxMath.isEven(i) ? -1 : 1));
            icon.y = item.y - (icon.height/2) + 10;
            iconGroup.add(icon);
        }

        warn = new FlxText(0, 0, 0, "");
		warn.setFormat(Main.gFont, 35, 0xFFFFFFFF);
		warn.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		warn.alignment = CENTER;
		warn.updateHitbox();
		warn.y = FlxG.height - warn.height - 8;
		warn.screenCenter(X);
		add(warn);

        special = new FlxSprite(0, 0).loadGraphic(Paths.image("credits/image"));
        special.alpha = 0;
		add(special);

        changeSelection();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        bg.color = Utils.smoothColorChange(bg.color, people[curSelected][4], 0.2);
   
		if(Controls.justPressed("BACK")) {
            if(special.alpha == 1)
                FlxTween.tween(special, {alpha: 0}, 0.1);
            else
			    Main.switchState(new MenuState());
		}

        if(Controls.justPressed("ACCEPT") && special.alpha == 0) {
            if(people[curSelected][3] == "st") {
                FlxTween.tween(special, {alpha: 1}, 0.1);
            }
            else
			    Utils.browserLoad(people[curSelected][3]);
		}

		if (FlxG.sound.music != null)
			Conductor.songPos = FlxG.sound.music.time;

        if(Controls.justPressed("UI_UP") && special.alpha == 0)
			changeSelection(-1);
		if(Controls.justPressed("UI_DOWN") && special.alpha == 0)
			changeSelection(1);

    }

    public function changeSelection(change:Int = 0)
    {
        curSelected += change;
        curSelected = FlxMath.wrap(curSelected, 0, people.length - 1);

        warn.text = people[curSelected][2];
        warn.screenCenter(X);
        

        if(change != 0) FlxG.sound.play(Paths.sound("beep"));

        for (item in textGroup) {
            if(curSelected == item.ID) {
                item.alpha = 1;
            }
            else {
                item.alpha = 0.4;
            }
        }
    }

    private override function beatHit() {
        super.beatHit();
        trace("BEAT" + curBeat);
        if(pleaseSpinLittleVersionsOfMyFriends) {
            for (icon in iconGroup) {
                if(curBeat % 2 == 0 || curBeat == 0){
                    icon.angle = -5;
                    icon.updateHitbox();
                }
                else {
                    icon.angle = 5;
                    icon.updateHitbox();
                }
            }
        }
	}
}