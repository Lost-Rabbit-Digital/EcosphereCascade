extends Node2D

var seed_pegs = []
var rocks = []
var vertical_rocks = []
var background_music: AudioStreamPlayer2D
var win_sound: AudioStreamPlayer2D
var combo_sound: AudioStreamPlayer2D

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

@onready var combo_label = $ComboLabel
@onready var score_label = $ScoreLabel

func _ready():
	setup_background_layer()
	randomize()
	setup_game()
	create_arrow()
	setup_audio()
	setup_ui()
	
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
	combo_label.name = "ComboLabel"
	combo_label.position = Vector2(20, 60)  # Adjust position as needed
	add_child(combo_label)
	
	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.position = Vector2(20, 20)  # Adjust position as needed
	add_child(score_label)
	
	update_score_display()

func is_cell_empty(x, y):
	return not occupied_cells[x][y]

func occupy_cell(x, y):
	occupied_cells[x][y] = true
	
func create_rocks():
	var num_rocks = 12
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
	var num_vertical_rocks = 8
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

func create_seed_pegs():
	var num_seeds = 20
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
	
	var win_banner = preload("res://WinBanner.tscn").instantiate()
	win_banner.position = Vector2(1920/2, 1080/2)
	add_child(win_banner)

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
