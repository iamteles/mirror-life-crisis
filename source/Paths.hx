package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxSound;
import flixel.FlxSprite;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class Paths
{
	public static var renderedGraphics:Map<String, FlxGraphic> = [];
	public static var renderedSounds:Map<String, Sound> = [];

	// idk
	public static function getPath(key:String):String
		return 'assets/$key';
	
	public static function getSound(key:String):Sound
	{
		if(!renderedSounds.exists(key))
			renderedSounds.set(key, Sound.fromFile(getPath('$key.ogg')));
		
		return renderedSounds.get(key);
	}
	public static function getGraphic(key:String):FlxGraphic
	{
		var path = getPath('images/$key.png');
		if(FileSystem.exists(path))
		{
			if(!renderedGraphics.exists(path))
			{
				var bitmap = BitmapData.fromFile(path);
				
				var newGraphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);
				trace('created new image $key');
				
				renderedGraphics.set(path, newGraphic);
			}
			
			return renderedGraphics.get(path);
		}
		trace('$key doesnt exist, fuck');
		return null;
	}

	public static var dumpExclusions:Array<String> = [];
	public static function clearMemory()
	{	
		// sprite handler
		var clearCount:Int = 0;
		for(key => graphic in renderedGraphics)
		{
			trace('cleared $key');
			clearCount++;
			
			if (openfl.Assets.cache.hasBitmapData(key))
				openfl.Assets.cache.removeBitmapData(key);
			
			graphic.dump();
			graphic.destroy();
			FlxG.bitmap.remove(graphic);
			renderedGraphics.remove(key);
		}
		trace('cleared $clearCount assets');
		
		// sound clearing
		for (key => sound in renderedSounds)
		{
			if(!dumpExclusions.contains(key))
			{
				Assets.cache.clear(key);
				renderedSounds.remove(key);
			}
		}
	}
	
	public static function music(key:String):Sound
		return getSound('music/$key');
	
	public static function sound(key:String):Sound
		return getSound('sounds/$key');

	public static function inst(key:String):Sound
		return getSound('songs/$key/Inst');

	public static function vocals(key:String):Sound
		return getSound('songs/$key/Voices');
	
	public static function image(key:String):FlxGraphic
		return getGraphic(key);
	
	public static function font(key:String):String
		return getPath('fonts/$key');

	public static function shader(key:String):String
		return getPath('shaders/$key.frag');
	
	public static function getSparrowAtlas(key:String)
		return FlxAtlasFrames.fromSparrow(getGraphic(key), 'assets/images/$key.xml');

	public static function preloadGraphic(key:String)
	{
		var what = new FlxSprite().loadGraphic(image(key));
		FlxG.state.add(what);
		FlxG.state.remove(what);
	}
	public static function preloadSound(key:String)
	{
		var what = new FlxSound().loadEmbedded(getSound(key), false, false);
		what.play();
		what.stop();
	}
	public static function video(key:String, ?format:String = 'mp4'):String {
		return getPath('videos/$key.' + format);
	}
}