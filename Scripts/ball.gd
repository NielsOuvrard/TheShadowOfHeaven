extends Area2D


var direction_ball : Vector2

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = direction_ball * 100 * delta
	position += velocity
	
