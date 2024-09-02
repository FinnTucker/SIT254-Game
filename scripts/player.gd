extends CharacterBody2D

var bullet = preload("res://scenes/bullet.tscn")
var b
const SPEED = 130.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = Input.get_axis("move_left", "move_right")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	move(delta)
	shoot()
	move_and_slide()

func move(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction which can be -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true	
		
	# Play Animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Apply the movement	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func shoot():
	if Input.is_action_just_pressed("shoot"):
		b = bullet.instantiate()
		
		# Set the bullet's initial position to the character's position
		b.global_position = global_position + Vector2(10, 0)
		
		# Determine the direction based on the character's facing direction
		var bullet_speed = 400.0  # Set the bullet speed
		if animated_sprite.flip_h:
			b.velocity = Vector2(-bullet_speed, 0)  # Shoot left
		else:
			b.velocity = Vector2(bullet_speed, 0)  # Shoot right
		
		# Add the bullet as a child of the current node
		add_child(b)
