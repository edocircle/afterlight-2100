extends Node

var _xp := {}
var _discovered := {}

signal skill_leveled_up(category, new_level)
signal recipe_discovered(recipe_id)

func _ready() -> void:
	_xp["tool_crafting"] = 0

func get_xp(category: String) -> int:
	return _xp.get(category, 0)

func get_level(category: String) -> int:
	return floor(get_xp(category) / 10.0)

func add_craft_xp(category: String, energy_cost: int, recipe_id: String) -> void:
	var xp_gain = ceil(energy_cost / 5.0)
	var first_time = not is_discovered(recipe_id)
	
	if first_time:
		xp_gain *= 3
		_discovered[recipe_id] = true
		recipe_discovered.emit(recipe_id)
		
	var old_level = get_level(category)
	_xp[category] = get_xp(category) + xp_gain
	var new_level = get_level(category)
	
	if new_level > old_level:
		skill_leveled_up.emit(category, new_level)

func is_discovered(recipe_id: String) -> bool:
	return _discovered.has(recipe_id) and _discovered[recipe_id]

func get_discovered_count() -> int:
	return _discovered.size()
