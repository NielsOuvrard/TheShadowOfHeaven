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

enum Projectiles {
	PISTOL,
	SHOTGUN,
	RAYGUN,
	ENEMIES,
	DEATH_BALL,
}

const WEAPONS = {
	Weapons.SWORD: {
		"name": "sword",
		"texture": "res://Assets/Items/Sword.png",
		"item_frame": 3,
		"cooldown_shot": 0.8,
		"cooldown_reload": 0.01,
		"ammo_max": 0, 
		"projectile": null,
		"ammo": null,
	},
	Weapons.PISTOL: {
		"name": "pistol",
		"texture": "res://Assets/Items/Gun.png",
		"item_frame": 0,
		"cooldown_shot": 0.2,
		"cooldown_reload": 1.0,
		"ammo_max": 6,
		"projectile": Projectiles.PISTOL,
		"ammo": Items.PISTOL_AMMO,
	},
	Weapons.SHOTGUN: {
		"name": "shotgun",
		"texture": "res://Assets/Items/Shotgun.png",
		"item_frame": 1,
		"cooldown_shot": 0.5,
		"cooldown_reload": 1.5,
		"ammo_max": 2,
		"projectile": Projectiles.SHOTGUN,
		"ammo": Items.SHOTGUN_AMMO,
	},
	Weapons.RAYGUN: {
		"name": "raygun", # maybe a charge, and need to wait to shoot again
		"texture": "res://Assets/Items/RayGun.png",
		"item_frame": 2,
		"cooldown_shot": 0.1,
		"cooldown_reload": 0.4,
		"ammo_max": 10,
		"projectile": Projectiles.RAYGUN,
		"ammo": Items.RAYGUN_AMMO,
	}
}

const PROJECTILS = {
	Projectiles.PISTOL: {
		"animation": "pistol",
		"speed": 200,
		"damage": 20,
		"knockback": 30.0,
		"light_color": Color(1, 1, 0, 1),
		"light_energy": 1,
		"collision_scale": Vector2(1, 0.5),
		"collision_radius": 5
	},
	Projectiles.SHOTGUN: {
		"animation": "shotgun",
		"speed": 200,
		"damage": 99,
		"knockback": 100.0,
		"light_energy": 1.5,
		"light_color": Color(1, 1, 0, 1),
		"collision_scale": Vector2(1, 0.33),
		"collision_radius": 5
	},
	Projectiles.RAYGUN: {
		"animation": "raygun", # this one is different, it's a ray
		"speed": 100,
		"damage": 40,
		"knockback": 0.0,
		"light_energy": 1,
		"light_color": Color(0, 1, 1, 1),
		"collision_scale": Vector2(1, 1),
		"collision_radius": 5.83
	},
	Projectiles.ENEMIES: {
		"animation": "enemies",
		"speed": 150,
		"damage": 30,
		"knockback": 5.0,
		"light_energy": 0.5,
		"light_color": Color(1, 0.5, 0, 1),
		"collision_scale": Vector2(1.2, 0.7),
		"collision_radius": 5.83
	},
	Projectiles.DEATH_BALL: {
		"animation": "death_ball",
		"speed": 200,
		"damage": 50,
		"knockback": 0.0,
		"light_energy": 2,
		"light_color": Color(1, 0, 1, 1),
		"collision_scale": Vector2(1.2, 0.6),
		"collision_radius": 13.33
	}
}

const ITEMS = {
	Items.PISTOL_AMMO: {
		"name": "pistol_ammo",
		"frame": 4,
		"weapon": Weapons.PISTOL,
		"n_max": 6,
		"n_min": 1
	},
	Items.SHOTGUN_AMMO: {
		"name": "shotgun_ammo",
		"frame": 5,
		"weapon": Weapons.SHOTGUN,
		"n_max": 4,
		"n_min": 1
	},
	Items.RAYGUN_AMMO: {
		"name": "raygun_ammo",
		"frame": 6,
		"weapon": Weapons.RAYGUN,
		"n_max": 2,
		"n_min": 1
	},
	Items.LIFE: {
		"name": "life",
		"frame": 7,
		"weapon": null,
		"n_max": 15,
		"n_min": 3
	},
}

func rand_range(min_value: int, max_value: int) -> int:
	return randi() % (max_value - min_value) + min_value

# not fan of putting this here, but it's working
var is_playing_controller := false
