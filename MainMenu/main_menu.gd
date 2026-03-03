extends Node2D

var currentMenu: Node


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_game_button_pressed() -> void:
	TimeTool.inGame = true
	get_tree().change_scene_to_file("res://Level/mainLevel.tscn")
	pass


func _on_load_data_button_pressed() -> void:
	$UI/Back.visible = true
	currentMenu = $UI/Load
	$UI/MainButtons.visible = false
	$UI/Load.visible = true
	pass


func _on_settings_button_pressed() -> void:
	$UI/Back.visible = true
	currentMenu = $UI/Settings
	$UI/MainButtons.visible = false
	$UI/Settings.visible = true
	pass


func _on_learning_center_button_pressed() -> void:
	$UI/Back.visible = true
	currentMenu = $UI/LearningCenter
	$UI/MainButtons.visible = false
	$UI/LearningCenter.visible = true
	pass


func _on_quit_button_pressed() -> void:
	get_tree().quit()
	pass


func _on_back_pressed() -> void:
	currentMenu.visible = false
	$UI/Back.visible = false
	$UI/MainButtons.visible = true
	pass
