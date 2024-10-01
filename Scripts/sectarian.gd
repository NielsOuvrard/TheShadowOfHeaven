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
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var torch: PointLight2D = $PointLight2D

@export var movement_type := Movement.NONE
@export var life := 100
@export var SPEED := 900.0

@export var followed_path : PathFollow2D
@export var offset_followed_path := 0.0
var percent_path := 0

var distance_vision := 100
var fov := 30.0
var able_to_shoot := true

# todo
# enum State {
# 	WANDERING,
# 	ATTACKING
# }

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
	
	if followed_path:
		followed_path.progress_ratio = offset_followed_path
		position = followed_path.position

func add_knockback(knockback: Vector2):
	knockback_velocity = knockback

func _physics_process(delta):
	if followed_path:
		followed_path.progress += SPEED * (1.0 / 60.0) * delta
		direction = (followed_path.position - position).normalized()
		
	sectario.flip_h = direction.x > 0
	velocity = direction * SPEED * delta
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.1)
	move_and_slide()
	ray_cast.target_position = direction * distance_vision
	torch.rotation = direction.angle() + PI
	
	if able_to_shoot:
		tryToShoot()

func update_life(new_life: int):
	life_bar.value = new_life
	life = new_life


func _on_area_2d_body_entered(_body: Node2D) -> void:
	if not followed_path:
		direction = -direction

func shoot(player):
	var proj = PROJECTILE.instantiate()
	proj.direction_proj = (player.global_position - global_position).normalized()  # calculate the direction to the player
	proj.thrower = "enemies"
	proj.target = "player"
	proj.position = position
	proj.type = Data.Projectiles.ENEMIES
	proj.is_shadow = true
	get_parent().add_child(proj)

	shot_cooldown.wait_time = float(Data.rand_range(10, 30)) / 10
	shot_cooldown.start()
	able_to_shoot = false

func tryToShoot():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	if position.distance_to(player.position) < distance_vision:
		#print("angle %10.2f pos %10.2f %10.2f" % [direction.angle_to(player.position - position), (player.position - position).x, (player.position - position).y])
		if abs(direction.angle_to(player.position - position)) < ((fov / 2.0) * PI / 180.0):
			shoot(player)

func _on_shot_cooldown_timeout() -> void:
	able_to_shoot = true
