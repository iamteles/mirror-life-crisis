package states.menus;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import data.GameData.MusicBeatState;
import gameObjects.menu.AlphabetMenu;
import gameObjects.menu.options.*;
import SaveData.SettingType;

class OptionsState extends MusicBeatState
{
	var optionShit:Map<String, Array<String>> =
	[
		"main" => [
			"Gameplay",
			"Appearance",
			"Controls",
			"Save Data"
		],
		"Gameplay" => [
			"Ghost Tapping",
			"Downscroll",
			"Botplay",
			"Flashbang Mode",
			"Framerate",
			"Munchlog"
		],
		"Appearance" => [
			"FPS Counter",
			"Flashing Lights",
			"Shaders",
			"Antialiasing",
			"Video Cutscenes",
			"Note Splashes",
			"Mania Overlay"
		],
		"Save Data" => [
			"Reset Story Mode",
			"Reset Options",
			"Reset Highscores",
			"Reset All"
		]
	];

	public static var bgColors:Map<String, FlxColor> = [
		"main" 		=> 0xFFcf68f7,
		"Gameplay"	=> 0xFF83e6aa,
		"Appearence"=> 0xFFf58ea9,
		"controls"  => 0xFF8295f5,
		"Save Data" => 0xfff7e968,
	];

	public static var curCat:String = "main";

	static var curSelected:Int = 0;
	static var storedSelected:Map<String, Int> = [];

	var grpTexts:FlxTypedGroup<AlphabetMenu>;
	var grpAttachs:FlxTypedGroup<FlxBasic>;

	// objects
	var bg:FlxBackdrop;

	// makes you able to go to the options and go back to the state you were before
	var backTarget:FlxState;
	public function new(?backTarget:FlxState)
	{
		super();
		if(backTarget == null) backTarget = new states.menus.MenuState();
		this.backTarget = backTarget;
	}

	override function create()
	{
		super.create();

		bg = new FlxBackdrop(Paths.image("menu/grid"), XY, 0, 0);
        bg.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
       	bg.screenCenter();
        add(bg);

		grpTexts = new FlxTypedGroup<AlphabetMenu>();
		grpAttachs = new FlxTypedGroup<FlxBasic>();

		add(grpTexts);
		add(grpAttachs);

		reloadCat();
	}

	public function reloadCat(curCat:String = "main")
	{
		storedSelected.set(OptionsState.curCat, curSelected);

		OptionsState.curCat = curCat;
		grpTexts.clear();
		grpAttachs.clear();

		if(storedSelected.exists(curCat))
			curSelected = storedSelected.get(curCat);
		else
			curSelected = 0;

		if(bgColors.exists(curCat))
			bg.color = bgColors.get(curCat);
		else
			bg.color = bgColors.get("main");

		if(curCat == "main" || curCat == "Save Data")
		{
			for(i in 0...optionShit.get(curCat).length)
			{
				var item = new AlphabetMenu(0,0, optionShit.get(curCat)[i], true);
				grpTexts.add(item);

				item.ID = i;

				item.alignment = CENTER;
				item.updateHitbox();
				item.screenCenter(X);

				item.posUpdate = false;

				var spaceY:Float = 36;

				//item.x = FlxG.width / 2;
				item.y = (FlxG.height / 2) + ((item.height + spaceY) * i);
				item.y -= (item.height + spaceY) * (optionShit.get(curCat).length - 1) / 2;
				item.y -= (70 / 2);
			}
		}
		else
		{
			for(i in 0...optionShit.get(curCat).length)
			{
				var daOption:String = optionShit.get(curCat)[i];
				var item = new AlphabetMenu(0,0, daOption, true);
				grpTexts.add(item);

				item.ID = i;
				item.focusY = i;

				item.scale.set(0.9,0.9);
				item.updateHitbox();

				item.xTo = 128;
				item.spaceX = 0;

				item.yTo = 48;
				item.spaceX = 0;
				item.spaceY = (70 + 12);

				item.updatePos();

				if(optionShit.get(curCat).length <= 7)
				{
					item.posUpdate = false;

					var spaceY:Float = 12;

					item.y = (FlxG.height / 2) + ((item.height + spaceY) * i);
					item.y -= (item.height + spaceY) * (optionShit.get(curCat).length - 1) / 2;
					item.y -= (70 / 2);
				}

				if(SaveData.displaySettings.exists(daOption))
				{
					var daDisplay:Dynamic = SaveData.displaySettings.get(daOption);

					switch(daDisplay[1])
					{
						case CHECKMARK:
							var daCheck = new OptionCheckmark(SaveData.data.get(daOption), 0.9);
							daCheck.ID = i;
							daCheck.x = FlxG.width - 128 - daCheck.width;
							grpAttachs.add(daCheck);

						case SELECTOR:
							var daSelec = new OptionSelector(
								daOption,
								SaveData.data.get(daOption),
								daDisplay[3]
							);
							daSelec.xTo = FlxG.width - 128;
							daSelec.updateValue();
							daSelec.ID = i;
							grpAttachs.add(daSelec);

						default: // uhhh
					}
				}
			}
		}

		updateAttachPos();
		changeSelection();
	}

	public function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.get(curCat).length - 1);

		if (change != 0)  FlxG.sound.play(Paths.sound("beep"));

		for(item in grpTexts.members)
		{
			item.focusY = item.ID;
			item.alpha = 0.4;
			if(item.ID == curSelected)
			{
				item.alpha = 1;
			}
			if(curSelected > 7)
			{
				item.focusY -= curSelected - 7;
			}
		}
		for(item in grpAttachs.members)
		{
			var daAlpha:Float = 0.4;
			if(item.ID == curSelected)
				daAlpha = 1;

			if(Std.isOfType(item, OptionCheckmark))
			{
				var check = cast(item, OptionCheckmark);
				check.alpha = daAlpha;
			}
			
			if(Std.isOfType(item, OptionSelector))
			{
				var selector = cast (item, OptionSelector);
				for(i in selector.members)
				{
					i.alpha = daAlpha;
				}
			}
		}

		// uhhh
		selectorTimer = Math.NEGATIVE_INFINITY;
	}

	function updateAttachPos()
	{
		for(item in grpAttachs.members)
		{
			for(text in grpTexts.members)
			{
				if(text.ID == item.ID)
				{
					if(Std.isOfType(item, OptionCheckmark))
					{
						var check = cast(item, OptionCheckmark);
						check.y = text.y + text.height / 2 - check.height / 2;
					}
					
					if(Std.isOfType(item, OptionSelector))
					{
						var selector = cast(item, OptionSelector);
						selector.setY(text);
					}
				}
			}
		}
	}

	var selectorTimer:Float = Math.NEGATIVE_INFINITY;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		updateAttachPos();

		if(Controls.justPressed("BACK"))
		{
			if(curCat == "main")
			{
				storedSelected.set("main", curSelected);
				Main.switchState(backTarget);//new states.MenuState();
			}
			else
				reloadCat("main");
		}

		if(Controls.justPressed("UI_UP"))
			changeSelection(-1);
		if(Controls.justPressed("UI_DOWN"))
			changeSelection(1);

		if(Controls.justPressed("ACCEPT"))
		{
			FlxG.sound.play(Paths.sound("select"));
			if(curCat == "main")
			{
				storedSelected.set("main", curSelected);
				var daOption:String = grpTexts.members[curSelected].text;
				switch(daOption.toLowerCase())
				{
					default:
						if(optionShit.exists(daOption))
							reloadCat(daOption);

					case "controls":
						new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							Main.skipStuff();
							Main.switchState(new ControlsState());
						});
				}
			}
			else if(curCat == "Save Data")
			{
				storedSelected.set("Save Data", curSelected);
				var daOption:String = grpTexts.members[curSelected].text;
				switch(daOption.toLowerCase())
				{
					case "reset story mode":
						SaveData.wipe('PROGRESS');
					case "reset highscores":
						SaveData.wipe('HIGHSCORE');
					case "reset options":
						SaveData.wipe('OPTIONS');
					case "reset all":
						SaveData.wipe('ALL');
				}
			}
			else
			{
				var curAttach = grpAttachs.members[curSelected];
				if(Std.isOfType(curAttach, OptionCheckmark))
				{
					var checkmark = cast(curAttach, OptionCheckmark);
					checkmark.setValue(!checkmark.value);

					SaveData.data.set(optionShit[curCat][curSelected], checkmark.value);
					SaveData.save();
				}
			}
		}
		
		if(Controls.pressed("UI_LEFT") || Controls.pressed("UI_RIGHT"))
		{
			if(curCat == 'Gameplay' && curSelected == 5 && !SaveData.clowns.get('munchlog')) {
				FlxG.sound.music.volume = 0.3;
				FlxG.sound.play(Paths.sound("munchlog"));
				SaveData.clowns.set('munchlog', true);
				SaveData.saveButTechnically();
			}
			var curAttach = grpAttachs.members[curSelected];
			if(Std.isOfType(curAttach, OptionSelector))
			{
				var selector = cast(curAttach, OptionSelector);

				if(Controls.justPressed("UI_LEFT") || Controls.justPressed("UI_RIGHT"))
				{
					selectorTimer = -0.5;

					if(Controls.justPressed("UI_LEFT"))
						selector.updateValue(-1);
					else
						selector.updateValue(1);
				}

				if(Controls.pressed("UI_LEFT"))
					selector.arrowL.animation.play("push");

				if(Controls.pressed("UI_RIGHT"))
					selector.arrowR.animation.play("push");

				if(selectorTimer != Math.NEGATIVE_INFINITY && !Std.isOfType(selector.bounds[0], String))
				{
					selectorTimer += elapsed;
					if(selectorTimer >= 0.02)
					{
						selectorTimer = 0;
						if(Controls.pressed("UI_LEFT"))
							selector.updateValue(-1);
						if(Controls.pressed("UI_RIGHT"))
							selector.updateValue(1);
					}
				}
			}
		}
		if(Controls.released("UI_LEFT") || Controls.released("UI_RIGHT"))
		{
			selectorTimer = Math.NEGATIVE_INFINITY;
			for(attach in grpAttachs.members)
			{
				if(Std.isOfType(attach, OptionSelector))
				{
					var selector = cast(attach, OptionSelector);
					if(Controls.released("UI_LEFT"))
						selector.arrowL.animation.play("idle");

					if(Controls.released("UI_RIGHT"))
						selector.arrowR.animation.play("idle");
				}
			}
		}
	}
}