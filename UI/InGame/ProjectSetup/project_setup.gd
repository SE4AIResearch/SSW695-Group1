extends Node2D

const PCWindowLayout = preload("res://UI/InGame/PCWindow/pc_window_layout.gd")

var projectList = load("res://Projects/projectList.gd").new()
var projectItem = preload("res://Projects/projectBase.tscn")
var methodItem = preload("res://UI/InGame/ProjectSetup/MethodItem/MethodItem.tscn")
var methodList = load("res://Projects/MethodologyList.gd").new()
var projectChoiceItem = preload("res://UI/InGame/ProjectSetup/ProjectItem/ProjectItem.tscn")

var selectedProject: Node

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
	var row_width: float = 788.0
	var row_left: float = content_rect.position.x + (content_rect.size.x - row_width) / 2.0
	var button_width: float = $ProjectChoose/Button.offset_right - $ProjectChoose/Button.offset_left
	var button_height: float = $ProjectChoose/Button.offset_bottom - $ProjectChoose/Button.offset_top
	var button_left: float = content_rect.position.x + (content_rect.size.x - button_width) / 2.0

	$ProjectChoose/ProjectChoices.offset_left = row_left
	$ProjectChoose/ProjectChoices.offset_right = row_left + row_width

	$MethodologyChoose/ScrollContainer.offset_left = row_left
	$MethodologyChoose/ScrollContainer.offset_right = row_left + row_width

	$ProjectChoose/Button.offset_left = button_left
	$ProjectChoose/Button.offset_right = button_left + button_width
	$ProjectChoose/Button.offset_top = content_rect.position.y + content_rect.size.y - button_height - 12.0
	$ProjectChoose/Button.offset_bottom = $ProjectChoose/Button.offset_top + button_height

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
		var newProject = projectItem.instantiate()
		var newChoice = projectChoiceItem.instantiate()
		var randomProject = projectList.projects.pick_random()
		
		newProject.projectName = randomProject.name
		newProject.projectDescription = randomProject.name
		newProject.clientName = PersonConstructor.generateName()
		newProject.frontEndProjectMin = totalFE*randomProject.frontEndScalar
		newProject.backEndProjectMin = totalBE*randomProject.backEndScalar
		newProject.documentingProjectMin = totalD*randomProject.documentingScalar
		newProject.sprintAmount = randomProject.baseSprintAmount
		newProject.sprintLength = randomProject.baseSprintLength
		newProject.sprintMetricAmount = randomProject.baseSprintMetricAmount
		newProject.frontEndMetrics = randomProject.frontEndMetrics
		newProject.backEndMetrics = randomProject.backEndMetrics
		newProject.documentingMetrics = randomProject.documentingMetrics

		match i:
			0: 	newProject.constraints.append(projectList.constraints.pick_random())
			1:	while newProject.constraints.size() < 2:
					var constraint = projectList.constraints.pick_random()
					if !newProject.constraints.has(constraint): newProject.constraints.append(constraint)
			2:	while newProject.constraints.size() < 3:
					var constraint = projectList.constraints.pick_random()
					if !newProject.constraints.has(constraint): newProject.constraints.append(constraint)
		
		for constraint in newProject.constraints:
			newProject.frontEndProjectMin *= constraint.get("frontEndScaling")
			newProject.backEndProjectMin *= constraint.get("backEndScaling")
			newProject.documentingProjectMin *= constraint.get("documentingScaling")
			newProject.sprintAmount += constraint.get("sprintAmount")
			newProject.sprintLength += constraint.get("sprintLength")
			newProject.sprintMetricAmount += constraint.get("sprintMetricAmount")
			newProject.eventChance *= constraint.get("randomEventChance")
		
		newChoice.prepProject(newProject)
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
	PlayerTool.newProject(selectedProject)
	get_parent().get_parent().newProject()
	pass
	
func finishProjectChoosing():
	get_tree().paused = false
	self.queue_free()
	pass


func _on_pc_back_pressed() -> void: get_parent().get_parent().endMenu()
