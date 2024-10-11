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

var hearts := [] # TODO

func _ready() -> void:
	weapon.type = Data.Weapons.SWORD
	weapon._ready()
	
	SignalsHandler.player_life_change.connect(_player_life_change)
	SignalsHandler.player_change_weapon.connect(_player_change_weapon)
	SignalsHandler.player_change_controller.connect(_player_change_controller)

	hearts.append(heart)
	for i in range(3):
		var new = heart.duplicate()
		new.position.x += i * heart.texture.get_size().x * (heart.scale.x / 2)
		add_child(new)
		hearts.append(new)


func _player_life_change(life):
	# TODO hearths changing
	pass

func _player_change_weapon(new_weapon: Data.Weapons):
	#print(Data.Weapons[weapon])
	weapon.type = new_weapon
	weapon._ready()
	
func _player_change_controller(value):
	# TODO change visibility of the cursor
	pass
