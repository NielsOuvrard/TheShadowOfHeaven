# ball.gd
#
# This script defines the behavior of the ball that the player shoots.
#
# Author: Sol Rojo
# Date: 24-09-2024
#

extends Area2D

@export var SPEED := 200 # maybe shoud vary according to weapon
var damage : int
var direction_ball : Vector2
var target : String

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = direction_ball * SPEED * delta
	position += velocity


func _on_body_entered(body):
	if body.is_in_group(target):
		queue_free()
		body.take_damage(damage)
