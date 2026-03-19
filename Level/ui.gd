extends CanvasLayer
var currentMenu: Node

var UpgradesMenu = load("res://UI/InGame/Upgrades/Upgrades.tscn")
var ProjectMetricsMenu = load("res://UI/InGame/ProjectMetrics/ProjectMetrics.tscn")
var HiringMenu = load("res://UI/InGame/Hiring/Hiring.tscn")
var BacklogMenu = load("res://UI/InGame/Backlog/Backlog.tscn")
var ProjectSetupMenu = load("res://UI/InGame/ProjectSetup/ProjectSetup.tscn")
var randomEventMenu = load("res://UI/InGame/RandomEvent/RandomEvent.tscn")

var basePCScreenSize = Vector2(1.312,1.208)
var basePCScreenPos = Vector2(958,466)
var inUsePCScreenSize = Vector2(4.5,4.5)
var inUsePCScreenPos = Vector2(576,324)

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

func _on_random_event_button_pressed() -> void: createMenu(randomEventMenu.instantiate())

func createMenu(menu):
	$NewMenu.add_child(menu)
	currentMenu = menu
	get_tree().paused = true
	currentMenu.visible = true
	$BackButton.visible = true

func _on_pc_pressed() -> void:
	#Insert code of screen lerping in size and position to the middle of the screen
	#and showing the PC Buttons when completed
	
	pass

func toggleProjectButtons():
	match PlayerTool.currentProject == null:
		false:
			$PCButtons/ProjectMetricsButton.disabled = false
			$BacklogButton.disabled = false
		true:
			$PCButtons/ProjectMetricsButton.disabled = true
			$BacklogButton.disabled = true
