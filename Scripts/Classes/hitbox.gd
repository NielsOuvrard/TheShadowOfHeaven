# hitbox.gd
#
# This script defines the Hitbox class, which is used to manage the hitboxes of characters.
#
# Author: Sol Rojo
# Date: 28-09-2024
#
extends Area2D

class_name Hitbox

@export var health_component: Health

func damage(attack: Attack) -> int:
	if health_component:
		return health_component.damage(attack)
	return -1
