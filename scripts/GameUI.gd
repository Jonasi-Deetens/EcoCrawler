extends Control

# GameUI - handles only UI updates and interactions
# Single responsibility: UI management

signal back_to_menu_requested

@onready var room_label: Label = $RoomLabel
@onready var back_button: Button = $BackButton

func _ready():
	# Connect UI button signals
	back_button.pressed.connect(_on_back_button_pressed)

func update_room_label(room_number: String):
	"""Update the room label with the current room number"""
	room_label.text = "Room " + room_number

func _on_back_button_pressed():
	"""Handle back button press"""
	back_to_menu_requested.emit() 