extends AnimationPlayer

#This script changes the current animation of the player sprite. There's just blinking right now.

func _process(_delta):					#Called every frame. 'delta' is the elapsed time since the previous frame.
	if not is_playing():
		if randf() < 0.1:				#10% chance to blink every 0.1 seconds. 0.1 is the length of the blink animation.
			play("Blink")
		else:
			play("Idle")
