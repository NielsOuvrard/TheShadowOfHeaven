## Behavior of the HUD.
##
## Player's health, weapon, ammo, and cursor are managed here.[br][br]
##
## Author: Sol Rojo[br]Date: 25-09-2024
##

extends CanvasLayer

@onready var weapon: Node2D = $Right/Weapon
@onready var heart: Sprite2D = $Left/Heart
@onready var cursor: Sprite2D = $Center/Cursor

@onready var cur_text: Label = $Right/CurText
@onready var inv_text: Label = $Right/InvText

var current_weapon := Data.Weapons.SWORD
var hearts := []
var hearts_index := []

const PLAYER_FULL_LIFE = 100
const HALFS_HEARTS = 6 ## 3 hearts, so 6 halfs ones
const NUMBER_HALFS_HEARTS = 4 ## 2 hearts, 4 halfs

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
	hearts.clear()
	for i in range(HALFS_HEARTS):
		var new = heart.duplicate()
		new.position.x += i * heart.texture.get_size().x * (heart.scale.x / NUMBER_HALFS_HEARTS)
		new.frame = hearts_index[i]
		add_child(new)
		hearts.append(new)

func _ready() -> void:
	weapon.type = Data.Weapons.SWORD
	weapon._ready()
	
	SignalsHandler.player_life_change.connect(_player_life_change)
	SignalsHandler.player_change_weapon.connect(_player_change_weapon)
	SignalsHandler.player_change_controller.connect(_player_change_controller)

	life_to_hearts_list(PLAYER_FULL_LIFE) # should print 3 full hearts
	update_hearts()


func _player_life_change(life):
	print("new life:", life)
	life_to_hearts_list(life)
	update_hearts()

func _player_change_weapon(new_weapon: Data.Weapons):
	weapon.type = new_weapon
	weapon._ready()
	
func _player_change_controller(value):
	# TODO change visibility of the cursor
	pass
