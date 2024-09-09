extends CharacterBody2D

@export var acceleration := 5.0
@export var max_speed := 250.0
@export var rotation_speed := 35.0
@export var angular_velocity: float = 0.0  
@export var angular_drag: float = 30.0  

func _physics_process(delta):
	var input_vector := Vector2(0, Input.get_axis("move_forward", "move_backward"))
	
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("rotate_right"):
		angular_velocity += rotation_speed * delta
	if Input.is_action_pressed("rotate_left"):
		angular_velocity -= rotation_speed * delta
	#velocity = Vector2(90, -90)
	
	if not Input.is_action_pressed("rotate_right") and not Input.is_action_pressed("rotate_left"):
		angular_velocity = move_toward(angular_velocity, 0, angular_drag * delta)
		
	rotate(deg_to_rad(angular_velocity) * delta)
	
	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 0.5)

	move_and_slide()

	var screen_size = get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
