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

const EACH_FRAME = 1.0 / 60.0

var next_process_free := false

func _ready():
	add_to_group("projectiles") # useless for now
	point_light.color = Data.PROJECTILS[type].light_color
	point_light.energy = Data.PROJECTILS[type].light_energy
	sprite.play(Data.PROJECTILS[type].animation)
	collision.scale = Data.PROJECTILS[type].collision_scale
	collision.shape.radius = Data.PROJECTILS[type].collision_radius

	if type == Data.Projectiles.SKULL:
		SignalsHandler.projectile_skull_spawn.emit()

	sprite.flip_h = direction_proj.x < 0
	if direction_proj.x < 0:
		sprite.rotation = direction_proj.angle() + PI
	else:
		sprite.rotation = direction_proj.angle()

	if is_shadow:
		shadow_small.visible = true

	self.collision_layer = LAYER_PLAYER_ATTACK if thrower == "player" else LAYER_ENEMY_ATTACK
	self.collision_mask = 48 + (LAYER_PLAYER if thrower != "player" else LAYER_ENEMY)

	SignalsHandler.asrael_die.connect(now_next_process_free)

func now_next_process_free():
	print("free now")
	next_process_free = true

func _physics_process(delta: float) -> void:
	var velocity = direction_proj.normalized() * Data.PROJECTILS[type].speed * EACH_FRAME
	position += velocity

	if next_process_free:
		emit_and_free()

func emit_and_free():
	if type == Data.Projectiles.SKULL:
		SignalsHandler.projectile_skull_despawn.emit()
		var sound_tmp = Global.SOUND_AND_FREE.instantiate()
		sound_tmp.path_sound = "res://Assets/Sounds/Weapons/DropSkull.mp3"
		get_parent().add_child(sound_tmp)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox and area.owner.is_in_group(target): 
		var attack = Attack.new(Data.PROJECTILS[type].damage, position,\
								Data.PROJECTILS[type].knockback, weapons_unlocked)
		var damage_given = area.damage(attack)
		emit_and_free()
	if area.is_in_group("sword_attack"):
		emit_and_free()


func _on_body_entered(body: Node2D) -> void:
	# collision projectile - walls
	# if it's the player body,ignore it (the area will handle it)
	if not (body.is_in_group("enemies") or body.is_in_group("player")):
		emit_and_free()
