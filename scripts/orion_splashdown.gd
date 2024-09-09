extends CharacterBody2D

@export var gravity: float = 35.0
@export var max_fall_speed: float = 100.0
@export var rotation_amplitude: float = 10.0  # Degrees to oscillate left and right
@export var rotation_speed: float = 2.0  # Speed of oscillation
@export var deceleration: float = 2000.0  # How quickly the capsule slows down
@export var sink_distance: float = 10.0  # How deep the capsule "sinks" in the water
@export var bounce_amplitude: float = 10.0  # Bounce height
@export var bounce_speed: float = 1.0  # Speed of bouncing
@export var delay_before_floating: float = 11  # Delay before starting to float

var rotation_angle = 0.0
var is_in_water = false
var bounce_offset = 0.0
var initial_y_position = 0.0
var time_in_air = 0.0  # Time spent falling

func _ready():
	# Initialize the rotation angle and position
	rotation_angle = 0.0
	initial_y_position = position.y
	bounce_offset = 0.0
	is_in_water = false
	time_in_air = 0.0  # Reset timer

func _physics_process(delta):
	time_in_air += delta
	
	# Start floating and decelerating after the specified delay
	if time_in_air >= delay_before_floating:
		is_in_water = true
	
	if is_in_water:
		# Decelerate horizontally and vertically, and simulate a bouncing effect
		velocity.x = lerp(velocity.x, 0.0, deceleration * delta)
		velocity.y = lerp(velocity.y, 0.0, deceleration * delta)
		rotation_speed = 0.5
		# Simulate floating with a sine wave bounce
		position.y = initial_y_position + sink_distance * sin(bounce_offset)
		bounce_offset += bounce_speed * delta
		$Daco4226653.visible = false
	else:
		# Apply gravity and movement
		velocity.y += gravity * delta
		velocity.y = clamp(velocity.y, -max_fall_speed, max_fall_speed)
		move_and_slide()

		# Update initial position for the next bounce when not in water
		initial_y_position = position.y

	# Update rotation angle based on a sine wave to simulate wind effect
	rotation_angle += rotation_speed * delta
	rotation_degrees = rotation_amplitude * sin(rotation_angle)
