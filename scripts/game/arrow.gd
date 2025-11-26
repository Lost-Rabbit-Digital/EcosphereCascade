extends Sprite2D

@export var rotation_speed := 35.0
@export var max_rotation := 90.0
@export var water_drop_speed := 750.0
var rotation_direction := 1

# Add a new variable for the AudioStreamPlayer
var water_drop_sound: AudioStreamPlayer

func _ready():
	# Initialize the AudioStreamPlayer
	water_drop_sound = AudioStreamPlayer.new()
	add_child(water_drop_sound)
	
	# Load the sound file
	var sound = load("res://audio/water_drop.mp3")
	if sound:
		water_drop_sound.stream = sound
	else:
		print("Failed to load water_drop.mp3")

func _process(delta):
	rotation_degrees += rotation_speed * rotation_direction * delta
	
	if abs(rotation_degrees) > max_rotation:
		rotation_direction *= -1
	
	if Input.is_action_just_pressed("ui_select"):
		launch_water_drop()

func launch_water_drop():
	var water_drop = preload("res://WaterDrop.tscn").instantiate()
	water_drop.position = global_position
	water_drop.rotation = global_rotation
	var direction = Vector2.UP.rotated(global_rotation)
	water_drop.linear_velocity = direction * water_drop_speed
	
	get_tree().current_scene.add_child(water_drop)
	
	# Play the water drop sound
	if water_drop_sound and water_drop_sound.stream:
		water_drop_sound.play()
	else:
		print("Water drop sound not available")
