extends CharacterBody2D

# Player script - handles only player movement and physics
# Single responsibility: Player movement and collision

var speed = 200.0

func _ready():
	# Set collision layers for proper NPC interaction
	collision_layer = 1  # Player layer
	collision_mask = 6   # Collide with walls (layer 2) and doors (layer 4) - includes NPCs on layer 2
	print("Player collision layers set: layer=1, mask=6 (walls+doors+NPCs)")
	
	# Set z-index to ensure player is above all visual elements but below UI
	z_index = 15
	print("Player z-index set to: ", z_index)

func _physics_process(_delta):
	# Handle movement input
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	# Normalize diagonal movement and apply speed
	if direction.length() > 0:
		velocity = direction.normalized() * speed
	else:
		velocity = Vector2.ZERO
	
	# Move and handle collisions
	move_and_slide() 
