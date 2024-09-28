# player.gd
#
# This script defines the behavior of the player character.
# The class Player is used to manage the player's actions and states.
#
# Author: Sol Rojo
# Date: 24-09-2024
#

extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var reload_cooldown: Timer = $ReloadCooldown
@onready var shoot_cooldown: Timer = $ShotCooldown
@onready var player_body: CharacterBody2D = $"."
@onready var weapon_sprite: Sprite2D = $Weapon
@onready var life_bar: ProgressBar = $LifeBar

# * SWORD
@onready var sword_attack: Area2D = $SwordAttack
@onready var sword_attack_animation: AnimationPlayer = $SwordAttack/Animation
@onready var sword_collision: CollisionShape2D = $SwordAttack/Collision

@export var SPEED = 5000.0
@export var ACCELERATION = 0.2
@export var life := 100
@export var current_weapon := Data.Weapons.SWORD
@export var debug := false

# TODO components
# - health
# - attack
# - hitbox



# for now, we will put a scene for each weapon_sprite's bullet
const BALL = preload("res://scenes/ball.tscn")
const DAMAGE_TEXT = preload("res://Scenes/damage_text.tscn")

var ammo_inventory := {
	Data.Weapons.PISTOL: 0,
	Data.Weapons.SHOTGUN: 0,
	Data.Weapons.RAYGUN: 0
}
var ammo_current := {
	Data.Weapons.PISTOL: Data.WEAPONS[Data.Weapons.PISTOL].ammo_max,
	Data.Weapons.SHOTGUN: Data.WEAPONS[Data.Weapons.SHOTGUN].ammo_max,
	Data.Weapons.RAYGUN: Data.WEAPONS[Data.Weapons.RAYGUN].ammo_max
}
var weapons_unlocked := {
	Data.Weapons.SWORD: true,
	Data.Weapons.PISTOL: false,
	Data.Weapons.SHOTGUN: false,
	Data.Weapons.RAYGUN: false
}

func _ready():
	add_to_group("player")

	# * Life Progress Bar
	life_bar.max_value = life
	life_bar.value = life

	# * Cooldowns
	reload_cooldown.wait_time = Data.WEAPONS[current_weapon].cooldown_reload
	shoot_cooldown.wait_time = Data.WEAPONS[current_weapon].cooldown_shot
	if debug:
		debug_weapons()

func change_radius_sword_collision(value: float):
	sword_collision.shape.radius = value


func look_player():
	var direction_input = Vector2.ZERO

	if Input.is_action_pressed('look_right'):
		direction_input.x += Input.get_action_strength('look_right')
	if Input.is_action_pressed('look_left'):
		direction_input.x -= Input.get_action_strength('look_left')
	if Input.is_action_pressed('look_down'):
		direction_input.y += Input.get_action_strength('look_down')
	if Input.is_action_pressed('look_up'):
		direction_input.y -= Input.get_action_strength('look_up')

	# * if we are using the controller
	if direction_input != Vector2.ZERO:
		return direction_input.normalized()

	# * if we are using the mouse
	var window_size = get_viewport().get_visible_rect().size
	var mouse_position = get_viewport().get_mouse_position() - window_size / 2
	return mouse_position.normalized()

func shoot():
	if not reload_cooldown.is_stopped():
		return
	shoot_cooldown.start()
	if current_weapon == Data.Weapons.SWORD:
		sword_attack_animation.play("sword_attack")
		sword_attack.rotation = look_player().angle() + (3.0 / 4.0 * PI)
		return
	if ammo_current[current_weapon] == 0:
		reload()
		return
	ammo_current[current_weapon] -= 1

	var ball = BALL.instantiate()
	ball.direction_ball = look_player()
	ball.thrower = "player"
	ball.target = "enemies"
	ball.type = Data.WEAPONS[current_weapon].projectile
	ball.weapons_unlocked = weapons_unlocked
	ball.position = position
	get_parent().add_child(ball)


func reload():
	if current_weapon == Data.Weapons.SWORD:
		return
	if ammo_inventory[current_weapon] == 0:
		return
	if ammo_current[current_weapon] == Data.WEAPONS[current_weapon].ammo_max:
		return
	# state = State.RELOAD
	# action_cooldown.start()
	var ammo_max_needed = Data.WEAPONS[current_weapon].ammo_max - ammo_current[current_weapon]
	var ammo_taken = min(ammo_inventory[current_weapon], ammo_max_needed)
	ammo_current[current_weapon] += ammo_taken
	ammo_inventory[current_weapon] -= ammo_taken
	
	reload_cooldown.start()

func change_weapon():
	var next_weapon = (current_weapon + 1) % Data.WEAPONS.size()
	while not weapons_unlocked[next_weapon]:
		next_weapon = (next_weapon + 1) % Data.WEAPONS.size()

	if debug:
		debug_inventory()

	if next_weapon == current_weapon:
		return
	
	# auto reload
	if current_weapon != Data.Weapons.SWORD and ammo_current[current_weapon] == 0 and ammo_inventory[current_weapon] > 0:
		reload()
	current_weapon = next_weapon as Data.Weapons
	weapon_sprite.texture = load(Data.WEAPONS[current_weapon].texture)

	# * Cooldowns
	reload_cooldown.wait_time = Data.WEAPONS[current_weapon].cooldown_reload
	shoot_cooldown.wait_time = Data.WEAPONS[current_weapon].cooldown_shot

func add_to_inventory(item: Data.Items, number: int):
	if item == Data.Items.LIFE:
		life += number
		life_bar.value = life
	else:
		ammo_inventory[Data.ITEMS[item].weapon] += number

func unlock_weapon(weapon: Data.Weapons):
	weapons_unlocked[weapon] = true

# TODO put this in a component
func damage(attack: Attack) -> int:
	var damage_received = min(attack.damage, life)
	if life <= 0:
		damage_received = 0
	life -= attack.damage
	life_bar.value = life

	if attack.knockback > 0.0:
		velocity = (position - attack.position).normalized() * attack.knockback

	if life <= 0:
		# TODO game over
		print("Game Over")
	return damage_received


func _physics_process(delta):
	# * Direction
	var direction_input = Vector2.ZERO

	if Input.is_action_pressed('move_right'):
		direction_input.x += 1
	if Input.is_action_pressed('move_left'):
		direction_input.x -= 1
	if Input.is_action_pressed('move_down'):
		direction_input.y += 1
	if Input.is_action_pressed('move_up'):
		direction_input.y -= 1

	# TODO looks like repeated code with "direction_input != null" and "target_velocity != Vector2.ZERO"
	# TODO fix it
	if direction_input != null:
		direction_input = direction_input.normalized()

	var direction = direction_input
	if direction != Vector2.ZERO:
		animated_sprite.flip_h = direction.x > 0
		weapon_sprite.flip_h = direction.x > 0
		animated_sprite.play("Move")
	else:
		animated_sprite.play("Idle")
	direction = direction.rotated(rotation)
	
	# * Velocity 
	var target_velocity = Vector2.ZERO
	if direction != Vector2.ZERO:
		target_velocity = delta * direction * SPEED
	else:
		target_velocity = Vector2.ZERO
	# Use lerp to smoothly transition the velocity
	velocity = velocity.lerp(target_velocity, ACCELERATION)
	move_and_slide()

	# * Actions
	if Input.is_action_pressed("reload") and shoot_cooldown.is_stopped():
		shoot_cooldown.start()
		reload()

	if Input.is_action_pressed("change_weapon") and shoot_cooldown.is_stopped():
		shoot_cooldown.start()
		change_weapon()

	if Input.is_action_pressed('shoot') and shoot_cooldown.is_stopped():
		shoot()

func _on_sword_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("damage"):
		var attack = Attack.new(60, position, 100, weapons_unlocked)
		var damage_given = body.damage(attack)
		var damage_text = DAMAGE_TEXT.instantiate()
		damage_text.text = str(damage_given)
		damage_text.position = position
		get_parent().add_child(damage_text)



func debug_inventory():
	for weapon in weapons_unlocked:
		print("weapon ", weapon, " unlocked ", weapons_unlocked[weapon])

	for weapon in Data.WEAPONS:
		if weapon == Data.Weapons.SWORD:
			continue
		print("weapon ", Data.WEAPONS[weapon].name, " ammo current ", ammo_current[weapon], " ammo inventory ", ammo_inventory[weapon])

func debug_weapons():
	for weapon in weapons_unlocked:
		weapons_unlocked[weapon] = true
	for weapon in ammo_current:
		ammo_current[weapon] = Data.WEAPONS[weapon].ammo_max
	for weapon in ammo_inventory:
		ammo_inventory[weapon] = 99
