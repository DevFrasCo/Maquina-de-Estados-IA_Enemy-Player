extends CharacterBody2D

var damage_melee : float = 0.5
@warning_ignore("narrowing_conversion")
var life : int = 3
var in_hit : bool = false
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_attack: CollisionShape2D = $Area2D/CollisionShape2D
@onready var ray_detec_att: RayCast2D = $RayCast2D
@onready var spawn_point: Marker2D = $Marker2D

@onready var states = {
	"IdleState": $States/IdleState,
	"ChaseState": $States/ChaseState,
	"AttackSwordState": $States/AttackSwordState,
	"DeadState": $States/DeadState,
	"HitState" : $States/HitState,
	"AttackDistanceState" :$States/AttackDistanceState
}

var projectile_scene := preload("res://Creations/minions/human_soldier/Bullet_Arrow.tscn")

@export var distance_attack_cooldown := 5 # segundos aprox.
var can_distance_attack : bool = true
var is_dead : bool = false
var can_attack : bool = true
var gravity : float = 900
var speed : int = 100
var player = null
var current_state
var can_move : bool = true
var _last_hit_position: Vector2


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Boss")
	if player == null:
		_change_state("IdleState")
	else:
		_change_state("ChaseState") # <-------- CON ESTO SE CAMBIA DE ESTADO !!!

func _physics_process(delta: float) -> void:
	
	if current_state:
		current_state.update(delta)

	if !is_dead and !in_hit:
		look_player()
		flih_area_attack()
		apply_gravedad(delta)

	move_and_slide()

func look_player():
	if player.global_position.x < global_position.x:
		anim.flip_h = true
	else:
		anim.flip_h = false

func apply_gravedad(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

func _change_state(state_name: String): # <--- Funcion para cambiar de estado !!!
	if states.has(state_name):
		current_state = states[state_name]
		current_state.enter({
			"player": player,
			"minion": self,
			#current_state.enter({ "minion": self }),

	})

func get_player_distance() -> float:
	if not player:
		return INF
	return global_position.distance_to(player.global_position)

func hit(damage: float, from_position: Vector2):
	if !is_dead:
		life = life - damage
		_last_hit_position = from_position
	if life <= 0:
		$CollisionShape2D.queue_free()
		is_dead = true
		_change_state("DeadState")
	else:
		in_hit = true
		_change_state("HitState")

func apply_knockback(from_position: Vector2, force: float, lift: float ):
	var dir = global_position - from_position
	dir = dir.normalized()

	# Empuje horizontal
	velocity.x = dir.x * force

	# Impulso vertical hacia arriba
	velocity.y = -lift

func flih_area_attack():
	if player.global_position.x < global_position.x:
		ray_detec_att.target_position = Vector2(-30, 0)
		area_attack.position.x = -21
	else:
		ray_detec_att.target_position = Vector2(30, 0)
		area_attack.position.x = 19

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Boss_Minion"):
		body.hit(damage_melee , global_position)
	if body.is_in_group("Boss"):
		body.hit(damage_melee)


func shoot_projectile():

	var projectile = projectile_scene.instantiate()
	projectile.global_position = spawn_point.global_position

	var dir = (player.global_position - global_position).normalized()
	projectile.direction = dir

	get_tree().current_scene.add_child(projectile)

func start_distance_attack_cooldown():
	can_distance_attack = false
	await get_tree().create_timer(distance_attack_cooldown).timeout
	can_distance_attack = true
