extends Node

var _tool_durability := {}

func get_tool_durability(tool_id: String) -> int:
	if _tool_durability.has(tool_id):
		return _tool_durability[tool_id]
	if DataStore.items.has(tool_id):
		var tool_data = DataStore.items[tool_id]
		if tool_data.get("type") == "tool":
			return tool_data.get("durability", 1)
	return 0

func try_craft(slots: Dictionary, tool_id: String) -> Dictionary:
	var matched_recipe_id = ""
	for recipe_id in DataStore.recipes:
		var recipe = DataStore.recipes[recipe_id]
		var inputs = recipe.get("inputs", [])
		
		var recipe_slots = {}
		for input in inputs:
			recipe_slots[input.get("item")] = recipe_slots.get(input.get("item"), 0) + input.get("qty")
			
		var is_match = true
		if slots.size() != recipe_slots.size():
			continue
			
		for item in slots:
			if not recipe_slots.has(item) or recipe_slots[item] != slots[item]:
				is_match = false
				break
				
		if is_match:
			matched_recipe_id = recipe_id
			break
			
	if matched_recipe_id == "":
		return {"success": false, "message": "Nothing happens."}
		
	var recipe = DataStore.recipes[matched_recipe_id]
	
	var skill_cat = recipe.get("skill", "tool_crafting")
	var skill_req = recipe.get("skill_req", 0)
	var current_level = Skills.get_level(skill_cat)
	
	if current_level < skill_req:
		var name_parts = skill_cat.split("_")
		var nice_name = ""
		for part in name_parts:
			nice_name += part.capitalize() + " "
		return {"success": false, "message": "Needs " + nice_name.strip_edges() + " " + str(skill_req)}
		
	var required_tool = recipe.get("tool")
	if required_tool != null:
		if tool_id == "":
			return {"success": false, "message": "Requires a tool."}
		
		var req_family = required_tool.get("family")
		var req_tier = required_tool.get("min_tier", 1)
		
		var provided_tool_data = DataStore.items.get(tool_id, {})
		if provided_tool_data.get("type") != "tool" or provided_tool_data.get("family") != req_family or provided_tool_data.get("tier", 0) < req_tier:
			return {"success": false, "message": "Requires a better " + req_family + " tool."}
			
	for item_id in slots:
		if Inventory.count(item_id) < slots[item_id]:
			return {"success": false, "message": "Not enough ingredients."}
			
	if tool_id != "" and not Inventory.has(tool_id):
		return {"success": false, "message": "Tool is missing."}
		
	var energy_cost = recipe.get("energy", 0)
	if not Energy.has_energy(energy_cost):
		return {"success": false, "message": "Not enough energy."}
		
	# All checks passed
	Energy.consume(energy_cost)
	
	for item_id in slots:
		Inventory.remove(item_id, slots[item_id])
		
	var tool_consumed_as_input = slots.has(tool_id) and Inventory.count(tool_id) == 0
	
	var tool_broke = false
	if tool_id != "" and not tool_consumed_as_input:
		var current_durability = get_tool_durability(tool_id)
		current_durability -= 1
		
		if current_durability <= 0:
			Inventory.remove(tool_id, 1)
			_tool_durability.erase(tool_id)
			tool_broke = true
		else:
			_tool_durability[tool_id] = current_durability
			
	var output_item = recipe.get("output")
	var output_qty = recipe.get("output_qty", 1)
	Inventory.add(output_item, output_qty)
	
	Skills.add_craft_xp(skill_cat, energy_cost, matched_recipe_id)
	
	var success_msg = "Crafted " + DataStore.items[output_item].get("name", output_item) + "!"
	if tool_broke:
		success_msg += " (Tool broke)"
		
	return {"success": true, "message": success_msg}
