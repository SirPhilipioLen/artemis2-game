extends Node2D

var velocity = 0
var force = 0
var height = 0
var target_height = 0
var time_elapsed = 0.0

@onready var collision = $Area2D/CollisionShape2D

func _process(delta):
	time_elapsed += delta

func water_update(spring_constant, dampening):
	if time_elapsed >= 11:
		height = position.y 
		var x = height - target_height
		var loss = -dampening * velocity
		force =- spring_constant * x + loss
		velocity += force
		position.y += velocity
		pass

func initialize(x_position):
	height = position.y
	target_height = position.y
	velocity = 0
	position.x = x_position

