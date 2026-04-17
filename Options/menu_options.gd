extends Control

@onready var volume_slider: HSlider = $VBoxContainer/HSlider

func _ready() -> void:
	# Sincroniza la barra con el volumen real del juego
	volume_slider.value = AudioSettings.master_volume_db


func _on_volume_slider_value_changed(value: float) -> void:
	# Guardamos el nuevo valor
	AudioSettings.master_volume_db = value

	# Aplicamos el volumen al bus master
	AudioServer.set_bus_volume_db(0, value)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://Creations/Menus/Principal/menu_principal.tscn"
	)
