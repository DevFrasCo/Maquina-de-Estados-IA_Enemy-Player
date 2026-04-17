extends Node

var minion
var finished_attack := false

func enter(_data):
	minion = _data.minion
	finished_attack = false

	# El jefe mira al jugador antes de disparar
	#boss.rotar_sprite_marker(boss.player)

	minion.can_move = false

	# Reproduce la animación del ataque a distancia
	minion.anim.play("attack_bow")

	# Cuando termine la animación, disparamos
	await minion.anim.animation_finished

	minion.shoot_projectile()

	finished_attack = true
	minion.can_move = true
	finish_attack()


func update(delta):
	# Cuando termine el ataque, volvemos a persecución
	if finished_attack:
		minion._change_state("ChaseState")

func finish_attack() -> void:
	await minion.anim.animation_finished

	# Inicia cooldown
	minion.start_distance_attack_cooldown()

	#boss._change_state("ChaseState")
