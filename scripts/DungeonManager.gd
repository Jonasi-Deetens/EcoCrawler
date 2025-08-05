extends Node

# DungeonManager - handles multi-floor dungeon layout and management
# Single responsibility: Dungeon structure, floor generation, and navigation

signal room_changed(room)
signal player_moved_to_room(room)
signal floor_changed(floor)
signal player_changed_floor(from_floor, to_floor)

var floors: Dictionary = {}  # floor_number -> FloorInstance
var current_floor = null  # FloorInstance
var current_room = null  # RoomInstance
var player: CharacterBody2D

# Dungeon configuration
var total_floors: int = 5
var floor_themes: Array[String] = ["standard", "forest", "cave", "desert", "mystical"]
var floor_spacing: float = 10000.0  # Vertical spacing between floors

func _ready():
	call_deferred("_generate_multi_floor_dungeon")

func _generate_multi_floor_dungeon():
	"""Generate a multi-floor dungeon with varied themes"""
	
	print("Generating ", total_floors, " floor dungeon...")
	
	# Create floors
	for floor_num in range(1, total_floors + 1):
		var theme = floor_themes[(floor_num - 1) % floor_themes.size()]
		var floor_y_pos = (floor_num - 1) * floor_spacing
		var floor_pos = Vector2(0, floor_y_pos)
		
		var floor_instance = FloorInstance.new(floor_num, floor_pos, theme)
		floors[floor_num] = floor_instance
		get_parent().add_child.call_deferred(floor_instance)
		
		# Floor signals are handled directly by DungeonManager
		
		print("Created floor ", floor_num, " (", theme, ") at ", floor_pos)
	
	# Connect floors vertically
	_connect_floors()
	
	# Set starting floor and room
	current_floor = floors[1]
	current_floor.set_active(true)
	
	# Find the first room on the starting floor
	if current_floor.rooms.size() > 0:
		var first_room_id = current_floor.rooms.keys()[0]
		current_room = current_floor.get_room(first_room_id)
		current_room.set_active(true)
		print("Starting room set to: ", first_room_id, " and activated")
	else:
		print("ERROR: No rooms found on starting floor!")
	
	print("Multi-floor dungeon generated with ", floors.size(), " floors")

func _connect_floors():
	"""Connect floors vertically through stair rooms"""
	for floor_num in floors:
		var floor_instance = floors[floor_num]
		
		# Connect to floor above
		if floors.has(floor_num + 1):
			floor_instance.connect_to_floor_above(floors[floor_num + 1])
			print("Connected floor ", floor_num, " to floor ", floor_num + 1)
		
		# Connect to floor below
		if floors.has(floor_num - 1):
			floor_instance.connect_to_floor_below(floors[floor_num - 1])

func _get_opposite_direction(direction: String) -> String:
	"""Get the opposite direction"""
	match direction:
		"north": return "south"
		"south": return "north"
		"east": return "west"
		"west": return "east"
		_: return ""

func set_player(player_node: CharacterBody2D):
	"""Set the player reference"""
	player = player_node
	# Position player in starting room on starting floor
	if current_room:
		# Position player at the center of the starting room
		var room_center = Vector2(current_room.layout.room_size.x / 2.0, current_room.layout.room_size.y / 2.0)
		var target_pos = current_room.room_position + room_center
		player.position = target_pos
		print("Player positioned at room center: ", target_pos, " (room pos: ", current_room.room_position, ")")
	else:
		print("ERROR: No current room when setting player position!")

func get_current_room():
	"""Get the current room instance"""
	return current_room

func get_current_floor():
	"""Get the current floor instance"""
	return current_floor

func get_floor(floor_number: int):
	"""Get a specific floor instance"""
	return floors.get(floor_number)

func get_room_on_floor(floor_number: int, room_id: String):
	"""Get a specific room on a specific floor"""
	var floor_instance = get_floor(floor_number)
	if floor_instance:
		return floor_instance.get_room(room_id)
	return null

func get_room_number() -> String:
	"""Get the current room number as a string"""
	if current_room:
		var parts = current_room.room_id.split("_")
		if parts.size() >= 3:
			return parts[2]  # f1_room_1 -> "1"
	return "1"

func get_floor_number() -> int:
	"""Get the current floor number"""
	if current_floor:
		return current_floor.floor_number
	return 1

func change_floor(target_floor_number: int, target_room_id: String = "") -> bool:
	"""Change to a different floor"""
	if not floors.has(target_floor_number):
		return false
	
	var old_floor = current_floor
	var new_floor = floors[target_floor_number]
	
	# Deactivate old floor
	if old_floor:
		old_floor.set_active(false)
	
	# Activate new floor
	current_floor = new_floor
	current_floor.set_active(true)
	
	# Set target room or default to first room
	if target_room_id != "" and new_floor.rooms.has(target_room_id):
		current_room = new_floor.get_room(target_room_id)
	elif new_floor.rooms.size() > 0:
		var first_room_id = new_floor.rooms.keys()[0]
		current_room = new_floor.get_room(first_room_id)
	else:
		print("ERROR: No rooms found on floor ", target_floor_number)
		return false
	
	# Move player to new floor/room
	if player and current_room:
		player.position = current_room.room_position + Vector2(576, 324)
	
	# Emit signals
	floor_changed.emit(new_floor)
	if old_floor:
		player_changed_floor.emit(old_floor, new_floor)
	
	print("Changed from floor ", old_floor.floor_number if old_floor else 0, " to floor ", new_floor.floor_number)
	return true

# Signal handlers
func _on_room_entered(room):
	"""Handle room entry"""
	current_room = room
	room_changed.emit(room)
	player_moved_to_room.emit(room)
	print("Entered room: ", room.room_id)

func _on_room_exited(room):
	"""Handle room exit"""
	print("Exited room: ", room.room_id)

func _on_door_toggled(room, direction: String, is_open: bool):
	"""Handle door toggle"""
	print("Door ", direction, " in room ", room.room_id, " is now ", "OPEN" if is_open else "CLOSED")

 
