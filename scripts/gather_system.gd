extends Node

func hand_gather(item_id: String) -> void:
	if DataStore.items.has(item_id):
		Inventory.add(item_id, 1)
