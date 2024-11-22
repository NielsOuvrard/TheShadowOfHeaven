## Behavior of the items that the player can pick up.
##
## Author: Sol Rojo[br]Date: 24-09-2024
##

extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var item_sprite: Sprite2D = $ItemSprite
@onready var sound_take_item: AudioStreamPlayer2D = $TakeItem
@onready var destroy_cooldown: Timer = $DestroyCooldown

@export var type := Data.Items.PISTOL_AMMO
@export var is_static := false

# make animation throw on the ground
# make animation collect

# TODO delete weapon scene if possible, to keep only this one
var nmb

func _ready() -> void:
	nmb = Global.rand_range(Data.ITEMS[type].n_min, Data.ITEMS[type].n_max)
	item_sprite.frame = Data.ITEMS[type].frame
	if nmb == 1 and type == Data.Items.LIFE:
		# half life
		item_sprite.hframes = 8
		item_sprite.frame = 15
	if not is_static:
		animation_player.play("floating")
		

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and item_sprite.visible:
		body.add_to_inventory(type, nmb)

		var text_animated = Global.ANIMATED_TEXT.instantiate()
		text_animated.text = str(nmb)
		text_animated.z_index = 2
		text_animated.position = position
		get_parent().add_child(text_animated)
		item_sprite.visible = false
		destroy_cooldown.start()
		sound_take_item.play()


func _on_timer_timeout() -> void:
	queue_free()
