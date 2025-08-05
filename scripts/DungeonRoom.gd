extends Node2D

# DungeonRoom - orchestrates the dungeon components
# Single responsibility: Scene coordination and game flow

@onready var player: CharacterBody2D = $Player
@onready var dungeon_manager: Node = $DungeonManager
@onready var game_ui: Control = $UI

var teleport_cooldown = 1.0  # 1 second cooldown
var can_teleport = true

func _ready():
	# Connect signals from components
	_connect_signals()
	
	# Initialize the room
	_update_room_display()
	
	# Show door instructions
	show_door_instructions()

func _connect_signals():
	"""Connect all component signals"""
	# Connect door signals
	for exit in $Exits.get_children():
		if exit.has_signal("door_toggled"):
			exit.door_toggled.connect(_on_door_toggled)
	
	# Connect dungeon manager signals
	dungeon_manager.room_changed.connect(_on_room_changed)
	
	# Connect UI signals
	game_ui.back_to_menu_requested.connect(_on_back_to_menu_requested)

func _on_door_toggled(direction: String, is_open: bool):
	"""Handle door toggle from ExitHandler"""
	print("Door ", direction, " is now ", "OPEN" if is_open else "CLOSED")
	# Could add ecosystem effects here later

func handle_exit(direction: String):
	"""Handle exit request from ExitHandler (only if door is open)"""
	if can_teleport and dungeon_manager.change_room(direction):
		# Disable teleporting temporarily
		can_teleport = false
		
		# Move player to new spawn position with offset
		var spawn_pos = dungeon_manager.get_spawn_position(direction)
		player.position = spawn_pos
		
		# Start cooldown timer
		await get_tree().create_timer(teleport_cooldown).timeout
		can_teleport = true

func _on_room_changed(room_id: String):
	"""Handle room change from DungeonManager"""
	print("Now in room: ", room_id)
	_update_room_display()

func _update_room_display():
	"""Update UI to reflect current room"""
	var room_number = dungeon_manager.get_room_number()
	game_ui.update_room_label(room_number)

func show_door_instructions():
	"""Show instructions for door interaction"""
	print("=== DOOR INSTRUCTIONS ===")
	print("• Click on the golden door areas to open/close them")
	print("• Only open doors allow room transitions")
	print("• Closed doors are dark brown, open doors are golden yellow")
	print("• You cannot walk through walls (brown areas)")
	print("========================")

func _on_back_to_menu_requested():
	"""Handle back to menu request from GameUI"""
	print("Returning to menu...")
	get_tree().change_scene_to_file("res://scenes/MenuScreen.tscn")

# Handle escape key to return to menu
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_back_to_menu_requested()
	
	# Handle door clicking manually since Area2D input_event isn't working
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		print("DungeonRoom: Mouse click detected at: ", event.position)
		print("Global mouse position: ", mouse_pos)
		
		# Check each door area manually
		for exit in $Exits.get_children():
			if exit is Area2D and exit.has_method("toggle_door"):
				var exit_pos = exit.global_position
				var distance = mouse_pos.distance_to(exit_pos)
				print("Distance to ", exit.exit_direction, " door: ", distance)
				
				# Check if click is within door area (rough bounds)
				var in_door_area = false
				if exit.exit_direction in ["north", "south"]:
					# Horizontal doors: 64x16
					in_door_area = abs(mouse_pos.x - exit_pos.x) <= 32 and abs(mouse_pos.y - exit_pos.y) <= 8
				else:
					# Vertical doors: 16x64  
					in_door_area = abs(mouse_pos.x - exit_pos.x) <= 8 and abs(mouse_pos.y - exit_pos.y) <= 32
				
				if in_door_area:
					print("Manual door click detected on ", exit.exit_direction, " door!")
					exit.toggle_door()
					break 