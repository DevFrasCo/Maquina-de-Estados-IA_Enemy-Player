extends Area2D


@export var speed: float = 400
var direction: Vector2 = Vector2.ZERO
var damage : float = 1
@onready var collision_proyectile : CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D


func _physics_process(delta):
	if direction != Vector2.ZERO:
		global_position += direction * speed 
		

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Boss"):
		body.hit()
	elif body.is_in_group("Boss_Minion"):
		body.hit(damage, global_position)
	
	destroy_bullet()

func destroy_bullet():
	speed = 0
	collision_proyectile.disabled = true
	queue_free()

func rotar_sprite():
	if speed > 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
