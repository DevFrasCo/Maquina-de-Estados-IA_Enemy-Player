extends Node

var minion

@export var chase_distance := 600
@export var attack_distance := 10


func enter(msg := {}):
	minion = msg.minion


func update(delta):
	var dist = minion.get_player_distance()
	
	minion.anim.play("walk")
	
	# Muy lejos → dejar de perseguir
	if dist > chase_distance and minion.can_distance_attack:
		minion._change_state("AttackDistanceState")
		return

	#Muy cerca → atacar
	if dist <= attack_distance:
		minion.velocity.x = 0
		minion._change_state("AttackSwordState") #  <--- Luego Cambiar al de ataque ! ATTENTION
		return

	# Dirección hacia el jugador
	var dir = sign(minion.player.global_position.x - minion.global_position.x)
	minion.velocity.x = dir * minion.speed

	if minion.can_attack and minion.ray_detec_att.is_colliding():
		minion._change_state("AttackSwordState")
