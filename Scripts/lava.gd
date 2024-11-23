extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var mirror_cooldown: Timer = $MirorCooldown
@onready var damage_cooldown: Timer = $DamageCooldown
@onready var point_light: PointLight2D = $PointLight2D

var is_flipped_v := false
var time_passed: float = 0.0

func _ready() -> void:
	mirror_cooldown.start()

func _process(delta: float) -> void:
	time_passed += delta
	point_light.energy = abs(sin(time_passed)) * 0.15


func _on_timer_timeout() -> void:
	sprite.flip_v = is_flipped_v
	is_flipped_v = !is_flipped_v
	mirror_cooldown.start()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Hitbox and area.owner.is_in_group(&"player") and damage_cooldown.is_stopped():
		var attack = Attack.new(1, Vector2.ZERO)
		area.damage(attack)
		damage_cooldown.start()
