extends CanvasLayer
var currentMenu: Node

var UpgradesMenu = load("res://UI/InGame/Upgrades/Upgrades.tscn")
var ProjectMetricsMenu = load("res://UI/InGame/ProjectMetrics/ProjectMetrics.tscn")
var HiringMenu = load("res://UI/InGame/Hiring/Hiring.tscn")
var BacklogMenu = load("res://UI/InGame/Backlog/Backlog.tscn")
var ProjectSetupMenu = load("res://UI/InGame/ProjectSetup/ProjectSetup.tscn")

func _physics_process(delta: float) -> void:
	getCurrentProjStats()

func getCurrentProjStats():
	
	pass

func _on_pause_button_pressed() -> void:
	match get_tree().paused:
		true: $Pause.resumePaused = true
		false: $Pause.resumePaused = false
	get_tree().paused = true
	$Pause.visible = true
	pass

func _on_back_button_pressed() -> void:
	currentMenu.queue_free()
	$BackButton.visible = false
	get_tree().paused = false
	pass

func _on_upgrades_button_pressed() -> void: createMenu(UpgradesMenu)

func _on_project_metrics_button_pressed() -> void: createMenu(ProjectMetricsMenu)

func _on_hiring_button_pressed() -> void: createMenu(HiringMenu)

func _on_backlog_button_pressed() -> void: createMenu(BacklogMenu)

func _on_project_start_menu_pressed() -> void: createMenu(ProjectSetupMenu)

func createMenu(NewMenu):
	var menu = NewMenu.instantiate()
	$NewMenu.add_child(menu)
	currentMenu = menu
	get_tree().paused = true
	currentMenu.visible = true
	$BackButton.visible = true

