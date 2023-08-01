package gameObjects.hud.note;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import data.GameData.NoteUtil;

class StrumNote extends FlxSprite
{
	public function new()
	{
		super();
		reloadStrum(0, "default");
	}

	public var strumData:Int = 0;
	public var assetModifier:String = "default";

	// use these to modchart
	public var strumSize:Float = 1.0;
	public var scaleOffset:FlxPoint = new FlxPoint(0,0);
	public var initialPos:FlxPoint = new FlxPoint(0,0);

	private var direction:String = "left";

	public function reloadStrum(strumData:Int, ?assetModifier:String = "default"):StrumNote
	{
		this.strumData = strumData;
		this.assetModifier = assetModifier;
		strumSize = 1.0;

		direction = NoteUtil.getDirection(strumData);

		strumSize = 0.7;
		frames = Paths.getSparrowAtlas("notes/base/strums");

		addDefaultAnims();

		if (!SaveData.data.get("Downscroll")) {
			switch(strumData) {
				case 0:
					addOffset("static", 16, -14);
					addOffset("pressed", 14, -16);
					addOffset("confirm", 50, 22);
				case 3:
					addOffset("static", 0, -14);
					addOffset("pressed", -2, -16);
					addOffset("confirm", 36, 22);
				default:
					addOffset("static", 0, 0);
					addOffset("pressed", -2, -2);
					addOffset("confirm", 36, 36);
			}
		}
		else {
			switch(strumData) {
				case 0:
					addOffset("static", 16, 6);
					addOffset("pressed", 14, 4);
					addOffset("confirm", 50, 42);
				case 3:
					addOffset("static", 0, 6);
					addOffset("pressed", -2, 4);
					addOffset("confirm", 36, 42);
				default:
					addOffset("static", 0, 0);
					addOffset("pressed", -2, -2);
					addOffset("confirm", 36, 36);
			}
		}


		playAnim("static"); // once to get the scale offset

		scale.set(strumSize, strumSize);
		updateHitbox();
		scaleOffset.set(offset.x, offset.y);

		playAnim("static"); // twice to use the scale offset

		return this;
	}

	// just so i dont have to type everything over and over again
	public function addDefaultAnims()
	{
		animation.addByPrefix("static",  'strum $direction static',  24, false);
		animation.addByPrefix("pressed", 'strum $direction pressed', 12, false);
		animation.addByPrefix("confirm", 'strum $direction confirm', 24, false);
	}

	public var animOffsets:Map<String, Array<Float>> = [];

	public function addOffset(animName, offX:Float = 0, offY:Float = 0):Void
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