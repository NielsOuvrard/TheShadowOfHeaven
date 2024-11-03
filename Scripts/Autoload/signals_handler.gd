## Signals used across the game.
##
## Author: Sol Rojo[br]Date: 08-10-2024
##

extends Node

## * Player signals

signal player_died
signal player_change_weapon(weapon_type, ammo_current, ammo_inventory)
signal player_life_change(life)
signal level_completed
signal player_update_ammo_current(ammo)
signal player_update_ammo_both(cur, inv)
signal player_reload(type_weapon)
signal player_use_controller(value: bool)
signal player_look_direction(direction: Vector2)


## * other signals

