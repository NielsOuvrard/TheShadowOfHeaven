extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shot_cooldown: Timer = $ShotCooldown

@export var SPEED = 5000.0
@export var ACCELERATION = 0.2
@onready var player: CharacterBody2D = $"."
const BALL = preload("res://scenes/ball.tscn")

# Weapons
@onready var weapon: Sprite2D = $Weapon
const GUN = preload("res://Assets/Items/Gun.png")
const RAY_GUN = preload("res://Assets/Items/RayGun.png")
const SHOTGUN = preload("res://Assets/Items/Shotgun.png")
const SWORD = preload("res://Assets/Items/Sword.png")

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var weapons = [GUN, RAY_GUN, SHOTGUN, SWORD]
var weapons_unlocked = [SWORD]
var current_weapon = 0

func unlock_weapon(weapon_name: String) -> void:
	match weapon_name:
		"pistol":
			weapons_unlocked.append(GUN)
		"shotgun":
			weapons_unlocked.append(SHOTGUN)
		"raygun":
			weapons_unlocked.append(RAY_GUN)

func change_weapon(value: int) -> void:
	current_weapon = (current_weapon + value) % weapons_unlocked.size()
	weapon.texture = weapons_unlocked[current_weapon]
	

func _ready():
	add_to_group("player")

func _physics_process(delta):
	var direction_input = Vector2.ZERO
	var target_velocity = Vector2.ZERO

	if Input.is_action_pressed('move_right'):
		direction_input.x += 1
	if Input.is_action_pressed('move_left'):
		direction_input.x -= 1
	if Input.is_action_pressed('move_down'):
		direction_input.y += 1
	if Input.is_action_pressed('move_up'):
		direction_input.y -= 1

	if direction_input != null:
		direction_input = direction_input.normalized()

	var direction = direction_input
	if direction.x != 0:
		animated_sprite.flip_h = direction.x > 0
		weapon.flip_h = direction.x > 0
		animated_sprite.play("Move")
	else:
		animated_sprite.play("Idle")
	direction = direction.rotated(rotation)
	
	if direction != Vector2.ZERO:
		target_velocity = delta * direction * SPEED
	else:
		target_velocity = Vector2.ZERO

	# Use lerp to smoothly transition the velocity
	velocity = velocity.lerp(target_velocity, ACCELERATION)


	move_and_slide()

	if Input.is_action_pressed("reload") and shot_cooldown.is_stopped():
		shot_cooldown.start()
		change_weapon(1)

	if Input.is_action_pressed('shoot') and shot_cooldown.is_stopped():
		shot_cooldown.start()
		var window_size = get_viewport().get_visible_rect().size
		var mouse_position = get_viewport().get_mouse_position() - window_size / 2

		mouse_position = mouse_position.normalized() # * amos.size.x ?

		var ball = BALL.instantiate()
		ball.direction_ball = mouse_position
		ball.position = mouse_position + player.position
		get_parent().add_child(ball)
