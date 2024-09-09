extends CharacterBody2D

@export var detachment_speed: float = 200.0
@export var fall_speed: float = 300.0
@export var rotation_speed: float = 20.0

var boosters_detached = false
var covers_and_tower_detached = false

func _physics_process(delta):
	if boosters_detached:
		var booster_left = $CoreStage/LeftBooster
		var booster_right = $CoreStage/RightBooster

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
		else:
			print("One or both boosters are missing!")

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
		else:
			print("One or more of the covers or the tower are missing!")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if not boosters_detached:
			detach_boosters()
		elif boosters_detached and not covers_and_tower_detached:
			detach_covers_and_tower()
		elif boosters_detached and covers_and_tower_detached:
			Loader.change_level("res://scenes/level_3.tscn")

func detach_boosters():
	boosters_detached = true

func detach_covers_and_tower():
	covers_and_tower_detached = true
