extends AnimatedSprite2D

@onready var cooldown: Timer = $Cooldown
@onready var top_laser: AnimatedSprite2D = $TopLaser
@onready var collision: CollisionShape2D = $LaserDamageZone/CollisionShape2D
@onready var asrael_ray: AudioStreamPlayer2D = $AsraelRay

const NMB_PRE_LASER = 3
const SIZE_FRAME_RAY = 16
const SIZE_LASER = 10

var laser_queue := []
var time_to_wait

func _ready() -> void:
	SignalsHandler.asrael_die.connect(queue_free)
	self.visible = false
	await get_tree().create_timer(time_to_wait).timeout
	self.visible = true

	for i in range(NMB_PRE_LASER):
		laser_queue.append("laser_pre")
	laser_queue.append("laser")
	self.play("laser_pre")

func _on_top_laser_animation_finished() -> void:
	top_laser.visible = false
	for child in top_laser.get_children():
		remove_child(child)
		child.queue_free()
	queue_free()

func _on_animation_finished() -> void:
	if laser_queue.is_empty():
		collision.disabled = true
		return
	self.play(laser_queue[0])
	if laser_queue[0] == "laser":
		top_laser.visible = true
		collision.disabled = false
		asrael_ray.play()
		top_laser.play("top")
		for i in range(SIZE_LASER):
			var new = top_laser.duplicate()
			new.position.y -= SIZE_FRAME_RAY * i
			new.play("top")
			top_laser.add_child(new)
	laser_queue.pop_front()

func _on_laser_damage_zone_area_entered(area: Area2D) -> void:
	if area is Hitbox and area.owner.is_in_group(&"player"):
		var attack = Attack.new(1, Vector2.ZERO)
		area.damage(attack)
