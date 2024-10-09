extends Node2D

var seed_pegs = []
var rocks = []
var vertical_rocks = []
var background_music: AudioStreamPlayer2D
var win_sound: AudioStreamPlayer2D
var combo_sound: AudioStreamPlayer2D
var crossbow: Sprite2D
var trajectory_line: Line2D
var water_drop_scene = preload("res://WaterDrop.tscn")

var total_seed_pegs = seed_pegs.size()
var background_sprite = Sprite2D.new()
var grown_trees = 0
var grid_size = 100
var grid_width = 19  # 1920 / grid_size
var grid_height = 10  # 1080 / grid_size
var occupied_cells = []

var polluted_background = load("res://gfx/industry_bg_8.jpg")
var natural_background = load("res://gfx/nature_bg_3.png")

# Combo system variables
var combo_count = 0
var combo_timer = 0
var combo_timeout = 3.0  # Time window for combo (in seconds)
var score = 0

# Crossbow and shooting variables
var can_shoot = true
var shoot_cooldown := Timer.new()
var shoot_timer = 0.0
var gravity = Vector2(0, 980)  # Adjust this value to match your game's gravity
var shots_remaining = 10

@onready var combo_label = $ComboLabel
@onready var score_label = $ScoreLabel
@onready var shots_label = $ShotsLabel


func _ready():
	setup_background_layer()
	randomize()
	setup_game()
	create_crossbow()
	create_trajectory_line()
	setup_audio()
	setup_ui()
	setup_rocks()
	shoot_cooldown.timeout.connect(reset_shoot_cooldown)
	shoot_cooldown.one_shot = true
	add_child(shoot_cooldown)
	
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func setup_background_layer():
	var background_layer = CanvasLayer.new()
	background_layer.name = "BackgroundLayer"
	background_layer.layer = -1  # This ensures it's drawn behind other nodes
	add_child(background_layer)
	
	background_sprite.texture = polluted_background
	background_sprite.centered = false
	background_layer.add_child(background_sprite)
	
	var blend_sprite = Sprite2D.new()
	blend_sprite.name = "BlendSprite"
	blend_sprite.texture = natural_background
	blend_sprite.centered = false
	blend_sprite.modulate.a = 0  # Start fully transparent
	background_layer.add_child(blend_sprite)
	
	_on_viewport_size_changed()  # Initial size adjustment

func setup_game():
	occupied_cells = []
	for x in range(grid_width):
		occupied_cells.append([])
		for y in range(grid_height):
			occupied_cells[x].append(false)
	
	create_rocks()
	create_vertical_rocks()
	create_seed_pegs()
	total_seed_pegs = seed_pegs.size()
	create_water_drop()
	
func setup_audio():
	# Setup background music
	background_music = $AudioStreamPlayer2D  # Assuming the AudioStreamPlayer2D is already a child of main_game
	if not background_music:
		print("Warning: AudioStreamPlayer2D not found as a child of main_game")
	
	# Setup win sound
	win_sound = AudioStreamPlayer2D.new()
	add_child(win_sound)
	var sound = load("res://audio/game_win.wav")
	if sound:
		win_sound.stream = sound
	else:
		print("Failed to load game_win.wav")
	
	# Setup combo sound
	combo_sound = AudioStreamPlayer2D.new()
	add_child(combo_sound)
	var combo_sound_resource = load("res://audio/Impact Tom 001.wav")  # Make sure to create this audio file
	if combo_sound_resource:
		combo_sound.stream = combo_sound_resource
	else:
		print("Failed to load combo_sound.wav")

func setup_ui():
	combo_label = Label.new()
	combo_label.position = Vector2(20, 60)
	add_child(combo_label)
	
	score_label = Label.new()
	score_label.position = Vector2(20, 20)
	add_child(score_label)
	
	shots_label = Label.new()
	shots_label.position = Vector2(20, 100)
	add_child(shots_label)
	
	update_score_display()
	update_shots_display()

func update_shots_display():
	shots_label.text = "Shots: " + str(shots_remaining)

func is_cell_empty(x, y):
	return not occupied_cells[x][y]

func occupy_cell(x, y):
	occupied_cells[x][y] = true
	
func setup_rocks():
	for rock in rocks:
		rock.connect("eroded", Callable(self, "_on_rock_eroded"))
		
	for vertical_rock in vertical_rocks:
		vertical_rock.connect("eroded", Callable(self, "_on_rock_eroded"))

func create_rocks():
	var num_rocks = 25
	var rock_size = 60
	var top_margin = int(grid_height * 0.1)

	for i in range(num_rocks):
		var attempts = 0
		while attempts < 100:  # Limit attempts to prevent infinite loop
			var grid_x = randi() % (grid_width - 2) + 1
			var grid_y = randi() % (grid_height - top_margin - 2) + top_margin + 1
			if is_cell_empty(grid_x, grid_y):
				var rock = preload("res://Rock.tscn").instantiate()
				rock.position = Vector2(grid_x * grid_size + rock_size/2, grid_y * grid_size + rock_size/2)
				add_child(rock)
				rocks.append(rock)
				occupy_cell(grid_x, grid_y)
				break
			attempts += 1

func create_vertical_rocks():
	var num_vertical_rocks = 25
	var rock_size = 60
	var top_margin = int(grid_height * 0.1)

	for i in range(num_vertical_rocks):
		var attempts = 0
		while attempts < 100:  # Limit attempts to prevent infinite loop
			var grid_x = randi() % (grid_width - 2) + 1
			var grid_y = randi() % (grid_height - top_margin - 2) + top_margin + 1
			if is_cell_empty(grid_x, grid_y):
				var vertical_rock = preload("res://VerticalRock.tscn").instantiate()
				vertical_rock.position = Vector2(grid_x * grid_size + rock_size/2, grid_y * grid_size + rock_size/2)
				vertical_rock.rotation = randf_range(0, 2 * PI)
				add_child(vertical_rock)
				vertical_rocks.append(vertical_rock)
				occupy_cell(grid_x, grid_y)
				break
			attempts += 1

func _on_rock_eroded(rock):
	if rock in rocks:
		rocks.erase(rock)
	elif rock in vertical_rocks:
		vertical_rocks.erase(rock)
	rock.queue_free()

func create_seed_pegs():
	var num_seeds = 10
	var seed_peg_size = 80
	var top_margin = int(grid_height * 0.1)

	for i in range(num_seeds):
		var attempts = 0
		while attempts < 100:  # Limit attempts to prevent infinite loop
			var grid_x = randi() % (grid_width - 2) + 1
			var grid_y = randi() % (grid_height - top_margin - 2) + top_margin + 1
			if is_cell_empty(grid_x, grid_y):
				var seed_peg = preload("res://Seed.tscn").instantiate()
				seed_peg.position = Vector2(grid_x * grid_size + seed_peg_size/2, grid_y * grid_size + seed_peg_size/2)
				if seed_peg is StaticBody2D:
					(seed_peg as StaticBody2D).seed_grown.connect(_on_seed_grown)
				add_child(seed_peg)
				seed_pegs.append(seed_peg)
				occupy_cell(grid_x, grid_y)
				break
			attempts += 1

func create_water_drop():
	pass
	#var water_drop = preload("res://WaterDrop.tscn").instantiate()
	#water_drop.position = Vector2(randi_range(50, 400), randi_range(10, 50))
	# add_child(water_drop)

func _on_seed_grown(seed_peg):
	seed_pegs.erase(seed_peg)
	print("Removing seed peg.")
	grown_trees += 1
	update_background()
	
	# Add combo and scoring logic
	hit_peg(150)  # Assuming each seed peg is worth 100 points
	
	if seed_pegs.is_empty():
		win_game()
		
func update_background():
	var progress = float(grown_trees) / total_seed_pegs
	
	var blend_sprite = $BackgroundLayer/BlendSprite
	
	# Create and configure the tween
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Tween the alpha of the blend sprite
	tween.tween_property(blend_sprite, "modulate:a", progress, 1.0)
	
	tween.play()
	
func _on_viewport_size_changed():
	var viewport_size = get_viewport().get_visible_rect().size  # This returns Vector2, not Vector2i
	
	if background_sprite and background_sprite.texture:
		var texture_size = background_sprite.texture.get_size()
		background_sprite.scale = Vector2(viewport_size.x / texture_size.x, viewport_size.y / texture_size.y)
	
	var blend_sprite = $BackgroundLayer/BlendSprite
	if blend_sprite and blend_sprite.texture:
		var blend_texture_size = blend_sprite.texture.get_size()
		blend_sprite.scale = Vector2(viewport_size.x / blend_texture_size.x, viewport_size.y / blend_texture_size.y)
		

func win_game():
	print("You win!")
	
	# Stop background music
	if background_music:
		background_music.stop()
	
	# Play win sound
	if win_sound and win_sound.stream:
		win_sound.play()
	else:
		print("Win sound not available")
	
	#var win_banner = preload("res://WinBanner.tscn").instantiate()
	#win_banner.position = Vector2(1920/2, 1080/2)
	#add_child(win_banner)

func create_arrow():
	var arrow = preload("res://Arrow.tscn").instantiate()
	arrow.position = Vector2(970, 0)
	add_child(arrow)
	
func _process(delta):
	# Rotate vertical rocks
	for rock in vertical_rocks:
		rock.rotation += delta * randf_range(0, 0.5)  # Adjust rotation speed as needed
	
	# Combo timer logic
	if combo_count > 0:
		combo_timer += delta
		if combo_timer >= combo_timeout:
			end_combo()
	
	# Shooting cooldown
	if not can_shoot:
		shoot_timer += delta
		if shoot_timer >= 1.0:
			can_shoot = true
			shoot_timer = 0.0
	
	# Update crossbow aim and trajectory
	update_crossbow_aim()
	update_trajectory()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_shoot and shots_remaining > 0:
			shoot_water_drop()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			reset_game()

func reset_game():
	# Remove all existing game objects
	for child in get_children():
		if child is StaticBody2D or child is RigidBody2D:
			child.queue_free()
	
	# Clear arrays
	seed_pegs.clear()
	rocks.clear()
	vertical_rocks.clear()
	occupied_cells.clear()
	
	# Reset variables
	grown_trees = 0
	combo_count = 0
	combo_timer = 0
	score = 0
	shots_remaining = 10
	
	# Setup game again
	setup_game()
	
	# Update UI
	update_combo_display()
	update_score_display()
	update_shots_display()
	
	# Reset background
	var blend_sprite = $BackgroundLayer/BlendSprite
	blend_sprite.modulate.a = 0
	
	# Reset crossbow and trajectory line
	if crossbow:
		crossbow.rotation = 0
	if trajectory_line:
		trajectory_line.points = PackedVector2Array()
		
		
func update_crossbow_aim():
	var mouse_pos = get_global_mouse_position()
	crossbow.look_at(mouse_pos)
	crossbow.rotation += PI/2  # Adjust rotation by 90 degreess)

func update_trajectory():
	var start_pos = crossbow.global_position
	var direction = (get_global_mouse_position() - start_pos).normalized()
	var speed = 1500  # Adjust this value to change the initial speed of the water drop
	
	var points = PackedVector2Array()
	var pos = start_pos
	var velocity = direction * speed
	var step = 0.1  # Time step for trajectory prediction
	var max_distance = get_viewport_rect().size.y / 2  # Half the screen height
	var total_distance = 0
	
	while total_distance < max_distance:
		points.append(pos)
		velocity += gravity * step
		var step_distance = (velocity * step).length()
		pos += velocity * step
		total_distance += step_distance
		
		if points.size() % 2 == 0:  # Add a gap every other point for dotted effect
			points.append(pos)
	
	trajectory_line.points = points

func shoot_water_drop():
	if can_shoot and shots_remaining > 0:
		var water_drop = water_drop_scene.instantiate()
		water_drop.position = crossbow.global_position
		var direction = (get_global_mouse_position() - crossbow.global_position).normalized()
		water_drop.linear_velocity = direction * 1200  # Match the speed from update_trajectory
		add_child(water_drop)
		can_shoot = false
		shoot_timer = 0.0  # Reset the timer
		shots_remaining -= 1
		update_shots_display()
		
		if shots_remaining == 0:
			check_game_state()

func reset_shoot_cooldown():
	can_shoot = true
	shoot_timer = 0.0

func check_game_state():
	if seed_pegs.is_empty():
		win_game()
	elif shots_remaining == 0:
		game_loss()

func game_loss():
	var loss_label = Label.new()
	loss_label.text = "Game Over\nScore: " + str(score) + "\nClick to Restart"
	loss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loss_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	loss_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(loss_label)
	
	var restart_button = Button.new()
	restart_button.text = "Restart"
	restart_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	restart_button.pressed.connect(restart_game)
	add_child(restart_button)

func restart_game():
	get_tree().reload_current_scene()

# Combo system functions
func hit_peg(peg_value):
	combo_count += 1
	combo_timer = 0
	score += peg_value * combo_count
	
	update_combo_display()
	update_score_display()
	play_combo_sound()

func update_combo_display():
	combo_label.text = "Combo: x" + str(combo_count)
	# You can add visual effects here, like scaling or color change

func update_score_display():
	score_label.text = "Score: " + str(score)

func play_combo_sound():
	if combo_sound:
		# Adjust pitch based on combo count
		combo_sound.pitch_scale = 1.0 + (combo_count * 0.1)
		combo_sound.play()

func end_combo():
	combo_count = 0
	combo_timer = 0
	combo_label.text = ""
	

func create_crossbow():
	crossbow = Sprite2D.new()
	crossbow.texture = load("res://gfx/crossbow.png")  # Make sure to create this image
	crossbow.position = Vector2(960, 50)  # Adjust position as needed
	crossbow.scale = Vector2(0.5, 0.5)  # Reduce size by half
	add_child(crossbow)

func create_trajectory_line():
	trajectory_line = Line2D.new()
	trajectory_line.default_color = Color(1, 1, 1, 0.5)  # Semi-transparent white
	trajectory_line.width = 2
	trajectory_line.top_level = true
	add_child(trajectory_line)
