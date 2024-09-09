extends CharacterBody2D

@export var acceleration: float = 100.0
@export var max_speed: float = 500.0
@export var tilt_speed: float = 0.5  # Speed of tilting to the right
@export var exhaust_offset: Vector2 = Vector2(0, 20)

var rocket_launched = false
var rocket_off_screen = false
var sprite_height: float = 0.0

func _physics_process(delta):
	if rocket_launched:
		# Accelerate the rocket upward
		velocity.y -= acceleration * delta
		velocity.y = max(velocity.y, -max_speed)  # Cap speed to max_speed
		
		# Slightly tilt the rocket to the right
		rotation_degrees += tilt_speed * delta
		
		# Move the rocket
		move_and_slide()

		# Check if the rocket has moved off the screen
		if position.y + sprite_height < 0:
			rocket_off_screen = true

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if not rocket_launched:
			launch_rocket()
		elif rocket_off_screen:
			Loader.change_level("res://scenes/level_2.tscn")

func launch_rocket():
	rocket_launched = true

