extends Sprite2D

var can_fire = true

func _physics_process(delta: float):
	position.x = lerp(position.x, get_parent().position.x, 0.5)
	position.y = lerp(position.y, get_parent().position.y+10, 0.5)
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)

if Input.is_action_pressed("shoot"):
	
	
