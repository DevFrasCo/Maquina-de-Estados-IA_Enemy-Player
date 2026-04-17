extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var value : int = randi_range(1,2)


func _ready() -> void:
	rotar_sprite()

func rotar_sprite():
	if value > 1:
		anim.flip_h = true
	else:
		anim.flip_h = false
