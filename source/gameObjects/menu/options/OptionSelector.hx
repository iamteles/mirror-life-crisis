package gameObjects.menu.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class OptionSelector extends FlxTypedGroup<FlxSprite>
{
	public var label:String = "";
	public var value:Dynamic;
	public var bounds:Array<Dynamic>;

	public var xTo:Float = 0;

	public var arrowL:FlxSprite;
	public var text:FlxText;
	public var arrowR:FlxSprite;

	public function new(label:String, value:Dynamic, bounds:Array<Dynamic>)
	{
		super();
		this.label = label;
		this.value = value;
		this.bounds = bounds;

		arrowL = new FlxSprite();
		arrowL.frames = Paths.getSparrowAtlas("menu/menuArrows");
		arrowL.animation.addByPrefix("idle", "arrow left", 0, false);
		arrowL.animation.addByPrefix("push", "arrow push left", 0, false);
		arrowL.scale.set(0.8,0.8); arrowL.updateHitbox();
		arrowL.animation.play("idle");

		arrowR = new FlxSprite();
		arrowR.frames = Paths.getSparrowAtlas("menu/menuArrows");
		arrowR.animation.addByPrefix("idle", "arrow right", 0, false);
		arrowR.animation.addByPrefix("push", "arrow push right", 0, false);
		arrowR.scale.set(0.8,0.8); arrowR.updateHitbox();
		arrowR.animation.play("idle");

		text = new FlxText(0, 0, 0, Std.string(value));
		text.setFormat(Main.gFont, 54, 0xFFFFFFFF);
		text.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.7);
		text.updateHitbox();

		add(arrowL);
		add(text);
		add(arrowR);

		updateValue();
	}

	public function updateValue(change:Int = 0)
	{
		if(Std.isOfType(bounds[0], String))
		{
			var curSelected = bounds.indexOf(value) + change;
			curSelected = FlxMath.wrap(curSelected, 0, bounds.length - 1);
			value = bounds[curSelected];
		}
		else
		{
			value += change;
			if(value < bounds[0]) value = bounds[1];
			if(value > bounds[1]) value = bounds[0];
		}

		text.text = Std.string(value);

		arrowR.x = xTo - arrowR.width;
		text.x   = arrowR.x - text.width - 4;
		arrowL.x = text.x - arrowL.width - 4;

		SaveData.data.set(label, value);
		SaveData.save();
	}

	public function setY(item:FlxSprite)
	{
		for(i in [arrowL, arrowR])
			i.y = item.y + item.height / 2 - i.height / 2;

		text.y = item.y;
	}
}