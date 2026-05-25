extends Node2D

var resumePaused: bool
var currentMenu: Node
var tutorials_reset_pending: bool = false
signal resumeSignal
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not $LearningCenter.close_requested.is_connected(_on_learning_center_close_requested):
		$LearningCenter.close_requested.connect(_on_learning_center_close_requested)
	if $LearningCenter.has_signal("tutorials_reset_requested") and not $LearningCenter.tutorials_reset_requested.is_connected(_on_tutorials_reset_requested):
		$LearningCenter.tutorials_reset_requested.connect(_on_tutorials_reset_requested)
	if not $Settings.close_requested.is_connected(_on_settings_close_requested):
		$Settings.close_requested.connect(_on_settings_close_requested)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_tree_paused(paused: bool) -> void:
	var tree := get_tree()
	if tree != null:
		tree.paused = paused


func _on_resume_pressed() -> void:
	resumeSignal.emit()
	_set_tree_paused(false)
	self.visible = false
	match resumePaused:
		true: _set_tree_paused(true)
		false: _set_tree_paused(false)
	pass


func _on_quit_pressed() -> void:
	TimeTool.reset()
	var tree := get_tree()
	if tree != null:
		tree.paused = false
		tree.change_scene_to_file("res://MainMenu/MainMenu.tscn")
	SaveTool.savePlayerData()
	PlayerTool.resetData()
	pass


func _on_learning_centerbutton_pressed() -> void:
	currentMenu = $LearningCenter
	if currentMenu.has_method("reset_state"):
		currentMenu.reset_state()
	currentMenu.visible = true
	$Menu.visible = false
	$Back.visible = false


func _on_settings_button_pressed() -> void:
	currentMenu = $Settings
	currentMenu.visible = true
	$Menu.visible = false
	$Back.visible = false
	pass


func _on_back_pressed() -> void:
	currentMenu.visible = false
	$Menu.visible = true
	$Back.visible = false
	pass

func _on_learning_center_close_requested(close_all: bool) -> void:
	$LearningCenter.visible = false
	if tutorials_reset_pending:
		tutorials_reset_pending = false
		currentMenu = null
		$Menu.visible = true
		$Back.visible = false
		resumeSignal.emit()
		_set_tree_paused(false)
		self.visible = false
		var ui = get_parent()
		if ui != null and ui.has_method("show_office_intro_tutorial"):
			ui.call_deferred("show_office_intro_tutorial")
		return
	$Menu.visible = true
	$Back.visible = false
	currentMenu = null
	if close_all:
		_on_resume_pressed()

func _on_tutorials_reset_requested() -> void:
	tutorials_reset_pending = true

func _on_settings_close_requested() -> void:
	$Settings.visible = false
	$Menu.visible = true
	$Back.visible = false
	currentMenu = null
