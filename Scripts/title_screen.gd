extends CanvasLayer

@onready var buttons = [
	$ControlPlayboton/Playboton,
	$ControlLevelBoton/Levelboton,
	$ControlConfigBoton/Configboton,
	$ControlExitboton/Exitboton
]

@onready var selected_buttons = [
	$ControlPlayboton/Playboton/PlaybotonS,
	$ControlLevelBoton/Levelboton/LevelbotonS,
	$ControlConfigBoton/Configboton/ConfigbotonS,
	$ControlExitboton/Exitboton/ExitbotonS
]

@onready var timer: Timer = $Timer
@onready var background_music: AudioStreamPlayer2D = $AudioTitle

var current_index = 0
var can_accept_click = true
var start_time = 2.0
var config_panel_open = false

func _ready() -> void:
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	background_music.play()
	await get_tree().create_timer(0.1).timeout
	background_music.seek(start_time)
	update_selection()

# Actualiza la selección de botones visibles
func update_selection() -> void:
	for i in range(selected_buttons.size()):
		selected_buttons[i].visible = (i == current_index)

func show_config_panel():
	if not config_panel_open:
		config_panel_open = true
		var config_panel = load("res://Scenes/ConfigPanel.tscn").instantiate()
		config_panel.background_music = $AudioTitle
		add_child(config_panel)
		# Conectar a la señal "closed" del panel de configuración usando Callable
		config_panel.connect("closed", Callable(self, "_on_config_panel_closed"))

func _on_config_panel_closed():
	config_panel_open = false
	can_accept_click=true
	update_selection()

# Las demás funciones permanecen igual
func select_next():
	if not config_panel_open:
		current_index = (current_index + 1) % selected_buttons.size()
		update_selection()

func select_previous():
	if not config_panel_open:
		current_index = (current_index - 1 + selected_buttons.size()) % selected_buttons.size()
		update_selection()

func execute_action():
	if can_accept_click and not config_panel_open:
		can_accept_click = false
		match current_index:
			0:
				get_tree().change_scene_to_file("res://Scenes/gameplay.tscn")
			1:
				show_black_screen_and_load_selector()
			2:
				show_config_panel()
			3:
				get_tree().quit()
		timer.start(0.5)

func show_black_screen_and_load_selector() -> void:
	var black_screen = load("res://Scenes/black_screen.tscn").instantiate()
	add_child(black_screen)
	timer.start(0.1)
	await timer.timeout
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _process(delta: float) -> void:
	if not config_panel_open:
		if Input.is_action_just_pressed("ui_down"):
			select_next()
		elif Input.is_action_just_pressed("ui_up"):
			select_previous()
		elif Input.is_action_just_pressed("interact"):
			execute_action()

func _input(event):
	if not config_panel_open:
		if event is InputEventMouseMotion:
			for i in range(buttons.size()):
				if buttons[i].get_rect().has_point(buttons[i].to_local(event.position)):
					if current_index != i:
						current_index = i
						update_selection()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			execute_action()
