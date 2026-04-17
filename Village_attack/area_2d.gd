extends Area2D

signal cambiar_pista_audio

@onready var tp_door: Marker2D = $Marker2D

var player: Node2D = null

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null

func _process(_delta):
	if player and Input.is_action_just_pressed("Interactuar"):
		player.global_position = tp_door.global_position
		cambiar_pista_audio.emit()
		player = null
		queue_free()
