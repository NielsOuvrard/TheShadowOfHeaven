# sword_attack.gd
#
# This script defines the behavior of the sword attack.
# For now, it only adds the sword attack to the "sword_attack" group, so the ball can detect it.
#
# Author: Sol Rojo
# Date: 28-09-2024
#
extends Area2D


func _ready() -> void:
	add_to_group("sword_attack")