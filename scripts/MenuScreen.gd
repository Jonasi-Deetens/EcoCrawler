extends Control

# Menu Screen - Main orchestrator for the EcoCrawler menu
# Single responsibility: Coordinate between specialized menu components

@onready var button_manager: Control = $MenuButtonManager
@onready var particle_manager: Node2D = $ParticleEffects
@onready var animation_manager: Node = $MenuAnimationManager

func _ready():
	# Wait one frame to ensure all managers are ready
	await get_tree().process_frame
	
	print("MenuScreen: Initializing managers...")
	print("Button manager: ", button_manager)
	print("Particle manager: ", particle_manager)
	print("Animation manager: ", animation_manager)
	
	# Connect signals from specialized managers
	button_manager.button_pressed.connect(_on_button_pressed)
	button_manager.button_hovered.connect(_on_button_hovered)
	animation_manager.animation_completed.connect(_on_animation_completed)
	
	# Start particle effects
	print("Starting particle effects...")
	particle_manager.start_particle_systems()
	
	# Start title animation
	print("Starting title animation...")
	animation_manager.start_title_glow()

func _on_button_pressed(button_name: String):
	"""Handle button press events from button manager"""
	match button_name:
		"start":
			_handle_start_game()
		"tutorial":
			_handle_tutorial()
		"options":
			_handle_options()
		"quit":
			_handle_quit()

func _on_button_hovered(button_name: String):
	"""Handle button hover events from button manager"""
	# Get button position for particle effects
	var button = button_manager.get_button_by_name(button_name)
	if button:
		var button_center = button.global_position + button.size / 2
		particle_manager.create_particle_burst(button_center)
		
		# Trigger button animation
		animation_manager.animate_button_hover(button)

func _on_animation_completed(_animation_name: String):
	"""Handle animation completion events"""
	# Could be used for additional effects or state management
	pass

func _handle_start_game():
	"""Handle start game button press"""
	# Create particle burst effect
	var start_button = button_manager.get_button_by_name("start")
	if start_button:
		var button_center = start_button.global_position + start_button.size / 2
		particle_manager.create_particle_burst(button_center)
		animation_manager.animate_button_click(start_button)
	
	# Transition to the hometown
	get_tree().change_scene_to_file("res://scenes/Hometown.tscn")

func _handle_tutorial():
	"""Handle tutorial button press"""
	# TODO: Implement tutorial
	print("Tutorial - coming soon!")

func _handle_options():
	"""Handle options button press"""
	# TODO: Implement options menu
	print("Options menu - coming soon!")

func _handle_quit():
	"""Handle quit button press"""
	get_tree().quit() 
