extends CharacterBody2D

# Player script - handles only player movement and physics
# Single responsibility: Player movement and collision

var speed = 200.0

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
