extends CanvasLayer

var is_panel_visible := false

var toggle_button: Button
var panel: PanelContainer
var item_list: VBoxContainer
var search_input: LineEdit

func _ready() -> void:
	layer = 100
	
	toggle_button = Button.new()
	toggle_button.text = "Debug"
	toggle_button.position = Vector2(10, 10)
	toggle_button.pressed.connect(_on_toggle_pressed)
	add_child(toggle_button)
	
	panel = PanelContainer.new()
	panel.visible = false
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 10
	panel.offset_top = 60
	panel.offset_right = -10
	panel.offset_bottom = -10
	add_child(panel)
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var give_btn = Button.new()
	give_btn.text = "Give all hand materials x20"
	give_btn.pressed.connect(_on_give_hand_materials)
	vbox.add_child(give_btn)
	
	search_input = LineEdit.new()
	search_input.placeholder_text = "Search item..."
	search_input.text_changed.connect(_on_search_changed)
	vbox.add_child(search_input)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)
	
	item_list = VBoxContainer.new()
	item_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(item_list)
	
	Inventory.inventory_changed.connect(_on_inventory_changed)
	# Defers population until DataStore is fully ready
	call_deferred("_populate_items", "")

func _on_toggle_pressed() -> void:
	is_panel_visible = !is_panel_visible
	panel.visible = is_panel_visible

func _on_give_hand_materials() -> void:
	var hand_mats = ["rubble", "plastic_rod", "cable_strand"]
	for item_id in hand_mats:
		Inventory.add(item_id, 20)

func _on_search_changed(new_text: String) -> void:
	_populate_items(new_text.to_lower())

func _populate_items(filter: String = "") -> void:
	for child in item_list.get_children():
		child.queue_free()
		
	var all_items = DataStore.items.keys()
	all_items.sort()
	
	var count_shown = 0
	for item_id in all_items:
		if filter != "" and not item_id.to_lower().contains(filter):
			continue
			
		var hbox = HBoxContainer.new()
		
		var label = Label.new()
		var current_count = Inventory.count(item_id)
		label.text = item_id + " (x" + str(current_count) + ")"
		label.custom_minimum_size = Vector2(250, 0)
		hbox.add_child(label)
		
		var plus_one = Button.new()
		plus_one.text = "+1"
		plus_one.pressed.connect(func(): Inventory.add(item_id, 1))
		hbox.add_child(plus_one)
		
		var plus_ten = Button.new()
		plus_ten.text = "+10"
		plus_ten.pressed.connect(func(): Inventory.add(item_id, 10))
		hbox.add_child(plus_ten)
		
		var minus_one = Button.new()
		minus_one.text = "-1"
		minus_one.pressed.connect(func(): Inventory.remove(item_id, 1))
		hbox.add_child(minus_one)
		
		item_list.add_child(hbox)
		
		count_shown += 1
		if count_shown > 100 and filter == "": 
			# Cap to prevent lag if no filter is applied
			var note = Label.new()
			note.text = "... (Search to see more)"
			item_list.add_child(note)
			break

func _on_inventory_changed(item_id: String, new_count: int, old_count: int) -> void:
	if panel.visible:
		_populate_items(search_input.text.to_lower())
