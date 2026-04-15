extends Node2D

const PCWindowLayout = preload("res://UI/InGame/PCWindow/pc_window_layout.gd")

var projectList = load("res://Projects/projectList.gd").new()
var projectItem = preload("res://Projects/projectBase.tscn")
var methodItem = preload("res://UI/InGame/ProjectSetup/MethodItem/MethodItem.tscn")
var methodList = load("res://Projects/MethodologyList.gd").new()
var projectChoiceItem = preload("res://UI/InGame/ProjectSetup/ProjectItem/ProjectItem.tscn")

const PROJECT_CHOICES_HEIGHT := 245.0
const ACTION_BUTTON_WIDTH := 240.0
const ACTION_BUTTON_HEIGHT := 80.0
const ACTION_BUTTON_BOTTOM_PADDING := 10.0

var selectedProject: Node
var randomProject: Dictionary


func _on_button_pressed() -> void:
	generateProjectChoices()
	pass

func _ready():
	PCWindowLayout.apply(self)
	_apply_content_layout()
	if PlayerTool.workers.size() == 0:
		$ProjectChoose/Button.text = "Hire a Worker!"
		$ProjectChoose/Button.disabled = true
	pass

func _apply_content_layout() -> void:
	var content_rect: Rect2 = PCWindowLayout.content_rect()
	var choice_top: float = content_rect.position.y + 28.0
	var choices_left: float = content_rect.position.x + 82.0
	var choices_right: float = content_rect.position.x + content_rect.size.x - 81.0

	$ProjectChoose.position = Vector2.ZERO
	$MethodologyChoose.position = Vector2.ZERO

	$ProjectChoose/ProjectChoices.offset_left = choices_left
	$ProjectChoose/ProjectChoices.offset_top = choice_top
	$ProjectChoose/ProjectChoices.offset_right = choices_right
	$ProjectChoose/ProjectChoices.offset_bottom = choice_top + PROJECT_CHOICES_HEIGHT

	$ProjectChoose/Button.offset_left = content_rect.position.x + (content_rect.size.x - ACTION_BUTTON_WIDTH) / 2.0
	$ProjectChoose/Button.offset_top = content_rect.position.y + content_rect.size.y - ACTION_BUTTON_HEIGHT - ACTION_BUTTON_BOTTOM_PADDING
	$ProjectChoose/Button.offset_right = $ProjectChoose/Button.offset_left + ACTION_BUTTON_WIDTH
	$ProjectChoose/Button.offset_bottom = $ProjectChoose/Button.offset_top + ACTION_BUTTON_HEIGHT

	$MethodologyChoose/ScrollContainer.offset_left = content_rect.position.x + 82.0
	$MethodologyChoose/ScrollContainer.offset_top = choice_top
	$MethodologyChoose/ScrollContainer.offset_right = content_rect.position.x + content_rect.size.x - 81.0
	$MethodologyChoose/ScrollContainer.offset_bottom = content_rect.position.y + content_rect.size.y - 34.0

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
	for i in range(3):
		var projectInfo = projectItem.instantiate()
		var newChoice = projectChoiceItem.instantiate()
		randomProject = projectList.projects.pick_random()
		
		projectInfo.projectName = randomProject.name
		projectInfo.projectDescription = randomProject.description
		projectInfo.clientName = PersonConstructor.generateName()
		projectInfo.frontEndProjectMin = (totalFE*randomProject.frontEndScalar)*clampf(PlayerTool.projectAmount*1.025,1,1000)
		projectInfo.backEndProjectMin = (totalBE*randomProject.backEndScalar)*clampf(PlayerTool.projectAmount*1.025,1,1000)
		projectInfo.documentingProjectMin = (totalD*randomProject.documentingScalar)*clampf(PlayerTool.projectAmount*1.025,1,1000)
		projectInfo.sprintAmount = randomProject.baseSprintAmount
		projectInfo.sprintLength = randomProject.baseSprintLength
		projectInfo.sprintMetricAmount = randomProject.baseSprintMetricAmount
		projectInfo.frontEndMetrics = randomProject.frontEndMetrics.duplicate(true)
		projectInfo.backEndMetrics = randomProject.backEndMetrics.duplicate(true)
		projectInfo.documentingMetrics = randomProject.documentingMetrics.duplicate(true)

		match i:
			0: 	projectInfo.constraints.append(projectList.constraints.pick_random())
			1:	while projectInfo.constraints.size() < 2:
					var constraint = projectList.constraints.pick_random()
					if !projectInfo.constraints.has(constraint): projectInfo.constraints.append(constraint)
			2:	while projectInfo.constraints.size() < 3:
					var constraint = projectList.constraints.pick_random()
					if !projectInfo.constraints.has(constraint): projectInfo.constraints.append(constraint)
		
		for constraint in projectInfo.constraints:
			randomProject.set("frontEndScaling",constraint.get("frontEndScaling"))
			randomProject.set("backEndScaling",constraint.get("backEndScaling"))
			randomProject.set("documentingScaling",constraint.get("documentingScaling"))
			projectInfo.frontEndProjectMin *= constraint.get("frontEndScaling")
			projectInfo.backEndProjectMin *= constraint.get("backEndScaling")
			projectInfo.documentingProjectMin *= constraint.get("documentingScaling")
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
	$MethodologyChoose.visible = true
	for metric in methodList.methods:
		var newMethod = methodItem.instantiate()
		newMethod.setupMetric(metric)
		newMethod.connect("MethodChosen",methodSelected)
		$MethodologyChoose/ScrollContainer/MethodologyChoices.add_child(newMethod)
		pass
	pass

func methodSelected(chosenMetric):
	PlayerTool.resetProjectStats()
	selectedProject.methodology = chosenMetric
	for child in $MethodologyChoose/ScrollContainer/MethodologyChoices.get_children(): child.queue_free()
	calculateUpgradeEffects()
	pass

#Calculate effects from player upgrades here
func calculateUpgradeEffects():

	selectedProject.projectDifficulty = randomProject.get("frontEndScalar") + randomProject.get("backEndScalar") + randomProject.get("documentingScalar")
	PlayerTool.newProject(selectedProject)
	get_parent().get_parent().newProject()
	pass
	
func finishProjectChoosing():
	get_tree().paused = false
	self.queue_free()
	pass

func _on_pc_back_pressed() -> void: get_parent().get_parent().endMenu()
