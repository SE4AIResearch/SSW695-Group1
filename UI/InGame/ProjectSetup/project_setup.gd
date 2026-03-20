extends Node2D

var projectList = load("res://Projects/projectList.json")
var projectItem = preload("res://Projects/projectBase.tscn")
var methodItem = preload("res://UI/InGame/ProjectSetup/MethodItem/MethodItem.tscn")
var methodList = load("res://Projects/MethodologyList.gd").new()
var projectChoiceItem = preload("res://UI/InGame/ProjectSetup/ProjectItem/ProjectItem.tscn")

var selectedProject: Node

func _on_button_pressed() -> void:
	generateProjectChoices()
	pass

func generateProjectChoices() -> void:
	for child in $ProjectChoose/ProjectChoices.get_children():
		child.queue_free()
	for i in range(3):
		var newProject = projectItem.instantiate()
		var newChoice = projectChoiceItem.instantiate()
		var randomProject = null
		
		newProject.projectName = "Project Name"
		newProject.projectDescription = "Project Description"
		newProject.clientName = PersonConstructor.generateName()
		newProject.difficulty = 1
		newProject.frontEndScalar = 1
		newProject.backEndScalar = 1
		newProject.documentingScalar = 1
		newProject.frontEndProjectMin = 10
		newProject.backEndProjectMin = 10
		newProject.documentingProjectMin = 10
		newProject.baseSprintAmount = 1
		newProject.sprintAmount = 1
		newProject.baseSprintLength = 1
		newProject.sprintLength =1
		newProject.methodology = {}
		newProject.metric = {}
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
		$MethodologyChoose/MethodologyChoices.add_child(newMethod)
		pass
	pass

func methodSelected(chosenMetric):
	selectedProject.methodology = chosenMetric
	PlayerTool.newProject(selectedProject)
	for child in $MethodologyChoose/MethodologyChoices.get_children(): child.queue_free()
	get_parent().get_parent().endMenu()
	pass

func finishProjectChoosing():
	get_tree().paused = false
	self.queue_free()
	pass
