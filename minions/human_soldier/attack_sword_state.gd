extends Node

var minion
var attack_finished := false

func enter(msg = {}):
	minion = msg.minion
	attack_finished = false

	# 1️⃣ Frenar completamente
	minion.velocity = Vector2.ZERO

	# 2️⃣ Bloquear ataques encadenados
	minion.can_attack = false

	# 3️⃣ Ejecutar ataque
	_do_attack()

func _do_attack() -> void:
	minion.anim.play("attack_sword")

	# Activar hitbox en el momento justo
	await minion.get_tree().create_timer(0.3).timeout
	minion.area_attack.disabled = false

	# Desactivar hitbox
	await minion.get_tree().create_timer(0.2).timeout
	minion.area_attack.disabled = true

	# Esperar fin de animación
	attack_finished = true
	await minion.anim.animation_finished

	

func update(_delta):
	
	if attack_finished:
		minion.can_attack = true
		minion._change_state("ChaseState")
