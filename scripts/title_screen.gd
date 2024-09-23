extends Control
@onready var start_game: Button = $StartGame


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$StartGame.connect("pressed", Callable(self, "_on_start_button_pressed"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/intro_scene.tscn")
