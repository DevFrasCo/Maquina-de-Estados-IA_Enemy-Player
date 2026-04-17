extends Control




func _on_button_back_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Creations/Menus/Principal/menu_principal.tscn")


func _on_button_reset_pressed() -> void:
	get_tree().change_scene_to_file("res://Creations/Village_attack/game.tscn")
