extends Node

signal dead_boss

var boss
const BLINK_TIMES := 6
const BLINK_INTERVAL := 0.12

func enter(msg := {}):
	boss = msg.boss

	boss.can_distance_attack = false
	boss.can_dash = false
	boss.can_attack = false
	boss.is_dead = true
	boss.velocity = Vector2.ZERO
	boss.anim.play("idle")

	if boss == null:
		return

	boss.blood_ef_1.visible = true
	boss.blood_ef_2.visible = true
	boss.boss_dead.emit()
	await _blink_effect()
	boss.queue_free()

func _blink_effect() -> void:
	var sprite: AnimatedSprite2D = boss.get_node("AnimatedSprite2D")

	for i in BLINK_TIMES:
		sprite.modulate.a = 0.2
		await boss.get_tree().create_timer(BLINK_INTERVAL).timeout

		sprite.modulate.a = 1.0
		await boss.get_tree().create_timer(BLINK_INTERVAL).timeout
		sprite.modulate.a = 0.2
		await boss.get_tree().create_timer(BLINK_INTERVAL).timeout


func update(delta):
	pass
