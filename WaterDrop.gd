extends RigidBody2D

var water_impact_sound: AudioStreamPlayer
var lifetime_timer: Timer

func _ready():
	print("WaterDrop: Ready")
	$Area2D.body_entered.connect(_on_body_entered)
	
	# Initialize the AudioStreamPlayer
	water_impact_sound = AudioStreamPlayer.new()
	add_child(water_impact_sound)
	
	# Load the sound file
	var sound = load("res://audio/water_impact.mp3")
	if sound:
		water_impact_sound.stream = sound
		water_impact_sound.volume_db = -14
	else:
		print("Failed to load water_impact.mp3")
	
	# Create and start the lifetime timer
	lifetime_timer = Timer.new()
	add_child(lifetime_timer)
	lifetime_timer.wait_time = 10.0  # 10 seconds
	lifetime_timer.one_shot = true  # The timer will stop after one timeout
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	lifetime_timer.start()

func _on_body_entered(body):
	# Play the water impact sound
	if water_impact_sound and water_impact_sound.stream:
		water_impact_sound.play()
	else:
		print("Water impact sound not available")
	
	# Existing logic for seed growth
	if body.is_in_group("seeds"):
		body.grow()

func _on_lifetime_timeout():
	# This function is called when the lifetime timer runs out
	queue_free()  # Remove the water drop from the scene
