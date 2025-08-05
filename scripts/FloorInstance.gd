extends Node2D
class_name FloorInstance

# FloorInstance - Manages a single dungeon floor with multiple rooms
# Single responsibility: Coordinate rooms on a single floor level

@export var floor_number: int = 1
@export var floor_theme: String = "standard"  # standard, forest, cave, desert, mystical
@export var difficulty_level: int = 1
@export var floor_position: Vector2 = Vector2.ZERO  # Position in world space

# Floor properties
var rooms: Dictionary = {}  # room_id -> RoomInstance
var stair_rooms: Array = []  # Rooms with stairs up/down (RoomInstance)
var floor_size: Vector2 = Vector2(5000, 5000)  # Total floor area
var is_active: bool = false  # Currently loaded/visible

# Floor connections
var floor_above = null  # FloorInstance
var floor_below = null  # FloorInstance



func _init(floor_num: int, world_pos: Vector2, theme: String = "standard"):
	floor_number = floor_num
	floor_position = world_pos
	position = world_pos
	floor_theme = theme
	difficulty_level = floor_num  # Higher floors = higher difficulty
	name = "Floor_" + str(floor_num)

func _ready():
	_generate_floor_layout()
	print("FloorInstance ", floor_number, " (", floor_theme, ") created at ", floor_position)

func _generate_floor_layout():
	"""Generate the room layout for this floor"""
	var room_configs = _get_floor_room_configs()
	
	# Base spacing between rooms (reduced for testing)
	var base_spacing = Vector2(1800, 1200)
	
	# Create room instances for this floor
	for room_id in room_configs:
		var config = room_configs[room_id]
		var grid_pos = config.grid_pos
		var layout = config.layout
		
		# Calculate world position relative to floor position
		var room_world_pos = floor_position + Vector2(
			grid_pos.x * base_spacing.x,
			grid_pos.y * base_spacing.y
		)
		
		var room_instance = RoomInstance.new(room_id, room_world_pos, layout)
		rooms[room_id] = room_instance
		add_child(room_instance)
		
		# Track stair rooms
		if layout.room_type in ["stair_up", "stair_down", "stair_both"]:
			stair_rooms.append(room_instance)
		
		# Connect room signals
		room_instance.room_entered.connect(_on_room_entered)
		room_instance.room_exited.connect(_on_room_exited)
		room_instance.door_toggled.connect(_on_room_door_toggled)
		
		print("  Created ", layout.layout_name, " room: ", room_id, " at ", room_world_pos)
	
	# Connect rooms within this floor
	_connect_floor_rooms()

func _get_floor_room_configs() -> Dictionary:
	"""Get room configurations based on floor theme and number"""
	match floor_theme:
		"standard":
			return _get_standard_floor_config()
		"forest":
			return _get_forest_floor_config()
		"cave":
			return _get_cave_floor_config()
		"desert":
			return _get_desert_floor_config()
		"mystical":
			return _get_mystical_floor_config()
		_:
			return _get_standard_floor_config()

func _get_standard_floor_config():
	"""Standard dungeon floor layout"""
	return {
		"f" + str(floor_number) + "_room_1": {"grid_pos": Vector2(0, 0), "layout": RoomLayout.get_standard_room()},
		"f" + str(floor_number) + "_room_2": {"grid_pos": Vector2(-1, 0), "layout": RoomLayout.get_small_chamber()},
		"f" + str(floor_number) + "_room_3": {"grid_pos": Vector2(1, 0), "layout": RoomLayout.get_large_hall()},
		"f" + str(floor_number) + "_room_4": {"grid_pos": Vector2(0, -1), "layout": RoomLayout.get_horizontal_corridor()},
		"f" + str(floor_number) + "_room_5": {"grid_pos": Vector2(0, 1), "layout": RoomLayout.get_junction_room()},
		"f" + str(floor_number) + "_stair": {"grid_pos": Vector2(1, 1), "layout": _get_stair_room_layout()}
	}

func _get_forest_floor_config():
	"""Forest-themed floor with organic layout"""
	return {
		"f" + str(floor_number) + "_grove_1": {"grid_pos": Vector2(0, 0), "layout": _get_forest_grove_layout()},
		"f" + str(floor_number) + "_grove_2": {"grid_pos": Vector2(-1, -1), "layout": _get_forest_grove_layout()},
		"f" + str(floor_number) + "_path": {"grid_pos": Vector2(0, -1), "layout": _get_forest_path_layout()},
		"f" + str(floor_number) + "_clearing": {"grid_pos": Vector2(1, 0), "layout": _get_forest_clearing_layout()},
		"f" + str(floor_number) + "_stair": {"grid_pos": Vector2(1, 1), "layout": _get_stair_room_layout()}
	}

func _get_cave_floor_config():
	"""Cave-themed floor with tunnel system"""
	return {
		"f" + str(floor_number) + "_cavern_1": {"grid_pos": Vector2(0, 0), "layout": _get_cave_cavern_layout()},
		"f" + str(floor_number) + "_tunnel_1": {"grid_pos": Vector2(-1, 0), "layout": _get_cave_tunnel_layout()},
		"f" + str(floor_number) + "_tunnel_2": {"grid_pos": Vector2(1, 0), "layout": _get_cave_tunnel_layout()},
		"f" + str(floor_number) + "_chamber": {"grid_pos": Vector2(0, 1), "layout": _get_cave_chamber_layout()},
		"f" + str(floor_number) + "_stair": {"grid_pos": Vector2(0, -1), "layout": _get_stair_room_layout()}
	}

func _get_desert_floor_config():
	"""Desert-themed floor"""
	return {
		"f" + str(floor_number) + "_oasis": {"grid_pos": Vector2(0, 0), "layout": _get_desert_oasis_layout()},
		"f" + str(floor_number) + "_dune": {"grid_pos": Vector2(-1, 0), "layout": _get_desert_dune_layout()},
		"f" + str(floor_number) + "_ruins": {"grid_pos": Vector2(1, 0), "layout": _get_desert_ruins_layout()},
		"f" + str(floor_number) + "_stair": {"grid_pos": Vector2(0, 1), "layout": _get_stair_room_layout()}
	}

func _get_mystical_floor_config():
	"""Mystical-themed floor"""
	return {
		"f" + str(floor_number) + "_sanctum": {"grid_pos": Vector2(0, 0), "layout": _get_mystical_sanctum_layout()},
		"f" + str(floor_number) + "_portal": {"grid_pos": Vector2(-1, 0), "layout": _get_mystical_portal_layout()},
		"f" + str(floor_number) + "_library": {"grid_pos": Vector2(1, 0), "layout": _get_mystical_library_layout()},
		"f" + str(floor_number) + "_stair": {"grid_pos": Vector2(0, -1), "layout": _get_stair_room_layout()}
	}

func _connect_floor_rooms():
	"""Connect rooms within this floor"""
	# This would be specific to each floor layout
	# For now, implement a basic connection system
	var room_ids = rooms.keys()
	
	# Connect adjacent rooms based on grid positions
	for room_id in room_ids:
		var room = rooms[room_id]
		# Connect to nearby rooms (simplified for now)
		_connect_adjacent_rooms(room_id, room)

func _connect_adjacent_rooms(room_id: String, room: RoomInstance):
	"""Connect room to adjacent rooms (simplified logic)"""
	# This would be more sophisticated in a real implementation
	# For now, just connect rooms that have compatible doors
	for other_room_id in rooms:
		if other_room_id != room_id:
			var other_room = rooms[other_room_id]
			# Simple distance-based connection
			var distance = room.room_position.distance_to(other_room.room_position)
			if distance < 2000:  # Within connection range
				_try_connect_rooms(room, other_room)

func _try_connect_rooms(room1: RoomInstance, room2: RoomInstance):
	"""Try to connect two rooms if they have compatible doors"""
	var direction = _get_direction_between_rooms(room1, room2)
	var opposite = _get_opposite_direction(direction)
	
	if direction in room1.layout.available_doors and opposite in room2.layout.available_doors:
		room1.connect_room(direction, room2)

func _get_direction_between_rooms(room1: RoomInstance, room2: RoomInstance) -> String:
	"""Get the direction from room1 to room2"""
	var diff = room2.room_position - room1.room_position
	if abs(diff.x) > abs(diff.y):
		return "east" if diff.x > 0 else "west"
	else:
		return "south" if diff.y > 0 else "north"

func _get_opposite_direction(direction: String) -> String:
	"""Get the opposite direction"""
	match direction:
		"north": return "south"
		"south": return "north"
		"east": return "west"
		"west": return "east"
		_: return ""

# Room layout generators for different themes
func _get_stair_room_layout():
	"""Create a stair room layout"""
	var layout = RoomLayout.new("stair_room")
	layout.room_size = Vector2(800, 800)
	layout.available_doors.assign(["north", "south", "east", "west"])
	layout.door_positions = {
		"north": Vector2(400, 50),
		"south": Vector2(400, 750),
		"east": Vector2(750, 400),
		"west": Vector2(50, 400)
	}
	layout.background_color = Color(0.3, 0.25, 0.2, 1)
	layout.floor_color = Color(0.4, 0.35, 0.3, 1)
	layout.room_type = "stair_both"
	return layout

func _get_forest_grove_layout() :
	"""Forest grove room"""
	var layout = RoomLayout.get_small_chamber()
	layout.layout_name = "forest_grove"
	layout.background_color = Color(0.1, 0.3, 0.1, 1)
	layout.floor_color = Color(0.2, 0.4, 0.2, 1)
	layout.wall_color = Color(0.3, 0.5, 0.2, 1)
	layout.room_type = "forest"
	return layout

func _get_forest_path_layout() :
	"""Forest path (corridor)"""
	var layout = RoomLayout.get_horizontal_corridor()
	layout.layout_name = "forest_path"
	layout.background_color = Color(0.15, 0.25, 0.1, 1)
	layout.floor_color = Color(0.25, 0.35, 0.2, 1)
	layout.wall_color = Color(0.35, 0.45, 0.3, 1)
	layout.room_type = "forest"
	return layout

func _get_forest_clearing_layout() :
	"""Forest clearing (large open area)"""
	var layout = RoomLayout.get_large_hall()
	layout.layout_name = "forest_clearing"
	layout.background_color = Color(0.12, 0.28, 0.12, 1)
	layout.floor_color = Color(0.22, 0.38, 0.22, 1)
	layout.wall_color = Color(0.32, 0.48, 0.32, 1)
	layout.room_type = "forest"
	return layout

func _get_cave_cavern_layout() :
	"""Cave cavern"""
	var layout = RoomLayout.get_large_hall()
	layout.layout_name = "cave_cavern"
	layout.background_color = Color(0.1, 0.1, 0.15, 1)
	layout.floor_color = Color(0.2, 0.2, 0.25, 1)
	layout.wall_color = Color(0.3, 0.3, 0.35, 1)
	layout.room_type = "cave"
	return layout

func _get_cave_tunnel_layout() :
	"""Cave tunnel"""
	var layout = RoomLayout.get_vertical_corridor()
	layout.layout_name = "cave_tunnel"
	layout.background_color = Color(0.08, 0.08, 0.12, 1)
	layout.floor_color = Color(0.18, 0.18, 0.22, 1)
	layout.wall_color = Color(0.28, 0.28, 0.32, 1)
	layout.room_type = "cave"
	return layout

func _get_cave_chamber_layout() :
	"""Cave chamber"""
	var layout = RoomLayout.get_small_chamber()
	layout.layout_name = "cave_chamber"
	layout.background_color = Color(0.12, 0.1, 0.18, 1)
	layout.floor_color = Color(0.22, 0.2, 0.28, 1)
	layout.wall_color = Color(0.32, 0.3, 0.38, 1)
	layout.room_type = "cave"
	return layout

func _get_desert_oasis_layout() :
	"""Desert oasis"""
	var layout = RoomLayout.get_standard_room()
	layout.layout_name = "desert_oasis"
	layout.background_color = Color(0.3, 0.25, 0.15, 1)
	layout.floor_color = Color(0.4, 0.35, 0.25, 1)
	layout.wall_color = Color(0.5, 0.4, 0.25, 1)
	layout.room_type = "desert"
	return layout

func _get_desert_dune_layout() :
	"""Desert dune"""
	var layout = RoomLayout.get_large_hall()
	layout.layout_name = "desert_dune"
	layout.background_color = Color(0.35, 0.3, 0.2, 1)
	layout.floor_color = Color(0.45, 0.4, 0.3, 1)
	layout.wall_color = Color(0.55, 0.45, 0.3, 1)
	layout.room_type = "desert"
	return layout

func _get_desert_ruins_layout() :
	"""Desert ruins"""
	var layout = RoomLayout.get_junction_room()
	layout.layout_name = "desert_ruins"
	layout.background_color = Color(0.25, 0.2, 0.15, 1)
	layout.floor_color = Color(0.35, 0.3, 0.25, 1)
	layout.wall_color = Color(0.45, 0.35, 0.25, 1)
	layout.room_type = "desert"
	return layout

func _get_mystical_sanctum_layout() :
	"""Mystical sanctum"""
	var layout = RoomLayout.get_small_chamber()
	layout.layout_name = "mystical_sanctum"
	layout.background_color = Color(0.2, 0.1, 0.3, 1)
	layout.floor_color = Color(0.3, 0.2, 0.4, 1)
	layout.wall_color = Color(0.4, 0.25, 0.5, 1)
	layout.room_type = "mystical"
	return layout

func _get_mystical_portal_layout() :
	"""Mystical portal room"""
	var layout = RoomLayout.get_standard_room()
	layout.layout_name = "mystical_portal"
	layout.background_color = Color(0.15, 0.1, 0.25, 1)
	layout.floor_color = Color(0.25, 0.2, 0.35, 1)
	layout.wall_color = Color(0.35, 0.25, 0.45, 1)
	layout.room_type = "mystical"
	return layout

func _get_mystical_library_layout() :
	"""Mystical library"""
	var layout = RoomLayout.get_large_hall()
	layout.layout_name = "mystical_library"
	layout.background_color = Color(0.18, 0.12, 0.28, 1)
	layout.floor_color = Color(0.28, 0.22, 0.38, 1)
	layout.wall_color = Color(0.38, 0.28, 0.48, 1)
	layout.room_type = "mystical"
	return layout

# Floor management
func set_active(active: bool):
	"""Set floor active state"""
	is_active = active
	visible = active
	# Activate/deactivate all rooms on this floor
	for room in rooms.values():
		room.set_active(active)

func get_room(room_id: String):
	"""Get a specific room on this floor"""
	return rooms.get(room_id)

func get_stair_rooms() -> Array:
	"""Get all stair rooms on this floor"""
	return stair_rooms

func connect_to_floor_above(above_floor):
	"""Connect this floor to the floor above"""
	floor_above = above_floor
	above_floor.floor_below = self

func connect_to_floor_below(below_floor):
	"""Connect this floor to the floor below"""
	floor_below = below_floor
	below_floor.floor_above = self

# Signal handlers
func _on_room_entered(room):
	"""Handle room entry on this floor"""
	print("Entered room ", room.room_id, " on floor ", floor_number)

func _on_room_exited(room):
	"""Handle room exit on this floor"""
	print("Exited room ", room.room_id, " on floor ", floor_number)

func _on_room_door_toggled(room, direction: String, is_open: bool):
	"""Handle door toggle on this floor"""
	print("Door ", direction, " in room ", room.room_id, " on floor ", floor_number, " is now ", "OPEN" if is_open else "CLOSED")
