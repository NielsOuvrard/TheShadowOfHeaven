## Behavior of sectarian enemies.
##
## Author: Sol Rojo[br]Date: 24-09-2024
##

extends CharacterBody2D

# TODO and if diagonal ? change this to a directions vector
enum Movement {
	NONE,
	HORIZONTAL,
	VERTICAL
}

@onready var mark_sprite: Sprite2D = $Mark
@onready var shot_cooldown: Timer = $ShotCooldown
@onready var research_cool_down: Timer = $ResearchCoolDown

@export var movement_type := Movement.NONE
@export var SPEED := 900.0 ## speed movement
@export var SPEED_ROTATE := 0.03

@export var followed_path : PathFollow2D
@export var offset_followed_path := 0.0
var percent_path := 0

var distance_vision := 100
var fov := 30.0
var able_to_shoot := true

enum State {
	WALKING,
	ATTACKING,
	SEARCHING
}
var state := State.WALKING

var direction = Vector2.ZERO
var sect_look_at = Vector2.RIGHT
var knockback_velocity = Vector2.ZERO
var last_time_i_saw_him : Vector2

# TODO ray cast vision, see the first thing in the way, it can see walls, doors, etc

# TODO if player very close, he will attack
# TODO if he takes a projectile, he will search at the projectile's position

# TODO all_items_dropable.pick_random()

# for now, we will put a scene for each weapon_sprite's bullet
const PROJECTILE = preload("res://scenes/projectile.tscn")
const ITEM = preload("res://Scenes/item.tscn")

func _ready():
	add_to_group("enemies")

	if movement_type == Movement.HORIZONTAL:
		direction = Vector2.RIGHT
	elif movement_type == Movement.VERTICAL:
		direction = Vector2.UP
		sect_look_at = Vector2.UP
	
	shot_cooldown.wait_time = float(Global.rand_range(10, 30)) / 10
	shot_cooldown.start()
	
	mark_sprite.visible = false
	
	if followed_path:
		followed_path.progress_ratio = offset_followed_path
		position = followed_path.position

func add_knockback(knockback: Vector2):
	knockback_velocity = knockback

func update_rotation():
	# var sect_look_at = direction if direction != Vector2.ZERO else Vector2.RIGHT
	$RayCast2D.target_position = sect_look_at * distance_vision
	$PointLight2D.rotation = sect_look_at.angle() + PI

func continue_my_boring_life(delta: float):
	"""
	When the enemy is not attacking, it will continue walking
	"""
	if followed_path:
		followed_path.progress += SPEED * (1.0 / 60.0) * delta
		direction = (followed_path.position - position).normalized()
	
	if direction != Vector2.ZERO:
		$Sectarian.flip_h = direction.x > 0
		velocity += direction * SPEED * delta
	change_look(direction)
	update_rotation()


func is_mother_fucker_in_range(player: Node2D) -> bool:
	"""
	Check if there is a player in range
	"""
	if not player:
		return false
	if position.distance_to(player.position) > distance_vision:
		return false
	# print("angle %10.2f pos %10.2f %10.2f" % [sect_look_at.angle_to(player.position - position),
	# (player.position - position).x, (player.position - position).y])
	if abs(sect_look_at.angle_to(player.position - position)) < ((fov / 2.0) * PI / 180.0):
		return true
	return false

func change_look(goal: Vector2) -> void:
	if sect_look_at.angle_to(goal) > SPEED_ROTATE:
		sect_look_at = sect_look_at.rotated(SPEED_ROTATE)
	elif sect_look_at.angle_to(goal) < -SPEED_ROTATE:
		sect_look_at = sect_look_at.rotated(-SPEED_ROTATE)
		
func shoot(player: Node) -> void:
	var proj = PROJECTILE.instantiate()
	proj.direction_proj = (player.global_position - global_position).normalized()  # calculate the direction to the player
	proj.thrower = "enemies"
	proj.target = "player"
	proj.position = position
	proj.type = Data.Projectiles.ENEMIES
	proj.is_shadow = true
	get_parent().add_child(proj)

	shot_cooldown.wait_time = float(Global.rand_range(10, 30)) / 10
	shot_cooldown.start()
	able_to_shoot = false

func lets_aim_that_mother_fucker(player: Node, delta: float) -> void:
	var angle : float = sect_look_at.angle_to(player.position - position)
	if angle > 0.1:
		sect_look_at = sect_look_at.rotated(SPEED_ROTATE)
		update_rotation()
	elif angle < -0.1:
		sect_look_at = sect_look_at.rotated(-SPEED_ROTATE)
		update_rotation()
	else:
		if able_to_shoot:
			shoot(player)

	if position.distance_to(player.position) > 25:
		direction = sect_look_at
	else:
		direction = Vector2.ZERO
	velocity += direction * SPEED * delta

func fuck_i_lost_him(delta: float):
	if (last_time_i_saw_him - position).length() < 5:
		return
	direction = (last_time_i_saw_him - position).normalized()
	velocity += direction * SPEED * delta
	change_look(direction)
	update_rotation()

func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")

	if is_mother_fucker_in_range(player):
		state = State.ATTACKING
		mark_sprite.visible = true
		mark_sprite.texture = load("res://Assets/Items/small_exclamation_mark.png")
	elif state == State.ATTACKING:
		mark_sprite.texture = load("res://Assets/Items/small_interogation_mark.png")
		state = State.SEARCHING
		research_cool_down.start()
		print("fuck lost him in", player.position)
		last_time_i_saw_him = player.position if player else position # we avoid crash as we could

	velocity = Vector2.ZERO
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.1)

	match state:
		State.ATTACKING:
			lets_aim_that_mother_fucker(player, delta)
		State.SEARCHING:
			fuck_i_lost_him(delta)
		State.WALKING:
			continue_my_boring_life(delta)

	move_and_slide()



# TODO delet this crap and see according to the raycast
#func _on_area_2d_body_entered(_body: Node2D) -> void:
	#if not followed_path:
		#direction = -direction


func _on_shot_cooldown_timeout() -> void:
	able_to_shoot = true

func _on_research_cool_down_timeout() -> void:
	state = State.WALKING
	mark_sprite.visible = false

func _on_health_life_change(new_life: int) -> void:
	$LifeBar.value = new_life

func _on_health_life_ready(value: int) -> void:
	$LifeBar.max_value = value
	$LifeBar.value = value
