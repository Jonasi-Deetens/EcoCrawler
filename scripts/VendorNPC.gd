extends NPC
class_name VendorNPC

# VendorNPC - Specialized NPC for trading
# Single responsibility: Handle vendor-specific interactions and shop management

@export var shop_name: String = "General Store"
@export var buy_rate: float = 0.6  # Vendor buys at 60% of item value
@export var sell_markup: float = 1.2  # Vendor sells at 120% of base value

# Shop inventory
var shop_items: Array[Inventory.InventorySlot] = []
var vendor_gold: int = 1000

# Signals
signal shop_opened(vendor: VendorNPC)
signal shop_closed(vendor: VendorNPC)
signal item_purchased(item: Item, quantity: int, cost: int)
signal item_sold(item: Item, quantity: int, payment: int)

func _init():
	super._init()
	npc_type = "vendor"
	interaction_prompt = "Press E to shop"

func _ready():
	super._ready()
	_setup_shop_inventory()

func _setup_shop_inventory():
	"""Initialize shop with default items"""
	# Create some basic shop items
	add_shop_item(Item.create_weapon("iron_sword", "Iron Sword", 10, 50), 3)
	add_shop_item(Item.create_armor("leather_armor", "Leather Armor", 5, 30), 2)
	add_shop_item(Item.create_consumable("health_potion", "Health Potion", "heal_20", 15), 10)
	add_shop_item(Item.create_consumable("mana_potion", "Mana Potion", "mana_20", 12), 8)
	
	# Add some misc items
	var rope = Item.new("rope", "Rope", "Useful for climbing.")
	rope.item_type = "misc"
	rope.value = 5
	add_shop_item(rope, 5)
	
	var torch = Item.new("torch", "Torch", "Lights up dark places.")
	torch.item_type = "misc"
	torch.value = 3
	torch.stack_size = 5
	add_shop_item(torch, 20)

func add_shop_item(item: Item, quantity: int):
	"""Add an item to the shop inventory"""
	var slot = Inventory.InventorySlot.new(item, quantity)
	shop_items.append(slot)

func get_shop_items() -> Array[Inventory.InventorySlot]:
	"""Get all items available in the shop"""
	return shop_items.filter(func(slot): return not slot.is_empty())

func get_buy_price(item: Item) -> int:
	"""Get the price the vendor will pay for an item"""
	return int(item.value * buy_rate)

func get_sell_price(item: Item) -> int:
	"""Get the price the vendor charges for an item"""
	return int(item.value * sell_markup)

func can_buy_from_player(item: Item, quantity: int) -> bool:
	"""Check if vendor can buy item from player"""
	var total_cost = get_buy_price(item) * quantity
	return vendor_gold >= total_cost

func can_sell_to_player(item: Item, quantity: int) -> bool:
	"""Check if vendor has enough stock to sell"""
	for slot in shop_items:
		if not slot.is_empty() and slot.item.item_id == item.item_id:
			return slot.quantity >= quantity
	return false

func buy_from_player(item: Item, quantity: int, player_inventory: Inventory) -> bool:
	"""Vendor buys item from player"""
	if not can_buy_from_player(item, quantity):
		print("Vendor can't afford to buy ", quantity, "x ", item.item_name)
		return false
	
	if not player_inventory.has_item(item, quantity):
		print("Player doesn't have enough ", item.item_name)
		return false
	
	var total_payment = get_buy_price(item) * quantity
	
	# Remove item from player
	var removed = player_inventory.remove_item(item, quantity)
	if removed != quantity:
		print("Failed to remove items from player inventory")
		return false
	
	# Pay player
	player_inventory.add_gold(total_payment)
	vendor_gold -= total_payment
	
	# Add to vendor inventory (simplified - vendor has infinite storage)
	print("Vendor bought ", quantity, "x ", item.item_name, " for ", total_payment, " gold")
	item_purchased.emit(item, quantity, total_payment)
	return true

func sell_to_player(item: Item, quantity: int, player_inventory: Inventory) -> bool:
	"""Vendor sells item to player"""
	if not can_sell_to_player(item, quantity):
		print("Vendor doesn't have enough ", item.item_name)
		return false
	
	var total_cost = get_sell_price(item) * quantity
	if not player_inventory.has_gold(total_cost):
		print("Player can't afford ", quantity, "x ", item.item_name, " (costs ", total_cost, " gold)")
		return false
	
	# Check if player has inventory space
	var test_added = player_inventory.add_item(item, quantity)
	if test_added != quantity:
		# Remove what we added for the test
		if test_added > 0:
			player_inventory.remove_item(item, test_added)
		print("Player doesn't have enough inventory space")
		return false
	
	# Remove the test items we added
	player_inventory.remove_item(item, test_added)
	
	# Remove from vendor inventory
	for slot in shop_items:
		if not slot.is_empty() and slot.item.item_id == item.item_id:
			slot.remove_quantity(quantity)
			break
	
	# Actually add to player and charge
	player_inventory.add_item(item, quantity)
	player_inventory.remove_gold(total_cost)
	vendor_gold += total_cost
	
	print("Vendor sold ", quantity, "x ", item.item_name, " for ", total_cost, " gold")
	item_sold.emit(item, quantity, total_cost)
	return true

func start_interaction():
	"""Override to open shop instead of dialogue"""
	if not can_interact:
		return
	
	is_interacting = true
	interaction_started.emit(self)
	shop_opened.emit(self)
	print("Opened shop: ", shop_name)

func end_interaction():
	"""Override to close shop"""
	is_interacting = false
	interaction_ended.emit(self)
	shop_closed.emit(self)
	print("Closed shop: ", shop_name)

func get_shop_data() -> Dictionary:
	"""Get shop data for UI"""
	return {
		"shop_name": shop_name,
		"vendor_name": npc_name,
		"vendor_gold": vendor_gold,
		"items": get_shop_items(),
		"buy_rate": buy_rate,
		"sell_markup": sell_markup
	}

func restock_shop():
	"""Restock shop items (called periodically)"""
	for slot in shop_items:
		if not slot.is_empty():
			# Restock to a reasonable amount
			var max_stock = 10
			if slot.item.item_type == "consumable":
				max_stock = 20
			elif slot.item.item_type in ["weapon", "armor"]:
				max_stock = 3
			
			slot.quantity = min(slot.quantity + 1, max_stock)
	
	print("Shop restocked: ", shop_name)