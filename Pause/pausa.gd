extends CanvasLayer

@onready var menu: ColorRect = $ColorRect
@onready var text_pause: Label = $Control/VBoxContainer/Pause
@onready var button_back_menu: Button = $Control/VBoxContainer/Back_Menu

var menu_visible := false
func _ready():
	get_tree().paused = false
	menu_visible = false
	_set_menu_visible(false)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pausa"):
		if menu_visible:
			resume_game()
		else:
			pause_game()

func activar_visibilidad():
	button_back_menu.visible = not button_back_menu.visible
	get_tree().paused = not get_tree().paused
	menu.visible = not menu.visible
	text_pause.visible = not text_pause.visible

func resume_game():
	menu_visible = false
	get_tree().paused = false
	_set_menu_visible(false)


func pause_game():
	menu_visible = true
	get_tree().paused = true
	_set_menu_visible(true)
	

func _set_menu_visible(visible: bool):
	menu.visible = visible
	text_pause.visible = visible
	button_back_menu.visible = visible

func _on_back_menu_pressed() -> void:
	get_tree().paused = false
	menu_visible = false
	get_tree().change_scene_to_file("res://Creations/Menus/Principal/menu_principal.tscn")
