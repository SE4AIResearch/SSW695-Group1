extends CanvasLayer
var currentMenu: Node

var UpgradesMenu = load("res://UI/InGame/Upgrades/Upgrades.tscn")
var ProjectMetricsMenu = load("res://UI/InGame/ProjectMetrics/ProjectMetrics.tscn")
var HiringMenu = load("res://UI/InGame/Hiring/Hiring.tscn")
var BacklogMenu = load("res://UI/InGame/Backlog/Backlog.tscn")
var ProjectSetupMenu = load("res://UI/InGame/ProjectSetup/ProjectSetup.tscn")
var randomEventMenu = load("res://UI/InGame/RandomEvent/RandomEvent.tscn")
var projectCompletionMenu = load("res://UI/InGame/ProjectCompletion/ProjectCompletion.tscn")
var TutorialModal: PackedScene = preload("res://UI/InGame/TutorialModal/TutorialModal.tscn")
var pcMode = false



func _ready() -> void:
	PlayerTool.connect("projectSelected",toggleProjectButtons)
	PlayerTool.connect("deadlineReached",toggleProjectButtons)
	toggleProjectButtons()
	PlayerTool.projectCompleted.connect(runProjectCompletion)
	call_deferred("show_office_intro_tutorial")
	AudioManager.reset_resting_workers()
	AudioManager.play_music("gameplay")
	AudioManager.start_random_ambient()

func _exit_tree() -> void:
	AudioManager.stop_random_ambient()
	AudioManager.reset_resting_workers()
	
func _physics_process(delta: float) -> void: pass

func _on_pause_button_pressed() -> void:
	match get_tree().paused:
		true: $Pause.resumePaused = true
		false: $Pause.resumePaused = false
	get_tree().paused = true
	$Pause.visible = true
	pass

func _on_back_button_pressed() -> void:
	AudioManager.play_sfx("paper_rustle")
	endMenu()

func _on_pc_back_pressed() -> void:
	AudioManager.play_sfx("pc_click")
	endMenu()

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

func _on_upgrades_button_pressed() -> void:
	AudioManager.play_sfx("pc_click")
	createMenu(UpgradesMenu.instantiate())

func _on_project_metrics_button_pressed() -> void:
	AudioManager.play_sfx("pc_click")
	var metricsMenu = ProjectMetricsMenu.instantiate()
	metricsMenu.getCurrentMetrics(PlayerTool.project, PlayerTool.metrics)
	createMenu(metricsMenu)

func _on_hiring_button_pressed() -> void:
	AudioManager.play_sfx("pc_click")
	createMenu(HiringMenu.instantiate())

func _on_backlog_button_pressed() -> void:
	AudioManager.play_sfx("paper_rustle")
	createMenu(BacklogMenu.instantiate())

func _on_project_start_menu_pressed() -> void:
	AudioManager.play_sfx("pc_click")
	createMenu(ProjectSetupMenu.instantiate())

func _on_random_event_button_pressed() -> void:
	AudioManager.play_sfx("pc_click")
	createMenu(randomEventMenu.instantiate())

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
	AudioManager.play_sfx("pc_click")
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
	AudioManager.play_sfx("pc_click")
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
	createMenu(projectCompletionMenu.instantiate())


func _on_button_pressed() -> void: runProjectCompletion()

func show_office_intro_tutorial() -> void:
	_show_tutorial(
		"office_intro",
		"Welcome",
		"Welcome to Software Development Tycoon. Here is your office! Click the computer to get started on your project management journey."
	)

func _show_tutorial(tutorial_key: String, title: String, message: String) -> void:
	if !PlayerTool.should_show_tutorial(tutorial_key):
		return

	var modal: TutorialModalPanel = TutorialModal.instantiate() as TutorialModalPanel
	add_child(modal)
	modal.setup(title, message)
	modal.dismissed.connect(_on_tutorial_dismissed.bind(tutorial_key))

func _on_tutorial_dismissed(tutorial_key: String) -> void:
	PlayerTool.mark_tutorial_seen(tutorial_key)
	SaveTool.savePlayerData()
