extends Area2D

# Exit Handler - Manages door states and transitions
# Single responsibility: Handle door interactions and room transitions
# Area2D: Player detection and room transitions
# StaticBody2D sibling: Physical blocking when door is closed

@export var exit_direction: String = "north"
@export var is_door_open: bool = false

@onready var door_visual: ColorRect
@onready var door_blocker: StaticBody2D  # The physical blocker

signal door_toggled(direction: String, is_open: bool)

func _ready():
	print("ExitHandler ", exit_direction, " _ready() called")
	
	# Find the ColorRect child (door visual)
	for child in get_children():
		if child is ColorRect:
			door_visual = child
			door_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block input
			print("Found door visual: ", child.name)
			break
	
	# Find the StaticBody2D sibling (door blocker)
	var parent_node = get_parent()
	for sibling in parent_node.get_children():
		if sibling != self and sibling is StaticBody2D and sibling.name.contains(exit_direction.capitalize()):
			door_blocker = sibling
			print("Found door blocker: ", sibling.name)
			break
	
	# Enable input monitoring for mouse clicks
	input_pickable = true
	monitoring = true  # Enable body detection
	
	# Connect input event signal
	input_event.connect(_on_input_event)
	
	# Connect body entered signal for room transitions
	body_entered.connect(_on_body_entered)
	
	# Set initial door state
	_update_door_visual()
	_update_door_blocking()
	
	print("ExitHandler ", exit_direction, " initialized - input_pickable: ", input_pickable)
	print("Area2D global position: ", global_position)
	print("Area2D collision shape info:")
	for child in get_children():
		if child is CollisionShape2D:
			print("  CollisionShape2D: ", child.name, " - disabled: ", child.disabled)
			if child.shape:
				print("  Shape size: ", child.shape.size)

func _on_input_event(_viewport, event, _shape_idx):
	"""Handle mouse input on door"""
	print("Input event received on ", exit_direction, " door: ", event)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Left click detected on ", exit_direction, " door!")
		toggle_door()

func _input(event):
	"""Alternative input handling - check if mouse is over this area"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = get_global_mouse_position()
		query.collision_mask = collision_layer  # Check if mouse is over this area
		
		var result = space_state.intersect_point(query)
		for body in result:
			if body.collider == self:
				print("Alternative input method - Left click detected on ", exit_direction, " door!")
				toggle_door()
				break

func _on_body_entered(body: Node2D):
	"""Handle player entering door area"""
	if body.name == "Player" and is_door_open:
		# Only allow transition if door is open
		print("Player entering ", exit_direction, " door")
		# Get the DungeonManager and change room
		var dungeon_manager = body.get_parent().get_node("DungeonManager")
		if dungeon_manager.change_room(exit_direction):
			print("Room transition successful to ", exit_direction)
			# Move player to new spawn position
			var spawn_pos = dungeon_manager.get_spawn_position(exit_direction)
			body.position = spawn_pos
			print("Player moved to spawn position: ", spawn_pos)
		else:
			print("No room available in ", exit_direction, " direction")

func toggle_door():
	"""Toggle door open/closed state"""
	is_door_open = !is_door_open
	print("Door ", exit_direction, " toggled to: ", "OPEN" if is_door_open else "CLOSED")
	
	_update_door_visual()
	_update_door_blocking()
	door_toggled.emit(exit_direction, is_door_open)

func _update_door_visual():
	"""Update door visual appearance based on state"""
	if door_visual:
		if is_door_open:
			door_visual.color = Color(0.8, 0.6, 0.2, 1)  # Golden yellow for open
		else:
			door_visual.color = Color(0.4, 0.2, 0.1, 1)  # Dark brown for closed
	else:
		print("Warning: door_visual is null for ", exit_direction, " exit")

func _update_door_blocking():
	"""Update door physical blocking based on state"""
	if door_blocker:
		# Enable collision when door is closed, disable when open
		for child in door_blocker.get_children():
			if child is CollisionShape2D:
				child.disabled = is_door_open  # disabled = true when door is open
				print("Door blocker collision ", "disabled" if is_door_open else "enabled", " for ", exit_direction)
	else:
		print("Warning: door_blocker is null for ", exit_direction, " exit")

func set_door_state(open: bool):
	"""Set door state externally"""
	is_door_open = open
	_update_door_visual()
	_update_door_blocking() 
