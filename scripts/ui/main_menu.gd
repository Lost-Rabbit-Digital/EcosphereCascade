extends Control

# Direct to play scene
func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game/MainGame.tscn")

func _on_how_to_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/HowToPlayMenu.tscn")

# Direct to main menu scene
func _on_upgrades_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/UpgradesMenu.tscn")

func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/SettingsMenu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
