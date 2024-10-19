## Behavior the bullets icons
##
## Author: Sol Rojo[br]Date: 17-10-2024
##

extends Node2D

@onready var bullet: Sprite2D = $Bullet
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cooldown: Timer = $Cooldown

var frame := 0

var size_texture : = Vector2(3, 3)
var scale_sprite := Vector2(8, 8)

func disabled(time_cooldown: float):
	bullet.modulate = Color(0.25, 0.25, 0.25)
	cooldown.wait_time = time_cooldown
	cooldown.start()

func _ready() -> void:
	bullet.frame = frame
	size_texture = bullet.texture.get_size()
	scale_sprite = bullet.scale

func play(action):
	animation_player.play(action)

func _on_cooldown_timeout() -> void:
	bullet.modulate = Color(1, 1, 1)
