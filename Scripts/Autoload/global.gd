## Global functions and variables
##
## Autoloaded at the start of the game.[br]
##
## Author: Sol Rojo[br]Date: 24-09-2024
##

extends Node

func rand_range(min_value: int, max_value: int) -> int:
	return randi() % (max_value - min_value + 1) + min_value

const PROJECTILE = preload("res://Scenes/projectile.tscn")
const ANIMATED_TEXT = preload("res://Scenes/text_animated.tscn")
const ITEM = preload("res://Scenes/item.tscn")

const LEVEL_SIDE = preload("res://Scripts/level_side.gd")

var level_selected := Data.Level.GREED
var level_unlocked := Data.Level.GREED

func drop_random_item(position: Vector2, parent: Node2D, unlocked_weapons: Dictionary) -> void:
	var item = ITEM.instantiate()
	item.position = position

	var items_dropabale := []
	for weapon in unlocked_weapons:
		if weapon != Data.Weapons.SWORD and unlocked_weapons[weapon] == true:
			items_dropabale.append(Data.WEAPONS[weapon].ammo)
	items_dropabale.append(Data.Items.LIFE)
	item.type = items_dropabale.pick_random()

	parent.add_child(item)

# * Save and load game

const SAVE_PATH = "user://data.save"

func save_game() -> void:
	var player = get_tree().get_first_node_in_group("player")

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(player.ammo_current)
	file.store_var(player.weapons_unlocked)
	file.store_var(player.ammo_inventory)
	file.store_var(level_unlocked)

	file.close()

func load_game() -> void:
	var player = get_tree().get_first_node_in_group("player")

	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	player.ammo_current = file.get_var()
	player.weapons_unlocked = file.get_var()
	player.ammo_inventory = file.get_var()
	level_unlocked = file.get_var()

	file.close()
