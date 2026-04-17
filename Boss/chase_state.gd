extends Node

var boss


func enter(msg = {}):
	boss = msg.boss

func update(delta):
	if not boss.player:
		return

	var dist = boss.get_player_distance()

	# dirección hacia el jugador
	var direction = (boss.player.global_position - boss.global_position).normalized()

	# velocidad horizontal
	boss.velocity.x = direction.x * boss.speed

	# animación
	boss.anim.play("walk")

	# flip
	if !boss.is_attack :
		boss.anim.flip_h = boss.velocity.x > 0

	if boss.live <= 0:
		boss._change_state("DeadState")

	if dist > 250 and dist < 300 and boss.can_distance_attack and boss.live < 80:
		boss._change_state("AttackDistanceState")

	if dist > 200 and dist < 230 and boss.can_dash and boss.live < 60:
		boss.is_attack = true
		boss._change_state("DashState")

	if boss.ray.is_colliding() and boss.can_attack and dist < 100:
		boss.is_attack = true
		boss._change_state("AttackState")
