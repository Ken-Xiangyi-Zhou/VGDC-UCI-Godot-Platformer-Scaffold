extends AnimationPlayer

func _ready():							#Called when the node enters the scene tree for the first time.
	set_autoplay("Idle")

func _process(delta):					#Called every frame. 'delta' is the elapsed time since the previous frame.
	if not is_playing():
		if randf() < 0.1:				#10% chance to blink every 0.1 seconds. 0.1 is the length of the blink animation.
			play("Blink")
		else:
			play("Idle")
