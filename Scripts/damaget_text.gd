extends Node2D

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var text : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = text
	animation_player.play("text")
