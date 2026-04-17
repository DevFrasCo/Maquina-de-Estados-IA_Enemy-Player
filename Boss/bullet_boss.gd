extends Area2D

# AQUI VARIABLES DE SONIDOS -> EXPLOSION WARNING

@onready var audio_bullet: AudioStreamPlayer2D = $AudioStreamPlayer2D

var snd_explosion_1 = preload("res://Assets/Sonidos_Ex/explosion_1.wav")
var snd_explosion_2 = preload("res://Assets/Sonidos_Ex/explosion_2.wav")
var snd_explosion_3 = preload("res://Assets/Sonidos_Ex/explosion_3.wav")
var snd_explosion_4 = preload("res://Assets/Sonidos_Ex/explosion_4.wav")
var snd_explosion_5 = preload("res://Assets/Sonidos_Ex/explosion_5.wav")

var valor_snd : int = randi_range(1,5)
var damage : float = 1

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_proyectile : CollisionShape2D = $CollisionShape2D

@export var speed: float = 400
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass

func _physics_process(delta):
	if direction != Vector2.ZERO:
		global_position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("Player_Minion"):
		body.hit(damage, global_position)
	elif body.is_in_group("Player"):
		body.hit(damage)

	detener_avance()
	destruir_colision()
	destroy()

	if body is TileMapLayer: #  <-- WARNING OJO AQUI ESTA LO DEL TILEMAP !!! WARNING 
		detener_avance()
		destruir_colision()
		destroy()


		# <--- Aqui todo lo de la vida ATTENTION


func detener_avance():
	speed = 0

func destruir_colision():
	collision_proyectile.queue_free()

func destroy():
	anim.play("explosion")
	determinar_audio()
	await anim.animation_finished
	queue_free()

func determinar_audio():
	if valor_snd == 5:
		audio_bullet.stream = snd_explosion_5
	elif valor_snd == 4:
		audio_bullet.stream = snd_explosion_4
	elif valor_snd == 3:
		audio_bullet.stream = snd_explosion_3
	elif valor_snd == 2:
		audio_bullet.stream = snd_explosion_2
	else:
		audio_bullet.stream = snd_explosion_1

	reprodurcir_audio()

func reprodurcir_audio():
	audio_bullet.play()
