extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_game_pressed():
	Loader.change_level("res://scenes/level_1.tscn")

func _on_level_select_pressed():
	$"Control/Main Menu List".visible = false
	$"Control/Level Select List".visible = true
	
func _on_level_1_pressed():
	Loader.change_level("res://scenes/level_1.tscn")
func _on_level_2_pressed():
	Loader.change_level("res://scenes/level_2.tscn")
func _on_level_3_pressed():
	Loader.change_level("res://scenes/level_3.tscn")
func _on_level_4_pressed():
	Loader.change_level("res://scenes/level_4.tscn")
func _on_level_5_pressed():
	Loader.change_level("res://scenes/level_5.tscn")
func _on_level_6_pressed():
	Loader.change_level("res://scenes/level_6.tscn")
func _on_level_7_pressed():
	Loader.change_level("res://scenes/level_7.tscn")
func _on_level_8_pressed():
	Loader.change_level("res://scenes/level_8.tscn")
func _on_level_9_pressed():
	Loader.change_level("res://scenes/level_9.tscn")
func _on_level_10_pressed():
	Loader.change_level("res://scenes/level_10.tscn")

func _on_button_pressed():
	$"Control/Main Menu List".visible = true
	$"Control/Level Select List".visible = false

func _on_quit_pressed():
	get_tree().quit()
