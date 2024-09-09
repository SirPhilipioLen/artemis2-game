extends PointLight2D

@export var flicker_speed: float = 0.1
@export var min_energy: float = 5
@export var max_energy: float = 10

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func _process(delta):
	# Randomly adjust the energy value within the range to simulate flicker
	energy = rng.randf_range(min_energy, max_energy)
	# You can adjust the flicker speed using a timer or apply damping
