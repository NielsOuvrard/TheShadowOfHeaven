## Hitbox class, manage the hitboxes of characters.
##
## Author: Sol Rojo
## [br]
## Date: 28-09-2024
##

class_name Hitbox extends Area2D

@onready var health_component: Health = $"../Health"

signal knockback_emit(value: Attack)

## called by the projectiles
func damage(attack: Attack) -> int:
	if health_component:
		if attack.knockback > 0.1:
			knockback_emit.emit(attack)
		var damage_given = health_component.damage(attack)
		var text_animated = Global.ANIMATED_TEXT.instantiate()
		text_animated.text = str(damage_given)
		text_animated.position = position
		text_animated.z_index = 2
		get_parent().add_child(text_animated)
		return damage_given
	else:
		# in case of projectile
		owner.queue_free()
		return 0
