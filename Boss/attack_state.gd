extends Node
class_name AttackState

var player

var boss
var attack_finished := false
var can_attack := true

func enter(data):
	boss = data.boss
	player = data.player
	
	boss.can_move = false
	attack_finished = false

	if boss.can_attack:
		# Elegir ataque aleatorio
		var type_attack = randi_range(1, 3)

		if type_attack <= 2:
			_do_single_attack(type_attack)
		else:
			_do_double_attack()


func update(delta):
	if attack_finished:
		boss._change_state("ChaseState")



func _do_single_attack(type_attack:int):
	boss.can_attack = false
	boss.can_move = false
	if type_attack == 1:
		boss.anim.play("attack_1")
	else:
		boss.anim.play("attack_2")

	# Activar área de daño
	boss.activar_area_attack()

	await boss.anim.animation_finished
	
	attack_finished = true
	boss.can_move = true
	boss.is_attack = false
	
	boss.can_attack = true
	

func _do_double_attack():
	boss.can_attack = false

	boss.anim.play("attack_1")
	boss.activar_area_attack()
	await boss.anim.animation_finished

	boss.anim.play("attack_2")
	boss.activar_area_attack()
	await boss.anim.animation_finished

	boss.can_move = true
	boss.can_attack = true
	boss.is_attack = false
	attack_finished = true
	
	
