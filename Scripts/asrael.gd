extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hearts_parent: Node = $HeartsParent
@onready var hearts: Sprite2D = $Hearts
@onready var die_light: PointLight2D = $PointLight2D

@onready var health: Health = $Health
@onready var attack_moment: Timer = $AttackMoment
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var shield_cooldown: Timer = $ShieldCooldown
@onready var die_cooldown: Timer = $DieCooldown

@onready var stab_sprites: AnimatedSprite2D = $AnimatedSprite2D2
@onready var stab_collision: CollisionShape2D = $AnimatedSprite2D2/StabDamageZone/CollisionShape2D
@onready var shield: Sprite2D = $Shield
@onready var shield_collison: CollisionShape2D = $Hitbox/ShieldCollison

signal asrael_attack(strenth)
signal asrael_die_for_good

const ASRAEL_RAY = preload("res://Scenes/AsraelRay.tscn")
const ASRAEL_SKULLS = preload("res://Scenes/AsraelSkulls.tscn")

const ATTACK_COOLDOWN = 3.5
const TIME_ONE_FRAME = 1.0 / 12.0 # 12 frames per second
const NMB_PRE_FRAME = 2
const NUMBER_HEARTS = 2

const ASRAEL_FULL_LIFE = 40
const NMB_HEARTS = 2
const HEART_FULL = 0 # according to the frame in the sprite
const HEART_EMPTY = 1

const THRESHOLDS_PHASES_ATTACK = [
	{
		"threshold": 0.8,
		"level": 0,
	},
	{
		"threshold": 0.6,
		"level": 1,
		"new_phase": AsraelPhase.PHASE_RAYS
	},
	{
		"threshold": 0.4,
		"level": 2
	},
	{
		"threshold": 0.2,
		"level": 3
	}
]

# * Ray attack
const INITIAL_RAYS_NUMBER = 5
const FRAME_RAY_ATTACK = 5
const INITIAL_RAYS_INTERVAL = 0.35
const RAY_CIRCLE_RADIUS = 40
const SPREAD_RAYS_X = 1.2
var number_rays := INITIAL_RAYS_NUMBER
var rays_interval := INITIAL_RAYS_INTERVAL
var rays_circle_radius := RAY_CIRCLE_RADIUS
var spread_rays_x := SPREAD_RAYS_X

# * Stab attack
const FRAME_STAB_ATTACK = 5
const REPEAT_PRE_STAB = 4
var position_stab_sprit_x: float = -17.0
var position_stab_colis_x: float = -8.0

# * Skull attack
const FRAME_SKULL_ATTACK = 5
const REPEAT_PRE_SKULL = 4
const INITIAL_SKULLS_NUMBER = 5
const TIME_BETWEEN_SKULLS = 0.15
const TIME_BETWEEN_WAVE = 0.5
const MAX_SKULLS_DOUBLE_WAVE = INITIAL_SKULLS_NUMBER * 2

var number_skulls := INITIAL_SKULLS_NUMBER

# * Shield
const TIME_SHIELD_ON = 5.0
const TIME_SHIELD_OFF = 3.0
const TIME_SHIELD_BLINK = 2.0
const SHIELD_RADIUS = 41
var clockwise := false
var step_rotation_shield := 0
var step_blink_shield := 0
var about_to_unshield := false

enum AsraelPhase {
	PHASE_SKULL,
	PHASE_RAYS,
	PHASE_STAB
}

enum AttackType {
	NONE,
	STAB,
	SKULL,
	RAY
}

var player
var current_phase := AsraelPhase.PHASE_SKULL
var current_level := 0
var is_angry := false
var next_process_get_angry = false # because Godot wtf collision does not works otherwise

var animations := {
	AsraelPhase.PHASE_SKULL: skull_attack_animation,
	AsraelPhase.PHASE_RAYS: ray_attack_animation,
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
	hearts.visible = true
	var hearts_size = (hearts.texture.get_size().x / NMB_HEARTS)
	var inirial_heart_position = -(hearts_size) * (ASRAEL_FULL_LIFE / 2.0) + (hearts_size / 2.0)
	for i in range(ASRAEL_FULL_LIFE):
		var new = hearts.duplicate()
		new.frame = hearts_list[i]
		new.z_index = 2
		new.position.x += i * hearts_size
		hearts_parent.add_child(new)
	hearts.visible = false

# Attack ***************************************************************************************************

var attack_moments = {
	AttackType.STAB: stab_attack,
	AttackType.SKULL: skull_attack,
	AttackType.RAY: ray_attack
}

func new_skull(circle_rotation, i, offset = 0):
	var skull = ASRAEL_SKULLS.instantiate()
	var radian = (circle_rotation * i + offset) * (PI / 180.0)
	skull.direction = Vector2(cos(radian), sin(radian))
	skull.position = self.position
	return skull

func skull_attack():
	var circle_rotation = 180.0 / (number_skulls - 1)
	for i in range(number_skulls):
		var skull = new_skull(circle_rotation, i)
		if clockwise:
			skull.time_to_wait = i * TIME_BETWEEN_SKULLS
		else:
			skull.time_to_wait = (number_skulls - i - 1) * TIME_BETWEEN_SKULLS
		get_parent().add_child(skull)
	clockwise = not clockwise
	asrael_attack.emit(5)

func skull_duble_wave():
	var local_number_skulls = min(number_skulls, MAX_SKULLS_DOUBLE_WAVE)
	var circle_rotation = 180.0 / (local_number_skulls - 1)

	# first wave
	for i in range(local_number_skulls):
		var skull = new_skull(circle_rotation, i)
		skull.time_to_wait = 0
		get_parent().add_child(skull)
	asrael_attack.emit(15)

	if current_level < 2:
		return

	# second wave
	for i in range(local_number_skulls - 1):
		var skull = new_skull(circle_rotation, i, circle_rotation / 2)
		skull.time_to_wait = TIME_BETWEEN_WAVE
		get_parent().add_child(skull)

	if current_level < 3:
		return

	# third wave
	for i in range(local_number_skulls):
		var skull = new_skull(circle_rotation, i)
		skull.time_to_wait = TIME_BETWEEN_WAVE * 2
		get_parent().add_child(skull)


func ray_attack():
	var circle_rotation = 180.0 / (number_rays - 1)
	for i in range(number_rays):
		var ray = ASRAEL_RAY.instantiate()
		ray.time_to_wait = i * rays_interval
		var radian = circle_rotation * i * (PI / 180.0)
		ray.position = player.position + Vector2(cos(radian) * spread_rays_x, sin(radian)) * rays_circle_radius
		get_parent().add_child(ray)
	asrael_attack.emit()

	# also skull attack
	skull_attack()

func stab_attack():
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

func _wake_up():
	print("_wake_up")
	player = get_tree().get_first_node_in_group("player")
	stab_sprites.visible = false

	life_to_hearts_list(ASRAEL_FULL_LIFE)
	update_hearts()

	# just set to begin by a shield
	shield.visible = false
	about_to_unshield = true
	shield_cooldown.wait_time = 0.0
	shield_cooldown.start()

	attack_cooldown.start()

func _ready() -> void:
	add_to_group(&"enemies")
	add_to_group(&"boss")
	hearts.position.y = -70 # fuck it
	hearts.position.x = -((hearts.texture.get_size().x / NUMBER_HEARTS) * (health.max_life / 2.0))

	SignalsHandler.asrael_wake_up.connect(_wake_up)


# Signals ***************************************************************************************************

func _on_animated_sprite_2d_animation_finished() -> void:
	if animation_queue.is_empty():
		animated_sprite.play("idle")
	else:
		animated_sprite.play(animation_queue[0])
		animation_queue.pop_front()


func _on_attack_moment_timeout() -> void:
	attack_moments[current_attack].call()
	current_attack = AttackType.NONE


func _on_health_die(unlocked_weapons: Variant) -> void:
	SignalsHandler.asrael_die.emit()
	var sound_tmp = Global.SOUND_AND_FREE.instantiate()
	sound_tmp.path_sound = "res://Assets/Sounds/Enemigos/AsraelDie.mp3"
	get_parent().add_child(sound_tmp)
	attack_cooldown.stop()
	shield_cooldown.stop()
	animated_sprite.modulate = Color(0, 0, 0, 1)
	next_process_get_angry = true # to make shield disappear
	shield_collison.disabled = false
	die_cooldown.start()
	die_light.enabled = true
	die_light.energy = 0

func _on_die_cooldown_timeout() -> void:
	asrael_die_for_good.emit()
	queue_free()

func begin_angry_mode():
	is_angry = true
	shield.visible = true
	shield_collison.disabled = false
	shield.modulate.a = 1
	health.is_invicible = true
	shield_cooldown.wait_time = TIME_SHIELD_ON
	shield_cooldown.start()
	about_to_unshield = false

func _on_health_life_change(_old, life: Variant) -> void:
	life_to_hearts_list(life)
	update_hearts()

	for phase in THRESHOLDS_PHASES_ATTACK:
		if life <= ASRAEL_FULL_LIFE * phase.threshold and current_level == phase.level:
			next_process_get_angry = true
			if "new_phase" in phase:
				current_phase = phase.new_phase
			match current_level:
				0:
					number_skulls *= 2
				1: # rays
					number_skulls *= 1.5
				2:
					number_skulls = INITIAL_SKULLS_NUMBER * 2.5
					number_rays *= 1.4
					rays_interval /= 1.5
					spread_rays_x *= 1.8
				3:
					number_skulls *= 1.5
					number_rays *= 1.4
					rays_interval /= 1.5
					spread_rays_x *= 1.8
					rays_circle_radius *= 0.7
			print("current_level", current_level)
			current_level += 1


func _on_stab_damage_zone_area_entered(area: Area2D) -> void:
	if area is Hitbox and area.owner.is_in_group(&"player"):
		var attack = Attack.new(1, Vector2.ZERO)
		area.damage(attack)


func _on_animated_sprite_2d_2_animation_finished() -> void:
	stab_sprites.visible = false
	stab_collision.disabled = true


func _on_attack_cooldown_timeout() -> void:
	attack_cooldown.wait_time = ATTACK_COOLDOWN
	attack_cooldown.start()
	if is_angry:
		skull_duble_wave()
		is_angry = false
		return
	if player.position.distance_to(position) < 75.0:
		attack_cooldown.wait_time = 2.0
		attack_cooldown.start()

		stab_attack_animation()
	else:
		animations[current_phase].call()

# Shield event ***************************************************************************************************

func _process(delta: float) -> void:
	if die_light.enabled:
		die_light.energy += 0.02
	if next_process_get_angry and health.life == 0:
		shield.visible = false
		return
	if next_process_get_angry:
		next_process_get_angry = false
		begin_angry_mode()
	if health.is_invicible:
		step_rotation_shield += 1
		shield.rotation = sin(step_rotation_shield * 0.015)
		var scale = 1.0 + cos(step_rotation_shield * 0.025) * 0.1
		shield.scale = Vector2(scale, scale)
		shield_collison.shape.radius = SHIELD_RADIUS * scale

		if about_to_unshield:
			step_blink_shield += 1
			shield.modulate.a = sign(sin(step_blink_shield * 0.1))

func _on_shield_cooldown_timeout() -> void:
	if not about_to_unshield:
		shield_cooldown.wait_time = TIME_SHIELD_BLINK
		shield_cooldown.start()
		about_to_unshield = true
		step_blink_shield = 0
		return

	shield.visible = not shield.visible
	shield_collison.disabled = not shield.visible
	shield.modulate.a = 1
	health.is_invicible = not health.is_invicible
	about_to_unshield = false

	shield_cooldown.wait_time = TIME_SHIELD_ON if health.is_invicible else TIME_SHIELD_OFF
	shield_cooldown.start()
