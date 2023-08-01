package data;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import data.Conductor.BPMChangeEvent;
import flixel.util.FlxSort;
import gameObjects.hud.note.Note;

class NoteUtil
{
	public static function getDirection(i:Int)
		return ["left", "down", "up", "right"][i];

	public static function noteWidth()
	{
		return (160 * 0.7); // 112
	}
	
	public static function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.songTime, Obj2.songTime);
}

class Utils
{
	public static function flash(camera:FlxCamera, ?duration:Float = 0.5, ?color:FlxColor) {
		if(!SaveData.data.get("Flashing Lights")) return;
		camera.flash(color, duration, null, true);
	}

	public static function bang(camera:FlxCamera, ?duration:Float = 0.5, ?color:FlxColor) {
		if(!SaveData.data.get("Flashbang Mode")) return;
		FlxG.sound.play(Paths.sound('bang'));
		camera.flash(color, duration, null, true);
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static function camLerp(a:Float):Float
	{
		return FlxG.elapsed / 0.016666666666666666 * a;
		
	}

	public static function customLerp(a:Float, b:Float, c:Float):Float
	{
		return a + camLerp(c) * (b - a);
	}

	public static function smoothColorChange(from:FlxColor, to:FlxColor, ?speed:Float = 0.045):FlxColor
	{

		var result:FlxColor = FlxColor.fromRGBFloat
		(
			customLerp(from.redFloat, to.redFloat, speed), //red

			customLerp(from.greenFloat, to.greenFloat, speed), //green

			customLerp(from.blueFloat, to.blueFloat, speed) //blue
		);
		return result;
	}
}
class MusicBeatState extends FlxState
{
	//private var controls:Controls = new Controls();

	override function create()
	{
		super.create();
		
		//trace('switched to ${Type.getClassName(Type.getClass(FlxG.state))}');

		if(!Main.skipClearMemory)
			Paths.clearMemory();

		if(!Main.skipTrans)
			openSubState(new GameTransition(true));

		Main.skipStuff(false);
	}

	private var _curStep = 0; // fake curStep
	private var curStep = 0;
	private var curBeat = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		updateBeat();
	}

	private function updateBeat()
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for(change in Conductor.bpmChangeMap)
		{
			if (Conductor.songPos >= change.songTime)
				lastChange = change;
		}

		_curStep = lastChange.stepTime + Math.floor((Conductor.songPos - lastChange.songTime) / Conductor.stepCrochet);

		if(_curStep != curStep)
			stepHit();
	}

	private function stepHit()
	{
		if(_curStep > curStep)
			curStep++;
		else
		{
			curStep = _curStep;
		}

		if(curStep % 4 == 0)
			beatHit();
	}

	private function beatHit()
	{
		// finally you're useful for something
		curBeat = Math.floor(curStep / 4);
		for(change in Conductor.bpmChangeMap)
		{
			if(curStep >= change.stepTime && Conductor.bpm != change.bpm)
				Conductor.setBPM(change.bpm);
		}
	}
}

class MusicBeatSubState extends FlxSubState
{
	override function create()
	{
		super.create();
	}
}