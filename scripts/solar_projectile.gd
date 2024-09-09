extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

const SPEED = 300
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_top_level(true)

func _process(delta):
	position +=(Vector2.RIGHT*SPEED).rotated(rotation)*delta
	
	sprite_2d.rotation = rotation + (PI / 2)
	
	
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
