extends RigidBody2D

var water_impact_sound: AudioStreamPlayer
var lifetime_timer: Timer
var collision_count: int = 0
var max_pitch_scale: float = 3.0  # Maximum pitch scale
var pitch_increment: float = 0.1  # How much to increase pitch per collision

func _ready():
	print("WaterDrop: Ready")
	$Area2D.body_entered.connect(_on_body_entered)
	add_to_group("water_drops")
	
	# Initialize the AudioStreamPlayer
	water_impact_sound = AudioStreamPlayer.new()
	add_child(water_impact_sound)
	
	# Load the sound file
	var sound = load("res://audio/Impact Tom 002.wav")
	if sound:
		water_impact_sound.stream = sound
		water_impact_sound.volume_db = -14
	else:
		print("Failed to load water_impact.mp3")
	
	# Create and start the lifetime timer
	lifetime_timer = Timer.new()
	add_child(lifetime_timer)
	lifetime_timer.wait_time = 15.0  # 15 seconds
	lifetime_timer.one_shot = true  # The timer will stop after one timeout
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	lifetime_timer.start()

func _on_body_entered(body):
	# Increase collision count and adjust pitch
	collision_count += 1
	var new_pitch = 1.0 + (collision_count * pitch_increment)
	new_pitch = min(new_pitch, max_pitch_scale)
	
	# Play the water impact sound with adjusted pitch
	if water_impact_sound and water_impact_sound.stream:
		water_impact_sound.pitch_scale = new_pitch
		water_impact_sound.play()
	else:
		print("Water impact sound not available")
	
	# Existing logic for seed growth
	if body.is_in_group("seeds"):
		body.grow()
			
	# Existing logic for rock erosion
	if body.is_in_group("rocks"):
		body.erode()
		
func _on_lifetime_timeout():
	# This function is called when the lifetime timer runs out
	queue_free()  # Remove the water drop from the scene
