extends Control
class_name ShopUI

# ShopUI - User interface for vendor interactions
# Single responsibility: Handle shop transactions and display

@export var slot_size: Vector2 = Vector2(64, 64)

# UI Components
var shop_panel: Panel
var vendor_items_container: VBoxContainer
var player_items_container: VBoxContainer
var vendor_gold_label: Label
var player_gold_label: Label
var close_button: Button
var shop_title_label: Label

# References
var current_vendor: VendorNPC
var player_inventory: Inventory

# Signals
signal shop_closed()
signal transaction_completed(item: Item, quantity: int, is_purchase: bool)

func _ready():
	_setup_ui()
	hide()

func _setup_ui():
	"""Set up the shop UI components"""
	# Main panel
	shop_panel = Panel.new()
	shop_panel.size = Vector2(900, 650)
	shop_panel.position = Vector2(50, 25)
	add_child(shop_panel)
	
	# Title
	shop_title_label = Label.new()
	shop_title_label.text = "Shop"
	shop_title_label.position = Vector2(20, 15)
	shop_title_label.size = Vector2(400, 30)
	shop_title_label.add_theme_font_size_override("font_size", 24)
	shop_panel.add_child(shop_title_label)
	
	# Close button
	close_button = Button.new()
	close_button.text = "Close"
	close_button.size = Vector2(80, 35)
	close_button.position = Vector2(800, 15)
	close_button.pressed.connect(_on_close_pressed)
	shop_panel.add_child(close_button)
	
	# Vendor section header
	var vendor_label = Label.new()
	vendor_label.text = "Vendor Items (Click to Buy)"
	vendor_label.position = Vector2(20, 60)
	vendor_label.size = Vector2(300, 25)
	vendor_label.add_theme_font_size_override("font_size", 16)
	shop_panel.add_child(vendor_label)
	
	# Vendor gold display
	vendor_gold_label = Label.new()
	vendor_gold_label.text = "Vendor Gold: 0"
	vendor_gold_label.position = Vector2(20, 320)
	vendor_gold_label.size = Vector2(200, 25)
	vendor_gold_label.add_theme_font_size_override("font_size", 14)
	shop_panel.add_child(vendor_gold_label)
	
	# Vendor items scroll area
	var vendor_scroll = ScrollContainer.new()
	vendor_scroll.position = Vector2(20, 90)
	vendor_scroll.size = Vector2(400, 220)
	shop_panel.add_child(vendor_scroll)
	
	vendor_items_container = VBoxContainer.new()
	vendor_items_container.add_theme_constant_override("separation", 10)  # Add 10px spacing between items
	vendor_scroll.add_child(vendor_items_container)
	
	# Player section header
	var player_label = Label.new()
	player_label.text = "Your Items (Click to Sell)"
	player_label.position = Vector2(460, 60)
	player_label.size = Vector2(300, 25)
	player_label.add_theme_font_size_override("font_size", 16)
	shop_panel.add_child(player_label)
	
	# Player gold display
	player_gold_label = Label.new()
	player_gold_label.text = "Your Gold: 0"
	player_gold_label.position = Vector2(460, 320)
	player_gold_label.size = Vector2(200, 25)
	player_gold_label.add_theme_font_size_override("font_size", 14)
	shop_panel.add_child(player_gold_label)
	
	# Player items scroll area
	var player_scroll = ScrollContainer.new()
	player_scroll.position = Vector2(460, 90)
	player_scroll.size = Vector2(400, 220)
	shop_panel.add_child(player_scroll)
	
	player_items_container = VBoxContainer.new()
	player_items_container.add_theme_constant_override("separation", 10)  # Add 10px spacing between items
	player_scroll.add_child(player_items_container)

func open_shop(vendor: VendorNPC, inventory: Inventory):
	"""Open shop with vendor and player inventory"""
	current_vendor = vendor
	player_inventory = inventory
	
	# Update UI
	shop_title_label.text = vendor.shop_name
	_update_shop_display()
	
	show()

func _update_shop_display():
	"""Update the shop display"""
	if not current_vendor or not player_inventory:
		return
	
	# Update gold displays
	vendor_gold_label.text = "Vendor Gold: " + str(current_vendor.vendor_gold)
	player_gold_label.text = "Your Gold: " + str(player_inventory.gold)
	
	# Clear existing items
	for child in vendor_items_container.get_children():
		child.queue_free()
	for child in player_items_container.get_children():
		child.queue_free()
	
	# Populate vendor items
	for slot in current_vendor.get_shop_items():
		_create_vendor_item_entry(slot)
	
	# Populate player items
	for slot in player_inventory.get_all_items():
		_create_player_item_entry(slot)

func _create_vendor_item_entry(slot: Inventory.InventorySlot):
	"""Create UI entry for vendor item"""
	var item_panel = Panel.new()
	item_panel.size = Vector2(380, 90)
	item_panel.custom_minimum_size = Vector2(380, 100)  # Add extra space for separation
	vendor_items_container.add_child(item_panel)
	
	# Item icon/symbol
	var icon_label = Label.new()
	icon_label.text = slot.item.get_type_icon()
	icon_label.position = Vector2(10, 10)
	icon_label.size = Vector2(40, 40)
	icon_label.add_theme_font_size_override("font_size", 28)
	icon_label.modulate = slot.item.get_rarity_color()
	item_panel.add_child(icon_label)
	
	# Item name
	var name_label = Label.new()
	name_label.text = slot.item.item_name
	name_label.position = Vector2(60, 5)
	name_label.size = Vector2(200, 20)
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.clip_contents = true
	item_panel.add_child(name_label)
	
	# Item description
	var desc_label = Label.new()
	desc_label.text = slot.item.description
	desc_label.position = Vector2(60, 25)
	desc_label.size = Vector2(200, 15)
	desc_label.add_theme_font_size_override("font_size", 10)
	desc_label.modulate = Color(0.8, 0.8, 0.8, 1)
	desc_label.clip_contents = true
	item_panel.add_child(desc_label)
	
	# Quantity
	var quantity_label = Label.new()
	quantity_label.text = "Stock: " + str(slot.quantity)
	quantity_label.position = Vector2(60, 45)
	quantity_label.size = Vector2(80, 20)
	quantity_label.add_theme_font_size_override("font_size", 11)
	item_panel.add_child(quantity_label)
	
	# Price
	var price_label = Label.new()
	var sell_price = current_vendor.get_sell_price(slot.item)
	price_label.text = str(sell_price) + "g"
	price_label.position = Vector2(150, 45)
	price_label.size = Vector2(60, 20)
	price_label.add_theme_font_size_override("font_size", 12)
	price_label.modulate = Color(1, 0.8, 0, 1)  # Gold color
	item_panel.add_child(price_label)
	
	# Buy button
	var buy_button = Button.new()
	buy_button.text = "Buy"
	buy_button.size = Vector2(70, 35)
	buy_button.position = Vector2(300, 30)
	buy_button.pressed.connect(_on_buy_item.bind(slot.item, 1))
	
	# Disable if can't afford or no stock
	if not player_inventory.has_gold(sell_price) or slot.quantity <= 0:
		buy_button.disabled = true
	
	item_panel.add_child(buy_button)
	
	# Add spacer for separation
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 15)
	vendor_items_container.add_child(spacer)

func _create_player_item_entry(slot: Inventory.InventorySlot):
	"""Create UI entry for player item"""
	var item_panel = Panel.new()
	item_panel.size = Vector2(380, 90)
	item_panel.custom_minimum_size = Vector2(380, 100)  # Add extra space for separation
	player_items_container.add_child(item_panel)
	
	# Item icon/symbol
	var icon_label = Label.new()
	icon_label.text = slot.item.get_type_icon()
	icon_label.position = Vector2(10, 10)
	icon_label.size = Vector2(40, 40)
	icon_label.add_theme_font_size_override("font_size", 28)
	icon_label.modulate = slot.item.get_rarity_color()
	item_panel.add_child(icon_label)
	
	# Item name
	var name_label = Label.new()
	name_label.text = slot.item.item_name
	name_label.position = Vector2(60, 5)
	name_label.size = Vector2(200, 20)
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.clip_contents = true
	item_panel.add_child(name_label)
	
	# Item description
	var desc_label = Label.new()
	desc_label.text = slot.item.description
	desc_label.position = Vector2(60, 25)
	desc_label.size = Vector2(200, 15)
	desc_label.add_theme_font_size_override("font_size", 10)
	desc_label.modulate = Color(0.8, 0.8, 0.8, 1)
	desc_label.clip_contents = true
	item_panel.add_child(desc_label)
	
	# Quantity
	var quantity_label = Label.new()
	quantity_label.text = "Owned: " + str(slot.quantity)
	quantity_label.position = Vector2(60, 45)
	quantity_label.size = Vector2(80, 20)
	quantity_label.add_theme_font_size_override("font_size", 11)
	item_panel.add_child(quantity_label)
	
	# Sell price
	var price_label = Label.new()
	var buy_price = current_vendor.get_buy_price(slot.item)
	price_label.text = str(buy_price) + "g"
	price_label.position = Vector2(150, 45)
	price_label.size = Vector2(60, 20)
	price_label.add_theme_font_size_override("font_size", 12)
	price_label.modulate = Color(0.8, 1, 0.8, 1)  # Light green
	item_panel.add_child(price_label)
	
	# Sell button
	var sell_button = Button.new()
	sell_button.text = "Sell"
	sell_button.size = Vector2(70, 35)
	sell_button.position = Vector2(300, 30)
	sell_button.pressed.connect(_on_sell_item.bind(slot.item, 1))
	
	# Disable if vendor can't afford
	if not current_vendor.can_buy_from_player(slot.item, 1):
		sell_button.disabled = true
	
	item_panel.add_child(sell_button)
	
	# Add spacer for separation
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 15)
	player_items_container.add_child(spacer)

func _on_buy_item(item: Item, quantity: int):
	"""Handle buying item from vendor"""
	if current_vendor.sell_to_player(item, quantity, player_inventory):
		transaction_completed.emit(item, quantity, true)
		_update_shop_display()
		print("Purchased ", quantity, "x ", item.item_name)

func _on_sell_item(item: Item, quantity: int):
	"""Handle selling item to vendor"""
	if current_vendor.buy_from_player(item, quantity, player_inventory):
		transaction_completed.emit(item, quantity, false)
		_update_shop_display()
		print("Sold ", quantity, "x ", item.item_name)

func _on_close_pressed():
	"""Handle close button press"""
	hide()
	shop_closed.emit()
	
	if current_vendor:
		current_vendor.end_interaction()

func _input(event):
	"""Handle input events"""
	if visible and event.is_action_pressed("ui_cancel"):
		_on_close_pressed()