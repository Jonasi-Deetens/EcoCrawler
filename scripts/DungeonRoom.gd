extends Node2D

# DungeonRoom - Main dungeon scene coordinator
# Single responsibility: Scene coordination and game flow with room instances

@onready var player: CharacterBody2D = $Player
@onready var dungeon_manager: Node = $DungeonManager
@onready var game_ui: Control = $UI

func _ready():
	# Connect signals from components
	_connect_signals()
	
	# Set up player reference in dungeon manager
	dungeon_manager.set_player(player)
	
	# Initialize the room display (deferred to ensure dungeon is ready)
	call_deferred("_update_room_display")
	
	# Show door instructions
	show_door_instructions()

func _connect_signals():
	"""Connect all component signals"""
	# Connect dungeon manager signals (now uses floor and room instances)
	dungeon_manager.room_changed.connect(_on_room_changed)
	dungeon_manager.player_moved_to_room.connect(_on_player_moved_to_room)
	dungeon_manager.floor_changed.connect(_on_floor_changed)
	dungeon_manager.player_changed_floor.connect(_on_player_changed_floor)
	
	# Connect UI signals
	game_ui.back_to_menu_requested.connect(_on_back_to_menu_requested)

func _on_room_changed(room: RoomInstance):
	"""Handle room change from DungeonManager"""
	print("Now in room: ", room.room_id)
	_update_room_display()

func _on_player_moved_to_room(room: RoomInstance):
	"""Handle player movement to new room"""
	print("Player moved to room: ", room.room_id)
	# Could add camera following logic here later

func _on_floor_changed(floor: FloorInstance):
	"""Handle floor change from DungeonManager"""
	print("Now on floor: ", floor.floor_number, " (", floor.floor_theme, ")")
	_update_room_display()

func _on_player_changed_floor(from_floor: FloorInstance, to_floor: FloorInstance):
	"""Handle player changing floors"""
	print("Player changed from floor ", from_floor.floor_number, " to floor ", to_floor.floor_number)
	_update_room_display()

func _update_room_display():
	"""Update UI to reflect current floor and room"""
	var current_floor = dungeon_manager.get_current_floor()
	if not current_floor:
		print("Warning: Current floor is null, dungeon may not be ready yet")
		return
	
	var floor_number = dungeon_manager.get_floor_number()
	var floor_theme = current_floor.floor_theme
	var room_number = dungeon_manager.get_room_number()
	game_ui.update_floor_info(floor_number, floor_theme, room_number)

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
	
	# Door clicking is now handled by individual RoomInstance nodes 
