extends ParallaxBackground

var velocidad : int = 20
const DIALOGUE_FINAL = preload("res://Creations/dialogues/dialogue_final.dialogue")
var can_skip : bool = false

@onready var anim_text: AnimationPlayer = $"../CanvasLayer/Control/AnimationPlayer"

func  _ready() -> void:
	DialogueManager.show_dialogue_balloon(DIALOGUE_FINAL)
	DialogueManager.dialogue_ended.connect(finish_dialogue)

func _process(delta: float) -> void:
	scroll_offset.x -= velocidad * delta
	if can_skip and Input.is_action_just_pressed("Pausa"):
		get_tree().change_scene_to_file("res://Creations/Menus/Principal/menu_principal.tscn")

func finish_dialogue(_dialogue_resource):
	anim_text.play("text")
	await get_tree().create_timer(3).timeout
	can_skip = true
