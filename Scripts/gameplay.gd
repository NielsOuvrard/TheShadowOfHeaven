extends Node2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open_config"):
		$CanvasPanel/ConfigPanel.show()
		get_tree().paused = true

func _on_config_panel_closed() -> void:
	$CanvasPanel/ConfigPanel.hide()
	get_tree().paused = false
