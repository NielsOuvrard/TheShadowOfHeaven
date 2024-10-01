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

@onready var life_bar: ProgressBar = $LifeBar
@onready var sectario: Sprite2D = $Sectario
@onready var shot_cooldown: Timer = $ShotCooldown

@export var movement_type := Movement.NONE
@export var life := 100
@export var SPEED := 900.0

var direction = Vector2.ZERO
var knockback_velocity = Vector2.ZERO

# for now, we will put a scene for each weapon_sprite's bullet
const PROJECTILE = preload("res://scenes/projectile.tscn")
const ITEM = preload("res://Scenes/item.tscn")

func _ready():
	add_to_group("enemies")

	if movement_type == Movement.HORIZONTAL:
		direction = Vector2.RIGHT
	elif movement_type == Movement.VERTICAL:
		direction = Vector2.UP
	
	shot_cooldown.wait_time = float(Data.rand_range(10, 30)) / 10
	shot_cooldown.start()
	
	life_bar.max_value = life
	life_bar.value = life

func add_knockback(knockback: Vector2):
	knockback_velocity = knockback

func _physics_process(delta):
	velocity = direction * SPEED * delta
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.1)
	move_and_slide()

func update_life(new_life: int):
	life_bar.value = new_life
	life = new_life

func _on_area_2d_body_entered(_body: Node2D) -> void:
	direction = -direction

	if movement_type == Movement.HORIZONTAL:
		sectario.flip_h = direction.x > 0

func _on_shot_cooldown_timeout() -> void:
	var proj = PROJECTILE.instantiate()
	
	# TODO real IA, if enemy detect player
	var player = get_tree().get_first_node_in_group("player")
	proj.direction_proj = (player.global_position - global_position).normalized()  # calculate the direction to the player
	proj.thrower = "enemies"
	proj.target = "player"
	proj.position = position
	proj.type = Data.Projectiles.ENEMIES
	proj.is_shadow = true
	get_parent().add_child(proj)

	shot_cooldown.wait_time = float(Data.rand_range(10, 30)) / 10
	shot_cooldown.start()
