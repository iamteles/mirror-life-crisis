package data;

import flixel.FlxG;
import data.SongData.SwagSong;
import sys.io.File;

using StringTools;

typedef BPMJson = {
	var changes:Array<BPMChangeEvent>;
}
typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}
class Conductor
{
	public static var bpm:Float = 0;
	public static var crochet:Float = 0;
	public static var stepCrochet:Float = 0;

	public static var songPos:Float = 0;

	public static function setBPM(bpm:Float = 100)
	{
		Conductor.bpm = bpm;
		crochet = calcBeat(bpm);
		stepCrochet = calcStep(bpm);
	}

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];
	public static var bpmjson:BPMJson;
	public static function mapBPMChanges(?song:SwagSong)
	{
		bpmChangeMap = [];

		if(song == null) return;

		// so apparently these calculations dont exactly work well, which is fine ill just go around it
		try
		{
			bpmjson = haxe.Json.parse(File.getContent('assets/songs/' + song.song.toLowerCase() + '/bpm.json').trim());
			bpmChangeMap = bpmjson.changes;
		}
		catch (e)
		{
			//trace('Uncaught Error: $e');

			var curBPM:Float = song.bpm;
			var totalSteps:Int = 0;
			var totalPos:Float = 0;
			for (i in 0...song.notes.length)
			{
				if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
				{
					curBPM = song.notes[i].bpm;
					var event:BPMChangeEvent = {
						stepTime: totalSteps,
						songTime: totalPos,
						bpm: curBPM
					};
					bpmChangeMap.push(event);
				}
	
				var deltaSteps:Int = song.notes[i].lengthInSteps;
				totalSteps += deltaSteps;
				totalPos += calcStep(curBPM) * deltaSteps;
			}
		}
		//trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function calcBeat(bpm:Float):Float
		return ((60 / bpm) * 1000);

	public static function calcStep(bpm:Float):Float
		return calcBeat(bpm) / 4;
}