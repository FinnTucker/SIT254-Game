extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer = get_tree().create_timer(10)
	
	await timer.timeout
	var error = get_tree().change_scene_to_file("res://scenes/game.tscn")
	if error != OK:
		push_error("failed to change scene to game scene")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
