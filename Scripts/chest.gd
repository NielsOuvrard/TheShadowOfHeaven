## Chest script
##
## Author: Sol Rojo[br]Date: 14-10-2024
##

extends StaticBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $AreaRange/CollisionShape2D
@onready var mark: Sprite2D = $Mark

var is_opened = false

func _ready() -> void:
	mark.visible = false

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group(&"player")
	if not player:
		return
	if Input.is_action_pressed(&"interact") and\
	not is_opened and\
	position.distance_to(player.position) < collision_shape_2d.shape.radius:
		animated_sprite_2d.play(&"opening")


func _on_area_range_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		mark.visible = true

func _on_area_range_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		mark.visible = false

func _on_animated_sprite_2d_animation_finished() -> void:
	var player = get_tree().get_first_node_in_group(&"player")
	if not player:
		return
	is_opened = true
	var random_offset = Vector2(Global.rand_range(-10, 10), Global.rand_range(0, 10))
	Global.drop_random_item(position + random_offset, get_parent(), player.weapons_unlocked)
