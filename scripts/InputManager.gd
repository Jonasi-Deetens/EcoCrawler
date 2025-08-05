extends Node

# InputManager - handles only input events
# Single responsibility: Input processing

signal escape_pressed
signal enter_pressed

func _input(event):
	"""Process input events and emit signals"""
	if event.is_action_pressed("ui_cancel"):
		escape_pressed.emit()
	elif event.is_action_pressed("ui_accept"):
		enter_pressed.emit() 