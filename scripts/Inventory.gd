extends Node
class_name Inventory

# Inventory - Manages item storage and operations
# Single responsibility: Handle item storage, stacking, and inventory operations

@export var max_slots: int = 20
@export var gold: int = 100

# Inventory data
var items: Array[InventorySlot] = []

# Signals
signal item_added(item: Item, quantity: int)
signal item_removed(item: Item, quantity: int)
signal inventory_changed()
signal gold_changed(new_amount: int)

class InventorySlot:
	var item: Item
	var quantity: int
	
	func _init(item_instance: Item = null, qty: int = 0):
		item = item_instance
		quantity = qty
	
	func is_empty() -> bool:
		return item == null or quantity <= 0
	
	func can_add_item(new_item: Item, qty: int) -> bool:
		if is_empty():
			return true
		if item.can_stack_with(new_item):
			return quantity + qty <= item.stack_size
		return false
	
	func add_quantity(qty: int) -> int:
		var old_qty = quantity
		quantity = min(quantity + qty, item.stack_size if item else qty)
		return quantity - old_qty
	
	func remove_quantity(qty: int) -> int:
		var removed = min(quantity, qty)
		quantity -= removed
		if quantity <= 0:
			item = null
			quantity = 0
		return removed

func _ready():
	_initialize_inventory()

func _initialize_inventory():
	"""Initialize empty inventory slots"""
	items.clear()
	for i in range(max_slots):
		items.append(InventorySlot.new())

func add_item(item: Item, quantity: int = 1) -> int:
	"""Add item to inventory, returns quantity actually added"""
	if not item or quantity <= 0:
		return 0
	
	var remaining = quantity
	
	# First, try to stack with existing items
	if item.stack_size > 1:
		for slot in items:
			if slot.can_add_item(item, remaining):
				if slot.is_empty():
					slot.item = item
					slot.quantity = 0
				
				var added = slot.add_quantity(remaining)
				remaining -= added
				
				if remaining <= 0:
					break
	
	# Then, try to add to empty slots
	if remaining > 0:
		for slot in items:
			if slot.is_empty():
				slot.item = item
				var to_add = min(remaining, item.stack_size)
				slot.quantity = to_add
				remaining -= to_add
				
				if remaining <= 0:
					break
	
	var actually_added = quantity - remaining
	if actually_added > 0:
		item_added.emit(item, actually_added)
		inventory_changed.emit()
		print("Added ", actually_added, "x ", item.item_name, " to inventory")
	
	return actually_added

func remove_item(item: Item, quantity: int = 1) -> int:
	"""Remove item from inventory, returns quantity actually removed"""
	if not item or quantity <= 0:
		return 0
	
	var remaining = quantity
	
	for slot in items:
		if not slot.is_empty() and slot.item.item_id == item.item_id:
			var removed = slot.remove_quantity(remaining)
			remaining -= removed
			
			if remaining <= 0:
				break
	
	var actually_removed = quantity - remaining
	if actually_removed > 0:
		item_removed.emit(item, actually_removed)
		inventory_changed.emit()
		print("Removed ", actually_removed, "x ", item.item_name, " from inventory")
	
	return actually_removed

func has_item(item: Item, quantity: int = 1) -> bool:
	"""Check if inventory contains enough of an item"""
	return get_item_count(item) >= quantity

func get_item_count(item: Item) -> int:
	"""Get total count of an item in inventory"""
	var count = 0
	for slot in items:
		if not slot.is_empty() and slot.item.item_id == item.item_id:
			count += slot.quantity
	return count

func get_empty_slot_count() -> int:
	"""Get number of empty slots"""
	var count = 0
	for slot in items:
		if slot.is_empty():
			count += 1
	return count

func is_full() -> bool:
	"""Check if inventory is full"""
	return get_empty_slot_count() == 0

func get_all_items() -> Array[InventorySlot]:
	"""Get all non-empty inventory slots"""
	var non_empty_slots: Array[InventorySlot] = []
	for slot in items:
		if not slot.is_empty():
			non_empty_slots.append(slot)
	return non_empty_slots

func get_items_by_type(item_type: String) -> Array[InventorySlot]:
	"""Get all items of a specific type"""
	var filtered_slots: Array[InventorySlot] = []
	for slot in items:
		if not slot.is_empty() and slot.item.item_type == item_type:
			filtered_slots.append(slot)
	return filtered_slots

func add_gold(amount: int):
	"""Add gold to inventory"""
	gold += amount
	gold_changed.emit(gold)
	print("Added ", amount, " gold. Total: ", gold)

func remove_gold(amount: int) -> bool:
	"""Remove gold from inventory, returns true if successful"""
	if gold >= amount:
		gold -= amount
		gold_changed.emit(gold)
		print("Removed ", amount, " gold. Total: ", gold)
		return true
	return false

func has_gold(amount: int) -> bool:
	"""Check if player has enough gold"""
	return gold >= amount

func clear_inventory():
	"""Clear all items from inventory"""
	_initialize_inventory()
	inventory_changed.emit()
	print("Inventory cleared")

func get_inventory_value() -> int:
	"""Get total value of all items in inventory"""
	var total_value = 0
	for slot in items:
		if not slot.is_empty():
			total_value += slot.item.value * slot.quantity
	return total_value + gold

func sort_inventory():
	"""Sort inventory by item type and rarity"""
	var non_empty_slots = get_all_items()
	
	# Sort by type first, then by rarity
	non_empty_slots.sort_custom(func(a, b):
		if a.item.item_type != b.item.item_type:
			return a.item.item_type < b.item.item_type
		return a.item.rarity < b.item.rarity
	)
	
	# Clear and refill inventory
	_initialize_inventory()
	for i in range(min(non_empty_slots.size(), max_slots)):
		items[i] = non_empty_slots[i]
	
	inventory_changed.emit()
	print("Inventory sorted")

func get_save_data() -> Dictionary:
	"""Get inventory data for saving"""
	var save_data = {
		"gold": gold,
		"items": []
	}
	
	for slot in items:
		if not slot.is_empty():
			save_data.items.append({
				"item_id": slot.item.item_id,
				"quantity": slot.quantity
			})
	
	return save_data

func load_save_data(data: Dictionary):
	"""Load inventory data from save"""
	if data.has("gold"):
		gold = data.gold
		gold_changed.emit(gold)
	
	if data.has("items"):
		clear_inventory()
		for item_data in data.items:
			# This would need an ItemDatabase to recreate items from IDs
			# For now, we'll skip the actual loading
			pass
	
	inventory_changed.emit()