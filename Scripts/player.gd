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
@onready var shot_cooldown: Timer = $ShotCooldown
@onready var player_body: CharacterBody2D = $"."
@onready var weapon_sprite: Sprite2D = $Weapon
@onready var progress_bar: ProgressBar = $ProgressBar

@export var SPEED = 5000.0
@export var ACCELERATION = 0.2

# for now, we will put a scene for each weapon_sprite's bullet
const BALL = preload("res://scenes/ball.tscn")

class Player:
	var life := 100
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
	var current_weapon := Data.Weapons.SWORD
	var shoot_cooldown # ? a way to put the Timer Cooldown global in the file
	var reload_cooldown
	var progress_bar
	var weapon_sprite
	var parent_node

	func _init(_shoot_cooldown, _reload_cooldown, _progress_bar, _weapon, _parent_node):
		self.shoot_cooldown = _shoot_cooldown
		self.reload_cooldown = _reload_cooldown
		self.progress_bar = _progress_bar
		self.weapon_sprite = _weapon
		self.parent_node = _parent_node

		# * Life Progress Bar
		progress_bar.max_value = life
		progress_bar.value = life

		# * Cooldowns
		reload_cooldown.wait_time = Data.WEAPONS[current_weapon].cooldown_reload
		shoot_cooldown.wait_time = Data.WEAPONS[current_weapon].cooldown_shot
		
	func shoot():
		if current_weapon == Data.Weapons.SWORD:
			return
		if ammo_current[current_weapon] == 0:
			return
		ammo_current[current_weapon] -= 1
		shoot_cooldown.start()
		var window_size = parent_node.get_viewport().get_visible_rect().size
		var mouse_position = parent_node.get_viewport().get_mouse_position() - window_size / 2

		mouse_position = mouse_position.normalized() # * amos.size.x ?

		var ball = BALL.instantiate()
		ball.direction_ball = mouse_position
		ball.thrower = "player"
		ball.target = "enemies"
		ball.type = Data.WEAPONS[current_weapon].projectile
		ball.position = parent_node.position
		parent_node.get_parent().add_child(ball)

	func debug_inventory():
		for weapon in Data.WEAPONS:
			if weapon == Data.Weapons.SWORD:
				continue
			print("weapon ", Data.WEAPONS[weapon].name, " ammo current ", ammo_current[weapon], " ammo inventory ", ammo_inventory[weapon])

	func debug_weapons():
		for weapon in weapons_unlocked:
			weapons_unlocked[weapon] = true
		for weapon in ammo_current:
			ammo_current[weapon] = 500

	func reload():
		if current_weapon == Data.Weapons.SWORD:
			return
		if ammo_inventory[current_weapon] == 0:
			return
		if ammo_current[current_weapon] == Data.WEAPONS[current_weapon].ammo_max:
			return
		# state = State.RELOAD
		# action_cooldown.start()

		# * ammo inventory to current ammo
		ammo_current[current_weapon] = min(ammo_inventory[current_weapon], Data.WEAPONS[Data.Weapons.PISTOL].ammo_max)
		# * ammo inventory minus the current ammo
		ammo_inventory[current_weapon] -= ammo_current[current_weapon]

	func change_weapon():
		var next_weapon = (current_weapon + 1) % Data.WEAPONS.size()
		while not weapons_unlocked[next_weapon]:
			next_weapon = (next_weapon + 1) % Data.WEAPONS.size()

		# debug_inventory()

		if next_weapon == current_weapon:
			return
		current_weapon = next_weapon as Data.Weapons
		weapon_sprite.texture = load(Data.WEAPONS[current_weapon].texture)

		# * Cooldowns
		reload_cooldown.wait_time = Data.WEAPONS[current_weapon].cooldown_reload
		shoot_cooldown.wait_time = Data.WEAPONS[current_weapon].cooldown_shot

	func add_to_inventory(item: Data.Items, number: int):
		if item == Data.Items.LIFE:
			life += number
			progress_bar.value = life
		else:
			ammo_inventory[Data.ITEMS[item].weapon] += number

	func unlock_weapon(weapon: Data.Weapons):
		weapons_unlocked[weapon] = true

	func take_damage(damage: int):
		var damage_received = min(damage, life)
		life -= damage
		progress_bar.value = life
		if life <= 0:
			# parent_node.queue_free() # TODO just game over
			print("Game Over")
		return damage_received

func take_damage(damage: int) -> int:
	return player.take_damage(damage)

var player

func _ready():
	add_to_group("player")
	player = Player.new(shot_cooldown, reload_cooldown, progress_bar, weapon_sprite, self)

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
	if direction.x != 0:
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
	if Input.is_action_pressed("reload") and shot_cooldown.is_stopped():
		shot_cooldown.start()
		player.reload()

	if Input.is_action_pressed("change_weapon") and shot_cooldown.is_stopped():
		shot_cooldown.start()
		player.change_weapon()

	if Input.is_action_pressed('shoot') and shot_cooldown.is_stopped():
		player.shoot()
