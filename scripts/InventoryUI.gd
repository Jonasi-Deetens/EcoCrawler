extends Control
class_name InventoryUI

# InventoryUI - User interface for inventory management
# Single responsibility: Display and handle inventory interactions

@export var slot_size: Vector2 = Vector2(64, 64)
@export var slots_per_row: int = 5
@export var slot_margin: int = 8

# UI Components
var inventory_panel: Panel
var grid_container: GridContainer
var gold_label: Label
var close_button: Button
var sort_button: Button
var item_tooltip: RichTextLabel

# Inventory slots
var slot_buttons: Array[Button] = []
var inventory_reference: Inventory

# Signals
signal inventory_closed()
signal item_selected(item: Item, quantity: int)
signal item_used(item: Item)

func _ready():
	_setup_ui()
	hide()  # Start hidden

func _setup_ui():
	"""Set up the inventory UI components"""
	# Main panel
	inventory_panel = Panel.new()
	inventory_panel.size = Vector2(400, 500)
	inventory_panel.position = Vector2(50, 50)
	add_child(inventory_panel)
	
	# Title
	var title_label = Label.new()
	title_label.text = "Inventory"
	title_label.position = Vector2(20, 10)
	title_label.add_theme_font_size_override("font_size", 24)
	inventory_panel.add_child(title_label)
	
	# Gold display
	gold_label = Label.new()
	gold_label.text = "Gold: 0"
	gold_label.position = Vector2(20, 40)
	gold_label.add_theme_font_size_override("font_size", 16)
	inventory_panel.add_child(gold_label)
	
	# Close button
	close_button = Button.new()
	close_button.text = "X"
	close_button.size = Vector2(30, 30)
	close_button.position = Vector2(350, 10)
	close_button.pressed.connect(_on_close_pressed)
	inventory_panel.add_child(close_button)
	
	# Sort button
	sort_button = Button.new()
	sort_button.text = "Sort"
	sort_button.size = Vector2(60, 30)
	sort_button.position = Vector2(280, 10)
	sort_button.pressed.connect(_on_sort_pressed)
	inventory_panel.add_child(sort_button)
	
	# Grid container for inventory slots
	grid_container = GridContainer.new()
	grid_container.columns = slots_per_row
	grid_container.position = Vector2(20, 80)
	grid_container.size = Vector2(360, 350)
	inventory_panel.add_child(grid_container)
	
	# Tooltip
	item_tooltip = RichTextLabel.new()
	item_tooltip.size = Vector2(200, 150)
	item_tooltip.visible = false
	item_tooltip.bbcode_enabled = true
	item_tooltip.fit_content = true
	add_child(item_tooltip)

func setup_inventory(inventory: Inventory):
	"""Connect to an inventory instance"""
	inventory_reference = inventory
	
	# Connect signals
	inventory.inventory_changed.connect(_on_inventory_changed)
	inventory.gold_changed.connect(_on_gold_changed)
	
	# Create inventory slots
	_create_inventory_slots()
	_update_display()

func _create_inventory_slots():
	"""Create UI slots for inventory"""
	slot_buttons.clear()
	
	# Clear existing slots
	for child in grid_container.get_children():
		child.queue_free()
	
	# Create new slots
	for i in range(inventory_reference.max_slots):
		var slot_button = Button.new()
		slot_button.size = slot_size
		slot_button.custom_minimum_size = slot_size
		slot_button.flat = true
		
		# Style the slot
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(0.2, 0.2, 0.2, 0.8)
		style_box.border_color = Color(0.5, 0.5, 0.5, 1)
		style_box.border_width_left = 2
		style_box.border_width_right = 2
		style_box.border_width_top = 2
		style_box.border_width_bottom = 2
		slot_button.add_theme_stylebox_override("normal", style_box)
		
		# Connect signals
		slot_button.pressed.connect(_on_slot_pressed.bind(i))
		slot_button.mouse_entered.connect(_on_slot_hovered.bind(i))
		slot_button.mouse_exited.connect(_on_slot_unhovered)
		
		grid_container.add_child(slot_button)
		slot_buttons.append(slot_button)

func _update_display():
	"""Update the inventory display"""
	if not inventory_reference:
		return
	
	# Update gold
	gold_label.text = "Gold: " + str(inventory_reference.gold)
	
	# Update slots
	for i in range(min(slot_buttons.size(), inventory_reference.items.size())):
		var slot = inventory_reference.items[i]
		var button = slot_buttons[i]
		
		if slot.is_empty():
			button.text = ""
			button.icon = null
			button.tooltip_text = ""
		else:
			# Show item icon or type symbol
			if slot.item.icon_texture:
				button.icon = slot.item.icon_texture
				button.text = ""
			else:
				button.text = slot.item.get_type_icon()
			
			# Add quantity if stackable
			if slot.quantity > 1:
				button.text += "\n" + str(slot.quantity)
			
			# Set tooltip
			button.tooltip_text = slot.item.get_tooltip_text()
			
			# Color border based on rarity
			var style_box = button.get_theme_stylebox("normal").duplicate()
			style_box.border_color = slot.item.get_rarity_color()
			button.add_theme_stylebox_override("normal", style_box)

func _on_inventory_changed():
	"""Handle inventory changes"""
	_update_display()

func _on_gold_changed(new_amount: int):
	"""Handle gold changes"""
	gold_label.text = "Gold: " + str(new_amount)

func _on_slot_pressed(slot_index: int):
	"""Handle slot button press"""
	if not inventory_reference or slot_index >= inventory_reference.items.size():
		return
	
	var slot = inventory_reference.items[slot_index]
	if not slot.is_empty():
		item_selected.emit(slot.item, slot.quantity)
		
		# Right-click to use item (simplified)
		if Input.is_action_pressed("ui_select"):  # Right click or secondary action
			_use_item(slot.item)

func _use_item(item: Item):
	"""Use/consume an item"""
	if item.item_type == "consumable":
		item_used.emit(item)
		inventory_reference.remove_item(item, 1)
		print("Used ", item.item_name)

func _on_slot_hovered(slot_index: int):
	"""Show tooltip when hovering over slot"""
	if not inventory_reference or slot_index >= inventory_reference.items.size():
		return
	
	var slot = inventory_reference.items[slot_index]
	if not slot.is_empty():
		_show_tooltip(slot.item, get_global_mouse_position())

func _on_slot_unhovered():
	"""Hide tooltip when not hovering"""
	_hide_tooltip()

func _show_tooltip(item: Item, tooltip_position: Vector2):
	"""Show item tooltip"""
	item_tooltip.text = item.get_tooltip_text()
	item_tooltip.position = tooltip_position + Vector2(10, 10)
	item_tooltip.visible = true

func _hide_tooltip():
	"""Hide item tooltip"""
	item_tooltip.visible = false

func _on_close_pressed():
	"""Handle close button press"""
	hide()
	inventory_closed.emit()

func _on_sort_pressed():
	"""Handle sort button press"""
	if inventory_reference:
		inventory_reference.sort_inventory()

func show_inventory():
	"""Show the inventory UI"""
	show()
	_update_display()

func hide_inventory():
	"""Hide the inventory UI"""
	hide()
	_hide_tooltip()

func _input(event):
	"""Handle input events"""
	if visible and event.is_action_pressed("ui_cancel"):
		hide_inventory()
		inventory_closed.emit()
