extends Node2D

const DEFAULT_BACK_RECT := Rect2(1033.0, 529.0, 64.0, 64.0)
const LEARNING_CENTER_BACK_RECT := Rect2(1069.0, 155.0, 64.0, 64.0)

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

func _ready() -> void:
	if not $UI/LearningCenter.close_requested.is_connected(_on_learning_center_close_requested):
		$UI/LearningCenter.close_requested.connect(_on_learning_center_close_requested)
	AudioManager.play_music("main_menu")

func _on_new_game_button_pressed() -> void:
	AudioManager.play_sfx("paper_rustle")
	var saves = SaveTool.get_save_list()
	var new_name = "playerSave"
	var counter = 1
	if not SaveTool.should_reuse_default_new_game_slot():
		while new_name in saves:
			new_name = "playerSave_" + str(counter)
			counter += 1
	
	SaveTool.create_new_save(new_name)
	get_tree().change_scene_to_file("res://Level/mainLevel.tscn")

func setupMenu(menu):
	_position_back_button(menu)
	$UI/Back.visible = true
	currentMenu = menu
	menu.visible = true
	$UI/MainButtons.visible = false
	$Logo.visible = false
	pass

func _on_load_data_button_pressed() -> void:
	AudioManager.play_sfx("paper_rustle")
	setupMenu($UI/Load)

func _on_settings_button_pressed() -> void:
	AudioManager.play_sfx("paper_rustle")
	setupMenu($UI/Settings)

func _on_learning_center_button_pressed() -> void:
	AudioManager.play_sfx("paper_rustle")
	currentMenu = $UI/LearningCenter
	if currentMenu.has_method("reset_state"):
		currentMenu.reset_state()
	currentMenu.visible = true
	$UI/Back.visible = false
	$UI/MainButtons.visible = false
	$Logo.visible = false

func _on_quit_button_pressed() -> void:
	AudioManager.play_sfx("paper_rustle")
	get_tree().quit()

func _on_back_pressed() -> void:
	AudioManager.play_sfx("paper_rustle")
	currentMenu.visible = false
	$UI/Back.visible = false
	_position_back_button(null)
	$UI/MainButtons.visible = true
	$Logo.visible = true
	pass

func _position_back_button(menu) -> void:
	var target_rect: Rect2 = LEARNING_CENTER_BACK_RECT if menu == $UI/LearningCenter else DEFAULT_BACK_RECT
	$UI/Back.offset_left = target_rect.position.x
	$UI/Back.offset_top = target_rect.position.y
	$UI/Back.offset_right = target_rect.position.x + target_rect.size.x
	$UI/Back.offset_bottom = target_rect.position.y + target_rect.size.y

func _on_learning_center_close_requested() -> void:
	$UI/LearningCenter.visible = false
	$UI/Back.visible = false
	_position_back_button(null)
	$UI/MainButtons.visible = true
	$Logo.visible = true
	currentMenu = null

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
