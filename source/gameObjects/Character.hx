package gameObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import sys.io.File;

using StringTools;

// you might be asking yourself, why make a charactor json just for this! and i tell you to kill yourself
typedef CharInfo =
{
	var globalOffset:Null<Array<Float>>;
	var cameraOffset:Null<Array<Float>>;
	var offsets:Null<Array<Offsets>>;
}
typedef Offsets =
{
	var anim:String;
	var pos:Array<Float>;
} 

class Character extends FlxSprite
{
	public function new() {
		super();
	}

	public var curChar:String = "bf";
	public var isPlayer:Bool = false;

	public var holdTimer:Float = 0;
	public var holdLength:Float = 1;

	public var singAnims:Array<String> = [];
	public var missAnims:Array<String> = [];

	public var globalOffset:FlxPoint = new FlxPoint();
	public var cameraOffset:FlxPoint = new FlxPoint();
	private var scaleOffset:FlxPoint = new FlxPoint();

	var charData:CharInfo;

	public function reloadChar(curChar:String = "bf", isPlayer:Bool = false):Character
	{
		this.curChar = curChar;
		this.isPlayer = isPlayer;

		holdLength = 1;
		addSingPrefix(); // none

		var storedPos:Array<Float> = [x, y];
		globalOffset.set();
		cameraOffset.set();

		try
		{
			charData = haxe.Json.parse(File.getContent('assets/data/chars/' + curChar + '.json').trim());
		}
		catch (e)
		{
			trace('Uncaught Error: $e');

			charData = haxe.Json.parse('{
				"globalOffset": [0, 0],
				"cameraOffset": [0, 0]
			}');
		}

		// what
		switch(curChar)
		{
			case 'juke':
				frames = Paths.getSparrowAtlas("characters/juke/juke");

				animation.addByIndices('danceLeft', 'jukebox idle', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'jukebox idle', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft');
				addOffset('danceRight');

				playAnim('idle');

			case "minami":
				frames = Paths.getSparrowAtlas("characters/minami/Minami");

				animation.addByPrefix('idle', 			'Minami Idle', 		24, true);
				animation.addByPrefix('singLEFT', 		'Minami Left', 		24, false);
				animation.addByPrefix('singDOWN', 		'Minami Down', 		24, false);
				animation.addByPrefix('singUP', 		'Minami Up',   		24, false);
				animation.addByPrefix('singRIGHT', 		'Minami Right', 	24, false);
				animation.addByPrefix('singLEFTmiss',	'Minami MISSleft', 	24, false);
				animation.addByPrefix('singDOWNmiss',	'Minami MISSdown', 	24, false);
				animation.addByPrefix('singUPmiss',		'Minami MISSup', 	24, false);
				animation.addByPrefix('singRIGHTmiss',  'Minami MISSright', 24, false);

				addOffset('idle', 		   -35, 270);
				addOffset('singLEFT',  		84, 274);
				addOffset('singDOWN',	   -89, 130);
				addOffset('singUP', 		-7, 280);
				addOffset('singRIGHT', 	  -132, 204);
				addOffset('singLEFTmiss', 	77, 271);
				addOffset('singDOWNmiss', 	-89, 113);
				addOffset('singUPmiss', 	-7, 279);
				addOffset('singRIGHTmiss', -132, 200);

				playAnim('idle');

				flipX = true;
			
			case "clownami":
				frames = Paths.getSparrowAtlas("characters/clown/Clownami");

				animation.addByPrefix('idle', 		'Clownami Idle', 24, true);
				animation.addByPrefix('singLEFT', 	'Clownami Left', 24, false);
				animation.addByPrefix('singDOWN', 	'Clownami Down', 24, false);
				animation.addByPrefix('singUP', 	'Clownami Up', 24, false);
				animation.addByPrefix('singRIGHT', 	'Clownami Right', 24, false);
				animation.addByPrefix('bow', 		'Clownami Bow', 24, false);

				playAnim('idle');
			case "minami-3a":
				frames = Paths.getSparrowAtlas("characters/minami-3a/minami back");

				animation.addByPrefix('idle', 		'idle', 24, true);
				animation.addByPrefix('singLEFT', 	'left', 24, false);
				animation.addByPrefix('singDOWN', 	'down', 24, false);
				animation.addByPrefix('singUP', 	'up', 24, false);
				animation.addByPrefix('singRIGHT', 	'right', 24, false);

				flipX = true;
				playAnim('idle');

			case "minami-3c":
				frames = Paths.getSparrowAtlas("characters/minami-3c/minami back");

				animation.addByPrefix('idle', 		'idle', 24, true);
				animation.addByPrefix('singLEFT', 	'left', 24, false);
				animation.addByPrefix('singDOWN', 	'down', 24, false);
				animation.addByPrefix('singUP', 	'up', 24, false);
				animation.addByPrefix('singRIGHT', 	'right', 24, false);

				flipX = true;
				playAnim('idle');
			case "minami-3b":
				frames = Paths.getSparrowAtlas("characters/minami-3b/minami employee");

				animation.addByPrefix('idle', 		'idle', 24, true);
				animation.addByPrefix('singLEFT', 	'left', 24, false);
				animation.addByPrefix('singDOWN', 	'down', 24, false);
				animation.addByPrefix('singUP', 	'up', 24, false);
				animation.addByPrefix('singRIGHT', 	'right', 24, false);

				flipX = true;
				playAnim('idle');
			case "narrator":
				frames = Paths.getSparrowAtlas("characters/narrator/narrator");

				animation.addByPrefix('idle', 		'idle', 24, true);
				animation.addByPrefix('singLEFT', 	'left', 24, false);
				animation.addByPrefix('singDOWN', 	'down', 24, false);
				animation.addByPrefix('singUP', 	'up', 24, false);
				animation.addByPrefix('singRIGHT', 	'right', 24, false);

				playAnim('idle');
			case "narratorb":
				frames = Paths.getSparrowAtlas("characters/narrator/narrator");

				animation.addByPrefix('idle', 		'idle', 24, true);
				animation.addByPrefix('singLEFT', 	'left', 24, false);
				animation.addByPrefix('singDOWN', 	'down', 24, false);
				animation.addByPrefix('singUP', 	'up', 24, false);
				animation.addByPrefix('singRIGHT', 	'right', 24, false);

				playAnim('idle');

			case "boss":
				frames = Paths.getSparrowAtlas("characters/boss/boss");

				animation.addByPrefix('idle', 		'idle', 24, true);
				animation.addByPrefix('singLEFT', 	'left', 24, false);
				animation.addByPrefix('singDOWN', 	'down', 24, false);
				animation.addByPrefix('singUP', 	'up', 24, false);
				animation.addByPrefix('singRIGHT', 	'right', 24, false);

				playAnim('idle');
			case "bf":
				frames = Paths.getSparrowAtlas("characters/bf/BOYFRIEND");

				var leftright = ["LEFT", "RIGHT"];
				if(!isPlayer)
					leftright.reverse();

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('sing${leftright[0]}', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('sing${leftright[1]}', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('sing${leftright[0]}miss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('sing${leftright[1]}miss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				playAnim('idle');

				flipX = true;
			default:
				return reloadChar("bf", isPlayer);
		}

		if(charData.offsets != null) {
			for (anim in charData.offsets)
			{
				addOffset(anim.anim, anim.pos[0], anim.pos[1]);
			}
		}

		if(charData.globalOffset != null) 
			globalOffset.set(charData.globalOffset[0], charData.globalOffset[1]);
		if(charData.cameraOffset != null)
			cameraOffset.set(charData.cameraOffset[0], charData.cameraOffset[1]);

		updateHitbox();
		scaleOffset.set(offset.x, offset.y);

		if(isPlayer)
			flipX = !flipX;

		dance();

		setPosition(storedPos[0], storedPos[1]);

		return this;
	}

	public function addSingPrefix(prefix:String = "")
	{
		singAnims = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];

		for(i in 0...singAnims.length)
		{
			missAnims[i] = singAnims[i] + "miss";

			singAnims[i] += prefix;
			missAnims[i] += prefix;
		}
	}

	public var danced:Bool = false;

	public function dance(forced:Bool = false)
	{
		switch(curChar)
		{
			default:
				if(animation.exists("danceLeft"))
				{
					danced = !danced;
					if(danced)
						playAnim("danceLeft");
					else
						playAnim("danceRight");
				}
				else
					playAnim("idle");
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(holdTimer < holdLength)
		{
			holdTimer += elapsed;
		}
	}

	// animation handler
	public var animOffsets:Map<String, Array<Float>> = [];

	public function addOffset(animName:String, offX:Float = 0, offY:Float = 0):Void
		return animOffsets.set(animName, [offX, offY]);

	public function playAnim(animName:String, ?forced:Bool = false, ?reversed:Bool = false, ?frame:Int = 0)
	{
		animation.play(animName, forced, reversed, frame);

		if(animOffsets.exists(animName))
		{
			var daOffset = animOffsets.get(animName);
			offset.set(daOffset[0] * scale.x, daOffset[1] * scale.y);
		}
		else
			offset.set(0,0);

		// useful for pixel notes since their offsets are not 0, 0 by default
		offset.x += scaleOffset.x;
		offset.y += scaleOffset.y;
	}
}