extends Node2D

@onready var room_2: Node2D = $ROOM_2
@onready var room_3: Node2D = $ROOM_3
@onready var room_4: Node2D = $ROOM_4
@onready var room_5: Node2D = $ROOM_5

@onready var rooms = [
	# room 0 and 1 does not have enemies
	room_2,
	room_3,
	room_4,
	room_5
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


func _on_door_10_opening() -> void:
	Global.level_unlocked = Data.Level.WRATH if Global.level_unlocked == Data.Level.BETRAYAL else Global.level_unlocked
	Global.save_game()
	get_tree().change_scene_to_file("res://Scenes/level_selector.tscn")
