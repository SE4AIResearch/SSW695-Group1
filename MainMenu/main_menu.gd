extends Node2D

var currentMenu: Node

var postIt1Sprites = ["res://UI/Theme/MainMenu/postIt.png","res://UI/Theme/MainMenu/postItHover.png","res://UI/Theme/MainMenu/postItSelect.png"]
var postIt2Sprites = ["res://UI/Theme/MainMenu/postIt2.png","res://UI/Theme/MainMenu/postIt2Hover.png","res://UI/Theme/MainMenu/postIt2Select.png"]

func _process(delta: float) -> void: pass

func _enter_tree() -> void:
	setButtonVisual($UI/MainButtons/newGameButton)
	setButtonVisual($UI/MainButtons/loadDataButton)
	setButtonVisual($UI/MainButtons/settingsButton)
	setButtonVisual($UI/MainButtons/learningCenterButton)
	setButtonVisual($UI/MainButtons/QuitButton)
	pass

func _on_new_game_button_pressed() -> void:
	TimeTool.inGame = true
	get_tree().change_scene_to_file("res://Level/mainLevel.tscn")
	pass

func setupMenu(menu):
	$UI/Back.visible = true
	currentMenu = menu
	menu.visible = true
	$UI/MainButtons.visible = false
	$UI/Settings.visible = true
	$Logo.visible = false
	pass

func _on_load_data_button_pressed() -> void:setupMenu($UI/Load)
func _on_settings_button_pressed() -> void:setupMenu($UI/Settings)
func _on_learning_center_button_pressed() -> void:setupMenu($UI/LearningCenter)
func _on_quit_button_pressed() -> void: get_tree().quit()
	
func _on_back_pressed() -> void:
	currentMenu.visible = false
	$UI/Back.visible = false
	$UI/MainButtons.visible = true
	$Logo.visible = true
	pass

func setButtonVisual(menuButton: Button):
	var textureSet
	match randi_range(0,1):
		0: textureSet = postIt1Sprites
		1: textureSet = postIt2Sprites
	var normalStylebox = StyleBoxTexture.new()
	normalStylebox.texture = load(textureSet[0])
	var hoverStylebox = StyleBoxTexture.new()
	hoverStylebox.texture = load(textureSet[1])
	var pressedStylebox = StyleBoxTexture.new()
	pressedStylebox.texture = load(textureSet[2])
	
	hoverStylebox.texture = load(textureSet[1])
	menuButton.add_theme_stylebox_override("normal",normalStylebox)
	menuButton.add_theme_stylebox_override("hover",hoverStylebox)
	menuButton.add_theme_stylebox_override("pressed",pressedStylebox)
	menuButton.self_modulate = Color(randf_range(.5,1),randf_range(.5,1),randf_range(.5,1))
	pass
