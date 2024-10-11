## Signals used across the game.
##
## Author: Sol Rojo[br]Date: 08-10-2024
##

extends Node

## * Player signals

signal player_died
signal player_change_weapon(weapon_type)
signal player_life_change(life)
signal level_completed


## * other signals

signal player_change_controller(value)
