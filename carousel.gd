extends Node2D 

@export var rotation_speed = 1.0  # Adjust as needed

func _process(delta):
	rotation += rotation_speed * delta
