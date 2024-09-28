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
var knockback_velocity = Vector2.ZERO

# for now, we will put a scene for each weapon_sprite's bullet
const BALL = preload("res://scenes/ball.tscn")
const ITEM = preload("res://Scenes/item.tscn")

func _ready():
	add_to_group("enemies")

	if movement_type == Movement.HORIZONTAL:
		direction = Vector2.RIGHT
	elif movement_type == Movement.VERTICAL:
		direction = Vector2.UP
	
	shot_cooldown.wait_time = float(Data.rand_range(10, 30)) / 10
	shot_cooldown.start()
	
	progress_bar.max_value = life
	progress_bar.value = life

func _physics_process(delta):
	velocity = direction * SPEED * delta
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.1)
	move_and_slide()

func damage(attack: Attack) -> int:
	var damage_received = min(attack.damage, life)
	life -= attack.damage
	progress_bar.value = life

	if attack.knockback > 0.0:
		knockback_velocity = (position - attack.position).normalized() * attack.knockback

	if life <= 0:
		var item = ITEM.instantiate()
		var items_dropabale := []
		for weapon in attack.unlocked_weapons:
			if weapon != Data.Weapons.SWORD and attack.unlocked_weapons[weapon] == true:
				items_dropabale.append(Data.WEAPONS[weapon].ammo)
		items_dropabale.append(Data.Items.LIFE)
		item.type = items_dropabale[randi() % len(items_dropabale)]
		item.position = position
		get_parent().add_child(item)
		queue_free()
	return damage_received


func _on_area_2d_body_entered(_body: Node2D) -> void:
	direction = -direction

	if movement_type == Movement.HORIZONTAL:
		sectario.flip_h = direction.x > 0

func _on_shot_cooldown_timeout() -> void:
	var ball = BALL.instantiate()
	
	# TODO real IA, if enemy detect player
	var player = get_tree().get_nodes_in_group("player")[0]  # get the player node
	ball.direction_ball = (player.global_position - global_position).normalized()  # calculate the direction to the player
	ball.thrower = "enemies"
	ball.target = "player"
	ball.position = position
	ball.type = Data.Projectiles.ENEMIES
	ball.is_shadow = true
	get_parent().add_child(ball)

	shot_cooldown.wait_time = float(Data.rand_range(10, 30)) / 10
	shot_cooldown.start()
