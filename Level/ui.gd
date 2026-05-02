extends CanvasLayer
var currentMenu: Node

var UpgradesMenu = load("res://UI/InGame/Upgrades/Upgrades.tscn")
var ProjectMetricsMenu = load("res://UI/InGame/ProjectMetrics/ProjectMetrics.tscn")
var HiringMenu = load("res://UI/InGame/Hiring/Hiring.tscn")
var BacklogMenu = load("res://UI/InGame/Backlog/Backlog.tscn")
var ProjectSetupMenu = load("res://UI/InGame/ProjectSetup/ProjectSetup.tscn")
var ProjectPortfolioMenu = load("res://UI/InGame/ProjectPortfolio/ProjectPortfolio.tscn")
var randomEventMenu = load("res://UI/InGame/RandomEvent/RandomEvent.tscn")
var projectCompletionMenu = load("res://UI/InGame/ProjectCompletion/ProjectCompletion.tscn")
var TutorialModal: PackedScene = preload("res://UI/InGame/TutorialModal/TutorialModal.tscn")
const FIRST_SPRINT_REWARD_TUTORIAL_KEY := "first_sprint_reward_intro"
const FIRST_SPRINT_REWARD_TUTORIAL_TITLE := "First Sprint Complete"
const FIRST_SPRINT_REWARD_TUTORIAL_MESSAGE := "You just earned currency for completing a sprint. Congrats! Check out the Hiring menu to search for team members, or visit Upgrades to purchase an upgrade."
var pcMode = false
var _pending_first_sprint_reward_tutorial: bool = false



func _ready() -> void:
	PlayerTool.connect("projectSelected",toggleProjectButtons)
	PlayerTool.connect("deadlineReached",toggleProjectButtons)
	toggleProjectButtons()
	PlayerTool.projectCompleted.connect(_on_project_completed)
	PlayerTool.sprintComplete.connect(_on_sprint_completed)
	call_deferred("show_office_intro_tutorial")
	AudioManager.reset_resting_workers()
	AudioManager.play_music("gameplay")
	AudioManager.start_random_ambient()
	$Pause.resumeSignal.connect(checkRandomEventRinger)

func _exit_tree() -> void:
	AudioManager.stop_random_ambient()
	AudioManager.reset_resting_workers()
	
func _physics_process(delta: float) -> void: pass

func _on_pause_button_pressed() -> void:
	match get_tree().paused:
		true: $Pause.resumePaused = true
		false: $Pause.resumePaused = false
	if $randomEventRinger/ringerAudio.playing:$randomEventRinger/ringerAudio.stream_paused = true
	get_tree().paused = true
	$Pause.visible = true
	pass

func checkRandomEventRinger(): if $randomEventRinger/ringerAudio.stream_paused: $randomEventRinger/ringerAudio.stream_paused = false
		

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
			$PCButtons/ProjectPortfolioButton.disabled = false
			var hasProject = PlayerTool.project != null
			$PCButtons/projectStartMenu.text = "Already have a Project" if hasProject else "Start New Project"
			$PCButtons/projectStartMenu.disabled = hasProject
		false:
			$BackButton.visible = false
			get_tree().paused = false
	if _pending_first_sprint_reward_tutorial:
		call_deferred("_show_pending_first_sprint_reward_tutorial_if_needed")

func newProject():
	endMenu()
	_on_pc_power_pressed()
	createMenu(BacklogMenu.instantiate(),false)

func _on_upgrades_button_pressed() -> void:
	AudioManager.play_sfx("pc_click")
	createMenu(UpgradesMenu.instantiate(),false)

func _on_project_metrics_button_pressed() -> void:
	AudioManager.play_sfx("pc_click")
	var metricsMenu = ProjectMetricsMenu.instantiate()
	metricsMenu.getCurrentMetrics(PlayerTool.project, PlayerTool.metrics)
	createMenu(metricsMenu,true)

func _on_hiring_button_pressed() -> void:
	AudioManager.play_sfx("pc_click")
	createMenu(HiringMenu.instantiate(),false)

func _on_project_portfolio_button_pressed() -> void:
	AudioManager.play_sfx("pc_click")
	createMenu(ProjectPortfolioMenu.instantiate(),false)

func _on_backlog_button_pressed() -> void:
	AudioManager.play_sfx("paper_rustle")
	createMenu(BacklogMenu.instantiate(),true)

func _on_project_start_menu_pressed() -> void:
	AudioManager.play_sfx("pc_click")
	createMenu(ProjectSetupMenu.instantiate(),false)

func _on_random_event_button_pressed() -> void:
	AudioManager.play_sfx("pc_click")
	createMenu(randomEventMenu.instantiate(),false)

func createMenu(menu,allowBack):
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
			$PCButtons/ProjectPortfolioButton.disabled = true
			$PCButtons/projectStartMenu.disabled = true
		false:
			if allowBack: $BackButton.visible = true

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
	$PCButtons/ProjectPortfolioButton.disabled = false
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
	$PCButtons/ProjectPortfolioButton.disabled = false
	$PCButtons/projectStartMenu.disabled = false
	if $NewMenu.get_children().size() > 0: $NewMenu.get_child(0).queue_free()
	pass

func toggleProjectButtons():
	var hasProject = PlayerTool.project != null
	$BacklogButton.disabled = !hasProject

func startEvent() -> bool:
	if PlayerTool.project == null or $NewMenu.get_child_count() != 0:
		return false
	get_tree().paused = true
	$randomEventRinger.play("ringing")
	$randomEventRinger/ringerAudio.play()
	await $randomEventRinger/ringerAudio.finished
	$randomEventRinger.play("idle")
	if PlayerTool.project == null or $NewMenu.get_child_count() != 0:
		if $NewMenu.get_child_count() == 0:
			get_tree().paused = false
		return false
	createMenu(randomEventMenu.instantiate(),false)
	return true

func runProjectCompletion(completion_data: Dictionary = {}) -> void:
	var menu = projectCompletionMenu.instantiate()
	if !completion_data.is_empty() and menu.has_method("setup_from_snapshot"):
		menu.setup_from_snapshot(completion_data)
	createMenu(menu,true)

func _on_project_completed() -> void:
	runProjectCompletion(_build_project_completion_snapshot())

func _on_sprint_completed() -> void:
	if !_should_show_first_sprint_reward_tutorial():
		return
	_pending_first_sprint_reward_tutorial = true
	call_deferred("_show_pending_first_sprint_reward_tutorial_if_needed")

func _show_pending_first_sprint_reward_tutorial_if_needed() -> void:
	if !_pending_first_sprint_reward_tutorial:
		return
	if currentMenu != null and is_instance_valid(currentMenu):
		return
	_pending_first_sprint_reward_tutorial = false
	show_first_sprint_reward_tutorial()

func _should_show_first_sprint_reward_tutorial() -> bool:
	return PlayerTool.projSprint == 1 and PlayerTool.should_show_tutorial(FIRST_SPRINT_REWARD_TUTORIAL_KEY)

func _build_project_completion_snapshot() -> Dictionary:
	var project = PlayerTool.project
	if project == null:
		return {}
	return {
		"project_name": str(project.projectName),
		"client_name": str(project.clientName),
		"project_rated_difficulty": float(PlayerTool.projectRatedDifficulty),
		"project_amount": int(PlayerTool.projectAmount),
		"team_rank": int(PlayerTool.teamRank),
		"metrics": PlayerTool.metrics.duplicate(true),
		"front_end_target": int(project.frontEndProjectMin),
		"back_end_target": int(project.backEndProjectMin),
		"documenting_target": int(project.documentingProjectMin),
		"total_events": int(PlayerTool.totalEvents),
	}


func _on_button_pressed() -> void: runProjectCompletion()

func show_office_intro_tutorial() -> void:
	_show_tutorial(
		"office_intro",
		"Welcome",
		"Welcome to Software Development Tycoon. Here is your office! Click the computer to get started on your project management journey."
	)

func show_kanban_exit_tutorial() -> void:
	_show_tutorial(
		"kanban_exit_intro",
		"Week Started",
		"Your workers will now make progress on their assigned backlog items. Watch stamina during the week.",
		true
	)

func show_first_sprint_reward_tutorial() -> void:
	_show_tutorial(
		FIRST_SPRINT_REWARD_TUTORIAL_KEY,
		FIRST_SPRINT_REWARD_TUTORIAL_TITLE,
		FIRST_SPRINT_REWARD_TUTORIAL_MESSAGE,
		false
	)

func _show_tutorial(tutorial_key: String, title: String, message: String, show_stamina_examples: bool = false) -> void:
	if !PlayerTool.should_show_tutorial(tutorial_key):
		return

	var modal: TutorialModalPanel = TutorialModal.instantiate() as TutorialModalPanel
	add_child(modal)
	modal.setup(title, message, "OK", show_stamina_examples)
	modal.dismissed.connect(_on_tutorial_dismissed.bind(tutorial_key))

func _on_tutorial_dismissed(tutorial_key: String) -> void:
	PlayerTool.mark_tutorial_seen(tutorial_key)
	SaveTool.savePlayerData()
