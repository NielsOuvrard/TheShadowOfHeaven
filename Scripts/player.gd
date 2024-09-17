extends CharacterBody2D

@onready var amos = $Amos
@onready var shot_cooldown = $ShotCooldown

const SPEED = 5000.0
const JUMP_VELOCITY = -400.0

const BALL = preload("res://scenes/ball.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	var direction_input = Vector2.ZERO

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
		amos.flip_h = direction.x > 0
	direction = direction.rotated(rotation)
	
	if direction != Vector2.ZERO:
		velocity = delta * direction * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()


	if Input.is_action_pressed('shoot') and shot_cooldown.is_stopped():
		shot_cooldown.start()
		var window_size = get_viewport().get_visible_rect().size
		var mouse_position = get_viewport().get_mouse_position() - window_size / 2

		mouse_position = mouse_position.normalized() # * amos.size.x

		var ball = BALL.instantiate()
		ball.direction_ball = mouse_position
		ball.position = amos.position + mouse_position + amos.get_parent().position
		get_parent().add_child(ball)


