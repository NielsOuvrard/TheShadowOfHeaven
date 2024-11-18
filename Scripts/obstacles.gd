extends StaticBody2D

enum OBJECTS {
	STONE,
	BBQ,
	SNAIL,
	GARBAGE,
	SKULL,
	STONE_2
}

@export var user_frame := OBJECTS.SKULL
@onready var obstacles: Sprite2D = $Obstacles

func _ready() -> void:
	obstacles.frame = user_frame
