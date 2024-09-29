# attack.gd
#
# This script defines the Attack class, which is used to manage the attacks that characters can perform.
#
# Author: Sol Rojo
# Date: 27-09-2024
#

class_name Attack

var damage : int
var position : Vector2
var knockback : float = 0.0

# to know what item drop
var unlocked_weapons := {}

func _init(_damage: int, _position: Vector2, _knockback: float = 0.0, _unlocked_weapons: Dictionary = {}) -> void:
	self.damage = _damage
	self.position = _position
	self.knockback = _knockback
	self.unlocked_weapons = _unlocked_weapons

# velocity = (position - attack.position).normalized() * attack.knockback
