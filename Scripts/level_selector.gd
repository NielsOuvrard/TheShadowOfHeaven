extends CanvasLayer

@onready var portrait: Sprite2D = $PortraitsSelected
@onready var letters: Sprite2D = $Letters
@onready var timer: Timer = $Timer

const SCREEN_X_SIZE = 240
const NUMBER_NIVELS = 3

var selected = 0:
	set(value):
		selected = value % NUMBER_NIVELS
		if selected < 0:
			selected = NUMBER_NIVELS - 1

func change_selected_level(value):
	if timer.is_stopped():
		timer.start()
		selected = selected + value
		portrait.frame = selected

		var image_size_x = portrait.texture.get_size().x / NUMBER_NIVELS
		portrait.position.x = (SCREEN_X_SIZE / 2) - image_size_x + (image_size_x * selected)

func _ready() -> void:
	timer.wait_time = 0.1
	timer.start()

func _process(delta: float) -> void:
	if Input.is_action_pressed('move_right'):
		change_selected_level(1)
	if Input.is_action_pressed('move_left'):
		change_selected_level(-1)
	
	if Input.is_action_pressed("shoot"):
		get_tree().change_scene_to_file("res://Scenes/gameplay.tscn")
