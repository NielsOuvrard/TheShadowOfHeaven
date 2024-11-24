extends Node2D

const levels = [
	preload("res://Scenes/greed.tscn"),
	preload("res://Scenes/Betreyal.tscn"),
	preload("res://Scenes/Wrath.tscn")
]

func _ready() -> void:
	var actual_level = levels[Global.level_selected].instantiate()
	add_child(actual_level)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open_config"):
		$CanvasPanel/ConfigPanel.show()
		get_tree().paused = true

func _on_config_panel_closed() -> void:
	$CanvasPanel/ConfigPanel.hide()
	get_tree().paused = false
