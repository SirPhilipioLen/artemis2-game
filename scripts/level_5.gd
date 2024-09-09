extends Node2D

@onready var pause_menu: PackedScene = preload("res://scenes/pause_menu.tscn")
var pause_menu_instance: Node = null

func _ready():
	# Instance the transition scene and play the fade-in animation
	var transition_scene = load("res://scenes/transition.tscn").instantiate()
	add_child(transition_scene)
	transition_scene.start_fade_in()
	$ParallaxBackground3/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label.visible = true
	pause_menu_instance = pause_menu.instantiate()
	
func _input(event):
	if event.is_action_pressed("pause"):
		show_pause_menu_screen()
	if event.is_action_pressed("ui_accept"):
		Loader.change_level("res://scenes/level_6.tscn")

#Attitude
func _process(delta):
	# Get the rocket's current rotation in degrees
	var rotation_degrees = $orion_open.rotation_degrees
	# Calculate attitude relative to upward (90 degrees when pointing up)
	var attitude_degrees = wrapf(-rotation_degrees + 90, 0, 360)
	$CanvasLayer/Control/Panel/Degrees.text = str(round(attitude_degrees)) + "°"

func show_pause_menu_screen():
	# Add the "Try Again" screen to the scene tree if it's not already added
	if not pause_menu_instance.is_inside_tree():
		add_child(pause_menu_instance)
	
	# Show the "Try Again" screen
	pause_menu_instance.show_pause_menu()
