## Global data structures and enums
##
## Autoloaded at the start of the game. [br]
## Only data that is not expected to change during the game should be defined here.[br][br]
##
## Author: Sol Rojo[br]Date: 24-09-2024
##

extends Node


const TILE_SIZE = 16.0
const SPEED_PLAYER = TILE_SIZE * 7 ## each seconds

enum Weapons {
	SWORD,
	PISTOL,
	SHOTGUN,
	RAYGUN
}

const WEAPONS = {
	Weapons.SWORD: {	
		"name": "sword",
		"texture": "res://Assets/Items/Sword.png",
		"item_frame": 3,
		"cooldown_shot": 0.5,
		"cooldown_reload": 0.03,
		"ammo_max": 0,
		"projectile": null,
		"ammo": null,
	},
	Weapons.PISTOL: {
		"name": "pistol",
		"texture": "res://Assets/Items/Gun.png",
		"item_frame": 0,
		"cooldown_shot": 0.1,
		"cooldown_reload": 0.5,
		"ammo_max": 6,
		"projectile": Projectiles.PISTOL,
		"ammo": Items.PISTOL_AMMO,
	},
	Weapons.SHOTGUN: {
		"name": "shotgun",
		"texture": "res://Assets/Items/Shotgun.png",
		"item_frame": 1,
		"cooldown_shot": 0.5,
		"cooldown_reload": 1,
		"ammo_max": 2,
		"projectile": Projectiles.SHOTGUN,
		"ammo": Items.SHOTGUN_AMMO,
	},
	Weapons.RAYGUN: {
		"name": "raygun", # maybe a charge, and need to wait to shoot again
		"texture": "res://Assets/Items/RayGun.png",
		"item_frame": 2,
		"cooldown_shot": 0.1,
		"cooldown_reload": 1,
		"ammo_max": 4,
		"projectile": Projectiles.RAYGUN,
		"ammo": Items.RAYGUN_AMMO,
	}
}

enum Projectiles {
	PISTOL,
	SHOTGUN,
	RAYGUN,
	ENEMIES,
	SKULL,
}

# ? remplace collision data by animationPlayer ?
const PROJECTILS = {
	Projectiles.PISTOL: {
		"animation": "pistol",
		"speed": SPEED_PLAYER * 2,
		"damage": 1,
		"knockback": 30.0,
		"light_color": Color(1, 1, 0, 1),
		"light_energy": 1,
		"collision_scale": Vector2(1, 0.5),
		"collision_radius": 5
	},
	Projectiles.SHOTGUN: {
		"animation": "shotgun",
		"speed": SPEED_PLAYER * 2.5,
		"damage": 5,
		"knockback": 100.0,
		"light_energy": 1.5,
		"light_color": Color(1, 1, 0, 1),
		"collision_scale": Vector2(1, 0.33),
		"collision_radius": 5
	},
	Projectiles.RAYGUN: {
		"animation": "raygun", # this one is different, it's a ray
		"speed": SPEED_PLAYER * 4,
		"damage": 2,
		"knockback": 0.0,
		"light_energy": 1,
		"light_color": Color(0, 1, 1, 1),
		"collision_scale": Vector2(1, 1),
		"collision_radius": 5.83
	},
	Projectiles.ENEMIES: {
		"animation": "enemies",
		"speed": SPEED_PLAYER * 2,
		"damage": 2,
		"knockback": 5.0,
		"light_energy": 0.5,
		"light_color": Color(1, 0.5, 0, 1),
		"collision_scale": Vector2(1.2, 0.7),
		"collision_radius": 5.83
	},
	Projectiles.SKULL: {
		"animation": "skull",
		"speed": SPEED_PLAYER * 1.2,
		"damage": 3,
		"knockback": 0.0,
		"light_energy": 5,
		"light_color": Color(1, 0, 1, 1),
		"collision_scale": Vector2(1.2, 0.6),
		"collision_radius": 13.33
	}
}

enum Items {
	PISTOL_AMMO,
	SHOTGUN_AMMO,
	RAYGUN_AMMO,
	LIFE
}

const ITEMS = {
	Items.PISTOL_AMMO: {
		"name": "pistol_ammo",
		"frame": 4,
		"weapon": Weapons.PISTOL,
		"n_max": 6,
		"n_min": 3
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
		"n_max": 4,
		"n_min": 2
	},
	Items.LIFE: {
		"name": "life",
		"frame": 7,
		"weapon": null,
		"n_max": 2,
		"n_min": 1
	},
}

enum Animations {
	IDLE,
	MOVE,
	# RELOAD, # not for now
	CHANGE_WEAPON,
	PICK_UP,
	DASH,
	DIE
}

const animations_data := {
	Animations.IDLE: {
		"name": "idle",
		"seconds_active": 0.0,
		"can_be_override": true
	},
	Animations.MOVE: {
		"name": "move",
		"seconds_active": 0.0,
		"can_be_override": true
	},
	# Animations.RELOAD: {
	# 	"name": "reload",
	# 	"seconds_active": 0.6,
	# 	"can_be_override": false
	# },
	Animations.CHANGE_WEAPON: {
		"name": "change_weapon",
		"seconds_active": 0.6,
		"can_be_override": false
	},
	Animations.PICK_UP: {
		"name": "pick_up",
		"seconds_active": 0.6,
		"can_be_override": false
	},
	Animations.DASH: {
		"name": "dash",
		"seconds_active": 0.6,
		"can_be_override": false
	},
	Animations.DIE: {
		"name": "die",
		"seconds_active": 999.0,
		"can_be_override": false
	}
}
