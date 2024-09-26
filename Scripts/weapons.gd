# weapons.gd
#
# This script defines the behavior of the weapons that the player can pick up.
#
# Author: Sol Rojo
# Date: 24-09-2024
#

extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var weapon_sprite: Sprite2D = $WeaponSprite

@export var type := Data.Weapons.PISTOL
@export var is_static := false

const DAMAGET_TEXT = preload("res://Scenes/damage_text.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	weapon_sprite.frame = Data.WEAPONS[type].item_frame
	if not is_static:
		animation_player.play("floating")
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.player.unlock_weapon(type)

		var damage_text = DAMAGET_TEXT.instantiate()
		damage_text.text = str(Data.WEAPONS[type].name)
		damage_text.position = position
		get_parent().add_child(damage_text)

		queue_free()
