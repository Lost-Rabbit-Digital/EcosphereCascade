extends StaticBody2D

signal eroded(rock)

func _ready():
	# Set up collision shape and sprite as needed
	add_to_group("rocks")

func erode():
	emit_signal("eroded", self)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("water_drops"):
		erode()
