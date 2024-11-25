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

var room_index = 0

func _ready() -> void:
	SignalsHandler.enemy_has_die.connect(_enemy_has_die)
	Global.load_game()

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

# called when a door is opened for example
func _save_game() -> void:
	Global.save_game()


func _on_door_9_opening() -> void:
	Global.save_game()
	get_tree().change_scene_to_file("res://Scenes/level_selector.tscn")
