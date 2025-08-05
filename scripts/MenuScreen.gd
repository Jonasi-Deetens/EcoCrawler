extends Control

# Menu screen script for EcoCrawler
# Handles button interactions and scene transitions

func _ready():
	# Connect button signals when the scene loads
	$VBoxContainer/StartButton.pressed.connect(_on_start_button_pressed)
	$VBoxContainer/OptionsButton.pressed.connect(_on_options_button_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)
	
	# Set focus to the start button for keyboard navigation
	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed():
	print("Starting dungeon crawl...")
	get_tree().change_scene_to_file("res://scenes/DungeonRoom.tscn")

func _on_options_button_pressed():
	print("Opening options...")
	# TODO: Open options menu
	# get_tree().change_scene_to_file("res://scenes/Options.tscn")

func _on_quit_button_pressed():
	print("Quitting game...")
	get_tree().quit()

# Handle keyboard input
func _input(event):
	if event.is_action_pressed("ui_accept"):
		# Enter key pressed - trigger focused button
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused is Button:
			focused.pressed.emit()
	
	elif event.is_action_pressed("ui_cancel"):
		# Escape key pressed - quit game
		_on_quit_button_pressed() 
