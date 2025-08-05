extends CharacterBody2D
class_name NPC

# NPC - Reusable base class for all non-player characters
# Single responsibility: Handle NPC behavior, interaction, and state management

@export var npc_name: String = "Unknown NPC"
@export var npc_type: String = "generic"  # vendor, guard, citizen, etc.
@export var interaction_radius: float = 80.0
@export var can_interact: bool = true

# Visual and dialogue
@export var sprite_texture: Texture2D
@export var dialogue_lines: Array[String] = []
@export var interaction_prompt: String = "Press E to interact"

# NPC state
var is_player_nearby: bool = false
var is_interacting: bool = false
var current_dialogue_index: int = 0

# Components
var interaction_area: Area2D
var sprite: Sprite2D
var collision_shape: CollisionShape2D
var prompt_label: Label

# Signals
signal interaction_started(npc: NPC)
signal interaction_ended(npc: NPC)
signal dialogue_advanced(npc: NPC, line: String)

func _init():
	name = "NPC_" + npc_name.replace(" ", "_")

func _ready():
	_setup_npc_components()

func _setup_npc_components():
	"""Set up NPC visual and interaction components"""
	print("=== Setting up NPC components for ", npc_name, " ===")
	
	# Set collision layers for the CharacterBody2D
	collision_layer = 2  # NPC physics layer
	collision_mask = 0   # NPCs don't need to collide with anything
	z_index = 16  # Above player but below UI
	print("Set collision layers and z-index for ", npc_name)
	
	# Collision for physics
	collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(32, 32)
	collision_shape.shape = shape
	add_child(collision_shape)
	
	# Sprite
	sprite = Sprite2D.new()
	if sprite_texture:
		sprite.texture = sprite_texture
		add_child(sprite)
	else:
		# Default colored rectangle if no texture
		var color_rect = ColorRect.new()
		color_rect.size = Vector2(32, 32)
		color_rect.position = Vector2(-16, -16)
		color_rect.color = _get_npc_color()
		add_child(color_rect)
	
	print("Created visual representation for ", npc_name)
	
	# Interaction area
	interaction_area = Area2D.new()
	interaction_area.name = "InteractionArea"
	interaction_area.collision_layer = 8  # NPC interaction layer
	interaction_area.collision_mask = 1   # Detect player layer
	interaction_area.monitoring = true
	interaction_area.monitorable = true
	
	var area_collision = CollisionShape2D.new()
	var area_shape = CircleShape2D.new()
	area_shape.radius = interaction_radius
	area_collision.shape = area_shape
	interaction_area.add_child(area_collision)
	add_child(interaction_area)
	
	print("Created interaction area for ", npc_name, " with radius ", interaction_radius)
	
	# Connect signals immediately after creating the interaction area
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	print("Connected signals for ", npc_name, " interaction area")
	
	# Interaction prompt
	prompt_label = Label.new()
	prompt_label.text = interaction_prompt
	prompt_label.position = Vector2(-50, -60)
	prompt_label.size = Vector2(100, 20)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.modulate = Color(1, 1, 1, 0)  # Start invisible
	prompt_label.z_index = 20  # High z-index for UI elements
	add_child(prompt_label)



func _get_npc_color() -> Color:
	"""Get default color based on NPC type"""
	match npc_type:
		"vendor": return Color(0.8, 0.6, 0.2, 1)  # Golden
		"guard": return Color(0.6, 0.6, 0.8, 1)   # Blue-gray
		"citizen": return Color(0.7, 0.7, 0.7, 1) # Gray
		_: return Color(0.5, 0.8, 0.5, 1)         # Green

func _input(event):
	"""Handle interaction input"""
	if not can_interact or not is_player_nearby or is_interacting:
		return
	
	if event.is_action_pressed("interact"):  # E key
		print("Interaction triggered with ", npc_name)
		start_interaction()

func _on_player_entered(body: Node2D):
	"""Handle player entering interaction range"""
	print("Body entered ", npc_name, " area: ", body.name)
	if body.name == "Player":
		print("Player entered ", npc_name, " interaction range")
		is_player_nearby = true
		_show_interaction_prompt()

func _on_player_exited(body: Node2D):
	"""Handle player leaving interaction range"""
	print("Body exited ", npc_name, " area: ", body.name)
	if body.name == "Player":
		print("Player exited ", npc_name, " interaction range")
		is_player_nearby = false
		_hide_interaction_prompt()
		if is_interacting:
			end_interaction()

func _show_interaction_prompt():
	"""Show interaction prompt"""
	if prompt_label:
		var tween = create_tween()
		tween.tween_property(prompt_label, "modulate:a", 1.0, 0.3)

func _hide_interaction_prompt():
	"""Hide interaction prompt"""
	if prompt_label:
		var tween = create_tween()
		tween.tween_property(prompt_label, "modulate:a", 0.0, 0.3)

func start_interaction():
	"""Start interaction with this NPC"""
	if not can_interact:
		return
	
	is_interacting = true
	current_dialogue_index = 0
	interaction_started.emit(self)
	
	if dialogue_lines.size() > 0:
		dialogue_advanced.emit(self, dialogue_lines[0])
	
	print("Started interaction with ", npc_name)

func advance_dialogue():
	"""Advance to next dialogue line"""
	current_dialogue_index += 1
	
	if current_dialogue_index < dialogue_lines.size():
		dialogue_advanced.emit(self, dialogue_lines[current_dialogue_index])
	else:
		end_interaction()

func end_interaction():
	"""End interaction with this NPC"""
	is_interacting = false
	current_dialogue_index = 0
	interaction_ended.emit(self)
	print("Ended interaction with ", npc_name)

func set_dialogue(lines: Array[String]):
	"""Set dialogue lines for this NPC"""
	dialogue_lines.assign(lines)

func add_dialogue_line(line: String):
	"""Add a single dialogue line"""
	dialogue_lines.append(line)

func get_interaction_data() -> Dictionary:
	"""Get data for interaction UI"""
	return {
		"npc_name": npc_name,
		"npc_type": npc_type,
		"current_line": dialogue_lines[current_dialogue_index] if current_dialogue_index < dialogue_lines.size() else "",
		"has_more_dialogue": current_dialogue_index < dialogue_lines.size() - 1
	}

# Virtual methods for subclasses to override
func on_interaction_started():
	"""Override in subclasses for custom interaction behavior"""
	pass

func on_interaction_ended():
	"""Override in subclasses for custom cleanup"""
	pass

func on_dialogue_finished():
	"""Override in subclasses for post-dialogue actions"""
	pass