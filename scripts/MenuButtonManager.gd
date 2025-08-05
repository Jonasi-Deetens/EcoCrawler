extends Control

# Menu Button Manager - Handles all button interactions and navigation
# Single responsibility: Button management and user input handling

signal button_pressed(button_name: String)
signal button_hovered(button_name: String)

@onready var start_button: Button = $"../MainContainer/ButtonContainer/StartButton"
@onready var tutorial_button: Button = $"../MainContainer/ButtonContainer/TutorialButton"
@onready var options_button: Button = $"../MainContainer/ButtonContainer/OptionsButton"
@onready var quit_button: Button = $"../MainContainer/ButtonContainer/QuitButton"

var buttons: Array[Button] = []
var navigation_cooldown: float = 0.1  # 100ms cooldown between navigation
var last_navigation_time: float = 0.0

func _ready():
	# Wait one frame to ensure all nodes are ready
	await get_tree().process_frame
	
	# Debug: Check if buttons are found
	print("Start button found: ", start_button != null)
	print("Tutorial button found: ", tutorial_button != null)
	print("Options button found: ", options_button != null)
	print("Quit button found: ", quit_button != null)
	
	# Initialize button array with validation in correct order
	buttons = []
	if start_button:
		buttons.append(start_button)
		print("Added start button")
	if tutorial_button:
		buttons.append(tutorial_button)
		print("Added tutorial button")
	if options_button:
		buttons.append(options_button)
		print("Added options button")
	if quit_button:
		buttons.append(quit_button)
		print("Added quit button")
	
	# Debug: Print button order
	print("Button array size: ", buttons.size())
	print("Button order: ", buttons.map(func(b): return b.name if b else "NULL"))
	
	# Connect all button signals
	_connect_button_signals()
	
	# Set initial focus
	if start_button:
		start_button.grab_focus()
		print("Set focus to start button")
	else:
		print("ERROR: Start button is null!")

func _connect_button_signals():
	"""Connect all button signals to their handlers"""
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))
		button.mouse_entered.connect(_on_button_hovered.bind(button))

func _input(event):
	"""Handle keyboard navigation"""
	if event.is_action_pressed("ui_accept"):
		_handle_enter_key()
	elif event.is_action_pressed("ui_cancel"):
		_handle_escape_key()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		# Check cooldown to prevent rapid navigation
		var current_time = Time.get_ticks_msec()
		if current_time - last_navigation_time >= navigation_cooldown * 1000:
			_handle_arrow_navigation(event)
			last_navigation_time = current_time

func _handle_enter_key():
	"""Handle Enter key press on focused button"""
	var focused_button = get_viewport().gui_get_focus_owner()
	if focused_button and focused_button is Button:
		_on_button_pressed(focused_button)

func _handle_escape_key():
	"""Handle Escape key press"""
	_on_button_pressed(quit_button)

func _handle_arrow_navigation(event):
	"""Handle arrow key navigation between buttons"""
	var current_focus = get_viewport().gui_get_focus_owner()
	if not current_focus or not current_focus is Button:
		print("No current focus or not a button")
		return
	
	var current_index = buttons.find(current_focus)
	if current_index == -1:
		print("Current focus not found in button array")
		return
	
	print("Current button index: ", current_index, " - ", current_focus.name)
	
	var new_index = current_index
	if event.is_action_pressed("ui_up"):
		# Find previous valid button
		new_index = current_index
		for i in range(buttons.size() - 1, -1, -1):
			var check_index = (current_index + i) % buttons.size()
			if buttons[check_index] and buttons[check_index].visible and not buttons[check_index].disabled:
				new_index = check_index
				break
		var button_name = "NULL"
		if buttons[new_index]:
			button_name = buttons[new_index].name
		print("Moving UP to index: ", new_index, " - ", button_name)
	elif event.is_action_pressed("ui_down"):
		# Find next valid button
		new_index = current_index
		for i in range(1, buttons.size() + 1):
			var check_index = (current_index + i) % buttons.size()
			if buttons[check_index] and buttons[check_index].visible and not buttons[check_index].disabled:
				new_index = check_index
				break
		var button_name = "NULL"
		if buttons[new_index]:
			button_name = buttons[new_index].name
		print("Moving DOWN to index: ", new_index, " - ", button_name)
	
	if buttons[new_index] and buttons[new_index].visible and not buttons[new_index].disabled:
		buttons[new_index].grab_focus()
		print("Focus set to: ", buttons[new_index].name)
		# Force focus to stay on this button
		await get_tree().process_frame
		buttons[new_index].grab_focus()
	else:
		print("ERROR: Cannot set focus to button at index: ", new_index)

func _on_button_pressed(button: Button):
	"""Handle button press events"""
	button_pressed.emit(button.name.to_lower().replace("button", ""))

func _on_button_hovered(button: Button):
	"""Handle button hover events"""
	button_hovered.emit(button.name.to_lower().replace("button", ""))

func get_button_by_name(button_name: String) -> Button:
	"""Get a button by its name"""
	for button in buttons:
		if button.name.to_lower().contains(button_name.to_lower()):
			return button
	return null

func set_button_enabled(button_name: String, enabled: bool):
	"""Enable or disable a specific button"""
	var button = get_button_by_name(button_name)
	if button:
		button.disabled = not enabled 
