extends CharacterBody2D

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 25.0
@export var angular_velocity: float = 0.0  
@export var angular_drag: float = 25.0  

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

	#var screen_size = get_viewport_rect().size
	#if global_position.y < 0:
		#global_position.y = screen_size.y
	#elif global_position.y > screen_size.y:
		#global_position.y = 0
	#if global_position.x < 0:
		#global_position.x = screen_size.x
	#elif global_position.x > screen_size.x:
		#global_position.x = 0

var LeftBooster: CharacterBody2D 

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):  # "ui_accept" is often mapped to the spacebar by default
		detach_part()

func detach_part():
	if LeftBooster != null:
		# Detach the part from the rocket and reparent it to the main scene or root
		LeftBooster.get_parent().remove_child(LeftBooster)
		get_tree().root.add_child(LeftBooster)
		
		# Optionally, set the position of the detachable part to its current global position
		LeftBooster.global_position = LeftBooster.global_position

		
		# Now, it will fall due to gravity if it's a RigidBody2D or KinematicBody2D
