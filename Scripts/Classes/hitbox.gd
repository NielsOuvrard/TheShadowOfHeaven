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
		return health_component.damage(attack)
	else:
		# in case of projectile
		owner.queue_free()
		return 0
