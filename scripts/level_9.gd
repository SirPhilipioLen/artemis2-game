extends Node2D

@export var emptying_speed: float = 5
@export var deceleration_distance: float = 20.0  # Distance moved backwards
@export var oscillation_amplitude: float = 5.0  # Amplitude of oscillation
@export var oscillation_speed: float = 2.0  # Speed of oscillation
@onready var pause_menu: PackedScene = preload("res://scenes/pause_menu.tscn")
@export var try_again_scene: PackedScene = preload("res://scenes/try_again.tscn")
var pause_menu_instance: Node = null
var animation_finished = false
@onready var wind: AudioStreamPlayer = $wind
# Point lights on the capsule
@onready var light1: Light2D = $orion_capsule/PointLight2D
@onready var light2: Light2D = $orion_capsule/PointLight2D/PointLight2D2
@onready var light3: Light2D = $orion_capsule/PointLight2D/PointLight2D3
# Progress bar to show reentry progress
@onready var progress_bar: ProgressBar = $CanvasLayer/Control/ProgressBar3
# Initial and minimum light intensities
@export var initial_light_intensity: float = 60.0
@export var min_light_intensity: float = 0.0
@onready var label1: Label = $ParallaxBackground/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label
@onready var label2: Label = $ParallaxBackground/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label2
@onready var label3: Label = $ParallaxBackground/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label3

var shake_intensity: float = 0.5  # Initial intensity of the shaking effect
var shake_end_intensity: float = 0.5  # Intensity of shaking after parachute deployment
var decelerating = false
var oscillating = false
var oscillation_timer: float = 0.0
var progress_bar_complete = false
var start_scene = false
var try_again_instance: Node = null

func _ready():
	# Instance the transition scene and play the fade-in animation
	var transition_scene = load("res://scenes/transition.tscn").instantiate()
	add_child(transition_scene)
	transition_scene.start_fade_in()
	pause_menu_instance = pause_menu.instantiate()
	try_again_instance = try_again_scene.instantiate()
	progress_bar.value = progress_bar.max_value  # Set progress bar to full

	# Set initial light intensities
	light1.energy = initial_light_intensity
	light2.energy = initial_light_intensity
	light3.energy = initial_light_intensity
	wind.play()
	label1.visible = true

func _process(delta):
	# Empty the progress bar over time
	if start_scene:
		if progress_bar.value > 0:
			progress_bar.value -= emptying_speed * delta
			update_light_intensities()
		else:
			progress_bar_complete = true

		# Handle shaking or oscillation based on parachute deployment
	if !oscillating:
		shake_capsule(delta)
	else:
		if decelerating:
			apply_deceleration(delta)
		else:
			apply_oscillation(delta)
	# Get the rocket's current rotation in degrees
	var rotation_degrees = $orion_capsule.rotation_degrees
	# Calculate attitude relative to upward (90 degrees when pointing up)
	var attitude_degrees = wrapf(-rotation_degrees + 90, 0, 360)
	
	if attitude_degrees > 180:
		attitude_degrees -= 360
	$CanvasLayer/Control/Panel/Degrees.text = str(round(attitude_degrees)) + "°"
	
func _input(event):
	if event.is_action_pressed("pause"):
		show_pause_menu_screen()
	if event.is_action_pressed("ui_accept"):
		if !start_scene:
			label1.visible = false
			label2.visible = true
			start_scene = true
		elif progress_bar_complete:
			label2.visible = false
			label3.visible = true
			$orion_capsule/AnimationPlayer.play("parachutes")
			start_deceleration()
		else:
			show_try_again_screen()

	# Change scene after animation is finished
	if event.is_action_pressed("ui_accept") and animation_finished:
		Loader.change_level("res://scenes/level_10.tscn")

func _on_animation_player_animation_finished(anim_name):
	animation_finished = true

func show_pause_menu_screen():
	if not pause_menu_instance.is_inside_tree():
		add_child(pause_menu_instance)
	pause_menu_instance.show_pause_menu()

func shake_capsule(delta):
	# Continuously shake the capsule
	var shake_offset = Vector2(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)
	$orion_capsule.position += shake_offset

func start_deceleration():
	decelerating = true
	oscillating = false
	print("Started Deceleration")

func apply_deceleration(delta):
	# Move the capsule back to simulate deceleration
	if deceleration_distance > 0:
		var move_back = Vector2(-deceleration_distance * delta, 0)
		$orion_capsule.position += move_back
		deceleration_distance -= move_back.length()
		print("Decelerating: Remaining distance = ", deceleration_distance)
	else:
		decelerating = false
		start_oscillation()
		print("Deceleration complete. Starting oscillation")

func start_oscillation():
	oscillating = true
	oscillation_timer = 0.0
	print("Started Oscillation")

func apply_oscillation(delta):
	# Apply up and down oscillation to simulate gentle movement with parachutes
	oscillation_timer += delta * oscillation_speed
	var oscillation_offset = Vector2(
		sin(oscillation_timer) * oscillation_amplitude,
		sin(oscillation_timer) * oscillation_amplitude
	)
	$orion_capsule.position += oscillation_offset * delta
	print("Oscillating: Position = ", $orion_capsule.position)

func update_light_intensities():
	# Calculate the normalized progress
	var progress_normalized = progress_bar.value / progress_bar.max_value
	# Interpolate light intensities
	var light_intensity = lerp(initial_light_intensity, min_light_intensity, 1.0 - progress_normalized)
	light1.energy = light_intensity
	light2.energy = light_intensity
	light3.energy = light_intensity

func show_try_again_screen():
	# Add the "Try Again" screen to the scene tree if it's not already added
	if not try_again_instance.is_inside_tree():
		add_child(try_again_instance)
	
	# Show the "Try Again" screen
	try_again_instance.show_try_again()
