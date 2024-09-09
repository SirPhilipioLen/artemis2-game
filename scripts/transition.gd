extends CanvasLayer

@export var next_scene_path: String

# Function to start the fade-in transition at the beginning of a new scene
func start_fade_in():
	$AnimationPlayer.play("fade_in_transition")


