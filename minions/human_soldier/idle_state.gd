extends Node

var minion

@export var chase_distance := 800
@export var attack_distance := 10

func enter(msg := {}):
	minion = msg.minion
	minion.velocity.x = 0
	minion.anim.play("idle")

func update(delta):
	if not minion.player:
		return

	var dist = minion.global_position.distance_to(minion.player.global_position)

	# Ataque cuerpo a cuerpo
	if dist <= attack_distance:
		minion._change_state("AttackSwordState")   # <---- Luego Cambiar al de ataque ATTENTION
		return

	# Perseguir
	if dist <= chase_distance:
		minion._change_state("ChaseState")
		return
