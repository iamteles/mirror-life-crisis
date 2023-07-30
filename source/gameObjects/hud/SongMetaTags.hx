package gameObjects.hud;

#if sys
import sys.io.File;
#end

import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;
using flixel.util.FlxSpriteUtil;

typedef SongInfo =
{
	var song:Null<String>;
    var composer:Null<String>;
}

class SongMetaTags extends FlxSpriteGroup
{
    var meta:SongInfo;
    var size:Float = 0;
    var fontSize:Int = 37;

    public function new(_x:Float, _y:Float, _song:String) {

        super(_x, _y);

        var text = new FlxText(0, 0, 0, "", fontSize);
        text.setFormat("cocogoose.ttf", fontSize, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.borderSize = 2.4;

        meta = haxe.Json.parse(File.getContent('assets/songs/' + _song + '/meta.json').trim());
        text.text = '';
        text.text += meta.song;
        text.text += '\n' + meta.composer;

        size = text.fieldWidth;
        
        var bg = new FlxSprite(fontSize/-2, fontSize/-2).makeGraphic(Math.floor(size + fontSize), Math.floor(text.height + fontSize), FlxColor.BLACK);
        bg.alpha = 0.67;

        text.text += "\n";

        add(bg);
        add(text);

        x -= size;
        visible = false;
        
    }



    public function start(){

        visible = true;

        FlxTween.tween(this, {x: x + size + (fontSize/2)}, 1, {ease: FlxEase.quintOut, onComplete: function(twn:FlxTween){
            FlxTween.tween(this, {x: x - size}, 1, {ease: FlxEase.quintIn, startDelay: 2, onComplete: function(twn:FlxTween){ this.destroy(); }});
        }});

    }
}