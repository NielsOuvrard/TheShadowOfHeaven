## Hitbox class, manage the hitboxes of characters.
##
## Author: Sol Rojo
## [br]
## Date: 28-09-2024
##

class_name Hitbox extends Area2D

@onready var health_component: Health = $"../Health"

signal knockback_emit(value: Attack)

const heart_anim = preload("res://Scenes/heart_lost.tscn")

## called by the projectiles
func damage(attack: Attack) -> int:
	if health_component:
		knockback_emit.emit(attack)
		var damage_given = health_component.damage(attack)

		for i in range(damage_given):
			var heart_sprite = heart_anim.instantiate()
			heart_sprite.z_index = 2
			get_parent().add_child(heart_sprite)

		return damage_given
	else:
		# in case of projectile
		owner.queue_free()
		return 0
