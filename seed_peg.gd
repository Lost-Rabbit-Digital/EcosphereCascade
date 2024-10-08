extends StaticBody2D

signal seed_grown

var growth_stage = 0

func grow():
	growth_stage += 1
	if growth_stage == 3:
		turn_into_tree()
	else:
		scale *= 1.2

func turn_into_tree():
	emit_signal("seed_grown", self)
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("seeds")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
