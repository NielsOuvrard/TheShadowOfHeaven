# ball.gd
#
# This script defines the behavior of the ball that the player shoots.
#
# Author: Sol Rojo
# Date: 24-09-2024
#

extends Area2D
@onready var color_rect: ColorRect = $ColorRect
@onready var point_light_2d: PointLight2D = $PointLight2D

@export var SPEED := 200 # maybe shoud vary according to weapon
var damage : int
var direction_ball : Vector2
var thrower : String
var target : String
var color : Color = Color(1, 1, 1, 1)
var light := false

const DAMAGET_TEXT = preload("res://Scenes/damage_text.tscn")

func _ready():
	color_rect.color = color
	point_light_2d.color = color
	if light:
		point_light_2d.energy = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = direction_ball * SPEED * delta
	position += velocity


func _on_body_entered(body):
	if body.is_in_group(target):
		var damage_given = body.take_damage(damage)
		var damage_text = DAMAGET_TEXT.instantiate()
		damage_text.text = str(damage_given)
		damage_text.position = position
		get_parent().add_child(damage_text)
	elif body.is_in_group(thrower):
		return
	queue_free()
