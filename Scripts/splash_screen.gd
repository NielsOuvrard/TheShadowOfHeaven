extends CanvasLayer

# Tiempo en segundos que durará la splash screen
var splash_duration = 2.0

func _ready():
	# Configura el temporizador
	$Timer.wait_time = splash_duration
	$Timer.start()
	# Conecta la señal de timeout del Timer al método _on_Timer_timeout
	$Timer.connect("timeout", Callable(self, "_on_Timer_timeout"))

func _on_Timer_timeout():
	# Cambia a la siguiente escena
	get_tree().change_scene_to_file("res://Scenes/Title_screen.tscn")
