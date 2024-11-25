extends Node2D

@onready var room_1: Node2D = $ROOMS/ROOM_2
@onready var room_2: Node2D = $ROOMS/ROOM_3
@onready var room_3: Node2D = $ROOMS/ROOM_4
@onready var room_4: Node2D = $ROOMS/ROOM_5

@onready var rooms = [
	room_1,
	room_2,
	room_3,
	room_4
	# ...
]

var level_class = Global.LEVEL_SIDE.new()

func _ready() -> void:
	SignalsHandler.enemy_has_die.connect(_enemy_has_die)
	Global.load_game()
	level_class.rooms = rooms

# This function is called when an enemy dies
func _enemy_has_die():
	level_class.enemy_has_die()
