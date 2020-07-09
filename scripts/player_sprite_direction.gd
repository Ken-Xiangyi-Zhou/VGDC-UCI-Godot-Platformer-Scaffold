extends AnimatedSprite

#This script controls the animation of the sprites.
#The implementation here uses frames, but you can also swap animations if you have more than one with
#	set_animation(value).

var time_since_last_change: float = 0.0	#Time elapsed since the last time the frame was changed.

func _process(_delta):					#_process is called by the engine once every "frame", default 60 fps.
	change_direction()

func change_direction():				#Flips sprite (horizontal) to last buffered direction.
	if Input.is_action_pressed("left"):
		self.flip_h = true
	if Input.is_action_pressed("right"):
		self.flip_h = false
