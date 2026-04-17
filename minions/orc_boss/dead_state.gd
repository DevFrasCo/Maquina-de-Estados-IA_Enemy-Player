extends Node

var minion

func enter(msg := {}):
	minion = msg.minion

	minion.velocity = Vector2.ZERO
	minion.anim.play("dead")

	await minion.get_tree().create_timer(1.5).timeout
	minion.queue_free()

func update(delta):
	pass
