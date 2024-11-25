extends Node


var direction: Vector2
var position: Vector2
var time_to_wait: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(time_to_wait).timeout
	
	var proj = Global.PROJECTILE.instantiate()
	proj.direction_proj = direction
	proj.thrower = "enemies"
	proj.target = "player"
	proj.position = position
	proj.type = Data.Projectiles.SKULL
	proj.is_shadow = true
	get_parent().add_child(proj)
