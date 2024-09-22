extends CharacterBody2D

@onready var ray_horizontal = $RayHorizontal
@onready var ray_vertical = $RayVertical


enum Movement {
	NONE,
	HORIZONTAL,
	VERTICAL
}

@export var movement_type := Movement.NONE
@export var SPEED = 900.0

var direction = Vector2.ZERO


func _ready():
	add_to_group("enemies")

	if movement_type == Movement.HORIZONTAL:
		direction = Vector2.RIGHT
	elif movement_type == Movement.VERTICAL:
		direction = Vector2.UP

func _physics_process(delta):
	if ray_horizontal.is_colliding() or ray_vertical.is_colliding():
		direction = -direction

	velocity = direction * SPEED * delta

	move_and_slide()
