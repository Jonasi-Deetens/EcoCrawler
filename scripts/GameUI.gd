extends Control

# GameUI - Manages UI elements in the dungeon
# Single responsibility: UI management and user feedback

@onready var room_label: Label = $RoomLabel
@onready var back_button: Button = $BackButton

signal back_to_menu_requested

func _ready():
	# Connect button signals
	back_button.pressed.connect(_on_back_button_pressed)

func update_room_label(room_number: String):
	"""Update the room label with current room number"""
	room_label.text = "Room " + room_number

func _on_back_button_pressed():
	"""Handle back button press"""
	back_to_menu_requested.emit()

# Add door instructions to the UI
func show_door_instructions():
	"""Show instructions for door interaction"""
	# Could add a temporary label or tooltip here
	print("Tip: Click on doors to open/close them!") 