extends Node2D

# Hometown - Main village hub for EcoCrawler
# Single responsibility: Manage village interactions and scene transitions

@onready var player: CharacterBody2D = $Player
@onready var dungeon_entrance_area: Area2D = $DungeonEntrance/DungeonEntranceArea

signal enter_dungeon_requested
signal back_to_menu_requested

func _ready():
	print("Hometown: Initializing village...")
	
	# Connect dungeon entrance signal
	dungeon_entrance_area.body_entered.connect(_on_dungeon_entrance_entered)
	
	print("Hometown: Village ready!")

func _input(event):
	"""Handle global input events"""
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()

func _on_back_button_pressed():
	"""Return to main menu"""
	print("Hometown: Returning to menu...")
	back_to_menu_requested.emit()
	get_tree().change_scene_to_file("res://scenes/MenuScreen.tscn")

func _on_dungeon_entrance_entered(body: Node2D):
	"""Handle player entering dungeon entrance"""
	if body == player:
		print("Hometown: Player entering dungeon...")
		enter_dungeon_requested.emit()
		# Defer the scene change to avoid physics callback issues
		call_deferred("_change_to_dungeon")

func _change_to_dungeon():
	"""Change to dungeon scene (called deferred)"""
	get_tree().change_scene_to_file("res://scenes/DungeonRoom.tscn") 
