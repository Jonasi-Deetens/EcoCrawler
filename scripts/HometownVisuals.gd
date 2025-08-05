extends Node2D
class_name HometownVisuals

# HometownVisuals - Handles visual design and decoration for the hometown
# Single responsibility: Create and manage visual elements, buildings, and environment

# Visual layers (z-index) - Adjusted to fix town square conflict
const BACKGROUND_LAYER = 1
const GROUND_LAYER = 2
const PATH_LAYER = 3
const DECORATION_LAYER = 4
const BUILDING_LAYER = 8  # Higher than town square

# Colors
const GRASS_COLOR = Color(0.3, 0.6, 0.2, 1)
const DIRT_PATH_COLOR = Color(0.6, 0.4, 0.2, 1)
const STONE_COLOR = Color(0.5, 0.5, 0.5, 1)
const BUILDING_COLOR = Color(0.8, 0.7, 0.5, 1)
const ROOF_COLOR = Color(0.6, 0.3, 0.2, 1)
const DOOR_COLOR = Color(0.4, 0.2, 0.1, 1)
const WINDOW_COLOR = Color(0.7, 0.9, 1.0, 0.8)

# Building positions (matching NPC positions)
const BLACKSMITH_POS = Vector2(200, 300)
const ALCHEMIST_POS = Vector2(400, 250)
const MERCHANT_POS = Vector2(600, 320)
const GUARD_POST_POS = Vector2(500, 150)
const CITIZEN_HOUSE_POS = Vector2(300, 400)
const DUNGEON_ENTRANCE_POS = Vector2(975, 375)  # Center of actual entrance area

func _ready():
	_create_visual_design()

func _create_visual_design():
	"""Create the complete visual design for the hometown"""
	print("HometownVisuals: Creating visual design...")
	
	# Create our own background now that scene background is removed
	_create_background()
	print("HometownVisuals: Background created")
	
	# Create perimeter walls with collision
	_create_perimeter_walls()
	print("HometownVisuals: Perimeter walls created")
	
	_create_ground_terrain()
	print("HometownVisuals: Ground terrain created")
	
	# Create paths connecting buildings
	_create_path_system()
	print("HometownVisuals: Path system created")
	
	# Create buildings for each NPC
	_create_blacksmith_building()
	print("HometownVisuals: Blacksmith building created")
	
	_create_alchemist_building()
	print("HometownVisuals: Alchemist building created")
	
	_create_merchant_building()
	print("HometownVisuals: Merchant building created")
	
	_create_guard_post()
	print("HometownVisuals: Guard post created")
	
	_create_citizen_house()
	print("HometownVisuals: Citizen house created")
	
	_create_dungeon_entrance_structure()
	print("HometownVisuals: Dungeon entrance created")
	
	# Add decorative elements
	_create_decorations()
	print("HometownVisuals: Decorations created")
	
	print("HometownVisuals: Visual design complete!")

func _create_background():
	"""Create the main background"""
	var background = ColorRect.new()
	background.size = Vector2(1200, 700)
	background.position = Vector2(-50, -50)
	background.color = Color(0.4, 0.7, 0.3, 1)  # Light green background
	background.z_index = BACKGROUND_LAYER
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	print("HometownVisuals: Created background at ", background.position, " with size ", background.size)

func _create_perimeter_walls():
	"""Create walls around the town perimeter with collision"""
	var wall_thickness = 20
	var town_bounds = Vector2(1100, 650)
	
	# Wall color - darker stone
	var wall_color = Color(0.3, 0.3, 0.3, 1)
	
	# North wall
	var north_wall = _create_wall(Vector2(0, 0), Vector2(town_bounds.x, wall_thickness), wall_color)
	
	# South wall  
	var south_wall = _create_wall(Vector2(0, town_bounds.y - wall_thickness), Vector2(town_bounds.x, wall_thickness), wall_color)
	
	# West wall
	var west_wall = _create_wall(Vector2(0, 0), Vector2(wall_thickness, town_bounds.y), wall_color)
	
	# East wall (with gap for dungeon entrance)
	var east_wall_top = _create_wall(Vector2(town_bounds.x - wall_thickness, 0), Vector2(wall_thickness, 250), wall_color)
	var east_wall_bottom = _create_wall(Vector2(town_bounds.x - wall_thickness, 500), Vector2(wall_thickness, town_bounds.y - 500), wall_color)

func _create_wall(pos: Vector2, size: Vector2, color: Color) -> ColorRect:
	"""Create a wall with visual and collision"""
	# Visual wall
	var wall = ColorRect.new()
	wall.position = pos
	wall.size = size
	wall.color = color
	wall.z_index = BUILDING_LAYER
	wall.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wall)
	
	# Collision for wall
	var collision_body = StaticBody2D.new()
	collision_body.position = pos + size / 2
	collision_body.collision_layer = 2  # Wall layer
	collision_body.collision_mask = 0
	
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size
	collision_shape.shape = shape
	
	collision_body.add_child(collision_shape)
	add_child(collision_body)
	
	print("HometownVisuals: Created wall at ", pos, " size ", size)
	return wall

func _create_ground_terrain():
	"""Create varied ground terrain"""
	# Main grass area
	var grass_area = ColorRect.new()
	grass_area.size = Vector2(900, 600)
	grass_area.position = Vector2(50, 50)
	grass_area.color = GRASS_COLOR
	grass_area.z_index = GROUND_LAYER
	grass_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(grass_area)
	
	# Town square (stone area)
	var town_square = ColorRect.new()
	town_square.size = Vector2(200, 200)
	town_square.position = Vector2(400, 200)
	town_square.color = STONE_COLOR
	town_square.z_index = GROUND_LAYER + 1  # Lower than buildings
	town_square.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(town_square)

func _create_path_system():
	"""Create dirt paths connecting buildings"""
	var paths = [
		# Main road (horizontal)
		{"pos": Vector2(100, 275), "size": Vector2(600, 25)},
		# Vertical connectors
		{"pos": Vector2(200, 275), "size": Vector2(25, 50)},  # To blacksmith
		{"pos": Vector2(400, 250), "size": Vector2(25, 50)},  # To alchemist
		{"pos": Vector2(600, 300), "size": Vector2(25, 50)},  # To merchant
		{"pos": Vector2(500, 150), "size": Vector2(25, 125)}, # To guard post
		{"pos": Vector2(300, 300), "size": Vector2(25, 125)}, # To citizen house
		# Path to dungeon
		{"pos": Vector2(700, 275), "size": Vector2(125, 25)},
		{"pos": Vector2(800, 200), "size": Vector2(25, 100)},
	]
	
	for path_data in paths:
		var path = ColorRect.new()
		path.position = path_data.pos
		path.size = path_data.size
		path.color = DIRT_PATH_COLOR
		path.z_index = PATH_LAYER
		path.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(path)

func _create_blacksmith_building():
	"""Create blacksmith forge building"""
	var building_pos = BLACKSMITH_POS + Vector2(-40, -60)
	print("HometownVisuals: Creating blacksmith at ", building_pos, " (NPC at ", BLACKSMITH_POS, ")")
	
	# Main building
	var building = ColorRect.new()
	building.size = Vector2(80, 60)
	building.position = building_pos
	building.color = BUILDING_COLOR
	building.z_index = BUILDING_LAYER
	building.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(building)
	print("HometownVisuals: Added blacksmith building with size ", building.size, " at ", building.position, " z_index: ", building.z_index)
	
	# Add collision for building
	_add_building_collision(building)
	
	# Roof
	var roof = ColorRect.new()
	roof.size = Vector2(90, 15)
	roof.position = building_pos + Vector2(-5, -15)
	roof.color = ROOF_COLOR
	roof.z_index = BUILDING_LAYER + 1
	roof.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(roof)
	
	# Door
	var door = ColorRect.new()
	door.size = Vector2(15, 25)
	door.position = building_pos + Vector2(32, 35)
	door.color = DOOR_COLOR
	door.z_index = BUILDING_LAYER + 2
	door.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(door)
	
	# Forge chimney with smoke effect
	var chimney = ColorRect.new()
	chimney.size = Vector2(8, 25)
	chimney.position = building_pos + Vector2(60, -25)
	chimney.color = Color(0.3, 0.3, 0.3, 1)
	chimney.z_index = BUILDING_LAYER + 1
	chimney.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(chimney)
	
	# Sign
	_create_building_sign("FORGE", building_pos + Vector2(40, -30))

func _create_alchemist_building():
	"""Create alchemist shop building"""
	var building_pos = ALCHEMIST_POS + Vector2(-35, -55)
	
	# Main building
	var building = ColorRect.new()
	building.size = Vector2(70, 55)
	building.position = building_pos
	building.color = Color(0.7, 0.6, 0.8, 1)  # Slightly purple tint
	building.z_index = BUILDING_LAYER
	building.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(building)
	
	# Roof
	var roof = ColorRect.new()
	roof.size = Vector2(80, 15)
	roof.position = building_pos + Vector2(-5, -15)
	roof.color = Color(0.5, 0.2, 0.4, 1)  # Purple roof
	roof.z_index = BUILDING_LAYER + 1
	roof.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(roof)
	
	# Door
	var door = ColorRect.new()
	door.size = Vector2(15, 25)
	door.position = building_pos + Vector2(27, 30)
	door.color = DOOR_COLOR
	door.z_index = BUILDING_LAYER + 2
	door.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(door)
	
	# Windows
	var window1 = ColorRect.new()
	window1.size = Vector2(12, 12)
	window1.position = building_pos + Vector2(10, 15)
	window1.color = WINDOW_COLOR
	window1.z_index = BUILDING_LAYER + 2
	window1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(window1)
	
	var window2 = ColorRect.new()
	window2.size = Vector2(12, 12)
	window2.position = building_pos + Vector2(48, 15)
	window2.color = WINDOW_COLOR
	window2.z_index = BUILDING_LAYER + 2
	window2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(window2)
	
	# Add collision for building
	_add_building_collision(building)
	
	# Sign
	_create_building_sign("ELIXIRS", building_pos + Vector2(35, -25))

func _create_merchant_building():
	"""Create general merchant building"""
	var building_pos = MERCHANT_POS + Vector2(-45, -65)
	
	# Main building (larger)
	var building = ColorRect.new()
	building.size = Vector2(90, 65)
	building.position = building_pos
	building.color = Color(0.8, 0.8, 0.6, 1)  # Yellowish
	building.z_index = BUILDING_LAYER
	building.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(building)
	
	# Roof
	var roof = ColorRect.new()
	roof.size = Vector2(100, 15)
	roof.position = building_pos + Vector2(-5, -15)
	roof.color = Color(0.7, 0.4, 0.2, 1)  # Brown roof
	roof.z_index = BUILDING_LAYER + 1
	roof.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(roof)
	
	# Double doors
	var door1 = ColorRect.new()
	door1.size = Vector2(12, 25)
	door1.position = building_pos + Vector2(32, 40)
	door1.color = DOOR_COLOR
	door1.z_index = BUILDING_LAYER + 2
	door1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(door1)
	
	var door2 = ColorRect.new()
	door2.size = Vector2(12, 25)
	door2.position = building_pos + Vector2(46, 40)
	door2.color = DOOR_COLOR
	door2.z_index = BUILDING_LAYER + 2
	door2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(door2)
	
	# Multiple windows
	for i in range(3):
		var window = ColorRect.new()
		window.size = Vector2(10, 10)
		window.position = building_pos + Vector2(15 + i * 20, 20)
		window.color = WINDOW_COLOR
		window.z_index = BUILDING_LAYER + 2
		window.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(window)
	
	# Add collision for building
	_add_building_collision(building)
	
	# Sign
	_create_building_sign("GENERAL STORE", building_pos + Vector2(45, -25))

func _create_guard_post():
	"""Create guard post structure"""
	var building_pos = GUARD_POST_POS + Vector2(-30, -50)
	
	# Watchtower base
	var base = ColorRect.new()
	base.size = Vector2(60, 40)
	base.position = building_pos
	base.color = STONE_COLOR
	base.z_index = BUILDING_LAYER
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(base)
	
	# Tower top
	var tower = ColorRect.new()
	tower.size = Vector2(40, 30)
	tower.position = building_pos + Vector2(10, -30)
	tower.color = STONE_COLOR
	tower.z_index = BUILDING_LAYER + 1
	tower.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tower)
	
	# Flag pole
	var pole = ColorRect.new()
	pole.size = Vector2(3, 20)
	pole.position = building_pos + Vector2(28, -50)
	pole.color = Color(0.4, 0.2, 0.1, 1)
	pole.z_index = BUILDING_LAYER + 2
	pole.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(pole)
	
	# Flag
	var flag = ColorRect.new()
	flag.size = Vector2(15, 10)
	flag.position = building_pos + Vector2(31, -45)
	flag.color = Color(0.8, 0.2, 0.2, 1)  # Red flag
	flag.z_index = BUILDING_LAYER + 2
	flag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flag)
	
	# Add collision for guard post
	_add_building_collision(base)

func _create_citizen_house():
	"""Create residential house"""
	var building_pos = CITIZEN_HOUSE_POS + Vector2(-35, -55)
	
	# Main house
	var building = ColorRect.new()
	building.size = Vector2(70, 55)
	building.position = building_pos
	building.color = Color(0.9, 0.8, 0.7, 1)  # Cream color
	building.z_index = BUILDING_LAYER
	building.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(building)
	
	# Roof
	var roof = ColorRect.new()
	roof.size = Vector2(80, 15)
	roof.position = building_pos + Vector2(-5, -15)
	roof.color = Color(0.3, 0.5, 0.3, 1)  # Green roof
	roof.z_index = BUILDING_LAYER + 1
	roof.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(roof)
	
	# Door
	var door = ColorRect.new()
	door.size = Vector2(15, 25)
	door.position = building_pos + Vector2(27, 30)
	door.color = Color(0.6, 0.4, 0.2, 1)  # Lighter door
	door.z_index = BUILDING_LAYER + 2
	door.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(door)
	
	# Garden area
	var garden = ColorRect.new()
	garden.size = Vector2(25, 15)
	garden.position = building_pos + Vector2(-30, 25)
	garden.color = Color(0.2, 0.5, 0.2, 1)  # Dark green
	garden.z_index = GROUND_LAYER + 10
	garden.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(garden)
	
	# Add collision for house
	_add_building_collision(building)

func _create_dungeon_entrance_structure():
	"""Create impressive dungeon entrance"""
	var entrance_pos = DUNGEON_ENTRANCE_POS + Vector2(-50, -80)
	
	# Stone archway
	var arch_left = ColorRect.new()
	arch_left.size = Vector2(15, 60)
	arch_left.position = entrance_pos
	arch_left.color = Color(0.3, 0.3, 0.3, 1)  # Dark stone
	arch_left.z_index = BUILDING_LAYER
	arch_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(arch_left)
	
	var arch_right = ColorRect.new()
	arch_right.size = Vector2(15, 60)
	arch_right.position = entrance_pos + Vector2(85, 0)
	arch_right.color = Color(0.3, 0.3, 0.3, 1)
	arch_right.z_index = BUILDING_LAYER
	arch_right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(arch_right)
	
	var arch_top = ColorRect.new()
	arch_top.size = Vector2(100, 15)
	arch_top.position = entrance_pos + Vector2(0, -15)
	arch_top.color = Color(0.3, 0.3, 0.3, 1)
	arch_top.z_index = BUILDING_LAYER
	arch_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(arch_top)
	
	# Dark entrance
	var entrance_dark = ColorRect.new()
	entrance_dark.size = Vector2(70, 45)
	entrance_dark.position = entrance_pos + Vector2(15, 15)
	entrance_dark.color = Color(0.1, 0.1, 0.1, 1)  # Very dark
	entrance_dark.z_index = BUILDING_LAYER - 5
	entrance_dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(entrance_dark)
	
	# Warning signs
	_create_building_sign("DANGER", entrance_pos + Vector2(20, -35))
	_create_building_sign("DUNGEON ENTRANCE", entrance_pos + Vector2(50, -50))

func _create_decorations():
	"""Add decorative elements around town"""
	# Trees around the perimeter
	var tree_positions = [
		Vector2(100, 100), Vector2(150, 120), Vector2(750, 150),
		Vector2(800, 350), Vector2(100, 450), Vector2(200, 500),
		Vector2(700, 450), Vector2(850, 100)
	]
	
	for pos in tree_positions:
		_create_tree(pos)
	
	# Well in town square
	_create_well(Vector2(500, 300))
	
	# Flower patches
	var flower_positions = [
		Vector2(250, 200), Vector2(550, 180), Vector2(350, 350),
		Vector2(450, 400), Vector2(650, 280)
	]
	
	for pos in flower_positions:
		_create_flower_patch(pos)

func _create_tree(pos: Vector2):
	"""Create a simple tree decoration"""
	# Trunk
	var trunk = ColorRect.new()
	trunk.size = Vector2(8, 20)
	trunk.position = pos
	trunk.color = Color(0.4, 0.2, 0.1, 1)
	trunk.z_index = DECORATION_LAYER
	trunk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(trunk)
	
	# Leaves
	var leaves = ColorRect.new()
	leaves.size = Vector2(25, 25)
	leaves.position = pos + Vector2(-8, -20)
	leaves.color = Color(0.2, 0.6, 0.2, 1)
	leaves.z_index = DECORATION_LAYER
	leaves.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(leaves)

func _create_well(pos: Vector2):
	"""Create a town well"""
	# Well base
	var well_base = ColorRect.new()
	well_base.size = Vector2(20, 20)
	well_base.position = pos
	well_base.color = STONE_COLOR
	well_base.z_index = DECORATION_LAYER + 5
	well_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(well_base)
	
	# Well rim
	var well_rim = ColorRect.new()
	well_rim.size = Vector2(24, 24)
	well_rim.position = pos + Vector2(-2, -2)
	well_rim.color = Color(0.4, 0.4, 0.4, 1)
	well_rim.z_index = DECORATION_LAYER + 4
	well_rim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(well_rim)

func _create_flower_patch(pos: Vector2):
	"""Create a small flower decoration"""
	var patch = ColorRect.new()
	patch.size = Vector2(15, 15)
	patch.position = pos
	patch.color = Color(0.8, 0.3, 0.6, 1)  # Pink flowers
	patch.z_index = DECORATION_LAYER
	patch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(patch)

func _create_building_sign(text: String, pos: Vector2):
	"""Create a sign for buildings"""
	# Sign background
	var sign_bg = ColorRect.new()
	sign_bg.size = Vector2(text.length() * 8 + 10, 20)
	sign_bg.position = pos + Vector2(-sign_bg.size.x/2, 0)
	sign_bg.color = Color(0.8, 0.7, 0.5, 0.9)
	sign_bg.z_index = BUILDING_LAYER + 10
	sign_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sign_bg)
	
	# Sign text
	var sign_text = Label.new()
	sign_text.text = text
	sign_text.position = pos + Vector2(-sign_bg.size.x/2 + 5, 2)
	sign_text.add_theme_font_size_override("font_size", 10)
	sign_text.modulate = Color(0.2, 0.2, 0.2, 1)
	sign_text.z_index = BUILDING_LAYER + 11
	add_child(sign_text)

func _add_building_collision(building: ColorRect):
	"""Add collision to a building so player can't walk through it"""
	var collision_body = StaticBody2D.new()
	collision_body.position = building.position + building.size / 2
	collision_body.collision_layer = 2  # Wall layer
	collision_body.collision_mask = 0
	
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = building.size
	collision_shape.shape = shape
	
	collision_body.add_child(collision_shape)
	add_child(collision_body)
	print("HometownVisuals: Added collision for building at ", collision_body.position, " size ", shape.size)
