## Behavior of the items that the player can pick up.
##
## Author: Sol Rojo[br]Date: 24-09-2024
##

extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var item_sprite: Sprite2D = $ItemSprite

@export var type := Data.Items.PISTOL_AMMO
@export var is_static := false

# make animation throw on the ground
# make animation moving
# make animation collect

# TODO delete weapon scene if possible, to keep only this one

func _ready() -> void:
	item_sprite.frame = Data.ITEMS[type].frame
	if not is_static:
		animation_player.play("floating")
		

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var nmb = Global.rand_range(Data.ITEMS[type].n_min, Data.ITEMS[type].n_max)
		body.add_to_inventory(type, nmb)

		var text_animated = Global.ANIMATED_TEXT.instantiate()
		text_animated.text = str(nmb)
		text_animated.position = position
		owner.add_child(text_animated)
		queue_free()
