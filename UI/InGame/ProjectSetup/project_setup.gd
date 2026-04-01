extends Node2D

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
	if PlayerTool.workers.size() == 0:
		$ProjectChoose/Button.text = "Hire a Worker!"
		$ProjectChoose/Button.disabled = true
	pass

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
		newProject.baseSprintAmount = randomProject.baseSprintAmount
		newProject.baseSprintLength = randomProject.baseSprintLength
		newProject.baseSprintMetricAmount = randomProject.baseSprintMetricAmount
		newProject.frontEndMetrics = randomProject.frontEndMetrics
		newProject.backEndMetrics = randomProject.backEndMetrics
		newProject.documentingMetrics = randomProject.documentingMetrics
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
	selectedProject.methodology = chosenMetric
	for child in $MethodologyChoose/ScrollContainer/MethodologyChoices.get_children(): child.queue_free()
	calculateConstraintAndMethodology()
	pass

#Calculate effects of chosen methodology and generated constraints onto the project
func calculateConstraintAndMethodology():
	PlayerTool.resetProjectStats()
	selectedProject.sprintAmount = selectedProject.baseSprintAmount
	selectedProject.sprintLength = selectedProject.baseSprintLength
	selectedProject.sprintMetricAmount = selectedProject.baseSprintMetricAmount
	#Return calculated Project
	PlayerTool.newProject(selectedProject)
	get_parent().get_parent().newProject()
	
func finishProjectChoosing():
	get_tree().paused = false
	self.queue_free()
	pass
