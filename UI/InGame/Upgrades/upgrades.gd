extends Node2D

func _on_close_button_pressed() -> void:
	get_parent().get_parent().endMenu()
