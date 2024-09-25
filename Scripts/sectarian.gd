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
@onready var shot_cooldown: Timer = $ShotCooldown

@export var movement_type := Movement.NONE
@export var life := 100
@export var SPEED := 900.0

var direction = Vector2.ZERO

# for now, we will put a scene for each weapon_sprite's bullet
const BALL = preload("res://scenes/ball.tscn")

func _ready():
	add_to_group("enemies")

	if movement_type == Movement.HORIZONTAL:
		direction = Vector2.RIGHT
	elif movement_type == Movement.VERTICAL:
		direction = Vector2.UP
	
	shot_cooldown.start()
	
	progress_bar.max_value = life
	progress_bar.value = life

func _physics_process(delta):
	velocity = direction * SPEED * delta

	move_and_slide()

func take_damage(damage: int) -> void:
	life -= damage
	progress_bar.value = life
	if life <= 0:
		queue_free()


func _on_area_2d_body_entered(_body: Node2D) -> void:
	direction = -direction

	if movement_type == Movement.HORIZONTAL:
		sectario.flip_h = direction.x > 0

func _on_shot_cooldown_timeout() -> void:
	var ball = BALL.instantiate()
	var player = get_tree().get_nodes_in_group("player")[0]  # get the player node
	ball.direction_ball = (player.global_position - global_position).normalized()  # calculate the direction to the player
	ball.position = position
	ball.damage = 5
	ball.target = "player"
	get_parent().add_child(ball)
	shot_cooldown.start()
