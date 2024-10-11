## Script for the weapon pickup
##
## Author: Sol Rojo[br]Date: 24-09-2024
##

extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var weapon_sprite: Sprite2D = $WeaponSprite

@export var type := Data.Weapons.PISTOL
@export var is_static := false

# TODO put this in a global script
const TEXT_ANIMATED = preload("res://Scenes/text_animated.tscn")

func _ready() -> void:
	weapon_sprite.frame = Data.WEAPONS[type].item_frame
	if not is_static:
		animation_player.play("floating")
		

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.unlock_weapon(type)

		var text_animated = TEXT_ANIMATED.instantiate()
		text_animated.text = str(Data.WEAPONS[type].name)
		text_animated.position = position
		get_parent().add_child(text_animated)

		queue_free()
