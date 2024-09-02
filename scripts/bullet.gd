extends Sprite2D

var velocity = Vector2()

func _physics_process(delta):
	position += velocity * delta
