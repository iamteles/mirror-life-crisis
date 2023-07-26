package gameObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import states.PlayState;
import sys.io.File;
import flixel.FlxBasic;

using StringTools;

typedef StageInfo =
{
	var objects:Array<StageObject>;
	var foreground:Array<StageObject>;

	var zoom:Null<Float>;
	var dadData:Array<Float>;
	var bfData:Array<Float>;
	var gfData:Array<Float>;

	var vgAlpha:Null<Float>;
}

typedef StageObject =
{
	var objName:Null<String>; // for the var/object name
	var path:Null<String>; // image path
	var position:Null<Array<Float>>; // position of the object
	var flipped:Null<Array<Bool>>; // whether object is flipped, on the X or Y axis
	var scale:Null<Float>; // sizer for object
	var alpha:Null<Float>; // alpha
	var scrollFactor:Null<Array<Int>>; // self explanatory i hope
}

class Stage extends FlxGroup
{
	public var curStage:String = "";
	public var stageData:StageInfo;

	// [POSITION X, POSITION Y, CAMERA X, CAMERA Y]
	public var dadData:Array<Float> = [0, 0, 0, 0];
	public var bfData:Array<Float> = [0, 0, 0, 0];
	public var gfData:Array<Float> = [0, 0, 0, 0];

	public var objectMap:Map<String, FlxSprite> = new Map<String, FlxSprite>();
	public var foreground:FlxTypedGroup<FlxBasic>;

	public function new() {
		super();
		foreground = new FlxTypedGroup<FlxBasic>();
	}

	public function reloadStageFromSong(song:String = "test"):Void
	{
		trace('Attempt to load' + 'assets/data/stage/' + song + '.json');
		try
		{
			
			stageData = haxe.Json.parse(File.getContent('assets/data/stage/' + song + '.json').trim());
			reloadStage(song);
			loadFromJson();
		}
		catch (e)
		{
			trace('Uncaught Error: $e');

			switch(song.toLowerCase())
			{
				default:
					reloadStage("stage");
			}
		}
	}

	function loadFromJson() {
		trace('Finish load.');

		if(stageData.zoom != null) 
			PlayState.defaultCamZoom = stageData.zoom;
		if(stageData.dadData != null)
			dadData = stageData.dadData;
		if(stageData.bfData != null)
			bfData = stageData.bfData;
		if(stageData.gfData != null)
			gfData = stageData.gfData;

		if (stageData.objects != null)
		{
			for (object in stageData.objects)
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

				objectMap.set(object.objName, newSpr);
				add(newSpr);
			}
		}

		if (stageData.foreground != null)
		{
			for (object in stageData.foreground)
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

				objectMap.set(object.objName, newSpr);
				foreground.add(newSpr);
			}
		}
	}

	public function reloadStage(curStage:String = "")
	{
		this.clear();
		foreground.clear();

		this.curStage = curStage;
		switch(curStage)
		{
			case 'prismatic' | 'echo':
				//
			default:
			//
		}
	}

	
}