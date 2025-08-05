extends Resource
class_name Item

# Item - Base class for all items in the game
# Single responsibility: Store item data and properties

@export var item_id: String = ""
@export var item_name: String = "Unknown Item"
@export var description: String = "A mysterious item."
@export var item_type: String = "misc"  # weapon, armor, consumable, misc, key
@export var rarity: String = "common"   # common, uncommon, rare, epic, legendary
@export var value: int = 1
@export var stack_size: int = 1
@export var icon_texture: Texture2D

# Item properties
@export var properties: Dictionary = {}

func _init(id: String = "", name: String = "", desc: String = ""):
	if id != "":
		item_id = id
	if name != "":
		item_name = name
	if desc != "":
		description = desc

func get_rarity_color() -> Color:
	"""Get color associated with item rarity"""
	match rarity:
		"common": return Color(0.8, 0.8, 0.8, 1)      # Light gray
		"uncommon": return Color(0.3, 0.8, 0.3, 1)    # Green
		"rare": return Color(0.3, 0.3, 0.9, 1)        # Blue
		"epic": return Color(0.7, 0.3, 0.9, 1)        # Purple
		"legendary": return Color(1.0, 0.6, 0.0, 1)   # Orange
		_: return Color(1, 1, 1, 1)

func get_type_icon() -> String:
	"""Get icon character for item type"""
	match item_type:
		"weapon": return "⚔"
		"armor": return "🛡"
		"consumable": return "🧪"
		"key": return "🗝"
		"misc": return "📦"
		_: return "?"

func can_stack_with(other_item: Item) -> bool:
	"""Check if this item can stack with another"""
	return item_id == other_item.item_id and stack_size > 1

func get_display_name() -> String:
	"""Get formatted display name with rarity"""
	var color_code = ""
	match rarity:
		"uncommon": color_code = "[color=green]"
		"rare": color_code = "[color=blue]"
		"epic": color_code = "[color=purple]"
		"legendary": color_code = "[color=orange]"
	
	if color_code != "":
		return color_code + item_name + "[/color]"
	return item_name

func get_tooltip_text() -> String:
	"""Get formatted tooltip text"""
	var tooltip = "[b]" + get_display_name() + "[/b]\n"
	tooltip += description + "\n"
	tooltip += "\n[i]Type: " + item_type.capitalize() + "[/i]"
	tooltip += "\n[i]Value: " + str(value) + " gold[/i]"
	
	if properties.size() > 0:
		tooltip += "\n\n[b]Properties:[/b]"
		for prop in properties:
			tooltip += "\n• " + str(prop) + ": " + str(properties[prop])
	
	return tooltip

# Static factory methods for common items
static func create_weapon(id: String, name: String, damage: int, item_value: int = 10) -> Item:
	var item = Item.new(id, name, "A weapon for combat.")
	item.item_type = "weapon"
	item.value = item_value
	item.properties["damage"] = damage
	return item

static func create_armor(id: String, name: String, defense: int, item_value: int = 15) -> Item:
	var item = Item.new(id, name, "Protective armor.")
	item.item_type = "armor"
	item.value = item_value
	item.properties["defense"] = defense
	return item

static func create_consumable(id: String, name: String, effect: String, item_value: int = 5) -> Item:
	var item = Item.new(id, name, "A consumable item.")
	item.item_type = "consumable"
	item.value = item_value
	item.stack_size = 10
	item.properties["effect"] = effect
	return item

static func create_key_item(id: String, name: String, desc: String) -> Item:
	var item = Item.new(id, name, desc)
	item.item_type = "key"
	item.value = 0
	item.stack_size = 1
	return item
