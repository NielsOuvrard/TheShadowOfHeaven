# data.gd
#
# This script defines global data structures and enums used across the game.
# It is autoloaded at the start of the game and can be accessed from any script.
# Only data that is not expected to change during the game should be defined here.
#
# Author: Sol Rojo
# Date: 24-09-2024
#

extends Node

enum Weapons {
	SWORD,
	PISTOL,
	SHOTGUN,
	RAYGUN
}

enum Items {
	PISTOL_AMMO,
	SHOTGUN_AMMO,
	RAYGUN_AMMO,
	LIFE
}


# TODO link cooldowns
const WEAPONS = {
	Weapons.SWORD: {
		"name": "sword",
		"texture": "res://Assets/Items/Sword.png",
		"cooldown_shot": 0.2,
		"cooldown_reload": 0.0,
		"ammo_max": 0,
		"damage": 30
	},
	Weapons.PISTOL: {
		"name": "pistol",
		"texture": "res://Assets/Items/Gun.png",
		"cooldown_shot": 0.2,
		"cooldown_reload": 1.0,
		"ammo_max": 6,
		"damage": 20
	},
	Weapons.SHOTGUN: {
		"name": "shotgun",
		"texture": "res://Assets/Items/Shotgun.png",
		"cooldown_shot": 0.5,
		"cooldown_reload": 1.5,
		"ammo_max": 2,
		"damage": 99
	},
	Weapons.RAYGUN: {
		"name": "raygun", # maybe a charge, and need to wait to shoot again
		"texture": "res://Assets/Items/RayGun.png",
		"cooldown_shot": 0.1,
		"cooldown_reload": 0.4,
		"ammo_max": 10,
		"damage": 40
	}
}

const ITEMS = {
	Items.PISTOL_AMMO: {
		"name": "pistol_ammo",
		"texture": "res://Assets/Items/ammo.png", # TODO put art's work
		"weapon": Weapons.PISTOL,
		"n_max": 6,
		"n_min": 1
	},
	Items.SHOTGUN_AMMO: {
		"name": "shotgun_ammo",
		"texture": "res://Assets/Items/ammo.png", # TODO put art's work
		"weapon": Weapons.SHOTGUN,
		"n_max": 4,
		"n_min": 1
	},
	Items.RAYGUN_AMMO: {
		"name": "raygun_ammo",
		"texture": "res://Assets/Items/ammo.png", # TODO put art's work
		"weapon": Weapons.RAYGUN,
		"n_max": 2,
		"n_min": 1
	},
	Items.LIFE: {
		"name": "life",
		"texture": "res://Assets/Items/life.png",  # TODO put art's work
		"weapon": null,
		"n_max": 15,
		"n_min": 3
	},
}

func rand_range(min_value: int, max_value: int) -> int:
	return randi() % (max_value - min_value) + min_value
