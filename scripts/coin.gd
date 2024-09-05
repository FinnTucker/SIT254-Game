extends Area2D

@onready var HUD: CanvasLayer = $"../../Player/Camera2D/HUD"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(_player):
	HUD.add_point()
	animation_player.play("pickup")
