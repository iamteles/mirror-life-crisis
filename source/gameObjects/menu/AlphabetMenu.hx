package gameObjects.menu;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

/*
**	instead of it being all mashed into one place
**	i've separated the Alphabet into two classes
**	use this one for menus such as Pause or Freeplay
*/
class AlphabetMenu extends FlxText
{
	public function new(x:Float = 0, y:Float = 0, ?text:String = "", bold:Bool = false)
	{
		super(x, y, 0, text);

		setFormat(Main.gFont, 60, 0xFFFFFFFF);
		setBorderStyle(OUTLINE, 0xFF000000, 3);
		updateHitbox();
	}

	public var xTo:Float = 100;
	public var yTo:Float = 300;

	public var focusY:Int = 0;
	public var spaceX:Float = 50;
	public var spaceY:Float = 200;

	public var posUpdate:Bool = true;

	public final boxHeight:Float = 70;

	public var nuhuh:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(posUpdate)
			updatePos(elapsed * 12);
	}

	public function updatePos(lerp:Float = 1)
	{
		if (nuhuh)
			return;
		x = FlxMath.lerp(x, xTo + (spaceX * focusY * scale.x), lerp);
		y = FlxMath.lerp(y, yTo + (spaceY * focusY * scale.y), lerp);
	}
}