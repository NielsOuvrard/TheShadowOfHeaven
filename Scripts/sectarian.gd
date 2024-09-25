# sectarian.gd
#
# This script defines the behavior of the enemies that the player will face.
#
# Author: Sol Rojo
# Date: 24-09-2024
#

extends CharacterBody2D

enum Movement {
	NONE,
	HORIZONTAL,
	VERTICAL
}

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var sectario: Sprite2D = $Sectario

@export var movement_type := Movement.NONE
@export var life := 100
@export var SPEED := 900.0

var direction = Vector2.ZERO


func _ready():
	add_to_group("enemies")

	if movement_type == Movement.HORIZONTAL:
		direction = Vector2.RIGHT
	elif movement_type == Movement.VERTICAL:
		direction = Vector2.UP
	
	progress_bar.max_value = life
	progress_bar.value = life

func _physics_process(delta):
	velocity = direction * SPEED * delta

	move_and_slide()

func _on_area_2d_body_entered(_body: Node2D) -> void:
	direction = -direction

	if movement_type == Movement.HORIZONTAL:
		sectario.flip_h = direction.x > 0

func take_damage(damage: int) -> void:
	life -= damage
	progress_bar.value = life
	if life <= 0:
		queue_free()
	
