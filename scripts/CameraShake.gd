extends Camera2D

@export var randomStrength: float = 1.5
@export var shakeFade: float = 5.0

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func _ready():
	# Start with an initial shake strength
	shake_strength = randomStrength

func _process(delta):
	# Apply shake continuously
	shake_camera(delta)

func shake_camera(delta):
	# Move the camera by a random offset each frame
	self.offset = randomOffset()
	# Reduce shake strength gradually if needed
	# shake_strength = lerp(shake_strength, 0, shakeFade * delta)

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
