## Projectile that player and enemies can shoots.
##
## Author: Sol Rojo[br]Date: 24-09-2024
##

extends Node2D

@onready var point_light: PointLight2D = $PointLight2D
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var shadow_small: Sprite2D = $ShadowSmall

var direction_proj : Vector2
var thrower : String
var target : String
var type : Data.Projectiles
var is_shadow := false
var weapons_unlocked := {}

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

	sprite.flip_h = direction_proj.x < 0
	if direction_proj.x < 0:
		sprite.rotation = direction_proj.angle() + PI
	else:
		sprite.rotation = direction_proj.angle()

	if is_shadow:
		shadow_small.visible = true
	
	self.collision_layer = LAYER_PLAYER_ATTACK if thrower == "player" else LAYER_ENEMY_ATTACK
	self.collision_mask = 48 + (LAYER_PLAYER if thrower != "player" else LAYER_ENEMY)

func _process(delta):
	var velocity = direction_proj * Data.PROJECTILS[type].speed * delta
	position += velocity

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox and area.owner.is_in_group(target): 
		var attack = Attack.new(Data.PROJECTILS[type].damage, position,\
								Data.PROJECTILS[type].knockback, weapons_unlocked)
		var damage_given = area.damage(attack)
		queue_free()
	if area.is_in_group("sword_attack"):
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	# collision projectile - walls
	# if it's the player body,ignore it (the area will handle it)
	if not (body.is_in_group("enemies") or body.is_in_group("player")):
		queue_free()
