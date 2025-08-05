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

func _connect_signals():
	"""Connect all component signals"""
	# Connect exit signals
	for exit in $Exits.get_children():
		if exit.has_signal("exit_triggered"):
			exit.exit_triggered.connect(_on_exit_triggered)
	
	# Connect dungeon manager signals
	dungeon_manager.room_changed.connect(_on_room_changed)
	
	# Connect UI signals
	game_ui.back_to_menu_requested.connect(_on_back_to_menu_requested)

func _on_exit_triggered(direction: String):
	"""Handle exit trigger from ExitHandler"""
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

func _on_back_to_menu_requested():
	"""Handle back to menu request from GameUI"""
	print("Returning to menu...")
	get_tree().change_scene_to_file("res://scenes/MenuScreen.tscn")

# Handle escape key to return to menu
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_back_to_menu_requested() 