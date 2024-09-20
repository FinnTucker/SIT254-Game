extends CharacterBody2D
class_name Player

var max_health = 100
var health = max_health


var solar_rifle_equipped = false
var solar_rifle_cooldown = true
var solar_projectile = preload("res://scenes/solar_projectile.tscn")
var max_solar_energy = 100
var solar_energy = max_solar_energy
var solar_recharge_rate = 10
var solar_drain_rate = 20
var is_in_sunlight = false

var mouse_loc_from_player = null
var radius = 5
var inventory: Array = []

const JUMP_VELOCITY = -300.0
const SPEED = 130.0
const WEAPON_SMOOTHING = 0.05
const WEAPON_FOLLOW_SPEED = 10
var direction = Input.get_axis("move_left", "move_right")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var solar_weapon: Sprite2D = $solar_weapon
@onready var marker_2d: Marker2D = $solar_weapon/Marker2D
@onready var timer: Timer = $Timer
@onready var ray_cast_up_charge: RayCast2D = $solar_weapon/RayCastUpCharge

func _ready():
	add_to_group("Player")
	

func _physics_process(delta):
	move(delta)
	move_and_slide()
	handle_solar_recharge(delta)
	mouse_loc_from_player = get_global_mouse_position() - self.position
	
	if Input.is_action_just_pressed("unequip_weapon"):
		if solar_rifle_equipped:
			solar_rifle_equipped = false
			$solar_weapon.visible = false
		else:
			solar_rifle_equipped = true
			$solar_weapon.visible = true

	var mouse_position = get_global_mouse_position()
	$solar_weapon.look_at(mouse_position)
	var marker2d = marker_2d.get_position()
	if Input.is_action_just_pressed("shoot") and solar_rifle_equipped and solar_rifle_cooldown:
		solar_rifle_cooldown = false
		var solar_projectile_instance = solar_projectile.instantiate()
		solar_projectile_instance.position = $solar_weapon/Marker2D.global_position
		solar_projectile_instance.rotation = $solar_weapon.global_rotation
		get_tree().current_scene.add_child(solar_projectile_instance)
		
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

func _process(delta: float) -> void:
		var mouse_pos = get_global_mouse_position()
		var player_pos = self.global_transform.origin 
		var distance = player_pos.distance_to(mouse_pos) 
		var mouse_dir = (mouse_pos - player_pos).normalized()
		if distance > radius:
			mouse_pos = player_pos + (mouse_dir * radius) + Vector2(0, -5)
		
		var angle = atan2(mouse_dir.y, mouse_dir.x)
		$solar_weapon.global_transform.origin = mouse_pos
		$solar_weapon.rotation = angle

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()
	else:
		print("player hurt! health remaining: ", health)


func die():
	print("You DIED")
	Engine.time_scale = 0.5
	get_node("CollisionShape2D").queue_free()
	timer.start()
	Engine.time_scale = 1
	get_tree().reload_current_scene()
	
func handle_solar_recharge(delta):
	if is_in_sunlight:
		solar_energy = min(solar_energy + solar_recharge_rate * delta, max_solar_energy)
		#add visual feedback for charging
	solar_energy = max(solar_energy - solar_drain_rate * delta, 0)

func add_item_to_inventory(item_name: String, item_type: String) -> void:
	inventory.append({"name": item_name, "type": item_type})
	print("Added to inventory: ", item_name, "of type: ", item_type)
	
