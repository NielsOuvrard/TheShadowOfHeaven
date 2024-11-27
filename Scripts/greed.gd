extends Node2D

@onready var room_2: Node2D = $ROOM_2
@onready var room_3: Node2D = $ROOM_3
@onready var room_4: Node2D = $ROOM_4

@onready var rooms = [
	# room 0 and 1 does not have enemies
	room_2,
	room_3,
	room_4
]

var level_class = Global.LEVEL_SIDE.new()

func _ready() -> void:
	SignalsHandler.enemy_has_die.connect(_enemy_has_die)
	Global.load_game()
	level_class.rooms = rooms

	if Global.easy_mode:
		level_class.kill_half_enemies()

# This function is called when an enemy dies
func _enemy_has_die():
	level_class.enemy_has_die()

# called when a door is opened for example
func _save_game() -> void:
	Global.save_game()

func _on_door_9_opening() -> void:
	Global.level_unlocked = Data.Level.BETRAYAL if Global.level_unlocked == Data.Level.GREED else Global.level_unlocked
	Global.save_game()
	get_tree().change_scene_to_file("res://Scenes/level_selector.tscn")
