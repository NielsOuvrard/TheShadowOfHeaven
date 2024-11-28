extends CanvasLayer


func _input(event):
	if event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://Scenes/level_selector.tscn")
	elif event is InputEventJoypadButton and event.pressed:
		get_tree().change_scene_to_file("res://Scenes/level_selector.tscn")
