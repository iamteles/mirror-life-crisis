package gameObjects.side;

import lime.graphics.opengl.GLTransformFeedback;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import states.SideState;
import sys.io.File;

using StringTools;

typedef LevelInfo =
{
	var objects:Array<LevelObject>;
	var foreground:Array<LevelObject>;
	var warp:Array<Warp>;
	var hitboxes:Array<Hitbox>;

	var zoom:Float;
	var spawnPoint:Array<Int>;
	var retPoint:Array<Int>;
	var boundaries:Null<Array<Int>>;
	var camPos:Null<Array<Int>>;
	var music:Null<String>;
}

typedef LevelObject =
{
	var objName:Null<String>; // for the var/object name
	var path:Null<String>; // image path
	var animations:Null<Array<Animation>>;
	var position:Null<Array<Float>>; // position of the object
	var flipped:Null<Array<Bool>>; // whether object is flipped, on the X or Y axis
	var scale:Null<Float>; // sizer for object
	var alpha:Null<Float>; // alpha
	var clickableCall:Null<String>; // what will happen when you click said object. if null will not be clickable
	var scrollFactor:Null<Array<Int>>; // self explanatory i hope
}

typedef Animation =
{
	var name:String;
	var prefix:String;
	var framerate:Int;
	var looped:Bool;
}

typedef Hitbox =
{
	var hbxName:Null<String>; // for the hitbox name
	var position:Null<Array<Float>>; // INITIAL position of the hitbox
	var size:Null<Array<Int>>; // size of the hitbox square
	var hbxImmovable:Null<Bool>; // if hitbox can be moved or not
}

typedef Warp =
{
	var wrpName:Null<String>; // for the warp name
	var position:Null<Array<Float>>; // INITIAL position of the warp
	var size:Null<Array<Int>>; // size of the warp square
	var location:Null<String>; // where to warp to
	var ret:Null<Bool>;
}

class Level extends FlxTypedGroup<FlxBasic>
{
	public var lvlData:LevelInfo;

	var lvlId:String;

	public var zoom:Float;
	public var spawnPoint:Array<Int>;
	public var retPoint:Array<Int>;
	
	public var objectMap:Map<String, FlxSprite> = new Map<String, FlxSprite>();
	public var clickableMap:Map<String, Array<Dynamic>> = new Map<String, Array<Dynamic>>();
	public var hbxMap:Map<String, FlxSprite> = new Map<String, FlxSprite>();
	public var warpMap:Map<String, Array<Dynamic>> = new Map<String, Array<Dynamic>>();
	public var foregroundLayer:FlxTypedGroup<FlxBasic>;
	public var hbxLayer:FlxTypedGroup<FlxBasic>;
	public var warpLayer:FlxTypedGroup<FlxBasic>;
	public var clickableLayer:FlxTypedGroup<FlxBasic>;

	public static var boundaries:Array<Int>;
	public var camPos:Array<Int>;

	public function new()
	{
		super();
		lvlId = SideState.lvlId;

		boundaries = [0, 0, 30000, 3000];
		camPos = [0, 0];

		hbxLayer = new FlxTypedGroup<FlxBasic>();
		warpLayer = new FlxTypedGroup<FlxBasic>();
		foregroundLayer = new FlxTypedGroup<FlxBasic>();
	}

	public function loadJson()
	{
		trace('Attempt to load' + 'assets/data/lvl/' + lvlId + '.json');
		try
		{
			
			lvlData = haxe.Json.parse(File.getContent('assets/data/lvl/' + lvlId + '.json').trim());
		}
		catch (e)
		{
			trace('Uncaught Error: $e');

			lvlData = haxe.Json.parse('{
			    "zoom": 1,
			    "spawnPoint": [400, 0]
			}');
		}

		trace('Finish load.');

		zoom = lvlData.zoom;
		spawnPoint = lvlData.spawnPoint;
		retPoint = lvlData.retPoint;
		if(lvlData.boundaries != null)
			boundaries = lvlData.boundaries;
		if(lvlData.camPos != null)
			camPos = lvlData.camPos;

		if (lvlData.objects != null)
		{
			for (object in lvlData.objects)
			{
				var newSpr:FlxSprite = new FlxSprite(object.position[0], object.position[1]);

				if(object.animations != null) {
					newSpr.frames = Paths.getSparrowAtlas(object.path);
					for (anim in object.animations) {
						newSpr.animation.addByPrefix(anim.name, anim.prefix, anim.framerate, anim.looped);
					}
					newSpr.animation.play('idle');
				}
				else {
					newSpr.loadGraphic(Paths.image(object.path));
				}

				if (object.scale != null)
				{
					newSpr.setGraphicSize(Std.int(newSpr.width * object.scale));
					newSpr.updateHitbox();
					trace('Scaled.');
				}

				if (object.alpha != null)
					newSpr.alpha = object.alpha;

				if(object.scrollFactor != null) {
					newSpr.scrollFactor.set(object.scrollFactor[0], object.scrollFactor[1]);
				}

				if (object.flipped != null)
				{
					newSpr.flipX = object.flipped[0];
					newSpr.flipY = object.flipped[1];
				}

				if (object.clickableCall != null)
					clickableMap.set(object.objName, [newSpr, object.clickableCall]);
				else
					objectMap.set(object.objName, newSpr);

				add(newSpr);
			}
		}

		if (lvlData.foreground != null)
		{
			for (object in lvlData.foreground)
			{
				var newSpr:FlxSprite = new FlxSprite(object.position[0], object.position[1]);
				newSpr.loadGraphic(Paths.image(object.path));

				if (object.scale != null)
				{
					newSpr.setGraphicSize(Std.int(newSpr.width * object.scale));
					newSpr.updateHitbox();
					trace('Scaled.');
				}

				if (object.alpha != null)
					newSpr.alpha = object.alpha;

				if(object.scrollFactor != null) {
					newSpr.scrollFactor.set(object.scrollFactor[0], object.scrollFactor[1]);
				}

				if (object.flipped != null)
				{
					newSpr.flipX = object.flipped[0];
					newSpr.flipY = object.flipped[1];
				}

				if (object.clickableCall != null)
					clickableMap.set(object.objName, [newSpr, object.clickableCall]);
				else
					objectMap.set(object.objName, newSpr);

				foregroundLayer.add(newSpr);
			}
		}

		if (lvlData.hitboxes != null)
		{
			for (hitbox in lvlData.hitboxes)
			{
				var newHbx = new FlxSprite(hitbox.position[0], hitbox.position[1]);
				newHbx.makeGraphic(hitbox.size[0], hitbox.size[1], FlxColor.RED);
				newHbx.visible = false;

				if (hitbox.hbxImmovable != null)
					newHbx.immovable = hitbox.hbxImmovable;
				else
					newHbx.immovable = true;

				hbxMap.set(hitbox.hbxName, newHbx);
				hbxLayer.add(newHbx);
			}
		}

		if (lvlData.warp != null)
		{
			for (warp in lvlData.warp)
			{
				var newWarp = new FlxSprite(warp.position[0], warp.position[1]);
				newWarp.makeGraphic(warp.size[0], warp.size[1], 0xFF0066FF);
				newWarp.visible = false;

				warpMap.set(warp.wrpName, [newWarp, warp.location, warp.ret]);
				warpLayer.add(newWarp);
			}
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.H)
		{
			for (hitbox in hbxMap)
			{
				hitbox.visible = !hitbox.visible;
			}
			for (warp in warpMap)
			{
				warp[0].visible = !warp[0].visible;
			}
		}
	}
}
