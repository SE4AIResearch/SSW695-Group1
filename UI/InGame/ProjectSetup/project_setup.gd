extends Node2D

var projectList = load("res://Projects/projectList.gd").new()
var projectItem = preload("res://Projects/projectBase.tscn")
var methodItem = preload("res://UI/InGame/ProjectSetup/MethodItem/MethodItem.tscn")
var methodList = load("res://Projects/MethodologyList.gd").new()
var projectChoiceItem = preload("res://UI/InGame/ProjectSetup/ProjectItem/ProjectItem.tscn")

var selectedProject: Node
var randomProject: Node


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
		var projectInfo = projectItem.instantiate()
		var newChoice = projectChoiceItem.instantiate()
		randomProject = projectList.projects.pick_random()
		
		projectInfo.projectName = randomProject.name
		projectInfo.projectDescription = randomProject.name
		projectInfo.clientName = PersonConstructor.generateName()
		projectInfo.frontEndProjectMin = (totalFE*randomProject.frontEndScalar)*clampf(PlayerTool.projectAmount*1.025,1,1000)
		projectInfo.backEndProjectMin = (totalBE*randomProject.backEndScalar)*clampf(PlayerTool.projectAmount*1.025,1,1000)
		projectInfo.documentingProjectMin = (totalD*randomProject.documentingScalar)*clampf(PlayerTool.projectAmount*1.025,1,1000)
		projectInfo.sprintAmount = randomProject.baseSprintAmount
		projectInfo.sprintLength = randomProject.baseSprintLength
		projectInfo.sprintMetricAmount = randomProject.baseSprintMetricAmount
		projectInfo.frontEndMetrics = randomProject.frontEndMetrics
		projectInfo.backEndMetrics = randomProject.backEndMetrics
		projectInfo.documentingMetrics = randomProject.documentingMetrics

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
	PlayerTool.projectInfo(selectedProject)
	get_parent().get_parent().projectInfo()
	pass
	
func finishProjectChoosing():
	get_tree().paused = false
	self.queue_free()
	pass


func _on_pc_back_pressed() -> void: get_parent().get_parent().endMenu()
