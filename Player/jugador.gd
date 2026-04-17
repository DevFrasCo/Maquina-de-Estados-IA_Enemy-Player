extends CharacterBody2D

signal player_dead

# === ATAQUE ===
var damage_slide : float = 1
var damage : float = 1.5
@export var attack_cooldown := 0.1
@export var attack_knockback := 300.0
@export var attack_hit_pushback := 200.0  # Retroceso si impacta durante dash

var is_attacking := false
var can_attack := true
var current_attack := 1  # Alterna entre 1 y 2
@onready var attack_col: CollisionShape2D = $Area_Attck/CollisionShape2D

@onready var audio_jump: AudioStreamPlayer2D = $AudioStreamPlayer_Jump
@onready var audio_hurt: AudioStreamPlayer2D = $AudioStreamPlayer_Hurt



@export var audios_hurts : Array[AudioStream]
@export var audios_jumps : Array[AudioStream]
var last_sound: AudioStream = null



@onready var hear_empety: Sprite2D = $"UI/Control-Player/Hear_empety"
@onready var health_bar: TextureProgressBar = $"UI/Control-Player/HealthBar_Player"
var max_bar_hp := 4
var bar_hp := 4

var heart_hp := 1
var is_dead := false


# --- CONFIGURACIÓN DE MOVIMIENTO ---
@export var speed: float = 180.0
@export var jump_force: float = 300.0
@export var gravity: float = 920.0
@export var max_jumps: int = 2


# --- DASH CONFIGURACIÓN ---
@export var dash_speed: float = 850.0        # Velocidad del impulso del dash
@export var dash_duration: float = 0.2       # Duración del dash en segundos
@export var dash_cooldown: float = 0.5  # Tiempo antes de poder volver a hacer dash

# --- ESTADO DEL DASH ---
var is_dashing: bool = false                 # Indica si el jugador está en medio de un dash
var can_dash: bool = true                    # Controla si el dash está disponible o en cooldown


# --- REFERENCIAS ---
@onready var col_dash: CollisionShape2D = $Area_attack_dash/CollisionShape2D
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var camera: Camera2D = $Camera2D



# --- ESTADO DEL JUGADOR ---
var jumps_done: int = 0
var facing_right: bool = true
var is_falling: bool = false
var is_jumping: bool = false
var input_enabled := true

func _ready() -> void:
	pass

# --- LOOP PRINCIPAL ---
func _physics_process(delta: float) -> void:

	if input_enabled:
		# Input
		if not is_dashing and not is_attacking:
			_handle_input()
			_handle_jump_input()  # Debe ir antes de aplicar la gravedad

		# Acciones
		_handle_attack_input()
		comprobacion_dash()
		move_colision()
	
	# Movimiento
	_move_player()
	
	# Gravedad
	if not is_on_floor():
		_apply_gravity(delta)
	if is_on_floor():
		jumps_done = 0 # Reset de saltos al tocar suelo
	
	if !is_dead:
		# Estados / animaciones
		_update_state()
		_update_animation()

# --- ENTRADAS DEL JUGADOR ---
func _handle_jump_input():
	if Input.is_action_just_pressed("Jump") and jumps_done < max_jumps:
		_perform_jump()
		jump_sounds()

func _handle_input() -> void:
	var input_dir = Input.get_axis("Left", "Right")
	velocity.x = input_dir * speed

	if Input.is_action_just_pressed("Roll") and can_dash:
			_perform_dash()

func _handle_attack_input() -> void:
	if not can_attack or is_attacking:
		return

	if Input.is_action_just_pressed("Attack"):
		_perform_attack()

# --- APLICAR GRAVEDAD ---
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

# --- REALIZAR SALTO ---
func _perform_jump() -> void:
	velocity.y = -jump_force
	jumps_done += 1
	is_jumping = true
	is_falling = false

# --- MOVER PERSONAJE ---
func _move_player() -> void:
	move_and_slide()

	# Volteo del sprite según dirección
	if velocity.x != 0:
		facing_right = velocity.x > 0
		anim_sprite.flip_h = not facing_right

# --- ACTUALIZAR ESTADOS ---
func _update_state() -> void:
	if not is_on_floor():
		is_falling = velocity.y > 0
	else:
		is_falling = false
		is_jumping = false

# --- CONTROL DE ANIMACIONES ---
func _update_animation() -> void:
	
	if is_attacking:
		return

	if is_dashing:
		if is_on_floor():
			anim_sprite.play("slide")
		else:
			anim_sprite.play("dash")
		return

	if is_jumping and not is_falling:
		anim_sprite.play("jump")
	elif is_falling:
		anim_sprite.play("fall")
	elif velocity.x != 0:
		anim_sprite.play("run")
	else:
		anim_sprite.play("idle")

#--- REPOCISIONAR COLISION ---#
func move_colision():
	if anim_sprite.flip_h == true:
		collision.position.x = 4.65
		attack_col.position.x = -14
		col_dash.position.x = -5
	else:
		collision.position.x = -4.65
		attack_col.position.x = 14
		col_dash.position.x = 5

# --- DASH --- #
func _perform_dash() -> void:
	is_dashing = true
	can_dash = false

	# Determina dirección (según hacia dónde mira el jugador)
	var dir: int
	if facing_right:
		dir = 1
	else:
		dir = -1

	velocity = Vector2(dash_speed * dir, 0)

	# Selecciona animación según estado (suelo o aire)
	if is_on_floor():
		anim_sprite.play("slide")
	else:
		anim_sprite.play("dash")
	
	# Desactivar la gravedad temporalmente
	var original_gravity = gravity
	gravity = 0
	
	# Mantiener dash por un tiempo fijo
	await get_tree().create_timer(dash_duration).timeout

	# Termina el dash
	is_dashing = false
	gravity = original_gravity
	velocity = Vector2.ZERO

	# Inicia el cooldown
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

func comprobacion_dash():
	if is_dashing and !is_jumping:
		col_dash.disabled = false
	else:
		col_dash.disabled = true

func _on_area_attack_dash_body_entered(body: Node2D) -> void:
	if body.is_in_group("Boss_Minion"):
		body.hit(damage_slide, global_position)
	
	if body.is_in_group("Boss"):
		body.hit(damage_slide)

	elif body.is_in_group("obj"):
		body.hit(damage_slide)
		body._apply_knockback(facing_right)


func _perform_attack() -> void:
	is_attacking = true
	can_attack = false

	# Cancela movimiento (excepto si está dashing)
	if not is_dashing:
		velocity = Vector2.ZERO

	# Activa la hitbox temporalmente
	attack_col.disabled = false

	if !is_on_floor():
		anim_sprite.play("attack_dash")
	
	if is_on_floor():
		if current_attack == 1:
			anim_sprite.play("attack_2")
			current_attack = 2
		else:
			anim_sprite.play("attack_2")
			current_attack = 1

	# Espera a que termine la animación
	await anim_sprite.animation_finished

	# Desactiva la hitbox
	attack_col.disabled = true
	
	is_attacking = false

	# Cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func facing_direction() -> int:
	if facing_right:
		return 1
	else:
		return -1

func _on_area_attck_body_entered(body: Node2D) -> void:
	if body.is_in_group("Boss_Minion"):
		body.hit(damage, global_position)
	if body.is_in_group("Boss"):
		if is_falling:
			body.hit(damage * 2 )
		else:
			body.hit(damage)
	elif body.is_in_group("obj"):
		body.hit(damage)
		body._apply_knockback(facing_right)

func force_idle(is_dead):
	if is_dead:
		anim_sprite.play("dead")
	else:
		anim_sprite.play("idle")
	velocity = Vector2.ZERO


#region SALUD PLAYER

func dead():
	player_dead.emit()
	input_enabled = false
	is_dead = true
	force_idle(is_dead)
	

func hit(damage):
	ef_hit()
	hurt_sounds()
	cal_damage_received(damage)


func cal_damage_received(damage: int) -> void:
	if is_dead:
		return

	if bar_hp > 0:
		bar_hp -= damage
		bar_hp = max(bar_hp, 0)
		update_health_bar()
		return

	if heart_hp > 0:
		heart_hp -= damage
		update_heart()
		dead()

func update_health_bar() -> void:
	health_bar.max_value = max_bar_hp
	health_bar.value = bar_hp

func update_heart() -> void:
	hear_empety.visible = true


func ef_hit(duration := 0.4, interval := 0.1) -> void:
	camera.add_shake(1)
	var elapsed := 0.0
	while elapsed < duration:
		$AnimatedSprite2D.modulate = Color(1, 1, 1, 0.3)  # transparente
		await get_tree().create_timer(interval).timeout
		$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)    # visible
		await get_tree().create_timer(interval).timeout
		elapsed += interval * 2
	$AnimatedSprite2D.modulate = Color.WHITE

#endregion SALUD PLAYER

func hurt_sounds():
	if audios_hurts.is_empty():
		return

	var sound = audios_hurts.pick_random()

	while sound == last_sound and audios_hurts.size() > 1:
		sound = audios_hurts.pick_random()

	last_sound = sound
	audio_hurt.stream = sound
	audio_hurt.play()

func jump_sounds():
	if audios_jumps.is_empty():
		return

	var sound = audios_jumps.pick_random()

	while sound == last_sound and audios_jumps.size() > 1:
		sound = audios_jumps.pick_random()

	last_sound = sound
	audio_jump.stream = sound
	audio_jump.play()
