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

func drop_random_item(position: Vector2, parent: Node2D, unlocked_weapons: Dictionary) -> void:
	var item = ITEM.instantiate()
	item.position = position
	item.z_index = 1
	item.y_sort_enabled = true

	var items_dropabale := []
	for weapon in unlocked_weapons:
		if weapon != Data.Weapons.SWORD and unlocked_weapons[weapon] == true:
			items_dropabale.append(Data.WEAPONS[weapon].ammo)
	items_dropabale.append(Data.Items.LIFE)
	item.type = items_dropabale.pick_random()

	parent.add_child(item)

var level_selected := 0
