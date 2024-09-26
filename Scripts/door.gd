# door.gd
#
# This script defines the behavior of the doors.
# The player can interact with it, or it can be triggered by it's own.
#
# Author: Sol Rojo
# Date: 24-09-2024
#

extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

enum DoorState {
	CLOSED,
	OPENED,
	OPENING,
	CLOSING
}
# opend-front / opend-back

@export var state: DoorState = DoorState.CLOSED


func _ready() -> void:
	match state:
		DoorState.CLOSED:
			animated_sprite.play("closed")
		DoorState.OPENED:
			animated_sprite.play("opened")
		DoorState.OPENING:
			animated_sprite.play("opening")
		DoorState.CLOSING:
			animated_sprite.play("closing")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and (state == DoorState.CLOSED or state == DoorState.CLOSING):
		state = DoorState.OPENING
		animation_player.play("opening")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and (state == DoorState.OPENED or state == DoorState.OPENING):
		state = DoorState.CLOSING
		animation_player.play("closing")

# TODO directly in the animation
#func _on_animated_sprite_2d_animation_finished() -> void:
	#match state:
		#DoorState.OPENING:
			#state = DoorState.OPENED
		#DoorState.CLOSING:
			#state = DoorState.CLOSED
