package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import data.Highscore;

import flixel.input.keyboard.FlxKey;

enum SettingType
{
	CHECKMARK;
	SELECTOR;
}
class SaveData
{
	public static var data:Map<String, Dynamic> = [];
	public static var progression:Int = 0;
	public static var clowns:Map<String, Bool> = [
		"lexi" => false,
		"juke" => false,
		"pete" => false,
		"munchlog" => false
	];
	public static var displaySettings:Map<String, Dynamic> = [
		"Ghost Tapping" => [
			true,
			CHECKMARK,
			"Makes you able to press keys freely without missing notes."
		],
		"Botplay" => [
			false,
			CHECKMARK,
			"The game plays for you."
		],
		"FPS Counter" => [
			false,
			CHECKMARK,
			"Show or hide the FPS counter."
		],
		"Downscroll" => [
			false,
			CHECKMARK,
			"Makes the notes go down instead of up."
		],
		"Middlescroll" => [
			false,
			CHECKMARK,
			"Disables the opponent's notes and moves yours to the middle."
		],
		"Antialiasing" => [
			true,
			CHECKMARK,
			"Disabling it might increase the fps at the cost of smoother sprites."
		],
		"Note Splashes" => [
			"ON",
			SELECTOR,
			"Whether a splash appear when you hit a note perfectly.",
			["ON", "PLAYER", "OFF"],
		],
		"Mania Overlay" => [
			"ALLEY",
			SELECTOR,
			"Select the overlay that appears in Mania mode.",
			["ALLEY", "CLOWN", "STREET", "FOOLTOPIA", "BRICK", "DAY", "NIGHT", "BASIC", "OFF"],
		],
		"Ratings on HUD" => [
			true,
			CHECKMARK,
			"Makes the ratings stick on the HUD."
		],
		"Flashing Lights" => [
			true,
			CHECKMARK,
			"Enables flashing lights."
		],
		"Flashbang Mode" => [
			false,
			CHECKMARK,
			"Lol"
		],
		"Shaders" => [
			true,
			CHECKMARK,
			"Enables shaders."
		],
		"Framerate"	=> [
			120,
			SELECTOR,
			"Self explanatory.",
			[30, 360]
		],
		"Munchlog"	=> [
			1,
			SELECTOR,
			"Self explanatory. Im pretty sure these descriptions dont actually show up ingame so if you are reading this props to you i guess.",
			[1, 999]
		],
		// this one doesnt actually appear at the regular options menu
		"Song Offset" => [
			0,
			[-500, 500]
		]
	];
	
	public static var saveFile:FlxSave;
	public static var progressionSave:FlxSave;
	public static function init()
	{
		saveFile = new FlxSave();
		saveFile.bind("options", "teles/MLC"); // use these for settings

		progressionSave = new FlxSave();
		progressionSave.bind("progression", "teles/MLC"); // use these for progressions´

		FlxG.save.bind("save-data", "teles/MLC"); // these are for other stuff
		load();

		Controls.load();
		Highscore.load();
	}
	
	public static function load()
	{
		if(saveFile.data.settings == null || Lambda.count(displaySettings) != Lambda.count(saveFile.data.settings))
		{
			for(key => values in displaySettings)
				data[key] = values[0];
			
			saveFile.data.settings = data;
		}

		if(progressionSave.data.progression == null)
		{
			progressionSave.data.progression = progression;
		}

		if(progressionSave.data.clowns == null || Lambda.count(clowns) != Lambda.count(progressionSave.data.clowns))
		{
			for(key => values in clowns)
				clowns[key] = values;
			
			progressionSave.data.clowns = clowns;
		}
		
		data 		= saveFile.data.settings;
		progression = progressionSave.data.progression;
		clowns		= progressionSave.data.clowns; 
		saveButTechnically();
	}
	
	public static function save()
	{
		saveFile.data.settings = data;
		saveFile.flush();
		update();
	}

	public static function saveButTechnically()
	{
		saveFile.data.settings = data;
		saveFile.flush();

		progressionSave.data.progression = progression;
		progressionSave.data.clowns = clowns;
		progressionSave.flush();

		update();
	}

	public static function progress(?newP:Int, ?add:Bool = false) {
		if(!add)
			progression = newP;
		else
			progression ++;
		progressionSave.data.progression = progression;
		progressionSave.flush();
	}

	public static function clownCheck():Bool {
		var checked = false;
		if(clowns.get('lexi') && clowns.get('pete') && clowns.get('juke'))
			checked = true;
		return checked;
	}

	public static function wipe(?which:String = 'ALL'){
		switch(which) {
			case 'PROGRESS':
				progressionSave.erase();
				progression = 0;
				clowns = [
					"lexi" => false,
					"juke" => false,
					"pete" => false,
					"munchlog" => false
				];
				trace ("Wiping progress " + progressionSave.data.progression + ' ' + progressionSave.data.clowns);
			case 'HIGHSCORE':
				FlxG.save.erase();
			case 'OPTIONS':
				saveFile.erase();
				data = [];
			default:
				FlxG.save.erase();
				saveFile.erase();
				progressionSave.erase();
				data = [];
				progression = 0;
				clowns = [
					"lexi" => false,
					"juke" => false,
					"pete" => false,
					"munchlog" => false
				];
		}

		load();
	}

	public static function update()
	{
		Main.changeFramerate(data.get("Framerate"));

		FlxSprite.defaultAntialiasing = data.get("Antialiasing");

		if(Main.fpsVar != null) {
			Main.fpsVar.visible = data.get("FPS Counter");
		}
	}
}