extends Node
class_name Character


var health = 100
var position = Vector2.ZERO




func _ready():
	pass

func move():
	pass

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		queue_free()

func die():
	print("Character died")
	queue_free()
