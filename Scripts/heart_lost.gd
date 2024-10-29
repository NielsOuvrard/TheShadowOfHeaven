extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

const ROTATION_MAX = PI / 3
const MOVEMENT_X_MAX = 5
const MOVEMENT_Y_MIN = 15
const MOVEMENT_Y_MAX = 45

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var animation = animation_player.get_animation("run")
	if animation:
		var position_track_index = animation.find_track(NodePath("Hearts:position"), Animation.TYPE_VALUE)
		if position_track_index != -1 and animation.track_get_key_count(position_track_index) > 1:
			var random_position = Vector2(
				MOVEMENT_X_MAX - Global.rand_range(0, 2 * MOVEMENT_X_MAX),
				-Global.rand_range(MOVEMENT_Y_MIN, MOVEMENT_Y_MAX))
			animation.track_set_key_value(position_track_index, 1, random_position)

		var rotation_track_index = animation.find_track(NodePath("Hearts:rotation"), Animation.TYPE_VALUE)
		if rotation_track_index != -1 and animation.track_get_key_count(rotation_track_index) > 1:
			var random_rotation = ROTATION_MAX - Global.rand_range(0, 2 * ROTATION_MAX)
			animation.track_set_key_value(rotation_track_index, 1, random_rotation)

	animation_player
	animation_player.play(&"run")
