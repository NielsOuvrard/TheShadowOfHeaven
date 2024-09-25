# weapons.gd
#
# This script defines the behavior of the weapons that the player can pick up.
#
# Author: Sol Rojo
# Date: 24-09-2024
#

extends Node2D

@onready var weapon_sprite: Sprite2D = $WeaponSprite
@export var type_weapon := Data.Weapons.PISTOL

const DAMAGET_TEXT = preload("res://Scenes/damage_text.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	weapon_sprite.frame = Data.WEAPONS[type_weapon].item_frame

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.player.unlock_weapon(type_weapon)

		var damage_text = DAMAGET_TEXT.instantiate()
		damage_text.text = str(Data.WEAPONS[type_weapon].name)
		damage_text.position = position
		get_parent().add_child(damage_text)

		queue_free()
