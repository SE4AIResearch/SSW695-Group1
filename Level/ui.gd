extends CanvasLayer
var currentMenu: Node

var UpgradesMenu = load("res://UI/InGame/Upgrades/Upgrades.tscn")
var ProjectMetricsMenu = load("res://UI/InGame/ProjectMetrics/ProjectMetrics.tscn")
var HiringMenu = load("res://UI/InGame/Hiring/Hiring.tscn")
var BacklogMenu = load("res://UI/InGame/Backlog/Backlog.tscn")
var ProjectSetupMenu = load("res://UI/InGame/ProjectSetup/ProjectSetup.tscn")
var randomEventMenu = load("res://UI/InGame/RandomEvent/RandomEvent.tscn")
var projectCompletionMenu = load("res://UI/InGame/ProjectCompletion/ProjectCompletion.tscn")
var pcMode = false



func _ready() -> void:
	PlayerTool.connect("projectSelected",toggleProjectButtons)
	PlayerTool.connect("deadlineReached",toggleProjectButtons)
	toggleProjectButtons()
	PlayerTool.projectCompleted.connect(runProjectCompletion)
	
func _physics_process(delta: float) -> void: pass

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
	if currentMenu != null and is_instance_valid(currentMenu):
		currentMenu.queue_free()
	currentMenu = null
	match pcMode:
		true:
			$PCButtons.visible = true
			$PCButtons/UpgradesButton.disabled = false
			$PCButtons/HiringButton.disabled = false
			var hasProject = PlayerTool.project != null
			$PCButtons/projectStartMenu.text = "Already have a Project" if hasProject else "Start New Project"
			$PCButtons/projectStartMenu.disabled = hasProject
		false:
			$BackButton.visible = false
			get_tree().paused = false

func newProject():
	endMenu()
	_on_pc_power_pressed()
	createMenu(BacklogMenu.instantiate())

func _on_upgrades_button_pressed() -> void: createMenu(UpgradesMenu.instantiate())

func _on_project_metrics_button_pressed() -> void:
	var metricsMenu = ProjectMetricsMenu.instantiate()
	metricsMenu.getCurrentMetrics(PlayerTool.project, PlayerTool.metrics)
	createMenu(metricsMenu)

func _on_hiring_button_pressed() -> void: createMenu(HiringMenu.instantiate())

func _on_backlog_button_pressed() -> void: createMenu(BacklogMenu.instantiate())

func _on_project_start_menu_pressed() -> void: createMenu(ProjectSetupMenu.instantiate())

func _on_random_event_button_pressed() -> void: createMenu(randomEventMenu.instantiate())

func createMenu(menu):
	if currentMenu != null and is_instance_valid(currentMenu):
		currentMenu.queue_free()
	$NewMenu.add_child(menu)
	currentMenu = menu
	get_tree().paused = true
	currentMenu.visible = true
	match pcMode:
		true: 
			$PCButtons.visible = false
			$PCButtons/UpgradesButton.disabled = true
			$PCButtons/HiringButton.disabled = true
			$PCButtons/projectStartMenu.disabled = true
		false: $BackButton.visible = true

func _on_pc_pressed() -> void:
	#Insert code of screen lerping in size and position to the middle of the screen
	#and showing the PC Buttons when completed
	pcMode = true
	get_tree().paused = true
	$PCStats.visible = false
	$PCScreen.visible = true
	$PCScreenPanel.visible = true	
	$PCButtons.visible = true
	match PlayerTool.project == null:
		true:
			$PCButtons/projectStartMenu.text = "Start New Project"
			$PCButtons/projectStartMenu.disabled = false
			pass
		false:
			$PCButtons/projectStartMenu.text = "Already have a Project"
			$PCButtons/projectStartMenu.disabled = true		
			pass
	
func _on_pc_power_pressed() -> void:
	#Insert code of screen lerping in size and position to the original PC location and render buttons invisible
	pcMode = false
	get_tree().paused = false
	$PCStats.visible = true
	$PCScreen.visible = false
	$PCScreenPanel.visible = false
	$PCButtons.visible = false
	$PCButtons/UpgradesButton.disabled = false
	$PCButtons/HiringButton.disabled = false
	$PCButtons/projectStartMenu.disabled = false
	if $NewMenu.get_children().size() > 0: $NewMenu.get_child(0).queue_free()
	pass

func toggleProjectButtons():
	var hasProject = PlayerTool.project != null
	$BacklogButton.disabled = !hasProject

func startEvent():
	get_tree().paused = true
	$randomEventRinger.play("ringing")
	$randomEventRinger/ringerAudio.play()
	await $randomEventRinger/ringerAudio.finished
	$randomEventRinger.play("idle")
	createMenu(randomEventMenu.instantiate())

func runProjectCompletion():
	createMenu(projectCompletionMenu)
