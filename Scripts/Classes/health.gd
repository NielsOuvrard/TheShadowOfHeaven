## Health class, manage the health of player and enemies.
##
## Author: Sol Rojo[br]Date: 28-09-2024
##

class_name Health extends Node

## emitted to know the initial life, and then the max life of an entity
signal life_ready(value)

signal life_change(old, new)

signal die(unlocked_weapons)

@export var life := 5:
	set(value):
		life_change.emit(life, value)
		life = value

var max_life : int
var is_invicible := false

func _ready() -> void:
	max_life = life
	life_ready.emit(life)

func damage(attack: Attack) -> int:
	if is_invicible:
		return 0
	var damage_received = min(attack.damage, life)
	if life <= 0:
		damage_received = 0
	life -= attack.damage

	if life <= 0 and not owner.is_in_group("player"):
		die.emit(attack.unlocked_weapons)
	return damage_received
