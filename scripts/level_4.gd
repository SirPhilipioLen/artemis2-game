extends CharacterBody2D

@export var icps_exhaust: Node  # Path to the right core engine exhaust node
@export var sem_exhaust: Node  # Path to the second stage exhaust node
@export var delay_before_engine_off: float = 3.0  # Seconds before turning off the engines
@export var detachment_speed: float = 250.0
@export var fall_speed: float = 300.0
@export var rotation_speed: float = 0.5
@export var sem_acceleration: float = 1.0
@onready var orion_loop: AudioStreamPlayer = $orion_loop
@onready var pause_menu: PackedScene = preload("res://scenes/pause_menu.tscn")
@export var try_again_scene: PackedScene = preload("res://scenes/try_again.tscn")
@export var fill_speed_bar1: float = 1 # Fill speed for the first bar
@export var fill_speed_bar2: float = 1 # Fill speed for the second, longer bar
@onready var progress_bar1 = $"../CanvasLayer/Control/ProgressBar2"
@onready var progress_bar2 = $"../CanvasLayer/Control/ProgressBar3"
@onready var label1: Label = $"../ParallaxBackground2/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label"
@onready var label2: Label = $"../ParallaxBackground2/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label2"

var icps_detached = false
var engine_on = true
var sem_ignited = false
var sem_shutdown = false
var time_elapsed = 0.0
var input_allowed = false
var pause_menu_instance: Node = null
var is_filling = false
var burn_complete = false
var try_again_instance: Node = null

func _ready():
	# Instance the transition scene and play the fade-in animation
	var transition_scene = load("res://scenes/transition.tscn").instantiate()
	add_child(transition_scene)
	transition_scene.start_fade_in()
	# Get exhaust nodes
	sem_exhaust = $sem_open/sem_engines/sem_engine
	# Set initial visibility
	sem_exhaust.visible = false
	pause_menu_instance = pause_menu.instantiate()
	try_again_instance = try_again_scene.instantiate()
	progress_bar1.value = 0
	progress_bar2.value = 0
	label1.visible = true

func _process(delta):
	# Count time to turn off engines after the delay
	if engine_on:
		time_elapsed += delta
		if time_elapsed >= delay_before_engine_off:
			input_allowed = true
			
	# Get the rocket's current rotation in degrees
	var rotation_degrees = $".".rotation_degrees
	# Calculate attitude relative to upward (90 degrees when pointing up)
	var attitude_degrees = wrapf(-rotation_degrees + 90, 0, 360)
	
	if attitude_degrees > 180:
		attitude_degrees -= 360
		
	$"../CanvasLayer/Control/Panel/Degrees".text = str(round(attitude_degrees)) + "°"

	if is_filling:
		progress_bar1.value += fill_speed_bar1 * delta
		progress_bar2.value += fill_speed_bar2 * delta
		
		# Check if the second bar is full
		if progress_bar2.value >= progress_bar2.max_value:
			show_try_again_screen()
			is_filling = false  # Stop filling when game over
		elif progress_bar1.value >= 9 and progress_bar2.value < 11 and sem_shutdown:
			_burn_complete()
			print("calling burn_complete function")

func _physics_process(delta):
	if icps_detached:
		var icps = $Icps
		if icps:
			# Move core away from second stage
			icps.position.y += detachment_speed * sem_acceleration * delta
			# Rotate the core
			icps.rotation_degrees -= rotation_speed * delta

func _input(event):
	if event.is_action_pressed("pause"):
		show_pause_menu_screen()
	if input_allowed and event.is_action_pressed("ui_accept"):
		if event.is_action_pressed("ui_accept"):
			if not icps_detached:
				detach_core()
			elif icps_detached and not sem_ignited and not burn_complete:
				_ignite_second_stage()
			elif icps_detached and not sem_shutdown and sem_ignited and not burn_complete:
				_orion_shutdown()
			elif burn_complete and not sem_ignited:
				Loader.change_level("res://scenes/level_5.tscn")

func detach_core():
	icps_detached = true

func _ignite_second_stage():
	# Ignite the second stage (make exhaust visible)
	sem_ignited = true
	sem_exhaust.visible = true
	sem_acceleration = 10.0
	orion_loop.play()
	$"../CanvasLayer/Control/ProgressBar".value = 100
	is_filling = true

func _orion_shutdown():
	sem_shutdown = true
	orion_loop.stop()
	sem_ignited = false
	sem_exhaust.visible = false
	$"../CanvasLayer/Control/ProgressBar".value = 0
	is_filling = false
	
func _burn_complete():
	sem_ignited = false
	burn_complete = true
	$"../ParallaxBackground2/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label".visible = false
	$"../ParallaxBackground2/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label2".visible = true
	is_filling = false
	sem_exhaust.visible = false
	_orion_shutdown()
	label1.visible = false
	label2.visible = true

func show_pause_menu_screen():
	# Add the "Try Again" screen to the scene tree if it's not already added
	if not pause_menu_instance.is_inside_tree():
		add_child(pause_menu_instance)
	
	# Show the "Try Again" screen
	pause_menu_instance.show_pause_menu()

func show_try_again_screen():
	# Add the "Try Again" screen to the scene tree if it's not already added
	if not try_again_instance.is_inside_tree():
		add_child(try_again_instance)
	
	# Show the "Try Again" screen
	try_again_instance.show_try_again()
