extends CharacterBody2D

@export var acceleration: float = 20.0
@export var max_speed: float = 500.0
@export var h_speed: float = 0.005
@export var tilt_speed: float = 0.3  # Speed of tilting to the right
@export var thrust_increment: float = 10.0  # How much the thrust bar increases per second
@export var thrust_decrement: float = 5.0   # How much the thrust bar decreases per second
@onready var space_sound: AudioStreamPlayer = $"../ParallaxBackground2/ParallaxLayer/LabelMain/AudioStreamPlayer2"
@onready var looped_rocket_sound: AudioStreamPlayer = $Looped_Rocket_Sound
@onready var crickets: AudioStreamPlayer = $"../crickets"
@onready var wind: AudioStreamPlayer = $"../wind"
@export var fade_out_speed: float = 1.0  # Speed at which the volume decreases
@onready var liftoff_sound: AudioStreamPlayer = $SRBs
@onready var thrust_bar: ProgressBar = $"../CanvasLayer/Control/ProgressBar"
@onready var Label1: Label = $"../ParallaxBackground2/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label"
@onready var Label2: Label = $"../ParallaxBackground2/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label2"
@onready var Label3: Label = $"../ParallaxBackground2/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label3"
@onready var Label4: Label = $"../ParallaxBackground2/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label4"
@export var delay_before_liftoff: float = 1.0
@onready var pause_menu: PackedScene = preload("res://scenes/pause_menu.tscn")

var paused = false
var engines_on = false
var rocket_launched = false
var rocket_off_screen = false
var sprite_height: float = 0.0
var time_elapsed = 0.0
var pause_menu_instance: Node = null

func _ready():
	# Instance the transition scene and play the fade-in animation
	var transition_scene = load("res://scenes/transition.tscn").instantiate()
	add_child(transition_scene)
	transition_scene.start_fade_in()
	Label1.visible = true
	thrust_bar.value = 0  # Initialize the thrust bar at 0
	wind.play()
	crickets.play()
	pause_menu_instance = pause_menu.instantiate()

func _physics_process(delta):
	# Handle thrust bar adjustments based on input
	if Input.is_action_pressed("thrust"):
		if thrust_bar.value < thrust_bar.max_value:
			thrust_bar.value += thrust_increment * delta  # Increase thrust bar value

	if rocket_launched:
		# Calculate velocity based on thrust bar value
		time_elapsed += delta
		if time_elapsed >= delay_before_liftoff:
			var thrust_percentage = thrust_bar.value / thrust_bar.max_value
			velocity.y -= acceleration * thrust_percentage * delta
			velocity.y = max(velocity.y, -max_speed * thrust_percentage)  # Cap speed to max_speed based on thrust
			velocity.x += h_speed
			
			# Slightly tilt the rocket to the right
			rotation_degrees += tilt_speed * delta
			
			move_and_slide()

		# Check if the rocket has moved off the screen
		if position.y + sprite_height < 0:
			rocket_off_screen = true
			Label3.visible = false
			Label4.visible = true
		
		if looped_rocket_sound.volume_db > -80:
			looped_rocket_sound.volume_db -= fade_out_speed * delta
			
func _input(event):
	if event.is_action_pressed("pause"):
		show_pause_menu_screen()
	if event.is_action_pressed("ui_accept"):
		space_sound.play()
		Label2.visible = true
		Label1.visible = false
		if not engines_on and thrust_bar.value == thrust_bar.max_value:
			_engines_ignition()  # First press ignites engines
			engines_on = true
		elif engines_on and not rocket_launched:
			launch_rocket()  # Second press launches the rocket
		elif rocket_off_screen and rocket_launched:
			Loader.change_level("res://scenes/level_2.tscn")

func _engines_ignition():
	engines_on = true
	looped_rocket_sound.play()
	$"../sls/CoreStage/Engines/RS-25-Left".visible = true
	$"../sls/CoreStage/Engines/RS-25-Right".visible = true
	Label2.visible = false
	Label3.visible = true

func launch_rocket():
	if thrust_bar.value >= thrust_bar.max_value:
		$"../sls/CoreStage/LeftBooster/LeftBoosterExhaust".visible = true
		$"../sls/CoreStage/RightBooster/RightBoosterExhaust".visible = true
		rocket_launched = true  # Rocket launches only if the thrust bar is full
		Label2.visible = false
		#looped_rocket_sound.loop = false
		#if looped_rocket_sound.finished:
		liftoff_sound.play()
	else:
		rocket_launched = false  # Otherwise, set the velocity based on thrust bar value
		velocity.y = 0  # Ensure rocket doesn't move until thrust is maxed

#Attitude
func _process(delta):
	# Get the rocket's current rotation in degrees
	var rotation_degrees = $".".rotation_degrees
	# Calculate attitude relative to upward (90 degrees when pointing up)
	var attitude_degrees = wrapf(-rotation_degrees + 90, 0, 360)
	
	if attitude_degrees > 180:
		attitude_degrees -= 360
	$"../CanvasLayer/Control/Panel/Degrees".text = str(round(attitude_degrees)) + "°"
	
func show_pause_menu_screen():
	# Add the "Try Again" screen to the scene tree if it's not already added
	if not pause_menu_instance.is_inside_tree():
		add_child(pause_menu_instance)
	
	# Show the "Try Again" screen
	pause_menu_instance.show_pause_menu()
