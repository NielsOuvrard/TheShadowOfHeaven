# door.gd
#
# This script defines the behavior of the doors.
# The player can interact with it, or it can be triggered by it's own.
#
# Author: Sol Rojo
# Date: 24-09-2024
#

extends CharacterBody2D

@onready var door: CharacterBody2D = $"."
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

enum DoorState {
	CLOSED,
	OPENED,
	OPENING,
	CLOSING
}
# opend-front / opend-back
# one way doors
# not openable
# openable with interract ?

var state: DoorState = DoorState.CLOSED

var is_rotation_normal := true
var rotation_normal : float
var rotation_reversed : float


func _ready() -> void:
	rotation_normal = rotation
	rotation_reversed = rotation + PI
	print("rotation_normal: ", rotation_normal, " rotation_reversed: ", rotation_reversed)
	
	match state:
		DoorState.CLOSED:
			animated_sprite.play("closed")
		DoorState.OPENED:
			animated_sprite.play("opened")
		DoorState.OPENING:
			animated_sprite.play("opening")
		DoorState.CLOSING:
			animated_sprite.play("closing")

func open(body: Node2D):
	if state == DoorState.CLOSED or state == DoorState.CLOSING:
		state = DoorState.OPENING
		animation_player.play("opening")

func close(body: Node2D):
	if state == DoorState.OPENED or state == DoorState.OPENING:
		state = DoorState.CLOSING
		animation_player.play("closing")

func set_state(value: DoorState):
	state = value

func reverse_door():
	if is_rotation_normal:
		is_rotation_normal = false
		rotation = rotation_reversed
	else:
		is_rotation_normal = true
		rotation = rotation_normal

func _on_back_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state == DoorState.CLOSED:
		reverse_door()

func _on_back_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and state == DoorState.CLOSED:
		reverse_door()

func _on_front_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		open(body)

func _on_front_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		close(body)
