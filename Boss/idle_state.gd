extends Node

var boss


func enter(msg := {}):
	boss = msg.boss 
	boss .velocity.x = 0
	boss .anim.play("idle")

func update(delta):
	if not boss.player:
		return
