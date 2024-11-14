extends Panel

signal closed  # Señal personalizada para indicar que el panel se cerró

@onready var close_button: Button = $CloseButton
@onready var main_menu_button: Button = $MainMenuButton
@onready var volume_slider: HSlider = $VColorRect/VolumeSlider
var background_music: AudioStreamPlayer2D
var selected_index = 0  # Índice para la navegación en el menú

# Lista de elementos de interfaz en orden de navegación
var menu_items = []

func _ready():
	# Configura el valor inicial del control deslizante según el volumen actual
	volume_slider.value = (background_music.volume_db + 80) / 80 * 100
	
	# Desactiva temporalmente el slider para evitar que reciba el clic inicial
	volume_slider.editable = false
	await get_tree().create_timer(0.1).timeout  # Pausa sin retorno
	volume_slider.editable = true

	# Añade los elementos de interfaz a la lista en orden de navegación
	menu_items = [volume_slider, main_menu_button, close_button]
	update_selection()

	# Conecta las señales
	close_button.pressed.connect(_on_close_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	volume_slider.value_changed.connect(_on_volume_slider_changed)

# Actualiza la selección visualmente y enfoca el elemento activo
func update_selection():
	for i in range(menu_items.size()):
		if i == selected_index:
			menu_items[i].grab_focus()  # Enfoca el elemento seleccionado
		else:
			menu_items[i].release_focus()  # Libera el foco de los otros elementos

		# Si es un Slider, habilita su edición solo si está seleccionado
		if menu_items[i] is HSlider:
			menu_items[i].editable = i == selected_index

# Navega hacia el siguiente elemento, pero evita volver al slider si ya estamos en los botones
func select_next():
	if selected_index == 0:  # Si estamos en el Slider, saltamos al primer botón
		selected_index = 1
	else:  # Navegación normal entre botones
		selected_index = min(selected_index + 1, menu_items.size() - 1)
	update_selection()

# Navega hacia el elemento anterior, pero evita volver al slider si estamos en los botones
func select_previous():
	if selected_index > 0:  # Navegación normal entre botones
		selected_index -= 1
	update_selection()

# Ejecuta la acción del elemento seleccionado
func execute_action():
	if menu_items[selected_index] == main_menu_button:
		_on_main_menu_button_pressed()  # Llama directamente a la función del botón de menú principal
	elif menu_items[selected_index] == close_button:
		_on_close_button_pressed()  # Llama directamente a la función del botón de cerrar
	elif menu_items[selected_index] is HSlider:
		# Activa el slider para que se pueda mover con el gamepad
		menu_items[selected_index].grab_focus()

# Detecta las entradas del gamepad para navegar y seleccionar
func _process(delta):
	if Input.is_action_just_pressed("ui_down"):
		select_next()
	elif Input.is_action_just_pressed("ui_up"):
		select_previous()
	elif Input.is_action_just_pressed("interact"):
		execute_action()
	elif Input.is_action_pressed("ui_left"):
		if menu_items[selected_index] is HSlider:
			volume_slider.value -= 1  # Ajusta el valor del slider
		else:
			select_previous()  # Cambia al elemento anterior si no es el slider
	elif Input.is_action_pressed("ui_right"):
		if menu_items[selected_index] is HSlider:
			volume_slider.value += 1  # Ajusta el valor del slider
		else:
			select_next()  # Cambia al siguiente elemento si no es el slider

# Función para cerrar el menú de configuración
func _on_close_button_pressed():
	emit_signal("closed")  # Emite la señal al cerrar el panel
	self.queue_free()  # Elimina el panel de la escena actual

# Función para ajustar el volumen de la música
func _on_volume_slider_changed(value: float):
	background_music.volume_db = -80 + (value / 100 * 80)  # Ajusta el volumen de -80 dB a 0 dB

# Función para regresar al menú principal
func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Title_screen.tscn")  # Cambia a la escena del menú principal
