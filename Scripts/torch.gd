extends StaticBody2D

@onready var point_light_2d: PointLight2D = $PointLight2D

@export var color : Color = Color("f1de00")
@export_range(0.01, 1) var energy: float = 0.5


func _ready() -> void:
	point_light_2d.color = color
	point_light_2d.energy = energy
