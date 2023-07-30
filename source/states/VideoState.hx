package states;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import hxcodec.flixel.FlxVideoSprite;
import data.GameData.MusicBeatState;

class VideoState extends MusicBeatState
{
    var video:FlxVideoSprite;
    var skip:FlxText;
    var skipBool:Bool = false;
    var string:String = "video";
    var target:FlxState;
    public function new(?string:String = "video", ?target:FlxState) {
        this.string = string;
        this.target = target;

        super();
    }
	override public function create():Void
	{
		video = new FlxVideoSprite();
	    video.bitmap.onEndReached.add(end);
        add(video);
		video.play(Paths.video(string));
        //video.updateHitbox();
        //video.screenCenter();

		skip = new FlxText(0, 0, 0, "Press SPACE again to skip.");
		skip.setFormat(Main.gFont, 27, 0xFFFFFFFF);
		skip.setBorderStyle(OUTLINE, 0xFF000000, 1);
		skip.alignment = CENTER;
		skip.updateHitbox();
		skip.y = FlxG.height - skip.height - 8;
        skip.alpha = 0;
		skip.screenCenter(X);
		add(skip);

		super.create();
	}

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if(FlxG.keys.justPressed.SPACE && !skipBool) {
            skipBool = true;
            skip.alpha = 1;
            FlxTween.tween(skip, {alpha: 0}, 1.6, {
                onComplete: function(twn:FlxTween)
                {
                    skipBool = false;
                }
            });
        }
        else if(FlxG.keys.justPressed.SPACE) {
            Main.switchState(target);
        }
    }
    function end() {
       // video.dispose();
        Main.switchState(target);
    }
}