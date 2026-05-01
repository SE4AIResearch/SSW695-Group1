extends Node2D

const PCWindowLayout = preload("res://UI/InGame/PCWindow/pc_window_layout.gd")

var projectList = load("res://Projects/projectList.gd").new()
var projectItem = preload("res://Projects/projectBase.tscn")
var methodItem = preload("res://UI/InGame/ProjectSetup/MethodItem/MethodItem.tscn")
var methodList = load("res://Projects/MethodologyList.gd").new()
var projectChoiceItem = preload("res://UI/InGame/ProjectSetup/ProjectItem/ProjectItem.tscn")
var TutorialModal: PackedScene = preload("res://UI/InGame/TutorialModal/TutorialModal.tscn")

const PROJECT_CHOICES_HEIGHT := 390.0
const PROJECT_CARD_WIDTH := 311.0
const PROJECT_CARD_GAP := 4.0
const LEARN_MORE_BUTTON_WIDTH := 160.0
const LEARN_MORE_BUTTON_HEIGHT := 40.0
const ACTION_BUTTON_WIDTH := 240.0
const PROJECT_ACTION_BUTTON_HEIGHT := 64.0
const ACTION_BUTTON_HEIGHT := 80.0
const ACTION_BUTTON_BOTTOM_PADDING := 2.0
const METHODOLOGY_WINDOW_SIDE_PADDING := 20.0
const METHODOLOGY_CARD_GAP := 2
const METHODOLOGY_CARD_HEIGHT := 240.0
const METHODOLOGY_CARD_WIDTH_REDUCTION := 20.0
const METHODOLOGY_CARD_BOTTOM_GAP := 16.0

var selectedProject: Node
var pendingMethodology: Dictionary = {}


func _on_button_pressed() -> void:
	generateProjectChoices()
	pass

func _ready():
	PCWindowLayout.apply(self)
	_apply_content_layout()
	if not $LearningCenter.close_requested.is_connected(_on_learning_center_close_requested):
		$LearningCenter.close_requested.connect(_on_learning_center_close_requested)
	$Title.text = "Select Project"
	_sync_project_setup_back_button()
	if PlayerTool.workers.size() == 0:
		$ProjectChoose/Button.text = "Hire a Worker!"
		$ProjectChoose/Button.disabled = true
	else:
		generateProjectChoices()

func _apply_content_layout() -> void:
	var content_rect: Rect2 = PCWindowLayout.content_rect()
	var choice_top: float = content_rect.position.y - 10.0
	var project_card_count := 3
	var choices_width: float = (PROJECT_CARD_WIDTH * project_card_count) + (PROJECT_CARD_GAP * (project_card_count - 1))
	var choices_left: float = content_rect.position.x + (content_rect.size.x - choices_width) / 2.0
	var choices_right: float = choices_left + choices_width
	var methodology_left: float = PCWindowLayout.WINDOW_LEFT + METHODOLOGY_WINDOW_SIDE_PADDING
	var methodology_right: float = PCWindowLayout.WINDOW_LEFT + PCWindowLayout.WINDOW_WIDTH - METHODOLOGY_WINDOW_SIDE_PADDING

	$ProjectChoose.position = Vector2.ZERO
	$MethodologyChoose.position = Vector2.ZERO

	$ProjectChoose/ProjectChoices.offset_left = choices_left
	$ProjectChoose/ProjectChoices.offset_top = choice_top
	$ProjectChoose/ProjectChoices.offset_right = choices_right
	$ProjectChoose/ProjectChoices.offset_bottom = choice_top + PROJECT_CHOICES_HEIGHT
	$ProjectChoose/ProjectChoices.alignment = BoxContainer.ALIGNMENT_CENTER
	$ProjectChoose/ProjectChoices.add_theme_constant_override("separation", int(PROJECT_CARD_GAP))

	$ProjectChoose/Button.offset_left = content_rect.position.x + (content_rect.size.x - ACTION_BUTTON_WIDTH) / 2.0
	$ProjectChoose/Button.offset_top = content_rect.position.y + content_rect.size.y - PROJECT_ACTION_BUTTON_HEIGHT - ACTION_BUTTON_BOTTOM_PADDING + 30.0
	$ProjectChoose/Button.offset_right = $ProjectChoose/Button.offset_left + ACTION_BUTTON_WIDTH
	$ProjectChoose/Button.offset_bottom = $ProjectChoose/Button.offset_top + PROJECT_ACTION_BUTTON_HEIGHT

	$LearnMoreButton.offset_left = PCWindowLayout.WINDOW_LEFT + 40.0
	$LearnMoreButton.offset_top = PCWindowLayout.WINDOW_TOP + 18.0
	$LearnMoreButton.offset_right = $LearnMoreButton.offset_left + LEARN_MORE_BUTTON_WIDTH
	$LearnMoreButton.offset_bottom = $LearnMoreButton.offset_top + LEARN_MORE_BUTTON_HEIGHT

	$MethodologyChoose/ConfirmButton.offset_left = content_rect.position.x + (content_rect.size.x - ACTION_BUTTON_WIDTH) / 2.0
	$MethodologyChoose/ConfirmButton.offset_top = content_rect.position.y + content_rect.size.y - ACTION_BUTTON_HEIGHT - ACTION_BUTTON_BOTTOM_PADDING
	$MethodologyChoose/ConfirmButton.offset_right = $MethodologyChoose/ConfirmButton.offset_left + ACTION_BUTTON_WIDTH
	$MethodologyChoose/ConfirmButton.offset_bottom = $MethodologyChoose/ConfirmButton.offset_top + ACTION_BUTTON_HEIGHT

	$MethodologyChoose/ScrollContainer.offset_left = methodology_left
	$MethodologyChoose/ScrollContainer.offset_top = choice_top
	$MethodologyChoose/ScrollContainer.offset_right = methodology_right
	$MethodologyChoose/ScrollContainer.offset_bottom = $MethodologyChoose/ConfirmButton.offset_top - METHODOLOGY_CARD_BOTTOM_GAP
	_layout_method_cards(methodology_right - methodology_left)

func _layout_method_cards(available_width: float) -> void:
	var methods_container: HBoxContainer = $MethodologyChoose/ScrollContainer/MethodologyChoices
	var method_count: int = max(1, methodList.methods.size())
	var base_card_width: float = floor((available_width - METHODOLOGY_CARD_GAP * (method_count - 1)) / method_count)
	var card_width: float = maxf(0.0, base_card_width - METHODOLOGY_CARD_WIDTH_REDUCTION)

	methods_container.alignment = BoxContainer.ALIGNMENT_CENTER
	methods_container.add_theme_constant_override("separation", METHODOLOGY_CARD_GAP)
	methods_container.custom_minimum_size = Vector2(available_width, METHODOLOGY_CARD_HEIGHT)

	for child in methods_container.get_children():
		child.custom_minimum_size = Vector2(card_width, METHODOLOGY_CARD_HEIGHT)
		child.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _sync_project_setup_back_button() -> void:
	$PCBack.visible = !$LearningCenter.visible

func generateProjectChoices() -> void:
	#Insert below code to pool together total worker skills
	var totalFE: int = 0
	var totalBE: int = 0
	var totalD: int = 0
	for worker in PlayerTool.workers:
		totalFE += worker.frontEndStat
		totalBE += worker.backEndStat
		totalD += worker.documentingStat
	#Read above comment
	for child in $ProjectChoose/ProjectChoices.get_children():
		child.queue_free()
	var project_choices: Array = PlayerTool.get_unique_project_choices(projectList.projects, 3)
	for i in range(project_choices.size()):
		var projectInfo = projectItem.instantiate()
		var newChoice = projectChoiceItem.instantiate()
		var project_data: Dictionary = project_choices[i]
		
		projectInfo.projectName = str(project_data.get("name", ""))
		projectInfo.projectDescription = str(project_data.get("description", ""))
		projectInfo.clientName = PersonConstructor.generateName()
		projectInfo.frontEndProjectMin = project_data.frontEndMetrics.size()
		projectInfo.backEndProjectMin = project_data.backEndMetrics.size()
		projectInfo.documentingProjectMin = project_data.documentingMetrics.size()
		projectInfo.sprintAmount = int(project_data.get("baseSprintAmount", 0))
		projectInfo.sprintLength = int(project_data.get("baseSprintLength", 0))
		projectInfo.sprintMetricAmount = int(project_data.get("baseSprintMetricAmount", 0))
		projectInfo.projectDifficulty = float(project_data.get("frontEndScalar", 0.0)) + float(project_data.get("backEndScalar", 0.0)) + float(project_data.get("documentingScalar", 0.0))
		projectInfo.frontEndMetrics = project_data.frontEndMetrics.duplicate(true)
		projectInfo.backEndMetrics = project_data.backEndMetrics.duplicate(true)
		projectInfo.documentingMetrics = project_data.documentingMetrics.duplicate(true)

		match i:
			0: 	projectInfo.constraints.append(projectList.constraints.pick_random())
			1:	while projectInfo.constraints.size() < 2:
					var constraint = projectList.constraints.pick_random()
					if !projectInfo.constraints.has(constraint): projectInfo.constraints.append(constraint)
			2:	while projectInfo.constraints.size() < 3:
					var constraint = projectList.constraints.pick_random()
					if !projectInfo.constraints.has(constraint): projectInfo.constraints.append(constraint)
		
		for constraint in projectInfo.constraints:
			projectInfo.sprintAmount += constraint.get("sprintAmount")
			projectInfo.sprintLength += constraint.get("sprintLength")
			projectInfo.sprintMetricAmount += constraint.get("sprintMetricAmount")
			projectInfo.eventChance *= constraint.get("randomEventChance")
		
		newChoice.prepProject(projectInfo)
		newChoice.connect("selected",projectSelected)
		$ProjectChoose/ProjectChoices.add_child(newChoice)
		pass

func projectSelected(project):
	for child in $ProjectChoose/ProjectChoices.get_children(): 
		if child.heldProject != project: child.heldProject.queue_free()
		child.queue_free()
	selectedProject = project
	$ProjectChoose.visible = false
	generateMetricsChoices()
	pass

func generateMetricsChoices():
	for child in $MethodologyChoose/ScrollContainer/MethodologyChoices.get_children():
		child.queue_free()
	pendingMethodology = {}
	$MethodologyChoose.visible = true
	$MethodologyChoose/ConfirmButton.visible = true
	$LearnMoreButton.visible = true
	$Title.visible = true
	$Title.text = "Select Methodology"
	for metric in methodList.methods:
		var newMethod = methodItem.instantiate()
		newMethod.setupMetric(metric)
		newMethod.connect("MethodChosen", methodSelected.bind(newMethod))
		$MethodologyChoose/ScrollContainer/MethodologyChoices.add_child(newMethod)
		pass
	_layout_method_cards($MethodologyChoose/ScrollContainer.offset_right - $MethodologyChoose/ScrollContainer.offset_left)
	_update_confirm_button_state()
	call_deferred("_show_methodology_tutorial")
	pass

func methodSelected(chosenMetric, chosenButton: Button):
	pendingMethodology = chosenMetric
	for child in $MethodologyChoose/ScrollContainer/MethodologyChoices.get_children():
		if child is Button:
			child.button_pressed = child == chosenButton
	_update_confirm_button_state()

func _on_confirm_button_pressed() -> void:
	if pendingMethodology.is_empty() or _requires_methodology_learning_center():
		return
	PlayerTool.resetProjectStats()
	selectedProject.methodology = pendingMethodology
	$LearningCenter.visible = false
	$MethodologyChoose.visible = false
	$MethodologyChoose/ConfirmButton.visible = false
	$LearnMoreButton.visible = false
	pendingMethodology = {}
	for child in $MethodologyChoose/ScrollContainer/MethodologyChoices.get_children():
		child.queue_free()
	calculateUpgradeEffects()

func _requires_methodology_learning_center() -> bool:
	return PlayerTool.completed_project_count == 0 and !PlayerTool.has_viewed_methodology_learning_center

func _update_confirm_button_state() -> void:
	var confirm_button: Button = $MethodologyChoose/ConfirmButton
	var has_selection := !pendingMethodology.is_empty()
	confirm_button.disabled = !has_selection or _requires_methodology_learning_center()

#Calculate effects from player upgrades here
func calculateUpgradeEffects():
	PlayerTool.newProject(selectedProject)
	get_parent().get_parent().newProject()
	pass
	
func finishProjectChoosing():
	get_tree().paused = false
	self.queue_free()
	pass

func _on_pc_back_pressed() -> void:
	if $LearningCenter.visible:
		_hide_learning_center()
		return
	get_parent().get_parent().endMenu()

func _on_learn_more_button_pressed() -> void:
	if _requires_methodology_learning_center():
		PlayerTool.has_viewed_methodology_learning_center = true
	$MethodologyChoose.visible = false
	$MethodologyChoose/ConfirmButton.visible = false
	$LearnMoreButton.visible = false
	$Title.visible = false
	_reset_learning_center()
	$LearningCenter.visible = true
	_sync_project_setup_back_button()

func _hide_learning_center() -> void:
	$LearningCenter.visible = false
	$MethodologyChoose.visible = true
	$MethodologyChoose/ConfirmButton.visible = true
	$Title.visible = true
	$LearnMoreButton.visible = true
	_reset_learning_center()
	_update_confirm_button_state()
	_sync_project_setup_back_button()

func _reset_learning_center() -> void:
	if $LearningCenter.has_method("reset_state"):
		$LearningCenter.reset_state()

func _on_learning_center_close_requested() -> void:
	_hide_learning_center()

func _show_methodology_tutorial() -> void:
	_show_tutorial(
		"methodology_intro",
		"Project Methodology",
		"Before finalizing your choice, open Learn More to compare the methodologies. The right process can make the whole project easier to manage."
	)

func _show_tutorial(tutorial_key: String, title: String, message: String) -> void:
	if !PlayerTool.should_show_tutorial(tutorial_key):
		return

	var modal: TutorialModalPanel = TutorialModal.instantiate() as TutorialModalPanel
	_get_tutorial_modal_parent().add_child(modal)
	modal.setup(title, message)
	modal.dismissed.connect(_on_tutorial_dismissed.bind(tutorial_key))

func _on_tutorial_dismissed(tutorial_key: String) -> void:
	PlayerTool.mark_tutorial_seen(tutorial_key)
	SaveTool.savePlayerData()

func _get_tutorial_modal_parent() -> Node:
	var scene_root: Node = get_tree().current_scene
	if scene_root != null:
		var ui_layer: Node = scene_root.get_node_or_null("UI")
		if ui_layer != null:
			return ui_layer
	return self
