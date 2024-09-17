extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

const SPEED = 300
var direction = Vector2.RIGHT # default direction
var damage = 25 # adjust as needed
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_top_level(true)
	direction = Vector2.RIGHT.rotated(rotation)
	set_process(true)

func _process(delta):
	#position +=(Vector2.RIGHT*SPEED).rotated(rotation)*delta
	position += direction * SPEED * delta
	sprite_2d.rotation = rotation + (PI / 2)
	
#@on_signal("body_entered")
func _on_body_entered(body):
	if body.is_in_group("Enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	elif body.is_in_group("Environment"):
		queue_free()
		
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
