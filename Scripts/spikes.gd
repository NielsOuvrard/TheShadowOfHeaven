## Spikes script
##
## Author: Sol Rojo[br]Date: 14-10-2024
##

extends Area2D

var damage_given := false
var DAMAGE := 1

func _process(delta: float) -> void:
	var bodies = $DamageZone.get_overlapping_bodies()
	if not damage_given:
		for body in bodies:
			var hitbox = body.get_node_or_null("Hitbox")
			if body.is_in_group("player") and hitbox and hitbox is Hitbox:
				damage_given = true
				hitbox.damage(Attack.new(DAMAGE, position, 0, {}))
				print("damage given")

func _on_body_entered(body: Node2D) -> void:
	$AnimationPlayer.play("run")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	damage_given = false
