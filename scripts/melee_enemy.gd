extends CharacterBody2D
@onready var character_body_2d: CharacterBody2D = $"."


enum State {
	IDLE,
	CHASING,
	ATTACKING
}
# Variables
@onready var animated_sprite: AnimatedSprite2D = $enemy_animation
var state = State.IDLE
var player = null
var speed = 50
var attack_range = 20
var detection_range = 100
var attack_cooldown = 1.0
var time_since_last_attack = 0.0
var health = 100
const SPEED = 200.0
const JUMP_VELOCITY = -400.0

func _ready():
	# Obtain a reference to the player node
	player = get_node("/root/Game/Player")  # Adjust the path to your player node
	add_to_group("Enemies")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	time_since_last_attack += delta
	
	match state:
		State.IDLE:
			idle_behaviour(delta)
		State.CHASING:
			chasing_behaviour(delta)
		State.ATTACKING:
			attacking_behaviour(delta)
	
	
	update_state()
	
	move_and_slide()

func idle_behaviour(delta):
	if not animated_sprite.is_playing() or animated_sprite.animation != "idle":
		animated_sprite.play("idle")
		velocity = Vector2.ZERO

func chasing_behaviour(delta):
	if not animated_sprite.is_playing() or animated_sprite.animation != "idle":
		animated_sprite.play("chase")
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * speed

func attacking_behaviour(delta):
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

	move_and_slide()

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()
	else:
		animated_sprite.play("hurt")
		print("enemy hurt! health remaining: ", health)

func die():
	print("enemy defeated")
	character_body_2d.queue_free()
