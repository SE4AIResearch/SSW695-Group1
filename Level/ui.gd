extends CanvasLayer
var currentMenu: Node

var UpgradesMenu = load("res://UI/InGame/Upgrades/Upgrades.tscn")
var ProjectMetricsMenu = load("res://UI/InGame/ProjectMetrics/ProjectMetrics.tscn")
var HiringMenu = load("res://UI/InGame/Hiring/Hiring.tscn")
var BacklogMenu = load("res://UI/InGame/Backlog/Backlog.tscn")
var ProjectSetupMenu = load("res://UI/InGame/ProjectSetup/ProjectSetup.tscn")
var randomEventMenu = load("res://UI/InGame/RandomEvent/RandomEvent.tscn")
var workerScene = preload("res://Person/Worker/Worker.tscn")

var pcMode = false
var deskWorker: Node2D

const DESK_WORKER_POSITION := Vector2(225, 375)
const DESK_WORKER_SCALE := Vector2(4.5, 4.5)
const DESK_WORKER_Z_INDEX := 0

func _ready() -> void:
	PlayerTool.connect("projectSelected",toggleProjectButtons)
	PlayerTool.connect("projectFinished",toggleProjectButtons)
	createDeskWorker()
	toggleProjectButtons()

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

func _on_back_button_pressed() -> void: endMenu()
func _on_pc_back_pressed() -> void: endMenu()

func endMenu():
	currentMenu.queue_free()
	match pcMode:
		true:
			$PCButtons/PCBack.disabled = true
			$PCButtons/UpgradesButton.disabled = false
			$PCButtons/HiringButton.disabled = false
			$PCButtons/projectStartMenu.disabled = false
		false:
			$BackButton.visible = false
			get_tree().paused = false
	

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
	match pcMode:
		true: 
			$PCButtons/PCBack.disabled = false
			$PCButtons/UpgradesButton.disabled = true
			$PCButtons/HiringButton.disabled = true
			$PCButtons/projectStartMenu.disabled = true
		false: $BackButton.visible = true

func _on_pc_pressed() -> void:
	#Insert code of screen lerping in size and position to the middle of the screen
	#and showing the PC Buttons when completed
	pcMode = true
	$PCButtons/PCBack.disabled = true
	get_tree().paused = true
	$Stats.visible = false
	$PCScreen.visible = true
	$PCScreenPanel.visible = true	
	$PCButtons.visible = true
	
func _on_pc_power_pressed() -> void:
	#Insert code of screen lerping in size and position to the original PC location and render buttons invisible
	pcMode = false
	get_tree().paused = false
	$Stats.visible = true
	$PCScreen.visible = false
	$PCScreenPanel.visible = false
	$PCButtons.visible = false
	$PCButtons/PCBack.disabled = true
	$PCButtons/UpgradesButton.disabled = false
	$PCButtons/HiringButton.disabled = false
	$PCButtons/projectStartMenu.disabled = false
	if $NewMenu.get_children().size() > 0: $NewMenu.get_child(0).queue_free()
	pass

func createDeskWorker() -> void:
	deskWorker = workerScene.instantiate()
	deskWorker.personName = PersonConstructor.generateName()
	PersonConstructor.generateVisuals(deskWorker)
	PersonConstructor.generateWorkerStats(deskWorker)
	deskWorker.position = DESK_WORKER_POSITION
	deskWorker.scale = DESK_WORKER_SCALE
	deskWorker.z_index = DESK_WORKER_Z_INDEX
	deskWorker.visible = false
	add_child(deskWorker)
	move_child(deskWorker, $DeskLaptopOpen.get_index())

func toggleProjectButtons():
	var hasProject = PlayerTool.currentProject != null
	$BacklogButton.disabled = !hasProject
	$DeskLaptopOpen.visible = hasProject
	if deskWorker != null:
		deskWorker.visible = hasProject
