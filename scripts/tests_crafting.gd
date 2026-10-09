extends Node

func run_tests() -> void:
	print("--- Running CraftingSystem Tests ---")
	
	Energy.current_energy = 100
	Skills._xp["tool_crafting"] = 0
	Skills._discovered.clear()
	Inventory._items.clear()
	
	Inventory.add("rubble", 10)
	Inventory.add("cable_strand", 10)
	Inventory.add("plastic_rod", 10)
	
	# 1. Valid recipe, swapped order
	var slots1 = {"rubble": 2}
	var res1 = CraftingSystem.try_craft(slots1, "")
	print("Test 1 (Valid): Expected success, got ", res1.success)
	print("  Expected 1 sharp_shard, got ", Inventory.count("sharp_shard"))
	print("  Expected 8 rubble, got ", Inventory.count("rubble"))
	
	var slots2 = {"rubble": 3}
	var res2 = CraftingSystem.try_craft(slots2, "")
	print("Test 1 (Extra qty): Expected false, got ", res2.success)
	print("  Expected 8 rubble, got ", Inventory.count("rubble"))
	
	# 2. Unknown combination
	var slots3 = {"rubble": 1, "plastic_rod": 1}
	var res3 = CraftingSystem.try_craft(slots3, "")
	print("Test 2 (Unknown): Expected false, got ", res3.success)
	print("  Expected 8 rubble, got ", Inventory.count("rubble"))
	
	CraftingSystem.try_craft({"sharp_shard": 1, "cable_strand": 1, "plastic_rod": 1}, "")
	CraftingSystem.try_craft({"rubble": 1, "cable_strand": 1, "plastic_rod": 1}, "")
	
	# 3. Skill too low
	Inventory.add("metal_scrap", 1)
	Inventory.add("rubber_strip", 1)
	var slots_std_hammer = {"scrap_hammer": 1, "metal_scrap": 1, "rubber_strip": 1}
	var res_skill = CraftingSystem.try_craft(slots_std_hammer, "scrap_hammer")
	print("Test 3 (Skill too low): Expected false (Needs Tool Crafting 35), got ", res_skill.success, " msg: ", res_skill.message)
	print("  Expected scrap_hammer still in inv: ", Inventory.has("scrap_hammer"))
	
	# 4. Missing tool or tool tier too low
	Inventory.add("metal_scrap", 1)
	var slots_digger = {"metal_scrap": 1, "plastic_rod": 1}
	var res_tool = CraftingSystem.try_craft(slots_digger, "scrap_hammer") # Requires cutter
	print("Test 4 (Missing/Wrong tool): Expected false, got ", res_tool.success, " msg: ", res_tool.message)
	
	# 5. Not enough energy
	Energy.current_energy = 0
	var res_energy = CraftingSystem.try_craft({"rubble": 2}, "")
	print("Test 5 (No energy): Expected false, got ", res_energy.success)
	print("  Expected nothing consumed (rubble): ", Inventory.count("rubble"))
	
	Energy.current_energy = 100
	
	# 6. Tool durability goes down by 1; at 0 the tool is removed
	Inventory.add("sharp_shard", 1)
	CraftingSystem.try_craft({"sharp_shard": 1, "rubble": 1, "plastic_rod": 1}, "")
	Inventory.add("metal_scrap", 20)
	Inventory.add("plastic_rod", 20)
	
	var uses = 0
	for i in range(16):
		var res_use = CraftingSystem.try_craft({"metal_scrap": 1, "plastic_rod": 1}, "scrap_cutter")
		if res_use.success:
			uses += 1
			
	print("Test 6 (Durability): Expected 15 uses, got ", uses)
	print("  Expected scrap_cutter removed: ", not Inventory.has("scrap_cutter"))
	
	# 7. Upgrade recipe consumes the lower tool
	Skills._xp["tool_crafting"] = 350
	Inventory.add("scrap_hammer", 1)
	Inventory.add("rubber_strip", 1)
	Inventory.add("metal_scrap", 1)
	var res_upgrade = CraftingSystem.try_craft({"scrap_hammer": 1, "metal_scrap": 1, "rubber_strip": 1}, "scrap_hammer")
	print("Test 7 (Upgrade consumes lower): Expected true, got ", res_upgrade.success)
	print("  Expected standard_hammer=1, got ", Inventory.count("standard_hammer"))
	print("  Expected scrap_hammer=0, got ", Inventory.count("scrap_hammer"))
	
	# 8. First craft gives 3x XP; discovery counter increases once.
	Inventory.add("rubble", 1)
	Inventory.add("sharp_shard", 1)
	
	var prev_xp = Skills.get_xp("tool_crafting")
	var prev_disc = Skills.get_discovered_count()
	CraftingSystem.try_craft({"rubble": 1, "sharp_shard": 1}, "")
	var new_xp = Skills.get_xp("tool_crafting")
	var new_disc = Skills.get_discovered_count()
	print("Test 8 (XP & Discovery):")
	print("  Expected XP gain=3, got ", new_xp - prev_xp)
	print("  Expected discovery +1, got ", new_disc - prev_disc)
	
	print("--- Crafting Tests Completed ---")
