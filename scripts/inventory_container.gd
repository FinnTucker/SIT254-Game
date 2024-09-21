extends Control
@onready var item_list: ItemList = $ItemList

func update_inventory_ui(inventory: Dictionary):
	item_list.clear()
	
	for item_name in inventory.keys():
		var item_data = inventory[item_name]
		var item_quantity = item_data["quantity"]
		var item_text = item_name + " x" + str(item_quantity)
		
		if item_data["type"] == "usable":
			item_list.add_item("[Usable] " + item_text)
		elif item_data["type"] == "crafting":
			item_list.add_item("[Crafting] " + item_text)
		
		if item_data.has("icon"):
			item_list.set_item_icon(item_list.get_item_count() - 1, item_data["icon"])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
