extends CharacterBody2D

class_name enemy

enum State {
	IDLE,
	CHASING,
	ATTACKING
}
# Variables
const RARE_ITEM = preload("res://scenes/rare_item.tscn")
const COMMON_ITEM = preload("res://scenes/common_item.tscn")
const UNIQUE_ITEM = preload("res://scenes/unique_item.tscn")
const HEALTH_PACK = preload("res://scenes/health_pack.tscn")
const ENEMY_HEALTH_BAR = preload("res://scenes/enemy_health_bar.tscn")
const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite: AnimatedSprite2D = $enemy_animation
var state = State.IDLE
var player = null
var speed = 50
var attack_range = 20
var detection_range = 100
var attack_cooldown = 1.0
var time_since_last_attack = 0.0
var max_health = 100
var health = max_health

@onready var health_label = null
@onready var health_bar_ui = null
@onready var health_bar = null
@onready var camera: Camera2D = get_viewport().get_camera_2d()

func _ready():
	# Obtain a reference to the player node
	player = get_node("/root/Game/Player")  # Adjust the path to your player node
	add_to_group("Enemies")
	var health_bar_instance = ENEMY_HEALTH_BAR.instantiate()
	var hud_node = get_tree().root.get_node("/root/Game/HUD")
	if hud_node:
		hud_node.add_child(health_bar_instance)
	else:
		print("hud node not found")
	
	health_bar_ui = health_bar_instance
	
	health_bar = health_bar_ui.get_node("HealthBar")
	health_label = health_bar_ui.get_node("HealthBar/HealthLabel")
	
	
	health_bar.max_value = max_health
	health_bar.value = health
	health_label.text = str(health)
	
	# store reference for updating
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	time_since_last_attack += delta
	
	match state:
		State.IDLE:
			idle_behaviour()
		State.CHASING:
			chasing_behaviour()
		State.ATTACKING:
			attacking_behaviour()
	
	
	update_state()
	
	move_and_slide()

func idle_behaviour():
	if not animated_sprite.is_playing() or animated_sprite.animation != "idle":
		animated_sprite.play("idle")
		velocity = Vector2.ZERO

func chasing_behaviour():
	if not animated_sprite.is_playing() or animated_sprite.animation != "idle":
		animated_sprite.play("chase")
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * speed

func attacking_behaviour():
	if not animated_sprite.is_playing() or animated_sprite.animation != "attack":
		animated_sprite.play("attack")
	if time_since_last_attack >= attack_cooldown:
		perform_attack()
		time_since_last_attack = 0.0


func update_state():
	var distance_to_player = global_position.distance_to(player.global_position)
	
	match state:
		State.IDLE:
			if distance_to_player < detection_range:
				state = State.CHASING
		State.CHASING:
			if distance_to_player < attack_range:
				state = State.ATTACKING
			elif distance_to_player > detection_range + 50:
				state = State.IDLE
		State.ATTACKING:
			if distance_to_player > attack_range:
				state = State.CHASING

func perform_attack():
	if player.has_method("take_damage"):
		player.take_damage(10)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func take_damage(amount):
	health -= amount
	health = clamp (health, 0, max_health)
	
	if health_bar:
		health_bar.value = health
	else:
		push_error("HealthBar node not found in EnemyHealthBar")
		
	if health_label:
		health_label.text = str(health)
	else:
		push_error("HealthLabel node not found.")
	if health <= 0:
		die()
	else:
		animated_sprite.play("hurt")
		print("enemy hurt! health remaining: ", health)

func die():
	print("enemy defeated")
	drop_item()
	self.queue_free()
	
func drop_item():
	var random_number = randi() % 100
	if random_number < 15:
		var rare_item = RARE_ITEM.instantiate()
		rare_item.global_position = global_position
		get_parent().call_deferred("add_child", rare_item)
	elif random_number < 65:
		var common_item = COMMON_ITEM.instantiate()
		common_item.global_position = global_position
		get_parent().call_deferred("add_child", common_item)
	elif random_number < 95:
		var health_pack = HEALTH_PACK.instantiate()
		health_pack.global_position = global_position
		get_parent().call_deferred("add_child", health_pack)
	else:
		var unique_item = UNIQUE_ITEM.instantiate()
		unique_item.global_position = global_position
		get_parent().call_deferred("add_child", unique_item)
	
		
