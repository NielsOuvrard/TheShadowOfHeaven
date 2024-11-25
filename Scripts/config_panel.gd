extends CanvasLayer

signal closed

# order of the elements in the menu
@onready var volume_slider: HSlider = $Control/SliderMusic
@onready var main_menu_button: Button = $Control/MainMenuButton
@onready var close_button: Button = $Control/CloseButton
@onready var menu_items := [volume_slider, main_menu_button, close_button]

@export var background_music: AudioStreamPlayer2D

# In Godot, the volume in dB typically ranges from
# -80 dB (silence) to 0 dB (maximum volume)
const VOLUME_MIN = -80

var selected_index := 0
var callbacks = [
	func (): return,
	func (): closed.emit(),
	func ():
		closed.emit()
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
]


func _ready():
	volume_slider.value = (background_music.volume_db + abs(VOLUME_MIN)) / abs(VOLUME_MIN) * 100
	
	# Unable the elements for a moment to avoid unwanted clicks
	await get_tree().create_timer(0.1).timeout
	volume_slider.editable = true
	main_menu_button.disabled = false
	close_button.disabled = false

func change_selected(direction: int) -> void:
	menu_items[selected_index].release_focus()
	if menu_items[selected_index] is HSlider:
		menu_items[selected_index].editable = false

	selected_index = (selected_index + direction) % menu_items.size()

	menu_items[selected_index].grab_focus()
	if menu_items[selected_index] is HSlider:
		menu_items[selected_index].editable = true

func is_next_slider(direction: int) -> bool:
	# I don't want to change the selected index if the next item is a slider
	# Only up or down should change the selected index in this case
	var next_index = (selected_index + direction) % menu_items.size()
	return menu_items[next_index] is HSlider

func _process(_delta):
	if Input.is_action_just_pressed("ui_down"):
		change_selected(1)
	elif Input.is_action_just_pressed("ui_up"):
		# not ideal, if I'm on the last one it should go to the first one
		change_selected(-1)
	elif Input.is_action_just_pressed("interact"):
		callbacks[selected_index].call()

	if menu_items[selected_index] is HSlider:
		if Input.is_action_pressed("ui_left"):
			volume_slider.value -= 1
		elif Input.is_action_pressed("ui_right"):
			volume_slider.value += 1
	else:
		if Input.is_action_just_pressed("ui_left") and not is_next_slider(-1):
			change_selected(-1)
		elif Input.is_action_just_pressed("ui_right") and not is_next_slider(1):
			change_selected(1)
	
func _on_close_button_pressed():
	closed.emit()

func _on_main_menu_button_pressed():
	closed.emit()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_volume_slider_drag_ended(_value_changed: bool) -> void:
	background_music.volume_db = VOLUME_MIN + (volume_slider.value / 100 * abs(VOLUME_MIN))
