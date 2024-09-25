# damage_text.gd
#
# This script defines the behavior of the damage text that appears when a character takes damage.
#
# Author: Sol Rojo
# Date: 25-09-2024
#

extends Node2D

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var text : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = text
	animation_player.play("text")
