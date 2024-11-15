extends CanvasLayer

const SPLASH_SCREEN_DURATION = 2.0

func _ready():
	$Cooldown.wait_time = SPLASH_SCREEN_DURATION
	$Cooldown.start()

func _on_cooldown_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
