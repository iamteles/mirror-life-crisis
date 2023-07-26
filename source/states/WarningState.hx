package states;

import data.GameData.MusicBeatState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import openfl.display.BlendMode;
import flixel.addons.display.FlxBackdrop;

/**
	a state for general warnings
	this is just code from the base game that i've made some slight improvements to
**/
class WarningState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warningText:FlxText;

	var warningField:String = 'beep bop bo skdkdkdbebedeoop brrapadop';
	var fieldOffset:Float = 0;

	override function create()
	{
		super.create();

        warningField = '!CONTENT WARNING!'
            + "\nThis mod features use of the following mechanics/themes.\n"
            + "\n- Flashing Lights -"
            + "\n- Shaders -"
            + "\n- Clowns -"
            + "\n- Depression -"
            + "\n- Meta humor -\n"
            + "\nPress ENTER to continue.";

		generateBackground();

		warningText = new FlxText(0, 0);
		warningText.setFormat(Main.gFont, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        warningText.borderSize = 2;
        warningText.text = warningField;
		warningText.screenCenter();
		warningText.alpha = 0;
		add(warningText);

		FlxTween.tween(warningText, {alpha: 1}, 0.4);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE)
		{
            Main.switchState(new MenuState());
		}
	}

	var background:FlxSprite;
	var darkBackground:FlxSprite;
	var funkyBack:FlxBackdrop;

	function generateBackground()
	{
		background = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.fromRGB(167, 103, 225), FlxColor.fromRGB(137, 20, 181)]);
		//background.alpha = 0;
		add(background);

        funkyBack = new FlxBackdrop(Paths.image("menu/grid"), XY, 0, 0);
        funkyBack.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
        funkyBack.screenCenter();
        funkyBack.alpha = 0.4;
        funkyBack.blend = BlendMode.DIFFERENCE;
        add(funkyBack);
	}
}