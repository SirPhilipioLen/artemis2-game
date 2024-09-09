extends Node2D

@onready var pause_menu: PackedScene = preload("res://scenes/pause_menu.tscn")
@onready var ocean: AudioStreamPlayer = $ocean
@onready var splash: AudioStreamPlayer = $splash
var pause_menu_instance: Node = null
var time_elapsed = 0.0
var splash_played = false  # Track whether the splash sound has been played

func _ready():
	# Instance the transition scene and play the fade-in animation
	var transition_scene = load("res://scenes/transition.tscn").instantiate()
	add_child(transition_scene)
	transition_scene.start_fade_in()
	pause_menu_instance = pause_menu.instantiate()
	ocean.play()	

func _process(delta):
	# Increment the elapsed time
	time_elapsed += delta

	# Check if 11 seconds have passed and the splash sound hasn't been played yet
	if time_elapsed >= 10.8 and not splash_played:
		splash.play()
		splash_played = true  # Set flag to true to ensure the splash sound plays only once

func _input(event):
	if event.is_action_pressed("pause"):
		show_pause_menu_screen()
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func show_pause_menu_screen():
	# Add the "Try Again" screen to the scene tree if it's not already added
	if not pause_menu_instance.is_inside_tree():
		add_child(pause_menu_instance)
	
	# Show the "Try Again" screen
	pause_menu_instance.show_pause_menu()
