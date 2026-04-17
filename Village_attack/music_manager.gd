extends Node2D

signal start_battle

var player = null
var final_round = preload("res://Assets/Music/Three Red Hearts - Out of Time.ogg")
var dialogo_music = preload("res://Assets/Music/Distalgia.ogg")
var music_battle = preload("res://Assets/Music/Three Red Hearts - Rumble at the Gates.ogg")
var music_win = preload("res://Assets/Music/Three Red Hearts - Three Red Hearts.ogg")

var diaologue_active : bool = false

var minion_player = preload("res://Creations/minions/human_soldier/soldier_player.tscn")
@onready var cooldown_minions: Timer = $Timer

const DIALOGUE_BOSS = preload("res://Creations/dialogues/dialogue_boss.dialogue")

@onready var area_dialogo: Area2D = $Area_Dialogo
@onready var anim_cinematic: AnimationPlayer = $"../Negro/AnimationPlayer"

@onready var audio: AudioStreamPlayer = $AudioListener2D/AudioStreamPlayer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	DialogueManager.dialogue_ended.connect(finish_dialogue)

func _on_area_2d_cambiar_pista_audio() -> void:
	audio.stream = dialogo_music
	reproducir_audio()

func _on_start_battle() -> void:
	audio.stream = music_battle
	reproducir_audio()


func reproducir_audio():
	audio.play()




func _on_area_dialogo_body_entered(body) -> void:
	desactivar_var_players()
	if !diaologue_active:
		diaologue_active = true
		DialogueManager.show_dialogue_balloon(DIALOGUE_BOSS)
		area_dialogo.queue_free()

func finish_dialogue(_dialogue_resource):
	activar_var_players()
	start_battle.emit()
	#$Timer.start()

func desactivar_var_players():
	player.input_enabled = false
	player.force_idle(player.is_dead)

func activar_var_players():
	player.input_enabled = true


func _on_boss_rage_active() -> void:
	audio.stream = final_round
	reproducir_audio()


func _on_boss_boss_dead() -> void:
	audio.stream = music_win
	reproducir_audio()
	#player.force_idle(player.is_dead)
	player.input_enabled = false
	await get_tree().create_timer(5).timeout
	anim_cinematic.play("appear")
	await anim_cinematic.animation_finished
	get_tree().change_scene_to_file("res://Creations/Village_attack/villague_ruins.tscn")


func _on_player_player_dead() -> void:
	await get_tree().create_timer(1).timeout
	anim_cinematic.play("appear")
	await anim_cinematic.animation_finished
	get_tree().change_scene_to_file("res://Creations/Menus/Game_Over/game_overl.tscn")


func _on_timer_timeout() -> void:
	invocar_minion_player()

func invocar_minion_player():
	var minion = minion_player.instantiate()
	minion.global_position = $Spawn_Ponit_Soldiers.global_position

	get_tree().current_scene.add_child(minion)
	$Timer.start()
