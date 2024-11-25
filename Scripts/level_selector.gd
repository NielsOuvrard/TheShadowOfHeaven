extends CanvasLayer

@onready var portrait: Sprite2D = $PortraitsSelected
@onready var portraits_locked: Sprite2D = $PortraitsLocked
@onready var letters: Sprite2D = $Letters
@onready var level_text: Sprite2D = $LevelText
@onready var timer: Timer = $Timer

const SCREEN_X_SIZE = 240
const NUMBER_NIVELS = 3
var image_size_x : int

var locked_portraits := []

var selected := Global.level_unlocked:
	set(value):
		print(value)
		selected = value % (1 + Global.level_unlocked)
		if selected < 0:
			selected = Global.level_unlocked

func change_selected_level(value):
	if timer.is_stopped():
		timer.start()
		selected = selected + value
		portrait.frame = selected
		level_text.frame = selected

		portrait.position.x = (SCREEN_X_SIZE / 2) - image_size_x + (image_size_x * selected)
		level_text.position.x = (SCREEN_X_SIZE / 2) - image_size_x + (image_size_x * selected)

func _ready() -> void:
	timer.wait_time = 0.1
	timer.start()
	image_size_x = portrait.texture.get_size().x / NUMBER_NIVELS

	locked_portraits.append(portraits_locked)
	locked_portraits.append(portraits_locked.duplicate())
	locked_portraits[0].frame += 1
	add_child(locked_portraits[1])
	# order:
	# [0] = wrath
	# [1] = betrayal

	for i in range(NUMBER_NIVELS - Global.level_unlocked - 1):
		locked_portraits[i].visible = true
		locked_portraits[i].position.x =\
			(SCREEN_X_SIZE / 2) - image_size_x +\
			(image_size_x * (NUMBER_NIVELS - i - 1))

	portrait.position.x = (SCREEN_X_SIZE / 2) - image_size_x
	level_text.position.x = (SCREEN_X_SIZE / 2) - image_size_x
	portrait.frame = 0
	level_text.frame = 0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('move_right'):
		change_selected_level(1)
	if Input.is_action_just_pressed('move_left'):
		change_selected_level(-1)

	if Input.is_action_just_pressed("shoot"):
		Global.level_selected = selected
		get_tree().change_scene_to_file("res://Scenes/gameplay.tscn")
