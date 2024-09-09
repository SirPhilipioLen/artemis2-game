extends Camera2D

@export var rocket: NodePath  # Path to the rocket node
@export var background: NodePath  # Path to the background node
@export var camera_margin_top: float = 50.0  # Margin from the top of the screen
@export var camera_margin_right: float = 50.0

var rocket_node: Node2D
var background_node: Sprite2D
var camera_following: bool = true

func _ready():
	# Cache the rocket and background nodes
	rocket_node = $"../sls"
	background_node = $"../ParallaxBackground/ParallaxLayer/Mg1997"

func _process(delta):
	if camera_following:
		# Update the camera's position to follow the rocket
		position.y = min(position.y, rocket_node.position.y - camera_margin_top)
		position.x = rocket_node.position.x

		# Check if the top of the background has reached the camera's margin
		var background_top_edge = background_node.position.y - background_node.texture.get_height() / 2
		if position.y <= background_top_edge:
			camera_following = false
			position.y = background_top_edge  # Stop the camera at the background's top edge
