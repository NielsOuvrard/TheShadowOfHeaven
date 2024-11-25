extends AnimatedSprite2D


var position_stab_x: float = -17.0

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player.position.x > position.x:
		self.flip_h = true
		self.position.x = abs(position_stab_x)
	else:
		self.flip_h = false
		self.position.x = position_stab_x
	self.visible = true
	self.play("default")

func _on_animation_finished() -> void:
	self.visible = false
	queue_free()

func _on_stab_damage_zone_area_entered(area: Area2D) -> void:
	if area is Hitbox and area.owner.is_in_group(&"player"):
		var attack = Attack.new(1, Vector2.ZERO)
		area.damage(attack)
