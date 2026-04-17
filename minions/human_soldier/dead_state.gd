extends Node

var minion

func enter(msg := {}):
	minion = msg.minion

	minion.velocity = Vector2.ZERO
	if minion.is_dead:
		minion.anim.play("dead")

	await minion.get_tree().create_timer(2).timeout
	minion.queue_free()

func update(delta):
	pass
