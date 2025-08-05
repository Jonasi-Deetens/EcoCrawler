extends Area2D

# ExitHandler - handles only exit detection and triggers
# Single responsibility: Exit collision detection

signal exit_triggered(direction: String)

@export var exit_direction: String = "north"

func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# Only trigger if the player entered the exit
	if body.has_method("get_class") and body.get_class() == "CharacterBody2D":
		print("Player entered ", exit_direction, " exit")
		exit_triggered.emit(exit_direction) 