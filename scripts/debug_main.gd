extends Control

func _ready() -> void:
	print("--- Debug Data Store Output ---")
	
	var gather_count = DataStore.gather_items.size()
	print("Gather items count: ", gather_count, " (Expected: 270)")
	
	var craft_count = DataStore.crafted_items.size()
	print("Crafted items count: ", craft_count, " (Expected: 37)")
	
	var recipes_count = DataStore.recipes.size()
	print("Recipes count: ", recipes_count, " (Expected: 37)")
	
	print("\nItems per chip:")
	for chip in DataStore.gather_by_chip.keys():
		var count = DataStore.gather_by_chip[chip].size()
		print("- ", chip, ": ", count)
	
	print("--- End Debug Output ---")
	
	get_tree().quit()
