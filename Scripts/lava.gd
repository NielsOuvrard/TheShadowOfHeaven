extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var point_light_2d: PointLight2D = $PointLight2D

@export var damage = 500

var is_flipped_v := false

func _ready() -> void:
	timer.start()

var time_passed: float = 0.0

func _on_timer_timeout() -> void:
	sprite_2d.flip_v = is_flipped_v
	is_flipped_v = !is_flipped_v
	timer.start()

func _process(delta: float) -> void:
	time_passed += delta
	point_light_2d.energy = abs(sin(time_passed) - 0.2) + 0.2


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Hitbox and area.owner.is_in_group(&"player"):
		var attack = Attack.new(1, Vector2.ZERO)
		var damage_given = area.damage(attack)
