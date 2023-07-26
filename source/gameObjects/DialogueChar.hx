package gameObjects;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import sys.io.File;

using StringTools;

typedef CharacterData =
{
	var name:String;
	var frames:Array<CharacterFrame>;
	var pos:Array<Int>;
	var scale:Null<Float>;
}

typedef CharacterFrame =
{
	var expression:Null<String>; // for the expression name
	var offset:Null<Array<Float>>; // position of the frame
	var flipped:Null<Array<Bool>>; // whether frame is flipped, on the X or Y axis
	var semiscale:Null<Float>; // sizer for the specific frame
}

class DialogueChar extends FlxTypedGroup<FlxBasic>
{
	public var charData:CharacterData;

	public static var name:String;
	var frameList:Array<String>;
	public var frameMap:Map<String, FlxSprite> = new Map<String, FlxSprite>();

	public static var lastFrame:String = 'nan';
	public var char:String;
	var flipped:Bool;

	public function new(char:String, flipped:Bool)
	{
		super();
		this.char = char;
		this.flipped = flipped;
		lastFrame = "nan";
	}

	public function loadJson()
	{
		trace('Attempt load.');
		try
		{
			charData = haxe.Json.parse(File.getContent('assets/data/logchars/' + char + '.json').trim());
		}
		catch (e)
		{
			trace('Uncaught Error: $e');

			/*
			lvlData = haxe.Json.parse('{
			    "zoom": 1,
			    "spawnPoint": [400, 0]
			}');
			*/
		}

		trace('Finish load.');

		name = charData.name;

		if (charData.frames != null)
		{
			for (frame in charData.frames)
			{
				var newSpr:FlxSprite = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
				//newSpr.screenCenter();
				newSpr.x += charData.pos[0] + frame.offset[0];
				newSpr.y += charData.pos[1] + frame.offset[1];
				newSpr.loadGraphic(Paths.image('hud/dialog/chars/' + charData.name.toLowerCase() + '/' + frame.expression));

				if (frame.semiscale != null && charData.scale != null)
				{
					newSpr.setGraphicSize(Std.int(newSpr.width * (charData.scale * frame.semiscale)));
				}

				if (frame.flipped != null)
				{
					newSpr.flipX = frame.flipped[0];
					newSpr.flipY = frame.flipped[1];
				}

				if(flipped) newSpr.flipX = !newSpr.flipX;

				newSpr.alpha = 0;

				frameMap.set(frame.expression, newSpr);
				add(newSpr);
			}
		}
	}

	public function enterFrame(name:String, ?fade:Bool) {
		if(lastFrame != 'nan') frameMap.get(lastFrame).alpha = 0;
		frameMap.get(name).alpha = 1;

		lastFrame = name;
	}

	public function tweenAlpha(target:Float, duration:Float) {
		FlxTween.tween(frameMap.get(lastFrame), {alpha: target}, duration);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
