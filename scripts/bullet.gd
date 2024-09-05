extends Area2D

const BULLET_SPEED = 300.0

func _ready():
	top_level = true

func _physics_process(delta):
	await(get_tree().create_timer(0.01), "timeout")
	$sprite.frame = 1
	set_physics_process(false)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
