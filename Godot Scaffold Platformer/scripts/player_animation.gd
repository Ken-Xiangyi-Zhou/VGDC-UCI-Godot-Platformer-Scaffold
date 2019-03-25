extends AnimatedSprite				#self.frame and self.flip_h attributes inherited from this class.

#This script controls the animation of the sprites.
#The implementation here uses frames, but you can also swap animations if you have more than one with
#	set_animation(value).

var time_since_last_change: float = 0.0	#Time elapsed since the last time the frame was changed.

func _process(delta):					#_process is called by the engine once every "frame", default 60 fps.
	blink(delta)						#	delta is time elapsed since last frame.
	change_direction()

func blink(delta):						#This function makes the sprite blink.
	time_since_last_change += delta
	if time_since_last_change > 0.1:
		if randi() % 11 < 1:			#Random integer mod 11 returns 0 - 9.
			frame = 1					#frame 0 is normal, frame 1 is a blink.
		else:
			frame = 0
		time_since_last_change = 0

func change_direction():				#Flips sprite (horizontal) to last buffered direction.
	if Input.is_action_pressed("left"):
		self.flip_h = true
	if Input.is_action_pressed("right"):
		self.flip_h = false