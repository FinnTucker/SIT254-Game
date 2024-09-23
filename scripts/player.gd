extends CharacterBody2D
class_name Player
signal health_changed(new_health: int)
signal solar_charge_changed(new_charge: int)
signal sunlight_changed(is_in_sunlight: bool)

var max_health = 100
var health = max_health


var solar_rifle_equipped = false
var solar_rifle_cooldown = true
var solar_projectile = preload("res://scenes/solar_projectile.tscn")
var max_solar_energy = 100
var solar_energy = max_solar_energy
var solar_recharge_rate = 20
var solar_drain_rate = 2
var is_in_sunlight = false

var kickback_strength = 300.0

var mouse_loc_from_player = null
var radius = 5
var inventory: Dictionary = {}
var crafting_recipes = {
	"Health Pack": {
		"Common Item": 2,
		"Rare Item": 1
	},
	"Damage Boost": {
		"Rare Item": 1,
		"Unique Item": 1
	}
}

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
@onready var ray_cast_up_charge: RayCast2D = $RayCastUpCharge
@onready var item_list: ItemList = $"../HUD/InventoryContainer/ItemList"

func _ready():
	add_to_group("Player")
	$solar_weapon.visible = false
	health = max_health
	solar_energy = max_solar_energy
	if item_list == null:
		print("error: item list null")
	else:
		print("itemlist initialised correctly")

func _physics_process(delta):
	move(delta)
	move_and_slide()
	detect_sunlight()
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
	if Input.is_action_just_pressed("shoot") and solar_rifle_equipped and solar_rifle_cooldown and solar_energy >= 20:
		solar_rifle_cooldown = false
		solar_energy = max(solar_energy - 20, 0)
		emit_signal("solar_charge_changed", solar_energy)
		print("weapon fired. charge remaining: ", solar_energy)
		var solar_projectile_instance = solar_projectile.instantiate()
		solar_projectile_instance.position = $solar_weapon/Marker2D.global_position
		solar_projectile_instance.rotation = $solar_weapon.global_rotation
		get_tree().current_scene.add_child(solar_projectile_instance)
		
		apply_kickback(mouse_position)
		
		await get_tree().create_timer(0.4).timeout
		solar_rifle_cooldown = true
	elif Input.is_action_just_pressed("shoot") and solar_rifle_equipped: 
		print("not enough charge")
	
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

func take_damage(amount: int):
		health -= amount
		health = clamp(health, 0, max_health)
		emit_signal("health_changed", health)
		if health <= 0:
			die()
		else:
			print("player hurt! health remaining: ", health)


func die():
	print("You DIED")
	Engine.time_scale = 0.5
	get_node("CollisionShape2D").queue_free()
	timer.start()


	
func detect_sunlight():
	ray_cast_up_charge.force_raycast_update()
	var previous_sunlight_status = is_in_sunlight
	
	if ray_cast_up_charge.is_colliding():
		is_in_sunlight = false
		
	else:
		is_in_sunlight = true
	
	if is_in_sunlight != previous_sunlight_status:
		emit_signal("sunlight_changed", is_in_sunlight)
	
func handle_solar_recharge(delta):
	var previous_solar_energy = solar_energy
	if is_in_sunlight:
		solar_energy = min(solar_energy + solar_recharge_rate * delta, max_solar_energy)
		#add visual feedback for charging
	solar_energy = max(solar_energy - solar_drain_rate * delta, 0)
	
	if solar_energy != previous_solar_energy:
		emit_signal("solar_charge_changed", solar_energy)

func add_item_to_inventory(item_name: String, item_type: String) -> void:
	if item_name in inventory:
		inventory[item_name]["quantity"] +=1
	else:
		inventory[item_name] = {"type": item_type, "quantity": 1}
	print("Added to inventory: ", item_name, " of type: ", item_type)
	update_inventory_ui(inventory)
	
func remove_item_from_inventory(item_name: String, quantity: int =1) -> bool:
	if item_name in inventory and inventory[item_name]["quantity"] >= quantity:
		inventory[item_name]["quantity"] -= quantity
		if inventory[item_name]["quantity"] <= 0:
			inventory.erase(item_name)
		print("Removed", quantity, " of ", item_name, " from inventory.")
		update_inventory_ui(inventory)
		return true
	else:
		print("Item not found in inventory or insufficient quantity.")
		return false

func craft_item(item_name: String) -> bool:
	if not crafting_recipes.has(item_name):
		print("Recipe not found for item: ", item_name)
		return false
	
	var recipe = crafting_recipes[item_name]
	
	for ingredient_name in recipe.keys():
		var required_quantity = recipe[ingredient_name]
		if not inventory.has(ingredient_name) or inventory[ingredient_name]["quantity"] < required_quantity:
			print("Not enough ", ingredient_name, " to craft ", item_name)
			return false
			
	for ingredient_name in recipe.keys():
		remove_item_from_inventory(ingredient_name, recipe[ingredient_name])
		
	add_item_to_inventory(item_name, "usable")
	print("Successfully crafted: ", item_name)
	
	var hud = get_node("../HUD/InventoryContainer")
	hud.update_inventory_ui(inventory)
	return true
		

func update_inventory_ui(inventory: Dictionary):
	var ui_node = get_node("../HUD/InventoryContainer")
	ui_node.update_inventory_ui(inventory)

func apply_kickback(mouse_position: Vector2):

	var player_pos = self.global_position
	var firing_dir = (mouse_position - player_pos).normalized()
	var kickback_dir = -firing_dir
	velocity += kickback_dir * kickback_strength

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()

func _on_craft_health_pack_button_pressed() -> void:
	craft_item("Health Pack")

func _on_craft_damage_boost_button_pressed() -> void:
	craft_item("Damage Boost")

func use_item(item_name: String):
	if inventory.has(item_name):
		var item_data = inventory[item_name]
		
		if item_data["type"] == "usable":
			if item_name == "Health Pack":
				use_health_pack()
			elif item_name == "Damage Boost":
				use_damage_boost()
			else:
				print("no logic define for this item.")
		else:
			print(item_name, " is a crafting item and cannot be used directly.")
	else:
		print("item not found in inventory (method use_item).")

func use_health_pack():
	if inventory.has("Health Pack"):
		if inventory["Health Pack"]["quantity"] > 0:
			health = min(health + 30, max_health)
			
			remove_item_from_inventory("Health Pack", 1)
			
			emit_signal("health_changed", health)
			print("used health pack. new health: ", health)
		else:
			print("no health packs available")
	else:
		print("no health packs in inventory.")

func use_damage_boost():
	if inventory.has("Damage Boost"):
		if inventory["Damage Boost"]["quantity"] > 0:
			
			remove_item_from_inventory("Damage Boost", 1)
			
			print("used damage boost. damage increased")
		else:
			print("no damage boost available")
	else:
		print("no damage boost in inventory")
			


func _on_item_list_item_selected(index: int) -> void:
	var item_name = item_list.get_item_text(index)
	handle_item_selection(item_name)
	
func handle_item_selection(item_name: String):
	var name_parts = item_name.split(" x")
	item_name = name_parts[0]
	
	if item_name.begins_with("[Usable] "):
		item_name = item_name.substr(9, item_name.length() - 9)
	elif item_name.begins_with("[Crafting] "):
		item_name = item_name.substr(9, item_name.length() - 11)
	print("selected item from item list: ", item_name)
	if inventory.has(item_name):
		var item_data = inventory[item_name]
	
		if item_data["type"] == "usable":
			print(item_name, " is a usable item.")
			use_item(item_name)
		elif item_data["type"] == "crafting":
			print(item_name, " is a crafting material and cannot be used directly")
		else:
			print("unkown item type")
	else:
		print("item not found in inventory (method handle_item_selection)")
