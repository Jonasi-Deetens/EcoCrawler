extends Node
class_name PlayerManager

# PlayerManager - Manages player state, inventory, and interactions
# Single responsibility: Coordinate player systems and UI management

# Player systems
var player_inventory: Inventory
var inventory_ui: InventoryUI
var shop_ui: ShopUI

# UI state
var is_inventory_open: bool = false
var is_shop_open: bool = false
var current_interacting_npc: NPC

# Signals
signal interaction_state_changed(is_interacting: bool)

func _ready():
	_initialize_player_systems()
	_setup_ui()

func _initialize_player_systems():
	"""Initialize player inventory and systems"""
	# Create inventory
	player_inventory = Inventory.new()
	add_child(player_inventory)
	
	# Add some starting items for testing
	_add_starting_items()

func _add_starting_items():
	"""Add some starting items to player inventory"""
	# Starting equipment
	var starter_sword = Item.create_weapon("starter_sword", "Rusty Sword", 5, 20)
	starter_sword.rarity = "common"
	player_inventory.add_item(starter_sword, 1)
	
	var leather_vest = Item.create_armor("leather_vest", "Leather Vest", 3, 25)
	leather_vest.rarity = "common"
	player_inventory.add_item(leather_vest, 1)
	
	# Starting consumables
	var health_potion = Item.create_consumable("health_potion_small", "Small Health Potion", "heal_10", 8)
	player_inventory.add_item(health_potion, 3)
	
	# Starting misc items
	var old_key = Item.create_key_item("old_key", "Old Key", "A rusty old key. What does it unlock?")
	player_inventory.add_item(old_key, 1)
	
	print("Added starting items to player inventory")

func _setup_ui():
	"""Set up UI systems"""
	# Create inventory UI
	inventory_ui = InventoryUI.new()
	inventory_ui.name = "InventoryUI"
	get_tree().current_scene.add_child(inventory_ui)
	inventory_ui.setup_inventory(player_inventory)
	
	# Connect inventory UI signals
	inventory_ui.inventory_closed.connect(_on_inventory_closed)
	inventory_ui.item_used.connect(_on_item_used)
	
	# Create shop UI
	shop_ui = ShopUI.new()
	shop_ui.name = "ShopUI"
	get_tree().current_scene.add_child(shop_ui)
	
	# Connect shop UI signals
	shop_ui.shop_closed.connect(_on_shop_closed)
	shop_ui.transaction_completed.connect(_on_transaction_completed)

func _input(event):
	"""Handle player input"""
	# Toggle inventory
	if event.is_action_pressed("toggle_inventory"):  # I key
		toggle_inventory()
	
	# Handle NPC interactions
	if event.is_action_pressed("ui_accept") and current_interacting_npc:
		if current_interacting_npc is VendorNPC:
			open_shop(current_interacting_npc as VendorNPC)

func toggle_inventory():
	"""Toggle inventory UI"""
	if is_shop_open:
		return  # Don't open inventory while shop is open
	
	if is_inventory_open:
		close_inventory()
	else:
		open_inventory()

func open_inventory():
	"""Open inventory UI"""
	if is_shop_open:
		return
	
	is_inventory_open = true
	inventory_ui.show_inventory()
	interaction_state_changed.emit(true)
	print("Inventory opened")

func close_inventory():
	"""Close inventory UI"""
	is_inventory_open = false
	inventory_ui.hide_inventory()
	interaction_state_changed.emit(false)
	print("Inventory closed")

func open_shop(vendor: VendorNPC):
	"""Open shop UI with vendor"""
	if is_inventory_open:
		close_inventory()
	
	is_shop_open = true
	shop_ui.open_shop(vendor, player_inventory)
	interaction_state_changed.emit(true)
	print("Shop opened with ", vendor.npc_name)

func close_shop():
	"""Close shop UI"""
	is_shop_open = false
	shop_ui.hide()
	interaction_state_changed.emit(false)
	print("Shop closed")

func _on_inventory_closed():
	"""Handle inventory UI being closed"""
	is_inventory_open = false
	interaction_state_changed.emit(false)

func _on_shop_closed():
	"""Handle shop UI being closed"""
	is_shop_open = false
	interaction_state_changed.emit(false)

func _on_item_used(item: Item):
	"""Handle item being used"""
	print("Player used: ", item.item_name)
	
	# Handle different item effects
	match item.item_type:
		"consumable":
			_handle_consumable_use(item)
		"key":
			_handle_key_use(item)

func _handle_consumable_use(item: Item):
	"""Handle consumable item effects"""
	if item.properties.has("effect"):
		var effect = item.properties["effect"]
		
		match effect:
			"heal_10":
				print("Player healed for 10 HP")
				# TODO: Actually heal player when health system exists
			"heal_20":
				print("Player healed for 20 HP")
			"mana_20":
				print("Player restored 20 MP")
			_:
				print("Unknown consumable effect: ", effect)

func _handle_key_use(item: Item):
	"""Handle key item usage"""
	print("Used key item: ", item.item_name)
	# TODO: Implement key item logic

func _on_transaction_completed(item: Item, quantity: int, is_purchase: bool):
	"""Handle shop transaction completion"""
	if is_purchase:
		print("Player bought ", quantity, "x ", item.item_name)
	else:
		print("Player sold ", quantity, "x ", item.item_name)

func register_npc_interaction(npc: NPC):
	"""Register NPC for interaction"""
	current_interacting_npc = npc
	npc.interaction_started.connect(_on_npc_interaction_started)
	npc.interaction_ended.connect(_on_npc_interaction_ended)

func unregister_npc_interaction(npc: NPC):
	"""Unregister NPC interaction"""
	if current_interacting_npc == npc:
		current_interacting_npc = null
	
	if npc.interaction_started.is_connected(_on_npc_interaction_started):
		npc.interaction_started.disconnect(_on_npc_interaction_started)
	if npc.interaction_ended.is_connected(_on_npc_interaction_ended):
		npc.interaction_ended.disconnect(_on_npc_interaction_ended)

func _on_npc_interaction_started(npc: NPC):
	"""Handle NPC interaction starting"""
	current_interacting_npc = npc
	
	if npc is VendorNPC:
		open_shop(npc as VendorNPC)

func _on_npc_interaction_ended(npc: NPC):
	"""Handle NPC interaction ending"""
	if current_interacting_npc == npc:
		current_interacting_npc = null
	
	if is_shop_open:
		close_shop()

func get_inventory() -> Inventory:
	"""Get player inventory reference"""
	return player_inventory

func add_item_to_inventory(item: Item, quantity: int = 1) -> int:
	"""Add item to player inventory"""
	return player_inventory.add_item(item, quantity)

func remove_item_from_inventory(item: Item, quantity: int = 1) -> int:
	"""Remove item from player inventory"""
	return player_inventory.remove_item(item, quantity)

func has_item(item: Item, quantity: int = 1) -> bool:
	"""Check if player has item"""
	return player_inventory.has_item(item, quantity)

func add_gold(amount: int):
	"""Add gold to player"""
	player_inventory.add_gold(amount)

func remove_gold(amount: int) -> bool:
	"""Remove gold from player"""
	return player_inventory.remove_gold(amount)

func has_gold(amount: int) -> bool:
	"""Check if player has enough gold"""
	return player_inventory.has_gold(amount)
