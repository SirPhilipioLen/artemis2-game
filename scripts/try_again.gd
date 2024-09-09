extends CanvasLayer

var time_elapsed = 0.0

func show_try_again():
	# Show the screen and pause the game
	visible = true
	_process(1)

func retry():
	get_tree().paused = false
	visible = false
	
func _process(delta):
	time_elapsed += delta
	if time_elapsed > 3.0:
		get_tree().paused = true

func _on_retry_pressed():
	retry()
	get_tree().reload_current_scene()  # Reload the current scene

func _on_main_menu_pressed():
	retry()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
func _on_quit_pressed():
	get_tree().quit()

