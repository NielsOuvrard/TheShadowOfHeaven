## Buttons and actions of the main screen
##
## Author: Sol Rojo[br]Date: 17-10-2024
##

extends CanvasLayer

@onready var background_music: AudioStreamPlayer2D = $AudioTitle
@onready var button_selected_sprite: Sprite2D = $Buttons/ButtonSelected
@onready var buttons_sprite: Sprite2D = $Buttons
@onready var timer: Timer = $Timer

const NUMBER_BUTTONS = 5

var buttons_callbacks = [
	func (): get_tree().change_scene_to_file("res://Scenes/gameplay.tscn"),
	func (): get_tree().change_scene_to_file("res://Scenes/main_menu.tscn"),
	func (): config_panel_open(),
	func (): get_tree().quit(),
	func (): return # TODO remove the 5th button on the picture
]
var PART_HEIGHT := 0
var pos_y_original := 0
var button_selected := 0

func _ready() -> void:
	background_music.play()
	PART_HEIGHT = buttons_sprite.texture.get_height() / NUMBER_BUTTONS
	pos_y_original = button_selected_sprite.position.y

func change_selected(direction: int) -> void:
	button_selected = (button_selected + direction) % NUMBER_BUTTONS
	if button_selected < 0: # Godot doesn't have a modulo that works with negative numbers
		button_selected += NUMBER_BUTTONS
	button_selected_sprite.frame = button_selected * 2 + 1
	button_selected_sprite.position.y = pos_y_original + button_selected * PART_HEIGHT

func config_panel_open():
	get_tree().paused = true
	$ConfigPanel.show()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		change_selected(1)
	elif Input.is_action_just_pressed("ui_up"):
		change_selected(-1)
	elif Input.is_action_just_pressed("interact"):
		buttons_callbacks[button_selected].call()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if buttons_sprite.get_rect().has_point(buttons_sprite.to_local(event.position)):
			var local_pos = buttons_sprite.to_local(event.position)
			var part = int(local_pos.y / PART_HEIGHT)
			button_selected = part
			button_selected_sprite.position.y = pos_y_original + part * PART_HEIGHT
			# 2 frames per height, +1 because right frame is the selected one
			button_selected_sprite.frame = part * 2 + 1
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		buttons_callbacks[button_selected].call()

func _on_config_panel_closed() -> void:
	$ConfigPanel.hide()
	get_tree().paused = false
