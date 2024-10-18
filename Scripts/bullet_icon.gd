## Behavior the bullets icons
##
## Author: Sol Rojo[br]Date: 17-10-2024
##

extends Node2D

@onready var bullet: Sprite2D = $Bullet
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var frame := 0

var size_texture : = Vector2(3, 3)
var scale_sprite := Vector2(8, 8)

func _ready() -> void:
	bullet.frame = frame
	size_texture = bullet.texture.get_size()
	scale_sprite = bullet.scale

func play(action):
	animation_player.play(action)
