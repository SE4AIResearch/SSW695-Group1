extends Node2D

var resumePaused: bool
var currentMenu: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resume_pressed() -> void:
	get_tree().paused = false
	self.visible = false
	match resumePaused:
		true: get_tree().paused = true
		false: get_tree().paused = false
	pass


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MainMenu/MainMenu.tscn")
	pass


func _on_learning_centerbutton_pressed() -> void:
	currentMenu = $LearningCenter
	currentMenu.visible = true
	$Menu.visible = false
	$Back.visible = true
	pass


func _on_settings_button_pressed() -> void:
	currentMenu = $Settings
	currentMenu.visible = true
	$Menu.visible = false
	$Back.visible = true
	pass


func _on_back_pressed() -> void:
	currentMenu.visible = false
	$Menu.visible = true
	$Back.visible = false
	pass
