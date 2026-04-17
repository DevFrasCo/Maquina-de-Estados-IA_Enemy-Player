extends Node

var boss
var finished_attack := false

func enter(_data):
	boss = _data.boss
	finished_attack = false

	# El jefe mira al jugador antes de disparar
	#boss.rotar_sprite_marker(boss.player)

	boss.can_move = false

	# Reproduce la animación del ataque a distancia
	boss.anim.play("attack_distance")

	# Cuando termine la animación, disparamos
	await boss.anim.animation_finished

	boss.shoot_projectile()

	finished_attack = true
	boss.can_move = true
	finish_attack()


func update(delta):
	# Cuando termine el ataque, volvemos a persecución
	if finished_attack:
		boss._change_state("ChaseState")

func finish_attack() -> void:
	await boss.anim.animation_finished

	# Inicia cooldown
	boss.start_distance_attack_cooldown()

	#boss._change_state("ChaseState")
