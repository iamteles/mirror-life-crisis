package gameObjects.side;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

using StringTools;

class Player extends FlxSprite
{
	public var stopped = false;

	var walkSpeed:Float = 260;
	var runSpeed:Float = 420;
	var speedState:Float = 0;

	private var scaleOffset:FlxPoint = new FlxPoint();

	var walkingSound:FlxSound;
	var runningSound:FlxSound;

	public function new(x:Float, y:Float)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas("side/minami");

		animation.addByPrefix('idle', 		'Minami Stand', 24, true);
		animation.addByPrefix('walk', 		'Minami Walk', 24, true);
		animation.addByPrefix('run', 		'Minami Sprint', 24, true);
		playAnim('idle');

		updateHitbox();
		scaleOffset.set(offset.x, offset.y);

		setFacingFlip(RIGHT, false, false);
		setFacingFlip(LEFT, true, false);
		//acceleration.y = 1500;
		maxVelocity.y = 750;

		walkingSound = new FlxSound();
		walkingSound.loadEmbedded(Paths.sound('footsteps'), true, false);
		FlxG.sound.list.add(walkingSound);

		runningSound = new FlxSound();
		runningSound.loadEmbedded(Paths.sound('running'), true, false);
		FlxG.sound.list.add(runningSound);
	}

	override public function update(elapsed:Float)
	{
		var run:Bool = FlxG.keys.anyPressed([SHIFT]);
		var left:Bool = FlxG.keys.anyPressed([A, LEFT]);
		var right:Bool = FlxG.keys.anyPressed([D, RIGHT]);

		if (!stopped)
		{
			if (run)
			{
				speedState = runSpeed;
			}
			else
				speedState = walkSpeed;
			if (left && right) {
				playAnim('idle');
				left = right = false;
				walkingSound.stop();
				runningSound.stop();
			}

			if (left)
			{
				velocity.x = -speedState;
				facing = LEFT;
				if (run) {
					walkingSound.stop();
					runningSound.play();
					playAnim('run');
				}
				else {
					runningSound.stop();
					walkingSound.play();
					playAnim('walk');
				}
			}
			else if (right)
			{
				velocity.x = speedState;
				facing = RIGHT;
				if (run) {
					walkingSound.stop();
					runningSound.play();
					playAnim('run');
				}
				else {
					runningSound.stop();
					walkingSound.play();
					playAnim('walk');
				}
			}
			else
			{
				walkingSound.stop();
				runningSound.stop();
				velocity.x = 0;
				playAnim('idle');
			}
		}
		else {
			walkingSound.stop();
			runningSound.stop();
			velocity.x = 0;
			playAnim('idle');
		}


		super.update(elapsed);
	}

	public var animOffsets:Map<String, Array<Float>> = [];

	public function addOffset(animName:String, offX:Float = 0, offY:Float = 0):Void
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
