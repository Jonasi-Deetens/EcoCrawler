extends Area2D

# HometownUI - Handles dungeon entrance interactions
# Single responsibility: Manage entrance area interactions and feedback

func _ready():
	# Connect area signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	"""Handle player entering the dungeon entrance area"""
	if body.name == "Player":
		print("HometownUI: Player near dungeon entrance")
		# Could add visual feedback here (glow effect, text prompt, etc.)

func _on_body_exited(body: Node2D):
	"""Handle player leaving the dungeon entrance area"""
	if body.name == "Player":
		print("HometownUI: Player left dungeon entrance area") 