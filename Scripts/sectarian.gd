extends CharacterBody2D

enum Movement {
	NONE,
	HORIZONTAL,
	VERTICAL
}

@onready var sectario: Sprite2D = $Sectario

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
	velocity = direction * SPEED * delta

	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	direction = -direction

	if movement_type == Movement.HORIZONTAL:
		sectario.flip_h = direction.x > 0
