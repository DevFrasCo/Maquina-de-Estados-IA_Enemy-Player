extends CharacterBody2D


signal rage_active
signal boss_dead

#region variables / menciones 
var damage : int = 1
var en_hit : bool = false
var direction = velocity.normalized()
var gravity : float = 900
var can_move : bool = true
var speed : float = 130
var player = null
var current_state
var can_distance_attack = true
var can_attack : bool = true
var can_dash : bool = true

var is_attack : bool = false

var is_dead : bool = false
var live : float = 105
var rage : bool = false



@onready var blood_ef_1: AnimatedSprite2D = $Blood_ef_1
@onready var blood_ef_2: AnimatedSprite2D = $Blood_ef_2

@onready var audio_hurt: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var audios_hurts : Array[AudioStream]
var last_sound: AudioStream = null

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_effect_timer: Timer = $DashEffectTimer
@onready var ray: RayCast2D = $Sist_Deteccion/Detec_Player
@onready var ar_attack: CollisionShape2D = $Area_Attck/CollisionShape2D
@onready var spawn_point: Marker2D = $SpawnPoint

@export var distance_attack_cooldown := 1.5 # segundos aprox.

var projectile_scene := preload("res://Creations/Boss/bullet_boss.tscn")

@onready var states = {
	"IdleState": $States/IdleState,
	"ChaseState": $States/ChaseState,
	"AttackState": $States/AttackState,
	"DeadState": $States/DeadState,
	"AttackDistanceState": $States/AttackDistanceState,
	"DashState" : $States/DashState 
}
#endregion variables / menciones 

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	stomp()

	#_change_state("ChaseState") # <-------- CON ESTO SE CAMBIA DE ESTADO !!!

func _physics_process(delta: float) -> void:
	if !is_dead:
		if live <= 40 and !rage:
			rage_active.emit()
		if rage:
			player.camera.add_shake(1)
			fade_to_red()


		get_player_distance()

		if !is_attack:
			rotar_sprite_marker()
			rotar_raycast()      #    FUNCIONES DE ATAQUE
			flip_area_attack()   

	apply_gravedad(delta)

	if current_state:
		current_state.update(delta)

	if can_move:
		move_and_slide()

#region Efectos DASH

func start_dash():
	dash_effect_timer.start()
	dash_duration_timer.start()

func _on_dash_duration_timer_timeout() -> void:
	dash_effect_timer.stop()

func _on_dash_effect_timer_timeout() -> void:
	create_dash_effect()

func create_dash_effect():
	var bossCopyNode = $AnimatedSprite2D.duplicate()
	get_parent().add_child(bossCopyNode)
	bossCopyNode.global_position = global_position
	
	var animationTime = dash_duration_timer.wait_time / 3
	await get_tree().create_timer(animationTime).timeout
	bossCopyNode.modulate.a = 0.4
	await get_tree().create_timer(animationTime).timeout
	bossCopyNode.modulate.a = 0.2
	await get_tree().create_timer(animationTime).timeout
	bossCopyNode.queue_free()

func hab_dash():
	await get_tree().create_timer(3).timeout
	can_dash = true

#endregion Efectos DASH

#region Func Melee
func rotar_raycast():
	if not player:
		return

	# Si el jugador está a la izquierda o a la derecha del jefe
	if player.global_position.x < global_position.x:
		# jugador a la izquierda
		ray.target_position = Vector2(-100, 0)
	else:
		# jugador a la derecha
		ray.target_position = Vector2(100, 0)

func activar_area_attack():
	await get_tree().create_timer(0.3).timeout
	ar_attack.disabled = false
	await get_tree().create_timer(0.2).timeout
	ar_attack.disabled = true

func flip_area_attack():
	if not player:
		return
	if player.global_position.x < global_position.x:
		ar_attack.position.x = -48
	else:
		ar_attack.position.x = 50
#endregion Func Melee

#region Func Globals
func _change_state(state_name: String): # <--- Funcion para cambiar de estado !!!
	if states.has(state_name):
		current_state = states[state_name]
		current_state.enter({
			"boss": self,
			"player": player,
	})

func apply_gravedad(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
#endregion Func Globals

#region Distance Attack
func start_distance_attack_cooldown():
	can_distance_attack = false
	await get_tree().create_timer(distance_attack_cooldown).timeout
	can_distance_attack = true

func get_player_distance() -> float:
	if player == null:
		return INF  # Por si el jugador no existe aún

	var distance_player: float = global_position.distance_to(player.global_position)
	return distance_player

func rotar_sprite_marker():
	if not player:
		return

	# Si el jugador está a la izquierda o a la derecha del jefe
	if player.global_position.x < global_position.x:
		# jugador a la izquierda
		$SpawnPoint.position.x = -150
		$SpawnPoint.position.y = 20
		anim.flip_h = false
		
	else:
		# jugador a la derecha
		spawn_point.position.x = 50
		anim.flip_h = true

func shoot_projectile():

	var projectile = projectile_scene.instantiate()
	projectile.global_position = spawn_point.global_position

	var dir = (player.global_position - global_position).normalized()
	projectile.direction = dir

	get_tree().current_scene.add_child(projectile)

#endregion Distance Attack

#region WARNING HIT !!
func hit(damage):
	cal_damage(damage)
	hurt_sounds()
	if !rage:
		ef_hit()

func ef_hit(duration := 0.4, interval := 0.1) -> void:
	if live >= 40 and !rage:
		var elapsed := 0.0
		while elapsed < duration:
			$AnimatedSprite2D.modulate = Color(1, 1, 1, 0.3)  # transparente
			await get_tree().create_timer(interval).timeout
			$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)    # visible
			await get_tree().create_timer(interval).timeout
			elapsed += interval * 2
		$AnimatedSprite2D.modulate = Color.WHITE

func cal_damage(damage):
	live = live - damage
	print(live)
#endregion WARNING HIT !!


func _on_dialogue_music_manajer_start_battle() -> void:
	await get_tree().create_timer(1).timeout
	_change_state("ChaseState")

func _on_area_attck_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.hit(damage)
	elif body.is_in_group("Player_Minion"):
		body.hit(damage * 3, global_position)

func fade_to_red(duration := 0.15) -> void:
	var elapsed := 0.0
	var start_color := anim.modulate
	var target_color := Color.RED

	while elapsed < duration:
		elapsed += get_process_delta_time()
		var t := elapsed / duration
		anim.modulate = start_color.lerp(target_color, t)
		await get_tree().process_frame

func var_mods():
	speed = speed * 2
	damage = damage * 2

func _on_rage_active() -> void:
	rage = true
	fade_to_red()
	var_mods()

func stomp() -> void:
	var player_camera = get_tree().get_first_node_in_group("player_camera")
	player_camera.add_shake(0.6)


func _on_player_player_dead() -> void:
	_change_state("IdleState")

func hurt_sounds():
	if audios_hurts.is_empty():
		return

	var sound = audios_hurts.pick_random()

	while sound == last_sound and audios_hurts.size() > 1:
		sound = audios_hurts.pick_random()

	last_sound = sound
	audio_hurt.stream = sound
	audio_hurt.play()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player_Minion"):
		body.hit(damage * 5 , global_position)
