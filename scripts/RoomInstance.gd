extends Node2D
class_name RoomInstance

# RoomInstance - Represents a single room with its own state and layout
# Single responsibility: Manage individual room data, doors, and entities

@export var room_id: String = ""
@export var room_position: Vector2 = Vector2.ZERO  # Position in world space
@export var layout: RoomLayout  # Room layout configuration

# Room state
var door_states: Dictionary = {}  # direction -> bool (open/closed)
var entities: Array = []  # Future: creatures, items, etc.
var is_visited: bool = false
var is_active: bool = false  # Currently loaded/visible

# Room connections
var connections: Dictionary = {}  # direction -> RoomInstance

# Visual components
var background: ColorRect
var floor_rect: ColorRect
var walls: Node2D
var exits: Node2D

signal room_entered(room)
signal room_exited(room)
signal door_toggled(room, direction: String, is_open: bool)

func _init(id: String, world_pos: Vector2, room_layout: RoomLayout = null):
	room_id = id
	room_position = world_pos
	position = world_pos
	name = "Room_" + id
	
	# Use provided layout or default to standard room
	if room_layout:
		layout = room_layout
	else:
		layout = RoomLayout.get_standard_room()
	
	# Initialize door states based on available doors
	door_states = {}
	for direction in ["north", "south", "east", "west"]:
		door_states[direction] = false  # All doors start closed

func _ready():
	_create_room_structure()
	print("RoomInstance ", room_id, " created at world pos: ", room_position, " node pos: ", position)
	print("  Room active: ", is_active, " visible: ", visible)

func _create_room_structure():
	"""Create the visual and collision structure of the room"""
	print("Creating room structure for ", room_id, " with layout: ", layout.layout_name)
	
	# Background
	background = ColorRect.new()
	background.size = layout.room_size
	background.color = layout.background_color
	background.name = "Background"
	background.z_index = -100  # Behind everything
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block input
	add_child(background)
	print("  Added background: ", background.size, " color: ", background.color)
	
	# Floor
	floor_rect = ColorRect.new()
	floor_rect.position = Vector2(layout.floor_margin, layout.floor_margin)
	floor_rect.size = Vector2(layout.room_size.x - layout.floor_margin * 2, layout.room_size.y - layout.floor_margin * 2)
	floor_rect.color = layout.floor_color
	floor_rect.name = "Floor"
	floor_rect.z_index = -90  # Behind player but above background
	floor_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block input
	add_child(floor_rect)
	print("  Added floor: ", floor_rect.size, " at ", floor_rect.position, " color: ", floor_rect.color)
	
	# Walls container
	walls = Node2D.new()
	walls.name = "Walls"
	walls.z_index = -50  # Behind player but above floor
	add_child(walls)
	print("  Creating walls...")
	_create_walls()
	
	# Exits container
	exits = Node2D.new()
	exits.name = "Exits"
	# Don't set z_index for exits - they need to be interactive
	add_child(exits)
	print("  Creating exits...")
	_create_exits()
	print("Room structure creation completed for ", room_id)

func _create_walls():
	"""Create wall collision bodies"""
	var wall_thickness = layout.wall_thickness
	var room_size = layout.room_size
	
	# Top wall
	_create_wall("WallTop", Vector2(room_size.x / 2.0, wall_thickness / 2.0), Vector2(room_size.x, wall_thickness))
	
	# Bottom wall
	_create_wall("WallBottom", Vector2(room_size.x / 2.0, room_size.y - wall_thickness / 2.0), Vector2(room_size.x, wall_thickness))
	
	# Left wall
	_create_wall("WallLeft", Vector2(wall_thickness / 2.0, room_size.y / 2.0), Vector2(wall_thickness, room_size.y))
	
	# Right wall
	_create_wall("WallRight", Vector2(room_size.x - wall_thickness / 2.0, room_size.y / 2.0), Vector2(wall_thickness, room_size.y))

func _create_wall(wall_name: String, pos: Vector2, size: Vector2):
	"""Create a single wall with collision"""
	var wall = StaticBody2D.new()
	wall.name = wall_name
	wall.position = pos
	wall.collision_layer = 2
	wall.collision_mask = 1
	
	# Collision shape
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	wall.add_child(collision)
	
	# Visual
	var visual = ColorRect.new()
	visual.position = -size / 2
	visual.size = size
	visual.color = layout.wall_color
	wall.add_child(visual)
	
	walls.add_child(wall)

func _create_exits():
	"""Create door areas for each direction"""
	# Only create doors that are available in this room layout
	for direction in layout.available_doors:
		if layout.door_positions.has(direction):
			_create_door(direction, layout.door_positions[direction])

func _create_door(direction: String, pos: Vector2):
	"""Create a door with blocker and area"""
	# Door blocker (StaticBody2D for collision when closed)
	var blocker = StaticBody2D.new()
	blocker.name = "DoorBlocker" + direction.capitalize()
	blocker.position = pos
	blocker.collision_layer = 2
	blocker.collision_mask = 1
	
	var blocker_collision = CollisionShape2D.new()
	var blocker_shape = RectangleShape2D.new()
	blocker_shape.size = Vector2(32, 32)
	blocker_collision.shape = blocker_shape
	blocker.add_child(blocker_collision)
	exits.add_child(blocker)
	
	# Door area (Area2D for detection and interaction)
	var door_area = Area2D.new()
	door_area.name = "Exit" + direction.capitalize()
	door_area.position = pos
	door_area.collision_layer = 4
	door_area.collision_mask = 1
	door_area.monitoring = true
	door_area.input_pickable = true
	
	# Area collision shape
	var area_collision = CollisionShape2D.new()
	var area_shape = RectangleShape2D.new()
	if direction in ["north", "south"]:
		area_shape.size = Vector2(64, 16)  # Horizontal doors
	else:
		area_shape.size = Vector2(16, 64)  # Vertical doors
	area_collision.shape = area_shape
	door_area.add_child(area_collision)
	
	# Door visual
	var door_visual = ColorRect.new()
	if direction in ["north", "south"]:
		door_visual.position = Vector2(-32, -8)
		door_visual.size = Vector2(64, 16)
	else:
		door_visual.position = Vector2(-8, -32)
		door_visual.size = Vector2(16, 64)
	door_visual.color = Color(0.4, 0.2, 0.1, 1)  # Start closed (dark brown)
	door_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	door_area.add_child(door_visual)
	
	# Connect signals
	door_area.body_entered.connect(_on_door_entered.bind(direction, blocker))
	door_area.input_event.connect(_on_door_clicked.bind(direction, door_visual, blocker_collision))
	
	exits.add_child(door_area)

func _on_door_clicked(_viewport, event, _shape_idx, direction: String, visual: ColorRect, blocker_collision: CollisionShape2D):
	"""Handle door clicking"""
	print("Door click detected on ", direction, " door in room ", room_id)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Left mouse button pressed on ", direction, " door")
		toggle_door(direction, visual, blocker_collision)

func _on_door_entered(body: Node2D, direction: String, _blocker: StaticBody2D):
	"""Handle player entering door area"""
	if body.name == "Player" and door_states[direction]:
		print("Player entering ", direction, " door in room ", room_id)
		# Signal will be handled by DungeonManager
		var connected_room = connections.get(direction)
		if connected_room:
			room_exited.emit(self)
			# Move player to connected room
			_transition_to_room(body, connected_room, direction)

func _transition_to_room(player: Node2D, target_room: RoomInstance, from_direction: String):
	"""Handle transition to another room"""
	# Calculate spawn position in target room
	var spawn_offset = _get_spawn_offset(from_direction)
	var target_pos = target_room.room_position + spawn_offset
	
	player.position = target_pos
	target_room.room_entered.emit(target_room)
	print("Player transitioned to room ", target_room.room_id)

func _get_spawn_offset(from_direction: String) -> Vector2:
	"""Get spawn position offset within room based on entry direction"""
	var room_size = layout.room_size
	var margin = layout.floor_margin + 50  # Extra margin from floor edge
	
	match from_direction:
		"north": return Vector2(room_size.x/2, room_size.y - margin)  # Spawn near south
		"south": return Vector2(room_size.x/2, margin)  # Spawn near north
		"east": return Vector2(margin, room_size.y/2)  # Spawn near west
		"west": return Vector2(room_size.x - margin, room_size.y/2)  # Spawn near east
		_: return Vector2(room_size.x/2, room_size.y/2)  # Center

func toggle_door(direction: String, visual: ColorRect, blocker_collision: CollisionShape2D):
	"""Toggle door open/closed state"""
	door_states[direction] = !door_states[direction]
	var is_open = door_states[direction]
	
	print("Door ", direction, " in room ", room_id, " toggled to: ", "OPEN" if is_open else "CLOSED")
	
	# Update visual
	if is_open:
		visual.color = Color(0.8, 0.6, 0.2, 1)  # Golden yellow for open
	else:
		visual.color = Color(0.4, 0.2, 0.1, 1)  # Dark brown for closed
	
	# Update collision
	blocker_collision.disabled = is_open
	
	door_toggled.emit(self, direction, is_open)

func connect_room(direction: String, room: RoomInstance):
	"""Connect this room to another room in the given direction"""
	connections[direction] = room
	print("Room ", room_id, " connected to room ", room.room_id, " via ", direction)

func set_active(active: bool):
	"""Set room active state (for optimization later)"""
	is_active = active
	visible = active

func get_door_state(direction: String) -> bool:
	"""Get the state of a door"""
	return door_states.get(direction, false)

func set_door_state(direction: String, open: bool):
	"""Set the state of a door externally"""
	door_states[direction] = open
	# Find and update the visual and collision
	for child in exits.get_children():
		if child.name == "Exit" + direction.capitalize():
			for grandchild in child.get_children():
				if grandchild is ColorRect:
					if open:
						grandchild.color = Color(0.8, 0.6, 0.2, 1)
					else:
						grandchild.color = Color(0.4, 0.2, 0.1, 1)
			break
	
	# Update blocker collision
	for child in exits.get_children():
		if child.name == "DoorBlocker" + direction.capitalize():
			for grandchild in child.get_children():
				if grandchild is CollisionShape2D:
					grandchild.disabled = open
			break
