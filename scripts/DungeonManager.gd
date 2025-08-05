extends Node

# DungeonManager - handles only dungeon layout and room transitions
# Single responsibility: Dungeon structure and navigation

signal room_changed(room_id: String)

var current_room_id = "room_1"
var room_data = {}

func _ready():
	_initialize_room_data()

func _initialize_room_data():
	# Define the dungeon layout - data only, no logic
	room_data = {
		"room_1": {
			"exits": {
				"north": "room_2",
				"south": "room_3", 
				"east": "room_4",
				"west": null
			},
			"player_spawn": Vector2(576, 324)
		},
		"room_2": {
			"exits": {
				"north": null,
				"south": "room_1",
				"east": "room_5",
				"west": null
			},
			"player_spawn": Vector2(576, 598)
		},
		"room_3": {
			"exits": {
				"north": "room_1",
				"south": null,
				"east": "room_6",
				"west": null
			},
			"player_spawn": Vector2(576, 50)
		},
		"room_4": {
			"exits": {
				"north": "room_5",
				"south": "room_6",
				"east": null,
				"west": "room_1"
			},
			"player_spawn": Vector2(50, 324)
		},
		"room_5": {
			"exits": {
				"north": null,
				"south": "room_4",
				"east": null,
				"west": "room_2"
			},
			"player_spawn": Vector2(1102, 324)
		},
		"room_6": {
			"exits": {
				"north": "room_4",
				"south": null,
				"east": null,
				"west": "room_3"
			},
			"player_spawn": Vector2(1102, 324)
		}
	}

func get_room_data(room_id: String) -> Dictionary:
	"""Get data for a specific room"""
	return room_data.get(room_id, {})

func get_current_room_data() -> Dictionary:
	"""Get data for the current room"""
	return get_room_data(current_room_id)

func can_exit_direction(direction: String) -> bool:
	"""Check if there's an exit in the given direction"""
	var current_room = get_current_room_data()
	return current_room.get("exits", {}).get(direction) != null

func get_next_room_id(direction: String) -> String:
	"""Get the room ID for the given exit direction"""
	var current_room = get_current_room_data()
	return current_room.get("exits", {}).get(direction, "")

func change_room(direction: String) -> bool:
	"""Change to the room in the given direction. Returns success status."""
	var next_room_id = get_next_room_id(direction)
	
	if next_room_id != "":
		current_room_id = next_room_id
		room_changed.emit(current_room_id)
		return true
	return false

func get_spawn_position(direction: String) -> Vector2:
	"""Get the spawn position for entering from a specific direction"""
	# Exit positions: North(576,50), South(576,598), East(1102,324), West(50,324)
	# Floor area: X(50-1102), Y(50-598) - 50px offset from exits to stay in playable area
	match direction:
		"north":
			# Entering from north door, spawn on south side of room
			return Vector2(576, 548)  # 50 pixels below south exit, within floor
		"south":
			# Entering from south door, spawn on north side of room
			return Vector2(576, 100)  # 50 pixels above north exit, within floor
		"east":
			# Entering from east door, spawn on west side of room
			return Vector2(100, 324)  # 50 pixels right of west exit, within floor
		"west":
			# Entering from west door, spawn on east side of room
			return Vector2(1052, 324) # 50 pixels left of east exit, within floor
		_:
			return Vector2(576, 324)  # Default center position

func get_room_number() -> String:
	"""Get the room number as a string"""
	return current_room_id.split("_")[1] 
