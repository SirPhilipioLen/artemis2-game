extends CharacterBody2D

@export var detachment_speed: float = 200.0
@export var fall_speed: float = 300.0
@export var rotation_speed: float = 20.0
@onready var rocket_sound: AudioStreamPlayer = $"../AudioStreamPlayer"
@export var srb_duration: float = 5.0
@onready var srb_progress1: ProgressBar = $"../ParallaxBackground/ParallaxLayer/CanvasLayer/Control/ProgressBar"
@onready var srb_progress2: ProgressBar = $"../ParallaxBackground/ParallaxLayer/CanvasLayer/Control/ProgressBar2"
@export var time_elapsed: float = 0.0
@onready var booster_left = $CoreStage/LeftBooster
@onready var booster_right = $CoreStage/RightBooster
@export var try_again_scene: PackedScene = preload("res://scenes/try_again.tscn")
@onready var pause_menu: PackedScene = preload("res://scenes/pause_menu.tscn")
@onready var label1: Label = $"../ParallaxBackground/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label"
@onready var label2: Label = $"../ParallaxBackground/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label2"
@onready var label3: Label = $"../ParallaxBackground/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label3"
@onready var label4: Label = $"../ParallaxBackground/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label4"

func _ready():
	# Instance the transition scene and play the fade-in animation
	var transition_scene = load("res://scenes/transition.tscn").instantiate()
	add_child(transition_scene)
	transition_scene.start_fade_in()
	$"../ParallaxBackground/ParallaxLayer/LabelMain/MarginContainer/MarginContainer/VBoxContainer/Label".visible = true
	rocket_sound.play()
	try_again_instance = try_again_scene.instantiate()
	pause_menu_instance = pause_menu.instantiate()
	label1.visible = true

var boosters_detached = false
var boosters_detached_early = false
var covers_and_tower_detached = false
var try_again_instance: Node = null
var pause_menu_instance: Node = null
var start_scene = false

func _physics_process(delta):
	if boosters_detached:
		if booster_left and booster_right:
			# Move boosters away from the rocket
			booster_left.position.x -= detachment_speed * delta
			booster_right.position.x += detachment_speed * delta
		   
			# Make boosters fall down
			booster_left.position.y += fall_speed * delta
			booster_right.position.y += fall_speed * delta

			# Rotate the boosters
			booster_left.rotation_degrees -= rotation_speed * delta
			booster_right.rotation_degrees += rotation_speed * delta

	if boosters_detached_early:
		if booster_left and booster_right:
		# Move boosters away from the rocket
			booster_left.position.x -= detachment_speed * delta
			booster_right.position.x += detachment_speed * delta
		   
			# Make boosters fall down
			booster_left.position.y -= 500 * delta
			booster_right.position.y -= 500 * delta

			# Rotate the boosters
			booster_left.rotation_degrees -= rotation_speed * delta
			booster_right.rotation_degrees += rotation_speed * delta
			
	if covers_and_tower_detached:
		var cover1 = $orion_sem/Cover1
		var cover2 = $orion_sem/Cover2New
		var tower = $orion_sem/EscapeTower

		if cover1 and cover2 and tower:
			# Move covers and tower away from the rocket
			cover1.position.x -= detachment_speed * delta * 30
			cover2.position.x += detachment_speed * delta * 30
			tower.position.y -= detachment_speed * delta * 50 # Tower moves upwards
			tower.position.x += detachment_speed * delta * 20
			
			# Make covers fall down
			cover1.position.y += fall_speed * delta * 50
			cover2.position.y += fall_speed * delta * 50

			# Rotate the covers and tower
			cover1.rotation_degrees -= rotation_speed * delta * 20
			cover2.rotation_degrees += rotation_speed * delta * 20
			tower.rotation_degrees += rotation_speed * delta * 10

func _input(event):
	if event.is_action_pressed("pause"):
		show_pause_menu_screen()
	if event.is_action_pressed("ui_accept"):
		if !start_scene:
			label1.visible = false
			label2.visible = true
			start_scene = true
		elif start_scene and not boosters_detached and srb_progress1.value > 2 and srb_progress2.value > 2:
			detach_boosters_early()
			show_try_again_screen()
		elif not boosters_detached:
			detach_boosters()
		elif boosters_detached and not covers_and_tower_detached:
			detach_covers_and_tower()
		elif boosters_detached and covers_and_tower_detached:
			Loader.change_level("res://scenes/level_3.tscn")

func detach_boosters():
	boosters_detached = true
	label2.visible = false
	label3.visible = true
	
func detach_boosters_early():
	boosters_detached_early = true

func detach_covers_and_tower():
	covers_and_tower_detached = true
	label3.visible = false
	label4.visible = true

#Attitude
func _process(delta):
	# Get the rocket's current rotation in degrees
	var rotation_degrees = $".".rotation_degrees
	# Calculate attitude relative to upward (90 degrees when pointing up)
	var attitude_degrees = wrapf(-rotation_degrees + 90, 0, 360)
	
	if attitude_degrees > 180:
		attitude_degrees -= 360
		
	$"../CanvasLayer/Control/Panel/Degrees".text = str(round(attitude_degrees)) + "°"
	srb_progress1.value -= delta
	srb_progress2.value -= delta

func show_try_again_screen():
	# Add the "Try Again" screen to the scene tree if it's not already added
	if not try_again_instance.is_inside_tree():
		add_child(try_again_instance)
	
	# Show the "Try Again" screen
	try_again_instance.show_try_again()

func show_pause_menu_screen():
	# Add the "Try Again" screen to the scene tree if it's not already added
	if not pause_menu_instance.is_inside_tree():
		add_child(pause_menu_instance)
	
	# Show the "Try Again" screen
	pause_menu_instance.show_pause_menu()
