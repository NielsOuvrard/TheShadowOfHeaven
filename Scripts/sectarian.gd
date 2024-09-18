extends CharacterBody2D


const SPEED = 300.0


func _ready():
	add_to_group("enemies")

func _physics_process(delta):
	velocity = Vector2.ZERO
	move_and_slide()
