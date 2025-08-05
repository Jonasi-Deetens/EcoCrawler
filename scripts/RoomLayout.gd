extends Resource
class_name RoomLayout

# RoomLayout - Defines room structure templates
# Single responsibility: Store room configuration data

@export var layout_name: String = ""
@export var room_size: Vector2 = Vector2(1152, 648)
@export var floor_margin: int = 50
@export var wall_thickness: int = 32

# Door configuration - position and availability
@export var door_positions: Dictionary = {}
@export var available_doors: Array[String] = []

# Visual theming (future biomes)
@export var background_color: Color = Color(0.2, 0.15, 0.1, 1)
@export var floor_color: Color = Color(0.3, 0.25, 0.2, 1)
@export var wall_color: Color = Color(0.4, 0.3, 0.2, 1)

# Room type for gameplay mechanics
@export var room_type: String = "standard"  # standard, corridor, chamber, junction

func _init(name: String = ""):
	layout_name = name

# Predefined room layouts
static func get_standard_room() -> RoomLayout:
	"""Standard rectangular room with doors on all sides"""
	var layout = RoomLayout.new("standard")
	layout.room_size = Vector2(1152, 648)
	layout.available_doors.assign(["north", "south", "east", "west"])
	layout.door_positions = {
		"north": Vector2(576, 50),
		"south": Vector2(576, 598),
		"east": Vector2(1102, 324),
		"west": Vector2(50, 324)
	}
	return layout

static func get_small_chamber() -> RoomLayout:
	"""Small square chamber"""
	var layout = RoomLayout.new("small_chamber")
	layout.room_size = Vector2(800, 800)
	layout.available_doors.assign(["north", "south", "east", "west"])
	layout.door_positions = {
		"north": Vector2(400, 50),
		"south": Vector2(400, 750),
		"east": Vector2(750, 400),
		"west": Vector2(50, 400)
	}
	layout.background_color = Color(0.15, 0.2, 0.15, 1)  # Slightly green tint
	layout.floor_color = Color(0.25, 0.35, 0.25, 1)
	layout.room_type = "chamber"
	return layout

static func get_large_hall() -> RoomLayout:
	"""Large rectangular hall"""
	var layout = RoomLayout.new("large_hall")
	layout.room_size = Vector2(1600, 900)
	layout.available_doors.assign(["north", "south", "east", "west"])
	layout.door_positions = {
		"north": Vector2(800, 50),
		"south": Vector2(800, 850),
		"east": Vector2(1550, 450),
		"west": Vector2(50, 450)
	}
	layout.background_color = Color(0.25, 0.2, 0.15, 1)  # Warmer tint
	layout.floor_color = Color(0.35, 0.3, 0.25, 1)
	layout.room_type = "hall"
	return layout

static func get_horizontal_corridor() -> RoomLayout:
	"""Long horizontal corridor"""
	var layout = RoomLayout.new("horizontal_corridor")
	layout.room_size = Vector2(1400, 400)
	layout.available_doors.assign(["east", "west"])  # Only horizontal exits
	layout.door_positions = {
		"east": Vector2(1350, 200),
		"west": Vector2(50, 200)
	}
	layout.background_color = Color(0.18, 0.15, 0.12, 1)  # Darker
	layout.floor_color = Color(0.28, 0.25, 0.22, 1)
	layout.room_type = "corridor"
	return layout

static func get_vertical_corridor() -> RoomLayout:
	"""Long vertical corridor"""
	var layout = RoomLayout.new("vertical_corridor")
	layout.room_size = Vector2(400, 1200)
	layout.available_doors.assign(["north", "south"])  # Only vertical exits
	layout.door_positions = {
		"north": Vector2(200, 50),
		"south": Vector2(200, 1150)
	}
	layout.background_color = Color(0.18, 0.15, 0.12, 1)  # Darker
	layout.floor_color = Color(0.28, 0.25, 0.22, 1)
	layout.room_type = "corridor"
	return layout

static func get_junction_room() -> RoomLayout:
	"""Cross-shaped junction room"""
	var layout = RoomLayout.new("junction")
	layout.room_size = Vector2(1000, 1000)
	layout.available_doors.assign(["north", "south", "east", "west"])
	layout.door_positions = {
		"north": Vector2(500, 50),
		"south": Vector2(500, 950),
		"east": Vector2(950, 500),
		"west": Vector2(50, 500)
	}
	layout.background_color = Color(0.2, 0.18, 0.15, 1)
	layout.floor_color = Color(0.3, 0.28, 0.25, 1)
	layout.room_type = "junction"
	return layout

static func get_dead_end() -> RoomLayout:
	"""Dead end room with only one entrance"""
	var layout = RoomLayout.new("dead_end")
	layout.room_size = Vector2(900, 600)
	layout.available_doors.assign(["south"])  # Only one exit
	layout.door_positions = {
		"south": Vector2(450, 550)
	}
	layout.background_color = Color(0.15, 0.1, 0.2, 1)  # Purple tint
	layout.floor_color = Color(0.25, 0.2, 0.3, 1)
	layout.room_type = "dead_end"
	return layout

static func get_stair_up_room() -> RoomLayout:
	"""Room with stairs going up"""
	var layout = RoomLayout.new("stair_up")
	layout.room_size = Vector2(1000, 800)
	layout.available_doors.assign(["north", "south", "east", "west"])
	layout.door_positions = {
		"north": Vector2(500, 50),
		"south": Vector2(500, 750),
		"east": Vector2(950, 400),
		"west": Vector2(50, 400)
	}
	layout.background_color = Color(0.25, 0.2, 0.18, 1)
	layout.floor_color = Color(0.35, 0.3, 0.28, 1)
	layout.wall_color = Color(0.45, 0.35, 0.3, 1)
	layout.room_type = "stair_up"
	return layout

static func get_stair_down_room() -> RoomLayout:
	"""Room with stairs going down"""
	var layout = RoomLayout.new("stair_down")
	layout.room_size = Vector2(1000, 800)
	layout.available_doors.assign(["north", "south", "east", "west"])
	layout.door_positions = {
		"north": Vector2(500, 50),
		"south": Vector2(500, 750),
		"east": Vector2(950, 400),
		"west": Vector2(50, 400)
	}
	layout.background_color = Color(0.2, 0.18, 0.25, 1)
	layout.floor_color = Color(0.3, 0.28, 0.35, 1)
	layout.wall_color = Color(0.4, 0.35, 0.45, 1)
	layout.room_type = "stair_down"
	return layout

static func get_stair_both_room() -> RoomLayout:
	"""Room with stairs going both up and down"""
	var layout = RoomLayout.new("stair_both")
	layout.room_size = Vector2(1200, 1000)
	layout.available_doors.assign(["north", "south", "east", "west"])
	layout.door_positions = {
		"north": Vector2(600, 50),
		"south": Vector2(600, 950),
		"east": Vector2(1150, 500),
		"west": Vector2(50, 500)
	}
	layout.background_color = Color(0.22, 0.2, 0.25, 1)
	layout.floor_color = Color(0.32, 0.3, 0.35, 1)
	layout.wall_color = Color(0.42, 0.38, 0.45, 1)
	layout.room_type = "stair_both"
	return layout

# Get all available layouts
static func get_all_layouts() -> Array[RoomLayout]:
	"""Get array of all predefined room layouts"""
	return [
		get_standard_room(),
		get_small_chamber(),
		get_large_hall(),
		get_horizontal_corridor(),
		get_vertical_corridor(),
		get_junction_room(),
		get_dead_end(),
		get_stair_up_room(),
		get_stair_down_room(),
		get_stair_both_room()
	]

# Get layouts by type
static func get_layouts_by_type(type: String) -> Array[RoomLayout]:
	"""Get layouts filtered by room type"""
	var all_layouts = get_all_layouts()
	var filtered = []
	for layout in all_layouts:
		if layout.room_type == type:
			filtered.append(layout)
	return filtered
