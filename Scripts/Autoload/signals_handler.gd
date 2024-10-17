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


## * other signals

signal player_change_controller(value)
