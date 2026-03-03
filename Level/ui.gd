extends CanvasLayer
var currentMenu: Node

var UpgradesMenu = load("res://UI/InGame/Upgrades/Upgrades.tscn")
var ProjectMetricsMenu = load("res://UI/InGame/ProjectMetrics/ProjectMetrics.tscn")
var HiringMenu = load("res://UI/InGame/Hiring/Hiring.tscn")
var BacklogMenu = load("res://UI/InGame/Backlog/Backlog.tscn")
var ProjectSetupMenu = load("res://UI/InGame/ProjectSetup/ProjectSetup.tscn")

func _ready() -> void:
	PlayerTool.connect("projectSelected",toggleProjectButtons)
	PlayerTool.connect("projectFinished",toggleProjectButtons)
	pass

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

func _on_upgrades_button_pressed() -> void: createMenu(UpgradesMenu.instantiate())

func _on_project_metrics_button_pressed() -> void:
	var metricsMenu = ProjectMetricsMenu.instantiate()
	metricsMenu.getCurrentMetrics(PlayerTool.currentProject,PlayerTool.currentMetrics)
	createMenu(metricsMenu)

func _on_hiring_button_pressed() -> void: createMenu(HiringMenu.instantiate())

func _on_backlog_button_pressed() -> void: createMenu(BacklogMenu.instantiate())

func _on_project_start_menu_pressed() -> void: createMenu(ProjectSetupMenu.instantiate())

func createMenu(menu):
	$NewMenu.add_child(menu)
	currentMenu = menu
	get_tree().paused = true
	currentMenu.visible = true
	$BackButton.visible = true

func toggleProjectButtons():
	match PlayerTool.currentProject == null:
		false:
			$ProjectMetricsButton.disabled = false
			$BacklogButton.disabled = false
		true:
			$ProjectMetricsButton.disabled = true
			$BacklogButton.disabled = true
