## Global functions and variables
##
## Autoloaded at the start of the game.[br]
##
## Author: Sol Rojo[br]Date: 24-09-2024
##

extends Node

func rand_range(min_value: int, max_value: int) -> int:
	return randi() % (max_value - min_value) + min_value
