extends KinematicBody2D

#This script controls all movement of the player object.
#It's not recommended to use RigidBody2D for player objects because sometimes weird movement can happen,
#	especially when using tiles. The player object often bounces on the floor because of the jagged edges
#	of tiles. That's why it's better to write everything out.

export var gravity: float = 2000.0			#Use "export" to create script variables. Gravity is gravity.
export var x_acceleration: int = 30			#Acceleration of player. Use for slow startups.
export var x_decceleration: int = 30		#Decceleration of player. Use for sliding.
export var max_speed: float = 500.0			#Maximum speed of the player.
export var jump_speed: float = 600.0		#Alters jump height.
export var can_wall_jump: bool = true		#Allows wall jumping.
export var coyote_time: int = 3				#Time you can still jump after walking off ground. 0 disables it.

enum direction {LEFT, RIGHT, NONE}			#Enum for where player is buffering input.

var velocity = Vector2()					#Velocity of the player object to move next frame.
var last_touched_ground: int = 0			#Number of frames ago ground was touched.
var turn_state = direction.NONE				#What direction player should move.
var is_on_wall: bool = false				#Whether this node is on a wall.

#Below variable is created when scene is ready. It represents the collider "Face Box" on "Face".
onready var collider_node = get_node("Face/Face Box")

#The below two functions are called by the engine. delta is the time elapsed between frames.

func _process(_delta):						#_process is called by the engine once every "frame", default 60 fps.
	if is_dead():
		die_and_respawn()

func _physics_process(delta):				#Unlike _process, Godot makes sure physics stuff is ready to be used
	change_turn_state()						#	before calling _physics_process. Specifically, the code here is
	record_last_touched_ground()			#	always called every 1/60th of a second, regardless of framedrops.
	move(delta)								#Previous functions edit the velocity of the player object.
	var _i = move_and_slide(velocity, Vector2(0, -1))#	move_and_slide actually moves the object.
	#Use an underscore before variables to get rid of the unused warning. This also gets rid of
	#	the "unused function value" warning

#The functions below are called by _process and _physics_process.

func change_turn_state():					#Makes the player face where they turned and moves in the correct
	if press_left():						#	direction. This allows a more traditional "prioritize last
		turn_state = direction.LEFT			#	button press" approach to movement input.
	if press_right():
		turn_state = direction.RIGHT
	if input_left() and not input_right():
		turn_state = direction.LEFT
	if input_right() and not input_left():
		turn_state = direction.RIGHT
	if release_left() and turn_state == direction.LEFT:
		turn_state = direction.NONE
	if release_right() and turn_state == direction.RIGHT:
		turn_state = direction.NONE

func is_dead():								#Death conditions can be set here.
	if get_slide_count() > 0:
		return get_position().y > 1010 or get_slide_collision(0).collider.collision_layer == 4
	return get_position().y > 1010

func die_and_respawn():						#Currently resets scene.
	var _i = get_tree().reload_current_scene()
	#Use an underscore before variables to get rid of the unused warning. This also gets rid of
	#	the "unused function value" warning

func move(delta):							#Controls movement.
	stop_if_collided()
	velocity.y += delta * gravity
	if press_up() and (is_on_floor() or can_phantom()):
		jump(jump_speed)
		last_touched_ground = coyote_time + 1
	if press_down() and is_on_floor() and get_slide_collision(0).collider.collision_layer == 8:
		position.y += 1						#The allows ducking through platforms.
	match turn_state:
		direction.LEFT:
			accelerate_x(-x_acceleration)
		direction.RIGHT:
			accelerate_x( x_acceleration)
		direction.NONE:
			deccelerate_x(x_decceleration)
	turn_face_box()
	if is_on_wall == true:					#Checks if player tried to wall-jump and jumps if player can.
		if press_up() and not is_on_floor() and can_wall_jump:
			wall_jump()

func wall_jump():							#Performs a wall-jump.
	match turn_state:
		direction.RIGHT:
			velocity.x = -max_speed
			turn_state = direction.LEFT
			jump(jump_speed)
		direction.LEFT:
			velocity.x = max_speed
			turn_state = direction.RIGHT
			jump(jump_speed)

func record_last_touched_ground():			#Records the last time the player touched the ground. This is
	if is_on_floor():						#	used for the phantom jump only and can be deleted if you do
		last_touched_ground = 0				#	not need that feature.
	else:
		last_touched_ground += 1

#The functions below are not called by _process or _physics_process, but the functions called in _physics_process
#	rely on these.

func stop_if_collided():						#Stops movement if collided with object.
	if is_on_floor() or is_on_ceiling():
		stop_y()
	if is_on_wall():
		stop_x()

func turn_face_box():						#Moves the "Face Box" node to be on the face, even after turning.
	if turn_state == direction.RIGHT:
		collider_node.position.x =  abs(collider_node.position.x)
		collider_node.rotation_degrees =  90
	if turn_state == direction.LEFT:
		collider_node.position.x = -abs(collider_node.position.x)
		collider_node.rotation_degrees = -90

func _on_wall(body):						#Called when a wall enters this object. See Node tab of Face.
	if body.get_name() == "Tiles":
		is_on_wall = true					#There's a method with this name, but this is a property, so no overwrite.

func _off_wall(body):						#Called when a wall exits this object. See Node tab of Face.
	if body.get_name() == "Tiles":
		is_on_wall = false

func accelerate_x(rate):					#Accelerates x based on parameter value.
	if rate > 0 and velocity.x <= max_speed:
		velocity.x += rate
	elif rate < 0 and -max_speed <= velocity.x:
		velocity.x += rate

func deccelerate_x(rate):					#Deccelerates x if speed is high enough. Otherwise, stops.
	if abs(velocity.x) < rate:
		stop_x()
	if velocity.x > 0:
		velocity.x -= rate
	if velocity.x < 0:
		velocity.x += rate

func jump(speed):							#Jumps at a rate.
	velocity.y = -speed

func stop_x():								#Stops x motion.
	velocity.x = 0

func stop_y():								#Stops y motion.
	velocity.y = 0

func bounce_x():							#Reverses x velocity.
	velocity.x = -velocity.x

func bounce_y():							#Reverses y velocity.
	velocity.y = -velocity.y

func can_phantom():							#Checks if player can phantom jump.
	return last_touched_ground <= coyote_time

#Generic input functions that can go in any file.

func input_left():							#Detects held input in specified direction.
	return Input.is_action_pressed("left")

func input_right():
	return Input.is_action_pressed("right")

func input_up():
	return Input.is_action_pressed("up")

func input_down():
	return Input.is_action_pressed("down")

func press_left():							#Detects button press in specified direction.
	return Input.is_action_just_pressed("left")

func press_right():
	return Input.is_action_just_pressed("right")

func press_up():
	return Input.is_action_just_pressed("up")

func press_down():
	return Input.is_action_just_pressed("down")

func release_left():						#Detects released input in specified direction.
	return Input.is_action_just_released("left")

func release_right():
	return Input.is_action_just_released("right")

func release_up():
	return Input.is_action_just_released("up")

func release_down():
	return Input.is_action_just_released("down")
