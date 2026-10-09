extends Control

func _ready() -> void:
	# Add the debug panel from Task 2 so it is still accessible
	var debug_panel_script = load("res://scripts/debug_panel.gd")
	if debug_panel_script:
		var panel = debug_panel_script.new()
		add_child(panel)

	# Run Crafting tests
	var crafting_tests = load("res://scripts/tests_crafting.gd")
	if crafting_tests:
		var tests = crafting_tests.new()
		tests.run_tests()
		tests.free()

	# Connect Status Bar
	$SafeArea/MainVBox/StatusBar/RecipeBookBtn.pressed.connect(_on_recipe_book_pressed)
	$RecipeBookPanel/SafeArea/VBox/Header/CloseBookBtn.pressed.connect(_on_close_book_pressed)
	
	# Connect Hand Gather
	$SafeArea/MainVBox/HandGatherStrip/RubbleBtn.pressed.connect(func(): _log("Gather Rubble"))
	$SafeArea/MainVBox/HandGatherStrip/PlasticBtn.pressed.connect(func(): _log("Gather Plastic"))
	$SafeArea/MainVBox/HandGatherStrip/CableBtn.pressed.connect(func(): _log("Gather Cable"))
	
	# Connect Robot
	$SafeArea/MainVBox/RobotPanel/RobotVBox/RobotControls/CollectBtn.pressed.connect(func(): _log("Robot Collect"))
	
	# Connect Craft Table
	$SafeArea/MainVBox/CraftTable/CraftVBox/SlotsHBox/ToolSlot.pressed.connect(func(): _log("Tap Tool Slot"))
	$SafeArea/MainVBox/CraftTable/CraftVBox/SlotsHBox/Ing1Slot.pressed.connect(func(): _log("Tap Ing 1 Slot"))
	$SafeArea/MainVBox/CraftTable/CraftVBox/SlotsHBox/Ing2Slot.pressed.connect(func(): _log("Tap Ing 2 Slot"))
	$SafeArea/MainVBox/CraftTable/CraftVBox/SlotsHBox/Ing3Slot.pressed.connect(func(): _log("Tap Ing 3 Slot"))
	$SafeArea/MainVBox/CraftTable/CraftVBox/SlotsHBox/ResultPreview.pressed.connect(func(): _log("Tap Result Preview"))
	$SafeArea/MainVBox/CraftTable/CraftVBox/CraftActions/ClearBtn.pressed.connect(func(): _log("Craft Clear"))
	$SafeArea/MainVBox/CraftTable/CraftVBox/CraftActions/CraftBtn.pressed.connect(_on_craft_pressed)
	
	# Connect Inventory Filters
	$SafeArea/MainVBox/InventoryArea/FilterHBox/FilterAll.pressed.connect(func(): _log("Filter All"))
	$SafeArea/MainVBox/InventoryArea/FilterHBox/FilterMat.pressed.connect(func(): _log("Filter Mat"))
	$SafeArea/MainVBox/InventoryArea/FilterHBox/FilterPart.pressed.connect(func(): _log("Filter Part"))
	$SafeArea/MainVBox/InventoryArea/FilterHBox/FilterTool.pressed.connect(func(): _log("Filter Tool"))
	
	# Populate dummy grid items for layout testing
	var grid = $SafeArea/MainVBox/InventoryArea/InvScroll/InvGrid
	for i in range(30):
		var btn = Button.new()
		# 60x60 minimum to fit 5 columns on narrow screens (360px)
		btn.custom_minimum_size = Vector2(60, 60)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.text = str(i)
		btn.pressed.connect(func(): _log("Tap Inv Item " + str(i)))
		grid.add_child(btn)

func _log(msg: String) -> void:
	print("CraftPage UI: ", msg)

func _on_recipe_book_pressed() -> void:
	_log("Open Recipe Book")
	$RecipeBookPanel.show()

func _on_close_book_pressed() -> void:
	_log("Close Recipe Book")
	$RecipeBookPanel.hide()

func _on_craft_pressed() -> void:
	# Currently slots are not selectable in the UI, passing empty dictionary
	var slots = {}
	var tool_id = ""
	var result = CraftingSystem.try_craft(slots, tool_id)
	
	var msg_label = $SafeArea/MainVBox/CraftTable/CraftVBox/MessageLine
	if msg_label:
		msg_label.text = result.message
	
	_log("Craft Result: " + str(result.success) + " | " + result.message)
