extends KinematicBody2D

#This script controls all movement of the player object.
#It's not recommended to use RigidBody2D for player objects because sometimes weird movement can happen,
#	especially when using tiles. The player object often bounces on the floor because of the jagged edges
#	of tiles. That's why it's better to write everything out.

export var gravity = 2000.0					#Use "export" to create script variables
export var x_acceleration = 20				#Acceleration of player. Use for slow startups.
export var x_decceleration = 20				#Decceleration of player. Use for sliding.
export var max_speed = 500					#Maximum speed of the player.
export var jump_speed = 600					#Alters jump height.
export var can_wall_jump = true				#Allows wall jumping.
export var phantom_jump_frames = 3			#Time you can still jump after walking off ground. 0 disables it.

var velocity = Vector2()					#Velocity of the player object to move next frame.
var _last_touched_ground = 0				#Number of frames ago ground was touched.
var turn_state = null						#false is left, true is right

#The below two functions are called by the engine. delta is the time elapsed between frames.

func _process(delta):						#_process is called by the engine once every "frame", default 60 fps.
	if _is_dead():
		_die_and_respawn(500, 0)

func _physics_process(delta):				#Unlike _process, Godot makes sure physics stuff is ready to be
	_change_turn_state()					#	used before calling _physics_process.
	_move_x()
	get_node("Face").check_and_wall_jump()	#Checks for wall-jump in script of node Face. Node names are important.
	_record_last_touched_ground()
	_move_y(delta)							#Previous functions edit the velocity of the player object.
	move_and_slide(velocity, Vector2(0, -1))#	move_and_slide actually moves the object.

#The functions below are called by _process and _physics_process.

func _change_turn_state():					#Makes the player face where they turned and moves in the correct
	if _press_left():						#	direction. This allows a more traditional "prioritize last
		self.turn_state = false				#	button press" approach to movement input.
	if _press_right():
		self.turn_state = true
	if _input_left() and not _input_right():
		self.turn_state = false
	if _input_right() and not _input_left():
		self.turn_state = true
	if _release_left() and turn_state == false:
		self.turn_state = null
	if _release_right() and turn_state == true:
		self.turn_state = null

func _is_dead():							#Death conditions can be set here.
	if get_slide_count() > 0:
		return self.get_position().y > 1010 or self.get_slide_collision(0).collider.collision_layer == 4
	return self.get_position().y > 1010

func _die_and_respawn(x, y):				#Currently resets scene.
	get_tree().reload_current_scene()

func _move_x():								#Controls x-axis movement.
	if self.turn_state == false:
		_accelerate_x(-x_acceleration)
	elif self.turn_state == true:
		_accelerate_x( x_acceleration)
	else:
		_deccelerate_x(x_decceleration)
	if self.is_on_wall():
		_stop_x()

func _move_y(delta):						#Controls y-axis movement.
	if self.is_on_floor() or self.is_on_ceiling():
		_stop_y()
	velocity.y += delta * gravity
	if _press_up() and (self.is_on_floor() or _can_phantom()):
		_jump(jump_speed)
		self._last_touched_ground = phantom_jump_frames + 1
	if _press_down() and self.is_on_floor() and self.get_slide_collision(0).collider.collision_layer == 8:
		self.position.y += 1

func wall_jump():							#Check if the settings allow for wall jumping, then jump under
	if can_wall_jump:						#	the right conditions:
		if not self.turn_state == null:
			_jump(jump_speed)
			if self.turn_state == true:
				self.velocity.x = -max_speed
				self.turn_state = false
			elif self.turn_state == false:
				self.velocity.x = max_speed
				self.turn_state = true

func _record_last_touched_ground():			#Records the last time the player touched the ground. This is
	if self.is_on_floor():					#	used for the phantom jump only and can be deleted if you do
		self._last_touched_ground = 0		#	not need that feature.
	else:
		self._last_touched_ground += 1

#The functions below are not called by _process or _physics_process, but the functions called in _physics_process
#	rely on these.

func _accelerate_x(rate):					#Accelerates x based on parameter value.
	if rate > 0 and velocity.x <= max_speed:
		velocity.x += rate
	elif rate < 0 and -max_speed <= velocity.x:
		velocity.x += rate

func _deccelerate_x(rate):					#Deccelerates x if speed is high enough. Otherwise, stops.
	if abs(velocity.x) < rate:
		_stop_x()
	if velocity.x > 0:
		velocity.x -= rate
	if velocity.x < 0:
		velocity.x += rate

func _jump(speed):							#Jumps at a rate.
	velocity.y = -speed

func _stop_x():								#Stops x motion.
	velocity.x = 0

func _stop_y():								#Stops y motion.
	velocity.y = 0

func _bounce_x():							#Reverses x velocity.
	velocity.x = -velocity.x

func _bounce_y():							#Reverses y velocity.
	velocity.y = -velocity.y

func _can_phantom():						#Checks if player can phantom jump.
	return self._last_touched_ground <= phantom_jump_frames

#Generic input functions that can go in any file.

func _input_left():							#Detects held input in specified direction.
	return Input.is_action_pressed("left")

func _input_right():
	return Input.is_action_pressed("right")

func _input_up():
	return Input.is_action_pressed("up")

func _input_down():
	Input.is_action_pressed("down")

func _press_left():							#Detects button press in specified direction.
	return Input.is_action_just_pressed("left")

func _press_right():
	return Input.is_action_just_pressed("right")

func _press_up():
	return Input.is_action_just_pressed("up")

func _press_down():
	return Input.is_action_just_pressed("down")

func _release_left():						#Detects released input in specified direction.
	return Input.is_action_just_released("left")

func _release_right():
	return Input.is_action_just_released("right")

func _release_up():
	return Input.is_action_just_released("up")

func _release_down():
	Input.is_action_just_released("down")