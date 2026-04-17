extends Node

var boss

# -------------- CONFIGURACIONES ----------------
var charge_time := 0.2         # Tiempo de carga antes del dash
var dash_duration := 0.4     # Duración real del desplazamiento
var dash_speed := 800
var dash_effect_interval := 0.06

var direction := Vector2.ZERO
var doing_dash := false
var can_create_effect := true
@onready var boss_anim: AnimatedSprite2D = $"../../AnimatedSprite2D"


func enter(msg := {}):
	boss = msg.boss
	if not boss.player: return
	
	boss.can_dash = false
	boss.hab_dash()

	boss.anim.play("idle")
	boss.can_move = false

	await boss.get_tree().create_timer(charge_time).timeout
	if !boss.rage:
		_flash_red()

	await boss.get_tree().create_timer(charge_time).timeout
	
	boss.start_dash()
	_start_dash()


func update(delta):
	if doing_dash:
		boss.velocity = direction * dash_speed
		boss.move_and_slide()

func exit():
	doing_dash = false
	boss.velocity = Vector2.ZERO
	can_create_effect = true

func _start_dash():
	if not boss.player: return

	# dirección hacia el jugador
	direction = (boss.player.global_position - boss.global_position).normalized()

	doing_dash = true

	# activar temporizador de efecto visual
	_create_dash_effect()

	# detener dash después del tiempo
	await boss.get_tree().create_timer(dash_duration).timeout

	doing_dash = false
	boss.velocity = Vector2.ZERO

	# ejecutar el golpe final del dash
	await _finish_dash()

func _create_dash_effect():
	if not can_create_effect: 
		return

	can_create_effect = false

	var copy = boss_anim.duplicate()
	boss.get_parent().add_child(copy)
	copy.global_position = boss.global_position

	var t = boss.get_tree().create_tween()
	t.tween_property(copy, "modulate:a", 0.1, 0.5)
	t.finished.connect(func(): copy.queue_free())

	await boss.get_tree().create_timer(dash_effect_interval).timeout
	can_create_effect = true

func _flash_red():
	var sprite = boss_anim
	var original = sprite.modulate

	var t = boss.get_tree().create_tween()
	t.tween_property(sprite, "modulate", Color.RED, 1)
	t.tween_property(sprite, "modulate", original, 2)

func _finish_dash():
	boss.anim.play("attack_2")
	boss.activar_area_attack()
	await boss.anim.animation_finished
	boss_anim.play("idle")
	boss.can_move = true
	boss.is_attack = false
	boss._change_state("ChaseState")
