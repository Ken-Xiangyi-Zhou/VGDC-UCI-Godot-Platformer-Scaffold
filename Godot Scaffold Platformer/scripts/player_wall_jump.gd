extends Area2D

# Declare member variables here. Examples:
var _wall_state = false

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_on_wall")
	connect("body_exited", self, "_off_wall")

func check_and_wall_jump():
	self._turn()
	if self._wall_state == true:
		if _press_up() and not self.find_parent("Player").is_on_floor():
			self._wall_jump()
	
func _press_up():
	return Input.is_action_just_pressed("up")

func _wall_jump():
	self.find_parent("Player").wall_jump()

func _on_wall(body):
	if body.get_name() == "Tiles":
		self._wall_state = true

func _off_wall(body):
	if body.get_name() == "Tiles":
		self._wall_state = false

func _turn():
	if self.find_parent("Player").turn_state == true:
		get_node("Face Box").position.x =  abs(get_node("Face Box").position.x)
		get_node("Face Box").rotation_degrees =  90
	if self.find_parent("Player").turn_state == false:
		get_node("Face Box").position.x = -abs(get_node("Face Box").position.x)
		get_node("Face Box").rotation_degrees = -90