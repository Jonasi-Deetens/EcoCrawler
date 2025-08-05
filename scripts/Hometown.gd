extends Node2D

# Hometown - Main village hub for EcoCrawler
# Single responsibility: Manage village interactions and scene transitions

@onready var player: CharacterBody2D = $Player
@onready var dungeon_entrance_area: Area2D = $DungeonEntrance/DungeonEntranceArea

# NPCs and vendors
var npcs: Array[NPC] = []
var player_manager: PlayerManager

signal enter_dungeon_requested
signal back_to_menu_requested

func _ready():
	print("Hometown: Initializing village...")
	
	# Create visual design first
	_setup_visual_design()
	
	# Set up player management systems
	_setup_player_manager()
	
	# Create NPCs and vendors
	_setup_npcs()
	
	# Connect signals
	_connect_signals()
	
	print("Hometown: Village ready with vendors and NPCs!")

func _setup_visual_design():
	"""Set up the visual design for the hometown"""
	var visuals = HometownVisuals.new()
	visuals.name = "HometownVisuals"
	add_child(visuals)

func _setup_player_manager():
	"""Set up player management systems"""
	player_manager = PlayerManager.new()
	player_manager.name = "PlayerManager"
	add_child(player_manager)

func _setup_npcs():
	"""Create and position NPCs in the town"""
	# Weapon vendor
	var weapon_vendor = VendorNPC.new()
	weapon_vendor.npc_name = "Gareth the Blacksmith"
	weapon_vendor.shop_name = "Gareth's Forge"
	weapon_vendor.position = Vector2(200, 300)
	weapon_vendor.dialogue_lines.assign([
		"Welcome to my forge!",
		"I've got the finest weapons and armor in town.",
		"Just forged some new pieces this morning!"
	])
	add_child(weapon_vendor)
	npcs.append(weapon_vendor)
	print("Added weapon vendor: ", weapon_vendor.npc_name, " at ", weapon_vendor.position)
	
	# Potion vendor
	var potion_vendor = VendorNPC.new()
	potion_vendor.npc_name = "Elara the Alchemist"
	potion_vendor.shop_name = "Elara's Elixirs"
	potion_vendor.position = Vector2(400, 250)
	potion_vendor.dialogue_lines.assign([
		"Greetings, adventurer!",
		"My potions will keep you alive in the dungeons.",
		"Fresh ingredients, guaranteed effectiveness!"
	])
	# Customize potion shop
	potion_vendor.shop_items.clear()
	potion_vendor.add_shop_item(Item.create_consumable("health_potion", "Health Potion", "heal_20", 15), 15)
	potion_vendor.add_shop_item(Item.create_consumable("mana_potion", "Mana Potion", "mana_20", 12), 12)
	potion_vendor.add_shop_item(Item.create_consumable("antidote", "Antidote", "cure_poison", 8), 8)
	potion_vendor.add_shop_item(Item.create_consumable("energy_drink", "Energy Drink", "boost_stamina", 20), 5)
	add_child(potion_vendor)
	npcs.append(potion_vendor)
	print("Added potion vendor: ", potion_vendor.npc_name, " at ", potion_vendor.position)
	
	# General goods vendor
	var general_vendor = VendorNPC.new()
	general_vendor.npc_name = "Marcus the Merchant"
	general_vendor.shop_name = "Marcus' General Store"
	general_vendor.position = Vector2(600, 320)
	general_vendor.dialogue_lines.assign([
		"Welcome to my store!",
		"I've got everything an adventurer needs.",
		"Tools, supplies, and curiosities from far lands!"
	])
	add_child(general_vendor)
	npcs.append(general_vendor)
	print("Added general vendor: ", general_vendor.npc_name, " at ", general_vendor.position)
	
	# Town guard (non-vendor NPC)
	var guard = NPC.new()
	guard.npc_name = "Captain Thorne"
	guard.npc_type = "guard"
	guard.position = Vector2(500, 150)
	guard.dialogue_lines.assign([
		"Stay safe out there, adventurer.",
		"The dungeons have been more dangerous lately.",
		"Strange creatures have been spotted in the deeper levels.",
		"Make sure you're well-equipped before venturing forth."
	])
	add_child(guard)
	npcs.append(guard)
	print("Added guard: ", guard.npc_name, " at ", guard.position)
	
	# Townsperson
	var citizen = NPC.new()
	citizen.npc_name = "Old Martha"
	citizen.npc_type = "citizen"
	citizen.position = Vector2(300, 400)
	citizen.dialogue_lines.assign([
		"Oh hello there, dear!",
		"Be careful in those dungeons.",
		"My grandson went in there last week...",
		"He came back with the strangest stories about the ecosystem down there."
	])
	add_child(citizen)
	npcs.append(citizen)
	print("Added citizen: ", citizen.npc_name, " at ", citizen.position)

func _connect_signals():
	"""Connect all necessary signals"""
	# Connect dungeon entrance signal
	dungeon_entrance_area.body_entered.connect(_on_dungeon_entrance_entered)
	
	# Connect NPC signals to player manager
	for npc in npcs:
		if npc is VendorNPC:
			var vendor = npc as VendorNPC
			# Connect to PlayerManager instead of local handlers
			vendor.shop_opened.connect(player_manager._on_vendor_shop_opened)
			vendor.shop_closed.connect(player_manager._on_vendor_shop_closed)



func _input(event):
	"""Handle global input events"""
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()

func _on_back_button_pressed():
	"""Return to main menu"""
	print("Hometown: Returning to menu...")
	back_to_menu_requested.emit()
	get_tree().change_scene_to_file("res://scenes/MenuScreen.tscn")

func _on_dungeon_entrance_entered(body: Node2D):
	"""Handle player entering dungeon entrance"""
	if body == player:
		print("Hometown: Player entering dungeon...")
		enter_dungeon_requested.emit()
		# Defer the scene change to avoid physics callback issues
		call_deferred("_change_to_dungeon")

func _change_to_dungeon():
	"""Change to dungeon scene (called deferred)"""
	get_tree().change_scene_to_file("res://scenes/DungeonRoom.tscn") 
