extends Node

signal inventory_changed(item_id, new_count, old_count)

var _items := {}
var max_stack_size := 999

func _ready() -> void:
	if DataStore.config.has("stack_limit"):
		max_stack_size = DataStore.config.get("stack_limit", 999)

func add(item_id: String, amount: int) -> int:
	if amount <= 0:
		return 0
		
	if not DataStore.items.has(item_id):
		push_error("Inventory: Attempt to add invalid item: ", item_id)
		return 0
		
	var old_count = count(item_id)
	var new_count = min(old_count + amount, max_stack_size)
	var added = new_count - old_count
	
	if added > 0:
		_items[item_id] = new_count
		inventory_changed.emit(item_id, new_count, old_count)
		
	return added

func remove(item_id: String, amount: int) -> bool:
	if amount <= 0:
		return false
		
	var old_count = count(item_id)
	if old_count < amount:
		return false
		
	var new_count = old_count - amount
	
	if new_count == 0:
		_items.erase(item_id)
	else:
		_items[item_id] = new_count
		
	inventory_changed.emit(item_id, new_count, old_count)
	return true

func count(item_id: String) -> int:
	return _items.get(item_id, 0)

func has(item_id: String) -> bool:
	return _items.has(item_id) and _items[item_id] > 0

func get_all_items() -> Dictionary:
	return _items.duplicate()
