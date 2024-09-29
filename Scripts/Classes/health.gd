# health.gd
#
# This script defines the Health class, which is used to manage the health of characters.
#
# Author: Sol Rojo
# Date: 28-09-2024
#

extends Node2D
class_name Health

@export var life : int
var max_life : int

func _ready() -> void:
	max_life = life

func damage(attack: Attack) -> int:
	var damage_received = min(attack.damage, life)
	if life <= 0:
		damage_received = 0
	life -= attack.damage

	# more something to handle directly the progress bar
	if get_parent().has_method("update_life"):
		get_parent().update_life(life)
		# ? life_bar.value = life # should we do this here?

	if attack.knockback > 0.0 and get_parent().has_method("add_knockback"):
		var velocity_knockback = (get_parent().position - attack.position).normalized() * attack.knockback
		get_parent().add_knockback(velocity_knockback)

	# it the sender is the player, we can delete it
	# otherwise if we delete the player it crash
	# bad way to check it, but works for now
	if life <= 0 and len(attack.unlocked_weapons) != 0:
		get_parent().queue_free()
	return damage_received
