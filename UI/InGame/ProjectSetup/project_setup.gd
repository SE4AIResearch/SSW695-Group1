extends Node2D

var projectList = load("res://Projects/projectList.json")
var projectItem = preload("res://Projects/projectBase.tscn")
var projectChoiceItem = preload("res://UI/InGame/ProjectSetup/ProjectItem/ProjectItem.tscn")

func _on_button_pressed() -> void:
	generateProjectChoices()
	pass

func generateProjectChoices() -> void:
	for child in $ProjectChoices.get_children():
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
		newProject.metrics = {}
		newChoice.prepProject(newProject)
		newChoice.connect("selected",projectSelected)
		$ProjectChoices.add_child(newChoice)
		pass

func projectSelected(project):
	for child in $ProjectChoices.get_children(): 
		if child.heldProject != project: child.heldProject.queue_free()
		child.queue_free()
	PlayerTool.newProject(project)
	get_tree().paused = false
	self.queue_free()
	pass
