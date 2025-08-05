extends Node

# Menu Animation Manager - Handles all menu animations and visual effects
# Single responsibility: Animation management and visual feedback

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal animation_completed(animation_name: String)

func _ready():
	# Wait one frame to ensure AnimationPlayer is ready
	await get_tree().process_frame
	# Start title glow animation
	start_title_glow()

func start_title_glow():
	"""Start the title glow animation"""
	print("MenuAnimationManager: Starting title glow animation...")
	if animation_player:
		print("AnimationPlayer found: ", animation_player)
		if animation_player.has_animation("title_glow"):
			print("title_glow animation found, playing...")
			animation_player.play("title_glow")
		else:
			print("ERROR: title_glow animation not found!")
			print("Available animations: ", animation_player.get_animation_list())
	else:
		print("ERROR: AnimationPlayer not found!")

func stop_title_glow():
	"""Stop the title glow animation"""
	if animation_player and animation_player.is_playing():
		animation_player.stop()

func animate_button_hover(button: Button):
	"""Animate button on hover"""
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
	tween.finished.connect(_on_button_animation_completed.bind("hover"))

func animate_button_click(button: Button):
	"""Animate button on click"""
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.05)
	tween.finished.connect(_on_button_animation_completed.bind("click"))

func _on_button_animation_completed(animation_type: String):
	"""Emit signal when button animation completes"""
	animation_completed.emit(animation_type) 