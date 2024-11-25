extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hearts_parent: Node = $HeartsParent
@onready var hearts: Sprite2D = $HeartsParent/Hearts

@onready var health: Health = $Health
@onready var attack_moment: Timer = $AttackMoment
@onready var attack_cooldown: Timer = $AttackCooldown

@onready var stab_sprites: AnimatedSprite2D = $AnimatedSprite2D2
@onready var stab_collision: CollisionShape2D = $AnimatedSprite2D2/StabDamageZone/CollisionShape2D

const ASRAEL_RAY = preload("res://Scenes/AsraelRay.tscn")
const ASRAEL_SKULLS = preload("res://Scenes/AsraelSkulls.tscn")

const TIME_ONE_FRAME = 1.0 / 12.0 # 12 frames per second
const NMB_PRE_FRAME = 2
const NUMBER_HEARTS = 2

const ASRAEL_FULL_LIFE = 20
const NMB_HEARTS = 2
const HEART_FULL = 0 # according to the frame in the sprite
const HEART_EMPTY = 1

# * Ray attack
const INITIAL_RAYS_NUMBER = 5
const FRAME_RAY_ATTACK = 5
const INITIAL_RAYS_INTERVAL = 0.35
const RAY_CIRCLE_RADIUS = 40
var number_rays := INITIAL_RAYS_NUMBER
var rays_interval := INITIAL_RAYS_INTERVAL
var rays_circle_radius := RAY_CIRCLE_RADIUS

# * Stab attack
const FRAME_STAB_ATTACK = 5
const REPEAT_PRE_STAB = 4
var position_stab_sprit_x: float = -17.0
var position_stab_colis_x: float = -8.0

# * Skull attack
const FRAME_SKULL_ATTACK = 5
const REPEAT_PRE_SKULL = 4
const INITIAL_SKULLS_NUMBER = 5
var number_skulls := INITIAL_SKULLS_NUMBER

enum AsraelPhase {
	PHASE_SKULL,
	PHASE_LASER,
	PHASE_STAB
}

enum AttackType {
	NONE,
	STAB,
	SKULL,
	RAY
}

var current_phase := AsraelPhase.PHASE_SKULL
var current_level := 0

var animations := {
	AsraelPhase.PHASE_SKULL: skull_attack_animation,
	AsraelPhase.PHASE_LASER: ray_attack_animation,
	AsraelPhase.PHASE_STAB: stab_attack_animation
}

# Health ***************************************************************************************************

var hearts_list := []

func life_to_hearts_list(life: int):
	hearts_list.clear()
	for i in range(life):
		hearts_list.append(HEART_FULL)
	for i in range(ASRAEL_FULL_LIFE - life):
		hearts_list.append(HEART_EMPTY)

func update_hearts():
	for i in range(hearts_parent.get_child_count()):
		hearts_parent.remove_child(hearts_parent.get_child(0))

	var hearts_size = (hearts.texture.get_size().x / NMB_HEARTS)
	var inirial_heart_position = -(hearts_size) * (ASRAEL_FULL_LIFE / 2.0) + (hearts_size / 2.0)
	for i in range(ASRAEL_FULL_LIFE):
		var new = hearts.duplicate()
		new.position.x = position.x + (i * hearts_size + inirial_heart_position)
		new.frame = hearts_list[i]
		new.z_index = 2
		hearts_parent.add_child(new)

# Attack ***************************************************************************************************

func skull_attack():
	var circle_rotation = 180.0 / (number_skulls - 1)
	for i in range(number_skulls):
		var skull = ASRAEL_SKULLS.instantiate()
		var radian = circle_rotation * i * (PI / 180.0)
		skull.direction = Vector2(cos(radian), sin(radian))
		skull.position = self.position
		skull.time_to_wait = i * 0.15
		get_parent().add_child(skull)

func ray_attack():
	var player = get_tree().get_first_node_in_group("player")
	var circle_rotation = 180.0 / (number_rays - 1)
	for i in range(number_rays):
		var ray = ASRAEL_RAY.instantiate()
		ray.time_to_wait = i * rays_interval
		var radian = circle_rotation * i * (PI / 180.0)
		ray.position = player.position + Vector2(cos(radian) * 1.2, sin(radian)) * rays_circle_radius
		get_parent().add_child(ray)

func stab_attack():
	var player = get_tree().get_first_node_in_group("player")
	stab_collision.disabled = false
	if player.position.x > position.x:
		stab_sprites.flip_h = true
		stab_sprites.position.x = -position_stab_sprit_x
		stab_collision.position.x = -position_stab_colis_x
	else:
		stab_sprites.flip_h = false
		stab_sprites.position.x = position_stab_sprit_x
		stab_collision.position.x = position_stab_colis_x
	stab_sprites.visible = true
	stab_sprites.play("default")

# Animation ***************************************************************************************************

var current_attack := AttackType.NONE
var animation_queue := []

func skull_attack_animation():
	current_attack = AttackType.SKULL
	animated_sprite.play("skull_pre")
	for i in range(REPEAT_PRE_SKULL - 1):
		animation_queue.append("skull_pre")
	animation_queue.append("skull")
	attack_moment.wait_time = (FRAME_SKULL_ATTACK + REPEAT_PRE_SKULL * NMB_PRE_FRAME) * TIME_ONE_FRAME
	attack_moment.start()

func ray_attack_animation():
	current_attack = AttackType.RAY
	animated_sprite.play("ray")
	attack_moment.wait_time = FRAME_RAY_ATTACK * TIME_ONE_FRAME
	attack_moment.start()

func stab_attack_animation():
	current_attack = AttackType.STAB
	animated_sprite.play("stab_pre")
	for i in range(REPEAT_PRE_STAB - 1):
		animation_queue.append("stab_pre")
	animation_queue.append("stab")
	attack_moment.wait_time = (FRAME_STAB_ATTACK + REPEAT_PRE_STAB * NMB_PRE_FRAME) * TIME_ONE_FRAME
	attack_moment.start()

# Physics ***************************************************************************************************

func _ready() -> void:
	add_to_group(&"enemies")
	stab_sprites.visible = false
	hearts.position.x = -((hearts.texture.get_size().x / NUMBER_HEARTS) * (health.max_life / 2.0))

	life_to_hearts_list(ASRAEL_FULL_LIFE)
	update_hearts()

	attack_cooldown.start()


# Signals ***************************************************************************************************

func _on_animated_sprite_2d_animation_finished() -> void:
	if animation_queue.is_empty():
		animated_sprite.play("idle")
	else:
		animated_sprite.play(animation_queue[0])
		animation_queue.pop_front()


func _on_attack_moment_timeout() -> void:
	match current_attack:
		AttackType.STAB:
			stab_attack()
		AttackType.SKULL:
			skull_attack()
		AttackType.RAY:
			ray_attack()
		_:
			pass
	current_attack = AttackType.NONE


func _on_health_die(unlocked_weapons: Variant) -> void:
	queue_free()


func _on_health_life_change(life: Variant) -> void:
	life_to_hearts_list(life)
	update_hearts()

	if life <= ASRAEL_FULL_LIFE * 0.8 and current_level == 0:
		current_level += 1
		number_skulls *= 2
		print(current_level)
	elif life <= ASRAEL_FULL_LIFE * 0.6 and current_level == 1:
		current_level += 1
		current_phase = AsraelPhase.PHASE_LASER
		print(current_level)
	elif life <= ASRAEL_FULL_LIFE * 0.4 and current_level == 2:
		current_level += 1
		number_rays *= 1.8
		rays_interval /= 2
		rays_circle_radius *= 2
		print(current_level)
	elif life <= ASRAEL_FULL_LIFE * 0.2 and current_level == 3:
		current_level += 1
		current_phase = AsraelPhase.PHASE_STAB
		print(current_level)


func _on_stab_damage_zone_area_entered(area: Area2D) -> void:
	if area is Hitbox and area.owner.is_in_group(&"player"):
		var attack = Attack.new(1, Vector2.ZERO)
		area.damage(attack)


func _on_animated_sprite_2d_2_animation_finished() -> void:
	stab_sprites.visible = false
	stab_collision.disabled = true


func _on_attack_cooldown_timeout() -> void:
	animations[current_phase].call()
	attack_cooldown.start()
