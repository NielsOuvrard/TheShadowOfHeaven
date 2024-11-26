## Behavior of the HUD.
##
## Player's health, weapon, ammo, and cursor are managed here.[br][br]
##
## Author: Sol Rojo[br]Date: 25-09-2024
##

extends CanvasLayer
@onready var left: Control = $Left
@onready var right: Control = $Right
@onready var weapon: Node2D = $Right/Weapon
@onready var cursor: Sprite2D = $Center/Cursor

@onready var heart_parent: Node = $Left/HeartParent
@onready var heart: Sprite2D = $Left/HeartParent/Heart

@onready var bullet_parent: Control = $Right/BulletParent
@onready var bullet_icon: Node2D = $Right/BulletParent/BulletIcon

@onready var dash_parent: Node = $Left/DashParent
@onready var dash: AnimatedSprite2D = $Left/DashParent/Dash

@onready var inv_text: Label = $Right/InvText

# hearts
const PLAYER_FULL_LIFE = 6
const HALFS_HEARTS = 6 ## 3 hearts, so 6 halfs ones
const NUMBER_HALFS_HEARTS = 4 ## 2 hearts, 4 halfs
var hearts_index := []

# Bullets & weapons
const NUMBER_TYPES_BULLETS = 3
var current_weapon := Data.Weapons.SWORD
var bullets := []

# * dash
const MAX_NMB_DASH = 3
const SIZE_DASH_POINT = 13
var dash_list := []
var nmb_dash_on := 3
var last_dash_modified : int


# todo hearts animated

func bullet_to_ammo_list(ammo: int):
	for i in range(bullet_parent.get_child_count()):
		bullet_parent.remove_child(bullet_parent.get_child(0))
	bullets.clear()
	for i in range(ammo):
		var new = bullet_icon.duplicate()
		# * x2 because we put 1px space between each bullet
		new.position.x -= (i * 2) * new.scale_sprite.x * (new.size_texture.x / NUMBER_TYPES_BULLETS)
		new.frame = current_weapon - 1
		bullet_parent.add_child(new)
		bullets.append(new)

func life_to_hearts_list(life: int):
	var local = int(float(life) / float(PLAYER_FULL_LIFE) * float(HALFS_HEARTS))
	hearts_index = []
	for i in range(HALFS_HEARTS):
		if local > 0:
			hearts_index.append(i % 2)
			local -= 1
		else:
			hearts_index.append((i % 2) + 2)

func update_hearts():
	for i in range(heart_parent.get_child_count()):
		heart_parent.remove_child(heart_parent.get_child(0))
	for i in range(HALFS_HEARTS):
		var new = heart.duplicate()
		new.position.x += i * heart.texture.get_size().x * (heart.scale.x / NUMBER_HALFS_HEARTS)
		new.frame = hearts_index[i]
		heart_parent.add_child(new)

func _ready() -> void:
	weapon.type = Data.Weapons.SWORD
	weapon._ready()

	cursor.visible = false

	SignalsHandler.player_life_change.connect(_player_life_change)
	SignalsHandler.player_change_weapon.connect(_player_change_weapon)
	SignalsHandler.player_update_ammo_current.connect(_player_update_ammo_current)
	SignalsHandler.player_update_ammo_both.connect(_player_update_ammo_both)
	SignalsHandler.player_use_controller.connect(_player_use_controller)
	SignalsHandler.player_look_direction.connect(_player_look_direction)
	SignalsHandler.player_reload.connect(_player_reload)
	SignalsHandler.player_update_dash.connect(_player_update_dash)

	life_to_hearts_list(PLAYER_FULL_LIFE) # should print 3 full hearts
	update_hearts()
	_player_change_weapon(current_weapon, 0, 0)

	dash_list.append(dash)
	for i in range(1, 3): # 2 and 3
		var new_dash = dash.duplicate()
		new_dash.position.x += SIZE_DASH_POINT * i * 5.5
		dash_list.append(new_dash)
		dash_parent.add_child(new_dash)

func _player_update_ammo_current(ammo):
	if ammo == len(bullets) - 1:
		bullets[-1].play("remove")
		bullets.pop_back()
	else:
		bullet_to_ammo_list(ammo)

func _player_update_ammo_both(cur, inv):
	inv_text.text = str(inv)
	bullet_to_ammo_list(cur)

func _player_life_change(life):
	life_to_hearts_list(life)
	update_hearts()

func _player_change_weapon(new_weapon: Data.Weapons, ammo_current: int, ammo_inventory: int):
	current_weapon = new_weapon
	weapon.type = new_weapon
	weapon._ready()
	bullet_to_ammo_list(ammo_current)
	if Data.WEAPONS[new_weapon].ammo_max == 0:
		inv_text.text = ""
	else:
		inv_text.text = str(ammo_inventory)

func _player_reload(type_weapon):
	bullet_to_ammo_list(Data.WEAPONS[type_weapon].ammo_max)
	var time_to_reload = Data.WEAPONS[type_weapon].cooldown_reload
	for i in range(len(bullets)):
		bullets[i].disabled((time_to_reload / len(bullets)) * (i + 1))

func _player_use_controller(value):
	cursor.visible = value

func _player_look_direction(direction: Vector2):
	cursor.rotation = direction.angle()

func _player_update_dash(value: int):
	if not abs(value - nmb_dash_on) == 1 or value == nmb_dash_on:
		assert("Error: Dash value is not correct")

	if nmb_dash_on > value:
		last_dash_modified = nmb_dash_on - 1
		dash_list[last_dash_modified].play("loss")
	else:
		last_dash_modified = value - 1
		dash_list[last_dash_modified].play("gain")

	nmb_dash_on = value


func _on_dash_animation_finished() -> void:
	if dash_list[last_dash_modified].animation == "loss":
		dash_list[last_dash_modified].play("off")
	elif dash_list[last_dash_modified].animation == "gain":
		dash_list[last_dash_modified].play("on")
