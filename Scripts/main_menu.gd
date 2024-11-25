## Buttons and actions of the main screen
##
## Author: Sol Rojo[br]Date: 17-10-2024
##

extends CanvasLayer

@onready var background_music: AudioStreamPlayer2D = $AudioTitle
@onready var buttons_sprite: Sprite2D = $Buttons
@onready var timer: Timer = $Timer

const NUMBER_BUTTONS = 4
const SPACE_BETWEEN_EACH = 1.5

var buttons_callbacks = [
	func (): get_tree().change_scene_to_file("res://Scenes/gameplay.tscn"),
	func (): get_tree().change_scene_to_file("res://Scenes/level_selector.tscn"),
	func (): config_panel_open(),
	func (): get_tree().quit()
]
var PART_HEIGHT := 0
var POS_Y_ORIGINAL := 0

var button_selected := 0
var list_buttons := []

func _ready() -> void:
	background_music.play()
	PART_HEIGHT = buttons_sprite.texture.get_height() / NUMBER_BUTTONS
	POS_Y_ORIGINAL = buttons_sprite.position.y

	list_buttons.append(buttons_sprite)
	for i in range(1, NUMBER_BUTTONS):
		var duped = buttons_sprite.duplicate()
		duped.frame_coords.y = i
		duped.position.y += i * PART_HEIGHT * SPACE_BETWEEN_EACH * buttons_sprite.scale.y
		var selected = duped.get_child(0)
		selected.visible = false
		selected.frame_coords.y = i
		add_child(duped)
		list_buttons.append(duped)

func change_selected(value: int) -> void:
	var new_button_selected = value % NUMBER_BUTTONS
	if new_button_selected < 0: # Godot doesn't have a modulo that works with negative numbers
		new_button_selected = NUMBER_BUTTONS - 1

	if new_button_selected == button_selected:
		return
	list_buttons[button_selected].get_child(0).visible = false
	button_selected = new_button_selected
	list_buttons[button_selected].get_child(0).visible = true


func config_panel_open():
	get_tree().paused = true
	$ConfigPanel.show()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		change_selected(button_selected + 1)
	elif Input.is_action_just_pressed("ui_up"):
		change_selected(button_selected - 1)
	elif Input.is_action_just_pressed("interact"):
		buttons_callbacks[button_selected].call()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		for i in NUMBER_BUTTONS:
			if list_buttons[i].get_rect().has_point(list_buttons[i].to_local(event.position)):
				change_selected(i)
				break
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		buttons_callbacks[button_selected].call()

func _on_config_panel_closed() -> void:
	$ConfigPanel.hide()
	get_tree().paused = false
