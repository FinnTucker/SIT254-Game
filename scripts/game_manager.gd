extends Node

signal start_game


var score = 0
var player: Node = null
@onready var score_label: Label = $ScoreLabel
@onready var HUD: CanvasLayer = $"."
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthBar/NumericalHealth
@onready var weapon_charge_bar: ProgressBar = $WeaponChargeBar
@onready var weapon_charge_label: Label = $WeaponChargeBar/NumericalCharge

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

func _process(delta):
	pass

func _on_health_changed(new_health: int):
	health_bar.value = new_health
	health_label.text = str(new_health)

func _on_solar_charge_changed(new_charge: int):
	weapon_charge_bar.value = new_charge
	weapon_charge_label.text = str(new_charge)
	
func new_game():
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	
func game_over():
	$HUD.show_game_over()

func add_point():
	score += 1
	print(score)
	score_label.text = "You collected " + str(score) + " coins." 
