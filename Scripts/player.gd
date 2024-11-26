## Behavior of the player character.
##
## Author: Sol Rojo[br]Date: 24-09-2024
##

extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_body: CharacterBody2D = $"."
@onready var weapon_sprite: Sprite2D = $Weapon

# * Sounds
@onready var reload_sound: AudioStreamPlayer2D = $Reload
@onready var weapons_sounds := {
	Data.Weapons.SWORD: $SwordSwing,
	Data.Weapons.PISTOL: $GunSoundArcade,
	Data.Weapons.SHOTGUN: $ShotGunSound,
	Data.Weapons.RAYGUN: $LaserSound
}

# * SWORD (Another scene ?)
@onready var sword_attack: Area2D = $SwordAttack
@onready var sword_attack_animation: AnimationPlayer = $SwordAttack/Animation
@onready var sword_collision: CollisionShape2D = $SwordAttack/Collision

@onready var health: Health = $Health
@onready var animation_handler: Node = $AnimationHandler

@onready var reload_cooldown: Timer = $ReloadCooldown
@onready var shoot_cooldown: Timer = $ShotCooldown
@onready var dash_cooldown: Timer = $DashCooldown

@export var SPEED := 16.0 * 7
@export var ACCELERATION := 0.9
@export var current_weapon := Data.Weapons.SWORD
@export var debug := false
@export var push_force = 80.0

const DASH_STRENGTH = 80.0

var look_direction := Vector2.ZERO
var last_look_direction_mouse := Vector2.ZERO
var knockback_velocity := Vector2.ZERO # ? component with this
var is_playing_controller := false

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

	# * Cooldowns
	reload_cooldown.wait_time = Data.WEAPONS[current_weapon].cooldown_reload
	shoot_cooldown.wait_time = Data.WEAPONS[current_weapon].cooldown_shot
	if debug:
		debug_weapons()

func change_radius_sword_collision(value: float):
	sword_collision.shape.radius = value

func add_knockback(knockback: Vector2):
	knockback_velocity = knockback

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

	var local_playing_controller = is_playing_controller
	# * if we are using the controller
	if direction_input != Vector2.ZERO:
		local_playing_controller = true
		look_direction = direction_input.normalized()
		SignalsHandler.player_look_direction.emit(look_direction)

	# * if we are using the mouse
	var window_size = get_viewport().get_visible_rect().size
	var mouse_position = get_viewport().get_mouse_position() - window_size / 2
	if last_look_direction_mouse != mouse_position.normalized():
		look_direction = mouse_position.normalized()
		local_playing_controller = false
		last_look_direction_mouse = mouse_position.normalized()

	if local_playing_controller != is_playing_controller:
		SignalsHandler.player_use_controller.emit(local_playing_controller)
		is_playing_controller = local_playing_controller

func shoot():
	if not reload_cooldown.is_stopped():
		return
	shoot_cooldown.start()
	if current_weapon == Data.Weapons.SWORD:
		sword_attack_animation.play("sword_attack")
		sword_attack.rotation = look_direction.angle() + (3.0 / 4.0 * PI)
		weapons_sounds[current_weapon].play()
		return
	if ammo_current[current_weapon] == 0:
		reload()
		return
	ammo_current[current_weapon] -= 1
	SignalsHandler.player_update_ammo_current.emit(ammo_current[current_weapon])
	weapons_sounds[current_weapon].play()

	var proj = Global.PROJECTILE.instantiate()
	proj.direction_proj = look_direction
	proj.thrower = "player"
	proj.target = "enemies"
	proj.type = Data.WEAPONS[current_weapon].projectile
	proj.weapons_unlocked = weapons_unlocked
	proj.position = position
	get_parent().add_child(proj)


func reload():
	if current_weapon == Data.Weapons.SWORD:
		return
	if ammo_inventory[current_weapon] == 0:
		return
	if ammo_current[current_weapon] == Data.WEAPONS[current_weapon].ammo_max:
		return
	var ammo_max_needed = Data.WEAPONS[current_weapon].ammo_max - ammo_current[current_weapon]
	var ammo_taken = min(ammo_inventory[current_weapon], ammo_max_needed)
	ammo_current[current_weapon] += ammo_taken
	ammo_inventory[current_weapon] -= ammo_taken
	SignalsHandler.player_update_ammo_both.emit(ammo_current[current_weapon], ammo_inventory[current_weapon])
	SignalsHandler.player_reload.emit(current_weapon)

	reload_cooldown.start()
	reload_sound.play()

func change_weapon():
	var next_weapon = (current_weapon + 1) % Data.WEAPONS.size()
	while not weapons_unlocked[next_weapon]:
		next_weapon = (next_weapon + 1) % Data.WEAPONS.size()

	if debug:
		debug_inventory()

	if next_weapon == current_weapon:
		return

	animation_handler.add_animation(Data.Animations.CHANGE_WEAPON)
	var current_ammo = ammo_current[next_weapon] if next_weapon != Data.Weapons.SWORD else 0
	var current_inventory = ammo_inventory[next_weapon] if next_weapon != Data.Weapons.SWORD else 0
	SignalsHandler.player_change_weapon.emit(next_weapon, current_ammo, current_inventory)

	# auto reload
	if current_weapon != Data.Weapons.SWORD and ammo_current[current_weapon] == 0 and ammo_inventory[current_weapon] > 0:
		reload()
	current_weapon = next_weapon as Data.Weapons
	weapon_sprite.texture = load(Data.WEAPONS[current_weapon].texture)

	# * Cooldowns
	reload_cooldown.wait_time = Data.WEAPONS[current_weapon].cooldown_reload
	shoot_cooldown.wait_time = Data.WEAPONS[current_weapon].cooldown_shot

## called by the item itself to add it to the player inventory
func add_to_inventory(item: Data.Items, number: int):
	if item == Data.Items.LIFE:
		health.life = min(health.life + number, health.max_life)
	else:
		ammo_inventory[Data.ITEMS[item].weapon] += number
	animation_handler.add_animation(Data.Animations.PICK_UP)

## used when the player unlock a new weapon
func unlock_weapon(weapon: Data.Weapons):
	weapons_unlocked[weapon] = true

func avoid_collision_with_other_bodies(delta: float):
	# Handle collision with other bodies
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider is CharacterBody2D:  # or CharacterBody3D

			# push the other body
			if collider.has_node_and_resource("Hitbox"):
				var area = collider.get_node("Hitbox")
				var attack = Attack.new(0, global_position, push_force)
				area.damage(attack)

func _physics_process(delta):
	if get_tree().paused:
		animation_handler.actualize_animation()
		return
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

	if direction != Vector2.ZERO:
		animation_handler.add_animation(Data.Animations.MOVE)
	direction = direction.rotated(rotation)

	# * Velocity
	var target_velocity = Vector2.ZERO
	if direction != Vector2.ZERO:
		target_velocity = direction * SPEED
	else:
		target_velocity = Vector2.ZERO
	# Use lerp to smoothly transition the velocity
	velocity = velocity.lerp(target_velocity, ACCELERATION)
	velocity += knockback_velocity

	# velocity in pixels per second,
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.1)

	avoid_collision_with_other_bodies(delta)

	move_and_slide()

	# * Look
	look_player()

	# * Actions
	if shoot_cooldown.is_stopped():
		if Input.is_action_pressed('reload'):
			shoot_cooldown.wait_time = 0.2 # TODO reload cooldown
			shoot_cooldown.start()
			reload()

		if Input.is_action_pressed('change_weapon'):
			shoot_cooldown.wait_time = 0.2  # TODO change weapon cooldown
			shoot_cooldown.start()
			change_weapon()

		if Input.is_action_pressed('shoot'):
			shoot()

		if Input.is_action_just_pressed('dash') and dash_cooldown.is_stopped():
			shoot_cooldown.wait_time = 0.2 # TODO dash cooldown
			animation_handler.add_animation(Data.Animations.DASH)
			position = position.lerp(position + velocity.normalized() * DASH_STRENGTH, 0.5)
			dash_cooldown.start()

	# * Animation
	animation_handler.actualize_animation()

func _on_sword_attack_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		var attack = Attack.new(1, position, 100, weapons_unlocked)
		area.damage(attack)

func _on_health_life_change(value: Variant) -> void:
	if value <= 0:
		animation_handler.add_animation(Data.Animations.DIE)
		get_tree().paused = true
	SignalsHandler.player_life_change.emit(value)

#region debug
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
#endregion


func _on_animated_sprite_2d_animation_finished() -> void:
	if get_tree().paused:
		await get_tree().create_timer(1).timeout
		get_tree().paused = false
		get_tree().change_scene_to_file("res://Scenes/death_screen.tscn")
