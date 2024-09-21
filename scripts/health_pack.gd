extends Area2D

var item_name = "Health Pack"
var item_type = "usable"


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.add_item_to_inventory(item_name, item_type)
		queue_free()
