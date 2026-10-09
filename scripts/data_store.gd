extends Node

var items := {}
var gather_items := []
var crafted_items := []
var tools := []
var recipes := {}

var config := {}
var gather_by_chip := {}

const VALID_CHIPS = ["Scavenge", "Quarry", "Harvest", "Fishing", "Wildlife"]
const VALID_TOOL_FAMILIES = ["axe", "hammer", "cutter", "lance", "digger", "rod", "grabber"]

func _ready() -> void:
	load_config()
	load_items()
	load_recipes()
	validate_data()

func load_config() -> void:
	var path = "res://data/config.json"
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		var parse_result = JSON.parse_string(text)
		if parse_result:
			config = parse_result
		else:
			push_error("Failed to parse config.json")
	else:
		push_error("Failed to open config.json")

func load_items() -> void:
	var path = "res://data/items.json"
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open items.json")
		return
	
	var text = file.get_as_text()
	var parse_result = JSON.parse_string(text)
	if not parse_result is Array:
		push_error("items.json is not an array")
		return
	
	for entry in parse_result:
		var id = entry.get("id")
		if not id: continue
		
		items[id] = entry
		var type = entry.get("type")
		if type == "gather":
			gather_items.append(entry)
			var chip = entry.get("chip")
			if chip:
				if not gather_by_chip.has(chip):
					gather_by_chip[chip] = []
				gather_by_chip[chip].append(entry)
		elif type == "tool":
			tools.append(entry)
			crafted_items.append(entry)
		elif type == "part":
			crafted_items.append(entry)

func load_recipes() -> void:
	var path = "res://data/recipes_tool_crafting.json"
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open recipes_tool_crafting.json")
		return
	
	var text = file.get_as_text()
	var parse_result = JSON.parse_string(text)
	if not parse_result is Array:
		push_error("recipes_tool_crafting.json is not an array")
		return
		
	for entry in parse_result:
		var id = entry.get("id")
		if not id: continue
		recipes[id] = entry

func validate_data() -> void:
	# Check unique IDs in items (already somewhat enforced by dictionary, but we can check if size matches array length)
	
	# Validate gather items
	for item in gather_items:
		var id = item.get("id")
		var chip = item.get("chip")
		var tool_family = item.get("tool_family")
		var tier = item.get("tier")
		
		if not VALID_CHIPS.has(chip):
			push_error("data/items.json: Bad chip '%s' in item %s" % [chip, id])
		if not VALID_TOOL_FAMILIES.has(tool_family):
			push_error("data/items.json: Bad tool_family '%s' in item %s" % [tool_family, id])
		if tier == null or tier < 1 or tier > 4:
			push_error("data/items.json: Bad tier '%s' in item %s" % [tier, id])
			
	# Validate recipes
	for recipe_id in recipes:
		var recipe = recipes[recipe_id]
		var output = recipe.get("output")
		
		if not items.has(output):
			push_error("data/recipes_tool_crafting.json: Output item '%s' does not exist in recipe %s" % [output, recipe_id])
		
		var inputs = recipe.get("inputs")
		if not inputs is Array or inputs.size() < 1 or inputs.size() > 3:
			push_error("data/recipes_tool_crafting.json: Invalid inputs count in recipe %s" % [recipe_id])
		
		for input in inputs:
			var input_item = input.get("item")
			if not items.has(input_item):
				push_error("data/recipes_tool_crafting.json: Input item '%s' does not exist in recipe %s" % [input_item, recipe_id])
				
		var tool = recipe.get("tool")
		if tool:
			var tool_family = tool.get("family")
			if tool_family and not VALID_TOOL_FAMILIES.has(tool_family):
				push_error("data/recipes_tool_crafting.json: Bad tool family '%s' in recipe %s" % [tool_family, recipe_id])
