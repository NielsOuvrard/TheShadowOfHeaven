# item.gd
#
# This script defines the behavior of the items that the player can pick up.
#
# Author: Sol Rojo
# Date: 24-09-2024
#

extends Node2D

@onready var item_sprite: Sprite2D = $ItemSprite
@export var type_item := Data.Items.PISTOL_AMMO

const DAMAGET_TEXT = preload("res://Scenes/damage_text.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_sprite.frame = Data.ITEMS[type_item].frame

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var nmb = Data.rand_range(Data.ITEMS[type_item].n_min, Data.ITEMS[type_item].n_max)
		body.player.add_to_inventory(type_item, nmb)

		var damage_text = DAMAGET_TEXT.instantiate()
		damage_text.text = str(nmb)
		damage_text.position = position
		get_parent().add_child(damage_text)

		queue_free()
