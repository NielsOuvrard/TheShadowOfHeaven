## Behavior of sectarian enemies.
##
## Author: Sol Rojo[br]Date: 24-09-2024
##

extends CharacterBody2D

@onready var mark_sprite: Sprite2D = $Mark
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var shot_cooldown: Timer = $ShotCooldown
@onready var research_cool_down: Timer = $ResearchCoolDown

@export var linear_movement := Vector2.ZERO:
	set(v):
		if v != Vector2.ZERO:
			v.normalized()
		linear_movement = v
		print("linear_movement", linear_movement)


@export var SPEED := 900.0 ## speed movement
@export var COOLDOWN_SHOT := 1.0 ## time between each shot

@export var followed_path : PathFollow2D
@export_range(0, 1, 0.01) var offset_followed_path := 0.0 ## offset of the path, between 0 and 1

var percent_path := 0
var distance_vision := 100
var fov := 30.0
var ready_finished := false
var objective_position : Vector2 ## position to go
var priority_objective_position := Vector2.ZERO ## position to go, in priority
var knockback_velocity = Vector2.ZERO
var last_time_i_saw_him : Vector2

enum State {
	WALKING,
	ATTACKING,
	SEARCHING,
	NOTHING
}
var state : State

enum StateSearching {
	# escape
	ROTATE_PI_PLAYER_ESCAPE,
	# damage
	ROTATE_ORIGIN_DAMAGE,
	# both
	GO_TO_POSITION_X,
	ROTATE_ON_HIMSELF
}
var state_searching : StateSearching

var DISTANCE_TO_COLLISION := 20
var EACH_FRAME := 1.0 / 60.0
var SPEED_ROTATE := 0.02

var sect_look_at = Vector2.RIGHT:
	set(v):
		if not ready_finished: # set the first time
			sect_look_at = v
		if v == Vector2.ZERO:
			return
		var angle_diff = sect_look_at.angle_to(v)
		if abs(angle_diff) > SPEED_ROTATE:
			angle_diff = sign(angle_diff) * SPEED_ROTATE
			sect_look_at = sect_look_at.rotated(angle_diff)
		else:
			sect_look_at = v
		ray_cast.target_position = sect_look_at * distance_vision
		$PointLight2D.rotation = sect_look_at.angle() + PI


# TODO if player very close, he will attack
# TODO if he gets attacking, he send a signal to clsest enemy to attack the player
# TODO all_items_dropable.pick_random()

const mark_texture_exclamation = preload("res://Assets/Items/small_exclamation_mark.png")
const mark_texture_interogation = preload("res://Assets/Items/small_interogation_mark.png")

func _ready():
	add_to_group("enemies")

	if linear_movement or followed_path:
		state = State.WALKING
		if linear_movement:
			sect_look_at = linear_movement.normalized()
			$Sectarian.flip_h = sect_look_at.x > 0
		elif followed_path:
			followed_path.progress_ratio = offset_followed_path
			position = followed_path.position
			sect_look_at = followed_path.position - position
	else:
		state = State.NOTHING
	
	mark_sprite.visible = false
	ready_finished = true

## State walking
func walking(delta: float):
	if followed_path:
		followed_path.progress += SPEED * EACH_FRAME * delta
		objective_position = followed_path.position
	elif priority_objective_position != Vector2.ZERO and position.distance_to(priority_objective_position) > 1:
		# set priority objective to ignore the collision while rotating
		objective_position = priority_objective_position
	elif priority_objective_position != Vector2.ZERO:
		# reset priority_objective_position to return to the normal objective_position
		objective_position = priority_objective_position
		priority_objective_position = Vector2.ZERO
	elif linear_movement != Vector2.ZERO:
		if ray_cast.is_colliding():
			var collider = ray_cast.get_collider()
			if collider.is_in_group("enemies"):
				return # wait for the other to move
			elif collider.position.distance_squared_to(position) < pow(DISTANCE_TO_COLLISION, 2):
				linear_movement = -linear_movement # TODO change also the cast
				priority_objective_position = position + (linear_movement * 2)
		objective_position = position + linear_movement
	else:
		return

	var new_direction = (objective_position - position).normalized()
	sect_look_at = new_direction
	$Sectarian.flip_h = sect_look_at.x > 0

	# walk only if he is not rotating
	if sect_look_at == new_direction or (followed_path and state == State.WALKING):
		velocity += new_direction * SPEED * delta


func is_player_in_range(player: Node2D) -> bool:
	if not player:
		return false

	var original_position = ray_cast.target_position
	var start_angle = ray_cast.target_position.angle() - deg_to_rad(fov) / 2

	for i in range(fov):
		var angle = start_angle + deg_to_rad(i)
		var new_direction = Vector2(cos(angle), sin(angle))
		ray_cast.target_position = new_direction * ray_cast.target_position.length()
		ray_cast.force_raycast_update()
		
		if ray_cast.is_colliding():
			var collider = ray_cast.get_collider()
			if collider.is_in_group("player"):
				ray_cast.target_position = original_position
				return true
	ray_cast.target_position = original_position
	return false

func shoot(player: Node) -> void:
	var proj = Global.PROJECTILE.instantiate()
	proj.direction_proj = (player.global_position - global_position).normalized()  # calculate the direction to the player
	proj.thrower = "enemies"
	proj.target = "player"
	proj.position = position
	proj.type = Data.Projectiles.ENEMIES
	proj.is_shadow = true
	proj.z_index = 1
	proj.y_sort_enabled = true
	get_parent().add_child(proj)

	shot_cooldown.wait_time = COOLDOWN_SHOT
	shot_cooldown.start()

func player_in_fov(player: Node, delta: float) -> void:
	var angle : float = sect_look_at.angle_to(player.position - position)
	if abs(angle) > 0.1:
		sect_look_at = sect_look_at.rotated(angle)
	elif shot_cooldown.is_stopped():
		shoot(player)

	var direction = Vector2.ZERO
	if position.distance_to(player.position) > 25:
		direction = sect_look_at
	else:
		direction = Vector2.ZERO
	velocity += direction * SPEED * delta


func searching(delta: float):
	match state_searching:
		StateSearching.ROTATE_PI_PLAYER_ESCAPE:
			if sect_look_at.angle_to(last_time_i_saw_him - position) > 0.1:
				sect_look_at = sect_look_at.rotated(SPEED_ROTATE)
			else:
				state_searching = StateSearching.GO_TO_POSITION_X
		StateSearching.ROTATE_ORIGIN_DAMAGE:
			if sect_look_at.angle_to(last_time_i_saw_him - position) > 0.1:
				sect_look_at = sect_look_at.rotated(SPEED_ROTATE)
			else:
				state_searching = StateSearching.GO_TO_POSITION_X
		StateSearching.GO_TO_POSITION_X:
			if position.distance_to(last_time_i_saw_him) > 5:
				var direction = (last_time_i_saw_him - position).normalized()
				velocity += direction * SPEED * delta
			else:
				state_searching = StateSearching.ROTATE_ON_HIMSELF
				research_cool_down.start()
		StateSearching.ROTATE_ON_HIMSELF:
			if not research_cool_down.is_stopped():
				sect_look_at = sect_look_at.rotated(-SPEED_ROTATE)
			else:
				state = State.WALKING

func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")

	if is_player_in_range(player):
		state = State.ATTACKING
		mark_sprite.visible = true
		mark_sprite.texture = mark_texture_exclamation
	elif state == State.ATTACKING:
		mark_sprite.texture = mark_texture_interogation
		state = State.SEARCHING
		last_time_i_saw_him = player.position
		state_searching = StateSearching.ROTATE_PI_PLAYER_ESCAPE

	velocity = Vector2.ZERO
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.1)

	match state:
		State.ATTACKING:
			player_in_fov(player, delta)
		State.SEARCHING:
			searching(delta)
		State.WALKING:
			walking(delta)
		State.NOTHING:
			pass

	move_and_slide()


#region signlas
func _on_research_cool_down_timeout() -> void:
	# state = State.WALKING if is_moving else State.NOTHING
	mark_sprite.visible = false

func _on_health_life_change(new_life: int) -> void:
	$LifeBar.value = new_life

func _on_health_life_ready(value: int) -> void:
	$LifeBar.max_value = value
	$LifeBar.value = value

func _on_hitbox_knockback_emit(attack: Attack) -> void:
	knockback_velocity = (position - attack.position).normalized() * attack.knockback
	if state == State.WALKING:
		state = State.SEARCHING
		state_searching = StateSearching.ROTATE_ORIGIN_DAMAGE
		last_time_i_saw_him = attack.position
		mark_sprite.visible = true
		mark_sprite.texture = mark_texture_interogation

func _on_health_die(unlocked_weapons) -> void:
	Global.drop_random_item(position, get_parent(), unlocked_weapons)
	queue_free()
#endregion
