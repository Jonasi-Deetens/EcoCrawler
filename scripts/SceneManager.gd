extends Node

# SceneManager - handles only scene transitions
# Single responsibility: Scene management

func change_scene(scene_path: String):
	"""Change to a new scene"""
	get_tree().change_scene_to_file(scene_path)

func quit_game():
	"""Quit the game"""
	get_tree().quit()

func reload_current_scene():
	"""Reload the current scene"""
	get_tree().reload_current_scene() 