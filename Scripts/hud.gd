# hud.gd
#
# This script defines the behavior of the HUD.
#
# Author: Sol Rojo
# Date: 25-09-2024
#
extends CanvasLayer

@onready var weapon: Node2D = $Right/Weapon
@onready var heart: Sprite2D = $Left/Heart
@onready var cursor: Sprite2D = $Center/Cursor

@onready var cur_text: Label = $Right/CurText
@onready var inv_text: Label = $Right/InvText

var current_weapon := Data.Weapons.SWORD

func _ready() -> void:
	weapon.type = Data.Weapons.SWORD
	weapon._ready()

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if current_weapon != player.current_weapon:
		current_weapon = player.current_weapon
		weapon.type = player.current_weapon
		weapon._ready()
	
	if player.current_weapon == Data.Weapons.SWORD:
		cur_text.text = ""
		inv_text.text = ""
	else:
		cur_text.text = str(player.ammo_current[player.current_weapon])
		inv_text.text = str(player.ammo_inventory[player.current_weapon])
		
	if Data.is_playing_controller:
		cursor.visible = true
		var cursor_vector = player.look_direction
		if cursor_vector != Vector2.ZERO:
			cursor.rotation = cursor_vector.angle()
	else:
		cursor.visible = false
