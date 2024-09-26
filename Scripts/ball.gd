# ball.gd
#
# This script defines the behavior of the ball that the player shoots.
#
# Author: Sol Rojo
# Date: 24-09-2024
#

extends Area2D
@onready var point_light: PointLight2D = $PointLight2D
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D

var direction_ball : Vector2
var thrower : String
var target : String
var type : Data.Projectiles

const DAMAGET_TEXT = preload("res://Scenes/damage_text.tscn")

# BALL

func _ready():
	point_light.color = Data.PROJECTILS[type].light_color
	point_light.energy = Data.PROJECTILS[type].light_energy
	sprite.play(Data.PROJECTILS[type].animation)
	collision.scale = Data.PROJECTILS[type].collision_scale
	collision.shape.radius = Data.PROJECTILS[type].collision_radius

	rotate(direction_ball.angle())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = direction_ball * Data.PROJECTILS[type].speed * delta
	position += velocity


func _on_body_entered(body):
	if body.is_in_group(target):
		var damage_given = body.take_damage(Data.PROJECTILS[type].damage)
		var damage_text = DAMAGET_TEXT.instantiate()
		damage_text.text = str(damage_given)
		damage_text.position = position
		get_parent().add_child(damage_text)
	elif body.is_in_group(thrower):
		return
	queue_free()
