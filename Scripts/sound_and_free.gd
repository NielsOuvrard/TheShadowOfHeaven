extends Node

@onready var sound: AudioStreamPlayer = $Sound

var path_sound := "res://Assets/Sounds/Weapons/DropSkull.mp3"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sound.stream = load(path_sound)
	sound.play()

func _on_sound_finished() -> void:
	queue_free()
