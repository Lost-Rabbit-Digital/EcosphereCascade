extends StaticBody2D

signal seed_grown

@export var max_growth_stage := 3
@export var scale_factor := 1.1
@export var tree_sprite: Texture

var growth_stage := 0
var transform_sound: AudioStreamPlayer

func _ready():
	add_to_group("seeds")
	print("Seed: Ready")
	
	# Initialize the AudioStreamPlayer
	transform_sound = AudioStreamPlayer.new()
	add_child(transform_sound)
	
	# Load the sound file
	var sound = load("res://audio/transform_braam.wav")
	if sound:
		transform_sound.stream = sound
		transform_sound.volume_db = -7
	else:
		print("Failed to load transform_braam.wav")

func grow():
	growth_stage += 1
	print("Seed: Growing, stage: ", growth_stage)
	if growth_stage >= max_growth_stage:
		turn_into_tree()
	else:
		scale *= scale_factor
		$CollisionShape2D.scale *= scale_factor
		$Sprite2D.scale *= scale_factor

func turn_into_tree():
	print("Seed: Turning into a tree")
	
	# Play the transformation sound
	if transform_sound and transform_sound.stream:
		transform_sound.play()
	else:
		print("Transformation sound not available")
	
	$Sprite2D.texture = tree_sprite
	$Sprite2D.scale = Vector2.ONE * 1.75
	remove_from_group("seeds")
	emit_signal("seed_grown", self)
