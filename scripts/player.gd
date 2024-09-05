extends CharacterBody2D
class_name Player

var solar_rifle_equipped = false
var solar_rifle_cooldown = true
var solar_projectile = preload("res://scenes/solar_projectile.tscn")
var mouse_loc_from_player = null

var inventory: Array = []
const JUMP_VELOCITY = -300.0
const SPEED = 130.0
var direction = Input.get_axis("move_left", "move_right")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	move(delta)
	move_and_slide()
	
	mouse_loc_from_player = get_global_mouse_position() - self.position
	print(mouse_loc_from_player)
	
	if Input.is_action_just_pressed("unequip_weapon"):
		if solar_rifle_equipped:
			solar_rifle_equipped = false
		else:
			solar_rifle_equipped = true

	var mouse_position = get_global_mouse_position()
	$solar_weapon/Marker2D.look_at(mouse_position)
	if Input.is_action_just_pressed("shoot") and solar_rifle_equipped and solar_rifle_cooldown:
		solar_rifle_cooldown = false
		var solar_projectile_instance = solar_projectile.instantiate()
		solar_projectile_instance.rotation = $solar_weapon/Marker2D.rotation
		solar_projectile_instance.global_position = $solar_weapon/Marker2D.global_position
		add_child(solar_projectile_instance)
		
		await get_tree().create_timer(0.4).timeout
		solar_rifle_cooldown = true
	
func move(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction which can be -1, 0, 1
	direction = Input.get_axis("move_left", "move_right")
	
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
	
