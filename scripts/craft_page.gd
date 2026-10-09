extends Control

var ingredient_slots = [{"item": "", "qty": 0}, {"item": "", "qty": 0}, {"item": "", "qty": 0}]
var tool_slot = ""

var current_filter = "All"
var current_search = ""

func _ready() -> void:
	var debug_panel_script = load("res://scripts/debug_panel.gd")
	if debug_panel_script:
		var panel = debug_panel_script.new()
		add_child(panel)

	# Status Bar
	$SafeArea/MainVBox/StatusBar/RecipeBookBtn.pressed.connect(_on_recipe_book_pressed)
	$RecipeBookPanel/SafeArea/VBox/Header/CloseBookBtn.pressed.connect(_on_close_book_pressed)
	
	# Hand Gather
	$SafeArea/MainVBox/HandGatherStrip/RubbleBtn.pressed.connect(func(): GatherSystem.hand_gather("rubble"))
	$SafeArea/MainVBox/HandGatherStrip/PlasticBtn.pressed.connect(func(): GatherSystem.hand_gather("plastic_rod"))
	$SafeArea/MainVBox/HandGatherStrip/CableBtn.pressed.connect(func(): GatherSystem.hand_gather("cable_strand"))
	
	# Robot
	$SafeArea/MainVBox/RobotPanel/RobotVBox/RobotControls/CollectBtn.pressed.connect(func(): pass)
	
	# Craft Table Slots
	$SafeArea/MainVBox/CraftTable/CraftVBox/SlotsHBox/ToolSlot.pressed.connect(_on_tool_slot_tapped)
	$SafeArea/MainVBox/CraftTable/CraftVBox/SlotsHBox/Ing1Slot.pressed.connect(func(): _on_ing_slot_tapped(0))
	$SafeArea/MainVBox/CraftTable/CraftVBox/SlotsHBox/Ing2Slot.pressed.connect(func(): _on_ing_slot_tapped(1))
	$SafeArea/MainVBox/CraftTable/CraftVBox/SlotsHBox/Ing3Slot.pressed.connect(func(): _on_ing_slot_tapped(2))
	$SafeArea/MainVBox/CraftTable/CraftVBox/CraftActions/ClearBtn.pressed.connect(_on_clear_pressed)
	$SafeArea/MainVBox/CraftTable/CraftVBox/CraftActions/CraftBtn.pressed.connect(_on_craft_pressed)
	
	# Inventory Filters
	$SafeArea/MainVBox/InventoryArea/FilterHBox/FilterAll.pressed.connect(func(): _set_filter("All"))
	$SafeArea/MainVBox/InventoryArea/FilterHBox/FilterMat.pressed.connect(func(): _set_filter("Mat"))
	$SafeArea/MainVBox/InventoryArea/FilterHBox/FilterPart.pressed.connect(func(): _set_filter("Part"))
	$SafeArea/MainVBox/InventoryArea/FilterHBox/FilterTool.pressed.connect(func(): _set_filter("Tool"))
	
	var search_input = $SafeArea/MainVBox/InventoryArea/FilterHBox/SearchInput
	search_input.text_changed.connect(_on_search_changed)
	
	Inventory.inventory_changed.connect(_on_inventory_changed)
	
	_update_ui()

func _set_filter(filter: String) -> void:
	current_filter = filter
	_update_ui()

func _on_search_changed(text: String) -> void:
	current_search = text.to_lower()
	_update_ui()

func _on_inventory_changed(_item: String, _new: int, _old: int) -> void:
	_update_ui()

func _on_recipe_book_pressed() -> void:
	$RecipeBookPanel.show()

func _on_close_book_pressed() -> void:
	$RecipeBookPanel.hide()

func _on_inventory_item_tapped(item_id: String) -> void:
	var item_type = DataStore.items[item_id].get("type", "gather")
	
	if item_type == "tool" and tool_slot == "":
		tool_slot = item_id
		_update_ui()
		return
		
	var max_avail = Inventory.count(item_id)
	var current_qty_in_slots = 0
	for slot in ingredient_slots:
		if slot.item == item_id:
			current_qty_in_slots += slot.qty
			
	if current_qty_in_slots >= max_avail:
		return
		
	for slot in ingredient_slots:
		if slot.item == item_id:
			slot.qty += 1
			_update_ui()
			return
			
	for slot in ingredient_slots:
		if slot.item == "":
			slot.item = item_id
			slot.qty = 1
			_update_ui()
			return

func _on_ing_slot_tapped(index: int) -> void:
	var slot = ingredient_slots[index]
	if slot.item != "":
		slot.qty -= 1
		if slot.qty <= 0:
			slot.item = ""
			slot.qty = 0
		_update_ui()

func _on_tool_slot_tapped() -> void:
	tool_slot = ""
	_update_ui()

func _on_clear_pressed() -> void:
	tool_slot = ""
	for slot in ingredient_slots:
		slot.item = ""
		slot.qty = 0
	_update_ui()

func _on_craft_pressed() -> void:
	var slots = {}
	for slot in ingredient_slots:
		if slot.item != "":
			slots[slot.item] = slots.get(slot.item, 0) + slot.qty
			
	var result = CraftingSystem.try_craft(slots, tool_slot)
	
	var msg_label = $SafeArea/MainVBox/CraftTable/CraftVBox/MessageLine
	if msg_label:
		msg_label.text = result.message
		
	if result.success:
		# Check if we still have enough items for the recipe, clear what we don't have
		for slot in ingredient_slots:
			if slot.item != "":
				var remaining = Inventory.count(slot.item)
				if remaining < slot.qty:
					slot.qty = remaining
				if slot.qty == 0:
					slot.item = ""
					
		if tool_slot != "" and not Inventory.has(tool_slot):
			tool_slot = ""
			
	_update_ui()

func _update_ui() -> void:
	var tool_btn = $SafeArea/MainVBox/CraftTable/CraftVBox/SlotsHBox/ToolSlot
	if tool_slot == "":
		tool_btn.text = "Tool"
	else:
		var n = DataStore.items[tool_slot].get("name", tool_slot)
		var dur = CraftingSystem.get_tool_durability(tool_slot)
		tool_btn.text = n + "\n(" + str(dur) + ")"
		
	var ing_btns = [
		$SafeArea/MainVBox/CraftTable/CraftVBox/SlotsHBox/Ing1Slot,
		$SafeArea/MainVBox/CraftTable/CraftVBox/SlotsHBox/Ing2Slot,
		$SafeArea/MainVBox/CraftTable/CraftVBox/SlotsHBox/Ing3Slot
	]
	
	for i in range(3):
		if ingredient_slots[i].item == "":
			ing_btns[i].text = "In " + str(i+1)
		else:
			var n = DataStore.items[ingredient_slots[i].item].get("name", ingredient_slots[i].item)
			ing_btns[i].text = n + "\nx" + str(ingredient_slots[i].qty)
			
	var grid = $SafeArea/MainVBox/InventoryArea/InvScroll/InvGrid
	for child in grid.get_children():
		child.queue_free()
		
	var all_items = Inventory.get_all_items()
	var sorted_keys = all_items.keys()
	sorted_keys.sort()
	
	for item_id in sorted_keys:
		var item_data = DataStore.items.get(item_id, {})
		var type = item_data.get("type", "gather")
		
		if current_filter == "Mat" and type != "gather": continue
		if current_filter == "Part" and type != "part": continue
		if current_filter == "Tool" and type != "tool": continue
		
		var display_name = item_data.get("name", item_id)
		if current_search != "" and not display_name.to_lower().contains(current_search) and not item_id.to_lower().contains(current_search):
			continue
			
		var count = all_items[item_id]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(60, 60)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.text = display_name + "\n" + str(count)
		
		# Allow word wrap to fit long names in small buttons
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.clip_text = true
		
		# Connect with a lambda that captures item_id
		var id_copy = item_id
		btn.pressed.connect(func(): _on_inventory_item_tapped(id_copy))
		
		grid.add_child(btn)
