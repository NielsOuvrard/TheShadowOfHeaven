extends Node2D

@onready var room_1: Node2D = $ROOM_1
@onready var rooms = [
	room_1
	# ...
]

var room_index = 0

func _ready() -> void:
	SignalsHandler.enemy_has_die.connect(_enemy_has_die)

func is_enemy_remaning(room_id: int):
	var enemies_founds = 0
	for node in rooms[room_index].get_children():
		if node.is_in_group("enemies"):
			enemies_founds += 1

	# the enemy just killed is still in the group
	if enemies_founds > 1:
		return true
	return false

func open_all_doors(room_id: int):
	for node in rooms[room_id].get_children():
		if node.is_in_group("doors"):
			node.openable = true

# This function is called when an enemy dies
func _enemy_has_die():
	if not is_enemy_remaning(room_index):
		print("All enemies are dead in room", room_index)
		open_all_doors(room_index)
		room_index += 1 if room_index < rooms.size() - 1 else rooms.size() - 1