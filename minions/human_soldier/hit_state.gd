extends Node


var minion
var knockback_force := 50

func enter(msg := {}):
	minion = msg.minion

	# detener control previo
	minion.velocity.x = 0

	# aplicar retroceso
	minion.apply_knockback(
		minion._last_hit_position,
		50,
		0
	)

	minion.anim.play("hit")
	await minion.anim.animation_finished
	minion.in_hit = false
	minion.can_attack = true
	_on_animation_finished()

func update(delta):
	# dejamos que el knockback se mueva solo
	minion.move_and_slide()

func _on_animation_finished():
	if minion and not minion.is_dead:
		minion._change_state("ChaseState")

func exit():
	pass
