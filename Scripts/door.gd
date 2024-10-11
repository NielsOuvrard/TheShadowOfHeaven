## Behavior of the doors.
## The player can interact with it, or it can be triggered by events.
##
## Author: Sol Rojo[br]Date: 24-09-2024
##

extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

enum DoorState {
	CLOSED,
	OPENED,
	OPENING,
	CLOSING
}
# opend-front / opend-back only
# one way doors
# not openable
# openable with interract ?

var state: DoorState = DoorState.CLOSED

var is_rotation_original := true ## original or reversed
var rotation_original : float ## auto set by the rotation of the door
var rotation_reversed : float ## auto set by the rotation of the door


func _ready() -> void:
	rotation_original = rotation
	rotation_reversed = rotation + PI
	
	match state:
		DoorState.CLOSED:
			animated_sprite.play("closed")
		DoorState.OPENED:
			animated_sprite.play("opened")
		DoorState.OPENING:
			animated_sprite.play("opening")
		DoorState.CLOSING:
			animated_sprite.play("closing")

func open():
	if state == DoorState.CLOSED or state == DoorState.CLOSING:
		state = DoorState.OPENING
		animation_player.play("opening")

func close():
	if state == DoorState.OPENED or state == DoorState.OPENING:
		state = DoorState.CLOSING
		animation_player.play("closing")

func set_state(value: DoorState):
	state = value

func reverse_door():
	if is_rotation_original:
		is_rotation_original = false
		rotation = rotation_reversed
	else:
		is_rotation_original = true
		rotation = rotation_original

func _on_back_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state == DoorState.CLOSED:
		reverse_door()

func _on_back_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and state == DoorState.CLOSED:
		reverse_door()

func _on_front_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		open()

func _on_front_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		close()
