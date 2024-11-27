extends Node2D
@onready var camera_asrael: Camera2D = $ROOMS/RoomFinal/Asrael/Camera2D
@onready var camera_player: Camera2D = $Player/Camera2D
@onready var player: CharacterBody2D = $Player

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

const LERP = 0.05
var camera_transition := false
var level_class = Global.LEVEL_SIDE.new()

@export var randomStrength: float = 30.0
@export var shakeFade: float = 5.0

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

func _ready() -> void:
	SignalsHandler.enemy_has_die.connect(_enemy_has_die)
	if not player.debug:
		Global.load_game()
	level_class.rooms = rooms
	SignalsHandler.projectile_skull_despawn.connect(_projectile_skull_despawn)
	SignalsHandler.projectile_skull_spawn.connect(_projectile_skull_spawn)

# This function is called when an enemy dies
func _enemy_has_die():
	level_class.enemy_has_die()

func _on_asrael_asrael_die() -> void:
	Global.save_game()
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")

func _process(delta: float) -> void:
	if camera_transition:
		camera_player.zoom = camera_player.zoom.lerp(camera_asrael.zoom, LERP)
		camera_player.global_position = camera_player.global_position.lerp(camera_asrael.global_position, LERP)

		if camera_player.global_position.distance_to(camera_asrael.global_position) < 1:
			camera_transition = false
			camera_player.enabled = false
			camera_asrael.enabled = true
			SignalsHandler.camera_change.emit(camera_asrael.global_position)

	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shakeFade * delta)
		camera_asrael.offset = randomOffset()

func _on_door_14_opening() -> void:
	camera_transition = true

func _on_asrael_asrael_attack(strenth: float) -> void:
	shake_strength = strenth


func _projectile_skull_spawn():
	if shake_strength < 1:
		shake_strength = 5


func _projectile_skull_despawn():
	if shake_strength < 1:
		shake_strength = 1.5
