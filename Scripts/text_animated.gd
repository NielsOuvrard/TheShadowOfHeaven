## Behavior of the standard animated text
##
## Author: Sol Rojo[br]Date: 25-09-2024
##

extends Node2D

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var text : String

func _ready() -> void:
	label.text = text
	animation_player.play("text")
