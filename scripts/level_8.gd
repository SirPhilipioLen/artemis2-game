extends Node2D

@onready var pause_menu: PackedScene = preload("res://scenes/pause_menu.tscn")
var pause_menu_instance: Node = null
var sem_detached = false
@onready var detachable_child: Node2D = $orion_open/orion_capsule/sem_open
@onready var label1: Label = $ParallaxBackground3/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label
@onready var label2: Label = $ParallaxBackground3/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label2

@export var detach_speed: Vector2 = Vector2(0, 5000)  # Initial detachment speed in pixels per second
var detach_velocity: Vector2 = Vector2.ZERO  # Velocity to move the child after detachment

func _ready():
	# Instance the transition scene and play the fade-in animation
	var transition_scene = load("res://scenes/transition.tscn").instantiate()
	add_child(transition_scene)
	transition_scene.start_fade_in()
	pause_menu_instance = pause_menu.instantiate()
	label1.visible = true

func _input(event):
	if event.is_action_pressed("pause"):
		show_pause_menu_screen()
	if event.is_action_pressed("ui_accept") and sem_detached:
		Loader.change_level("res://scenes/level_9.tscn")
	# Trigger detachment when space is pressed
	if event.is_action_pressed("ui_accept") and not sem_detached:  # Replace with the correct action for space if needed
		detach_child_with_speed(detachable_child)

func _process(delta):
	# Move the detached child continuously if detached
	if sem_detached and detachable_child:
		# Update position by adding velocity times delta to simulate sliding
		detachable_child.position += detach_velocity * delta
		# Attitude
	var rotation_degrees = $orion_open.rotation_degrees
	# Calculate attitude relative to upward (90 degrees when pointing up)
	var attitude_degrees = wrapf(-rotation_degrees + 90, 0, 360)
	$CanvasLayer/Control/Panel/Degrees.text = str(round(attitude_degrees)) + "°"

func show_pause_menu_screen():
	# Add the pause menu screen to the scene tree if not already added
	if not pause_menu_instance.is_inside_tree():
		add_child(pause_menu_instance)

	# Show the pause menu
	pause_menu_instance.show_pause_menu()

func detach_child_with_speed(child_node: Node2D):
	label1.visible = false
	label2.visible = true
	sem_detached = true
	if child_node and child_node.is_inside_tree():
		# Save the child's global transform to keep its world position
		var global_transform = child_node.global_transform

		# Remove the child from its current parent
		remove_child(child_node)

		# Reparent the child to the root of the scene (or any other non-moving node)
		get_tree().root.add_child(child_node)

		# Apply the saved global transform to keep it in the same world position
		child_node.global_transform = global_transform

		# Set the detachment velocity for continuous movement
		detach_velocity = detach_speed
