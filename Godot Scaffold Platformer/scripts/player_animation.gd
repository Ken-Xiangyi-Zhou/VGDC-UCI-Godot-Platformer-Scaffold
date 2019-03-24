extends AnimatedSprite				#self.frame and self.flip_h attributes inherited from this class.

#This script controls the animation of the sprites.
#The implementation here uses frames, but you can also swap animations if you have more than one with
#	set_animation(value).

var time_since_last_change = 0

func _process(delta):					#_process is called by the engine once every "frame", default 60 fps.
	_blink(delta)						#	delta is time elapsed since last frame.
	_change_direction()

func _blink(delta):						#This function currently makes the sprite blink.
	time_since_last_change += delta
	if time_since_last_change > 0.1:
		if randi() % 11 < 1:			#	Random integer mod 11 returns 0 - 9.
			self.frame = 1				#	frame 0 is normal, frame 1 is a blink.
		else:
			self.frame = 0
		time_since_last_change = 0

func _change_direction():				#Flips sprite to last buffered direction.
	if Input.is_action_pressed("left"):
		self.flip_h = true
	if Input.is_action_pressed("right"):
		self.flip_h = false