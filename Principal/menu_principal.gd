extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Creations/Village_attack/game.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Creations/Menus/Options/menu_options.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
