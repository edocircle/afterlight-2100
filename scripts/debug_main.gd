extends Control

func _ready() -> void:
	run_tests()
	
	# Add the debug panel
	var debug_panel_script = load("res://scripts/debug_panel.gd")
	var panel = debug_panel_script.new()
	add_child(panel)

func run_tests() -> void:
	print("--- Running Inventory Tests ---")
	
	# Assume 'rubble' is a valid item ID from items.json
	var test_item = "rubble"
	
	# 1. Test add
	var added = Inventory.add(test_item, 5)
	print("Test Add: Expected added=5, got ", added)
	print("Test Count: Expected 5, got ", Inventory.count(test_item))
	print("Test Has: Expected true, got ", Inventory.has(test_item))
	
	# 2. Test remove below zero
	var removed = Inventory.remove(test_item, 10)
	print("Test Remove Below Zero: Expected false, got ", removed)
	print("Test Count after failed remove: Expected 5, got ", Inventory.count(test_item))
	
	# 3. Test exact remove
	var removed_exact = Inventory.remove(test_item, 5)
	print("Test Remove Exact: Expected true, got ", removed_exact)
	print("Test Count after exact remove: Expected 0, got ", Inventory.count(test_item))
	print("Test Has after remove: Expected false, got ", Inventory.has(test_item))
	
	# 4. Test add to max stack
	var added_max = Inventory.add(test_item, 2000)
	var max_stack = Inventory.max_stack_size
	print("Test Add Over Max: Expected to add ", max_stack, ", got ", added_max)
	print("Test Count after max: Expected ", max_stack, ", got ", Inventory.count(test_item))
	
	print("--- Inventory Tests Completed ---")
