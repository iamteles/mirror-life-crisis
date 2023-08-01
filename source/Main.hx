package;

import data.*;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxGame;
import openfl.display.Sprite;
import data.FPSCounter;
import lime.app.Application;
import data.Discord.DiscordClient;

using StringTools;

class Main extends Sprite
{
	public static var fpsVar:FPSCounter;

	public function new()
	{
		super();
		//Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);

		#if DISCORD_RPC
		if (!DiscordClient.isInitialized) {
			DiscordClient.initialize();
			Application.current.window.onClose.add(function() {
				DiscordClient.shutdown();
			});
		}
		#end

		addChild(new FlxGame(0, 0, Init, 120, 120, true));

		#if desktop
		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		fpsVar.visible = false;
		addChild(fpsVar);
		#end
	}

	public static var gFont:String = Paths.font("coolvetica.otf");
	
	public static var skipTrans:Bool = true; // starts on but it turns false inside Init
	public static var skipClearMemory:Bool = false;
	public static function switchState(?target:FlxState):Void
	{
		var trans = new GameTransition(false);
		trans.finishCallback = function()
		{
			if(target != null)		
				FlxG.switchState(target);
			else
				FlxG.resetState();
		};

		if(skipTrans)
		{
			return trans.finishCallback();
		}
		
		FlxG.state.openSubState(trans);
	}

	
	public static function skipStuff(?ohreally:Bool = true):Void
	{
		skipClearMemory = ohreally;
		skipTrans = ohreally;
	}
	
	public static function changeFramerate(rawFps:Float = 120)
	{
		var newFps:Int = Math.floor(rawFps);

		if(newFps > FlxG.updateFramerate)
		{
			FlxG.updateFramerate = newFps;
			FlxG.drawFramerate   = newFps;
		}
		else
		{
			FlxG.drawFramerate   = newFps;
			FlxG.updateFramerate = newFps;
		}
	}
}