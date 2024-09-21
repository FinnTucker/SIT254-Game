extends CanvasLayer

var score = 0
var player: Node = null

@onready var score_label: Label = $ScoreLabel
@onready var HUD: CanvasLayer = $"."
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthBar/NumericalHealth
@onready var weapon_charge_bar: ProgressBar = $WeaponChargeBar
@onready var weapon_charge_label: Label = $WeaponChargeBar/NumericalCharge
@onready var sunlight_icon: Sprite2D = $SunlightIcon
@onready var shadow_icon: Sprite2D = $ShadowIcon
@onready var inventory_container: Control = $InventoryContainer
@onready var crafting_container: Control = $CraftingContainer


var menu_visible: bool = false

func _ready():
	player = get_node("../Player")
	health_bar.max_value = player.max_health
	health_bar.value = player.health
	health_label.text = str(player.health)
	
	player.connect("health_changed", Callable(self, "_on_health_changed"))
	
	weapon_charge_bar.max_value = player.max_solar_energy
	weapon_charge_bar.value = player.solar_energy
	
	weapon_charge_label.text = str(player.solar_energy)
	player.connect("solar_charge_changed", Callable(self, "_on_solar_charge_changed"))
	
	update_sunlight_icons(player.is_in_sunlight)
	player.connect("sunlight_changed", Callable(self, "_on_sunlight_changed"))

func _process(delta):
	if Input.is_action_just_pressed("toggle_menu"):
		print("toggling menu state. current state before toggle: ", menu_visible)
		_toggle_menu()

func _toggle_menu():
	if menu_visible == false:
		menu_visible = true
	else:
		menu_visible = false
	print("toggling menu: new state: ", menu_visible)
	
	inventory_container.visible = menu_visible
	crafting_container.visible = menu_visible
	


func _on_health_changed(new_health: int):
	health_bar.value = new_health
	health_label.text = str(new_health)

func _on_solar_charge_changed(new_charge: int):
	weapon_charge_bar.value = new_charge
	weapon_charge_label.text = str(new_charge)

func _on_sunlight_changed(is_in_sunlight: bool):
	update_sunlight_icons(is_in_sunlight)
	
func update_sunlight_icons(is_in_sunlight: bool):
	if is_in_sunlight:
		sunlight_icon.visible = true
		shadow_icon.visible = false
	else:
		sunlight_icon.visible = false
		shadow_icon.visible = true
	


func add_point():
	score += 1
	print(score)
	score_label.text = "You collected " + str(score) + " coins." 
