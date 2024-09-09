extends CharacterBody2D

@export var engineLeft_exhaust: Node  # Path to the left core engine exhaust node
@export var engineRight_exhaust: Node  # Path to the right core engine exhaust node
@export var second_stage_exhaust: Node  # Path to the second stage exhaust node
@export var delay_before_engine_off: float = 3.0  # Seconds before turning off the engines
@export var detachment_speed: float = 100.0
@export var fall_speed: float = 300.0
@export var rotation_speed: float = 1
@export var icps_acceleration: float = 1.0
@onready var pause_menu: PackedScene = preload("res://scenes/pause_menu.tscn")
@export var try_again_scene: PackedScene = preload("res://scenes/try_again.tscn")
@export var fill_speed_bar1: float = 1 # Fill speed for the first bar
@export var fill_speed_bar2: float = 1 # Fill speed for the second, longer bar
@onready var progress_bar1 = $"../CanvasLayer/Control/ProgressBar2"
@onready var progress_bar2 = $"../CanvasLayer/Control/ProgressBar3"
@onready var label1: Label = $"../ParallaxBackground3/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label"
@onready var label2: Label = $"../ParallaxBackground3/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label2"
@onready var label3: Label = $"../ParallaxBackground3/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label3"
@onready var looped_rocket_sound: AudioStreamPlayer = $"../Looped_Rocket_Sound"
@onready var icps_sound: AudioStreamPlayer = $"../orion_loop"

var core_detached = false
var engines_on = true
var second_stage_ignited = false
var second_stage_shutdown = false
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
	engineLeft_exhaust = $"CoreStage/Engines/RS-25-Left"
	engineRight_exhaust = $"CoreStage/Engines/RS-25-Right"
	second_stage_exhaust = $orion_sem/Icps/LeftBoosterExhaust
	# Set initial visibility
	engineLeft_exhaust.visible = true
	engineRight_exhaust.visible = true
	second_stage_exhaust.visible = false
	pause_menu_instance = pause_menu.instantiate()
	try_again_instance = try_again_scene.instantiate()
	# Initialize the progress bars
	progress_bar1.value = 0
	progress_bar2.value = 0
	label1.visible = true
	looped_rocket_sound.play()

func _process(delta):
	# Count time to turn off engines after the delay
	if engines_on:
		time_elapsed += delta
		if time_elapsed >= delay_before_engine_off:
			_turn_off_engines()
			input_allowed = true
	# Get the rocket's current rotation in degrees
	var rotation_degrees = $".".rotation_degrees
	# Calculate attitude relative to upward (90 degrees when pointing up)
	var attitude_degrees = wrapf(-rotation_degrees + 90, 0, 360)
	
	if attitude_degrees > 180:
		attitude_degrees -= 360
		
	$"../CanvasLayer/Control/Panel/Degrees".text = str(round(attitude_degrees)) + "°"
	# Handle the filling logic
	if is_filling:
		progress_bar1.value += fill_speed_bar1 * delta
		progress_bar2.value += fill_speed_bar2 * delta
		
		# Check if the second bar is full
		if progress_bar2.value >= progress_bar2.max_value:
			show_try_again_screen()
			is_filling = false  # Stop filling when game over
		elif progress_bar1.value >= 9 and progress_bar2.value < 11 and second_stage_shutdown:
			_burn_complete()
			print("calling burn complete function")
			
func _physics_process(delta):
	if core_detached:
		var core = $CoreStage

		if core:
			# Move core away from second stage
			core.position.y += detachment_speed * icps_acceleration * delta
			# Rotate the core
			core.rotation_degrees -= rotation_speed * delta
		else:
			print("Core is already detached")

func _input(event):
	if event.is_action_pressed("pause"):
		show_pause_menu_screen()
	if input_allowed and event.is_action_pressed("ui_accept"):
		if not core_detached:
			detach_core()
		elif core_detached and not second_stage_ignited and not burn_complete:
			_ignite_second_stage()
		elif core_detached and not second_stage_shutdown and second_stage_ignited and not burn_complete:
			_shutdown_second_stage()
		elif burn_complete and not second_stage_ignited:
			Loader.change_level("res://scenes/level_4.tscn")

func _turn_off_engines():
	# Turn off the engines (make exhaust invisible)
	engines_on = false
	engineLeft_exhaust.visible = false
	engineRight_exhaust.visible = false
	$"../CanvasLayer/Control/ProgressBar".value = 0
	looped_rocket_sound.stop()

func detach_core():
	core_detached = true
	label1.visible = false
	label2.visible = true

func _ignite_second_stage():
	# Ignite the second stage (make exhaust visible)
	second_stage_ignited = true
	second_stage_exhaust.visible = true
	icps_acceleration = 5.0
	is_filling = true
	icps_sound.play()
	
func _shutdown_second_stage():
	second_stage_ignited = false
	second_stage_shutdown = true
	second_stage_exhaust.visible = false
	is_filling = false
	icps_sound.stop()
	
func _burn_complete():
	second_stage_ignited = false
	burn_complete = true
	$"../ParallaxBackground3/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label".visible = false
	$"../ParallaxBackground3/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label2".visible = true
	is_filling = false
	second_stage_exhaust.visible = false
	label2.visible = false
	label3.visible = true
	icps_sound.stop()
	
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
