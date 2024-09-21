extends Resource
class_name Item
enum Rarity {
	COMMON,
	RARE,
	UNIQUE
}

@export var item_name: String = "New Item"
@export var item_description: String = "An Item"
@export var item_rarity: int = Rarity.COMMON

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
