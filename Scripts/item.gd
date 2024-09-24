extends Node2D

@onready var item_sprite: Sprite2D = $ItemSprite


enum Type {
	PISTOL,
	SHOTGUN,
	RAY_GUN
}

@export var type_item := Type.PISTOL

var weapons = [
	{
		"name": "pistol",
		"texture": "res://Assets/Items/Gun.png"
	},
	{
		"name": "shotgun",
		"texture": "res://Assets/Items/Shotgun.png"
	},
	{
		"name": "raygun",
		"texture": "res://Assets/Items/RayGun.png"
	}
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_sprite.texture = load(weapons[type_item].texture)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.unlock_weapon(weapons[type_item].name)
		queue_free()
