# ball.gd
#
# This script defines the behavior of the ball that the player shoots.
#
# Author: Sol Rojo
# Date: 24-09-2024
#

extends Node2D
@onready var point_light: PointLight2D = $PointLight2D
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var shadow_small: Sprite2D = $ShadowSmall
@onready var hitbox: Hitbox = $Hitbox

var direction_ball : Vector2
var thrower : String
var target : String
var type : Data.Projectiles
var is_shadow := false
var weapons_unlocked := {}

const DAMAGE_TEXT = preload("res://Scenes/damage_text.tscn")

const LAYER_PLAYER = 1
const LAYER_PLAYER_ATTACK = 2
const LAYER_ENEMY = 4
const LAYER_ENEMY_ATTACK = 8


func _ready():
	add_to_group("projectiles") # useless for now
	point_light.color = Data.PROJECTILS[type].light_color
	point_light.energy = Data.PROJECTILS[type].light_energy
	sprite.play(Data.PROJECTILS[type].animation)
	collision.scale = Data.PROJECTILS[type].collision_scale
	collision.shape.radius = Data.PROJECTILS[type].collision_radius

	sprite.flip_h = direction_ball.x < 0
	if direction_ball.x < 0:
		sprite.rotation = direction_ball.angle() + PI
	else:
		sprite.rotation = direction_ball.angle()

	if is_shadow:
		shadow_small.visible = true
	
	hitbox.collision_layer = LAYER_PLAYER_ATTACK if thrower == "player" else LAYER_ENEMY_ATTACK
	hitbox.collision_mask = 48 + (LAYER_PLAYER if thrower != "player" else LAYER_ENEMY)

func _process(delta):
	var velocity = direction_ball * Data.PROJECTILS[type].speed * delta
	position += velocity

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is Hitbox and area.get_parent().is_in_group(target): 
		var attack = Attack.new(Data.PROJECTILS[type].damage, position, Data.PROJECTILS[type].knockback, weapons_unlocked)
		var damage_given = area.damage(attack)
		var damage_text = DAMAGE_TEXT.instantiate()
		damage_text.text = str(damage_given)
		damage_text.position = position
		get_parent().add_child(damage_text)
		queue_free()
	if area.is_in_group("sword_attack"):
		queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	# if it's the player body, don't care the area will handle it
	# maybe find a better way to do it
	if not body.has_method("shoot"):
		queue_free()
