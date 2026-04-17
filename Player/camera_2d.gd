extends Camera2D

@export var trauma_decay := 6.0
@export var max_offset := Vector2(12, 12)

var trauma := 1.0
var noise := FastNoiseLite.new()
var noise_index := 0.0

func _ready() -> void:
	noise.seed = randi()
	noise.frequency = 20.0

func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = max(trauma - trauma_decay * delta, 0.0)

		var shake := trauma * trauma
		noise_index += delta * 30.0

		offset.x = noise.get_noise_1d(noise_index) * max_offset.x * shake
		offset.y = noise.get_noise_1d(noise_index + 100.0) * max_offset.y * shake
	else:
		offset = Vector2.ZERO

func add_shake(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)
