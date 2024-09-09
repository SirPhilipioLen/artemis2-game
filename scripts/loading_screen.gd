extends Control

@export var loading_bar : ProgressBar
@export var percentage_label : Label

var scene_path: String
var progress : Array

var update : float = 0.0

func _ready():
	scene_path = Loader.scene_path
	ResourceLoader.load_threaded_request(scene_path)
	if scene_path == "res://scenes/level_1.tscn":
		$LoadingImage1.visible = true
	elif scene_path == "res://scenes/level_2.tscn":
		$LoadingImage2.visible = true
	elif scene_path == "res://scenes/level_3.tscn":
		$LoadingImage3.visible = true
	elif scene_path == "res://scenes/level_4.tscn":
		$LoadingImage4.visible = true
	elif scene_path == "res://scenes/level_5.tscn":
		$LoadingImage5.visible = true
	elif scene_path == "res://scenes/level_6.tscn":
		$LoadingImage6.visible = true
	elif scene_path == "res://scenes/level_7.tscn":
		$LoadingImage7.visible = true
	elif scene_path == "res://scenes/level_8.tscn":
		$LoadingImage8.visible = true
	elif scene_path == "res://scenes/level_9.tscn":
		$LoadingImage9.visible = true
	elif scene_path == "res://scenes/level_10.tscn":
		$LoadingImage10.visible = true

func _process(delta):
	ResourceLoader.load_threaded_get_status(scene_path, progress)
	
	if progress[0] > update:
		update = progress[0]
		
	if loading_bar.value >= 1.0:
		if update >= 1.0:
			get_tree().change_scene_to_packed(
				ResourceLoader.load_threaded_get(scene_path)
			)
			
	if loading_bar.value < update:
		loading_bar.value = lerp(loading_bar.value, update, delta)
	loading_bar.value += delta * 0.2 * \
		(0.5 if update >= 1.0 else clamp(0.9 - loading_bar.value, 0.0, 1.0))
	
	percentage_label.text = str(int(loading_bar.value * 100.0)) + " %"





