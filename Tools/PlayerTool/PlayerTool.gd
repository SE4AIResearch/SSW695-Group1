extends Node

signal projectSelected
signal deadlineReached
signal sprintComplete
signal hireSelected
signal levelLoaded
signal statsChanged

var level

var project: Node
var projectRatedDifficulty: float
var metrics={
"frontEnd":0,
"backEnd":0,
"documenting":0,
"reliability":0,
"stakeholderSatisfaction":0
}
var MetricProgress={}
var completedMetrics=[]
var weekTime: int = 0
var projWeek: int = 0
var projSprint: int = 0
var FEBacklogStep: int = 0
var BEBacklogStep: int = 0
var docBacklogStep: int = 0

var teamRank: int = 1
var workers: Array
var upgrades: Array
var currency: float = 0.00
var projectAmount: int = 0

func initializeNewSave():
	var freeWorker1 = PersonConstructor.generateWorker(PersonConstructor.getStartingWorkerStats(0))
	var freeWorker2 = PersonConstructor.generateWorker(PersonConstructor.getStartingWorkerStats(1))
	$workerHoldover.add_child(freeWorker1)
	$workerHoldover.add_child(freeWorker2)
	freeWorker1.scale = Vector2(2.5,2.5)
	freeWorker2.scale = Vector2(2.5,2.5)
	newHire(freeWorker1)
	newHire(freeWorker2)
	pass

#Type : 0 = Front End | 1 = Back End | 2 = Documenting | 3 = Reliability | 4 = Stakeholder Satisfaction
func changeProjectStats(type,amount):
	match type:
		0: metrics.set("frontEnd",metrics.get("frontEnd")+amount)
		1: metrics.set("backEnd",metrics.get("backEnd",)+amount)
		2: metrics.set("documenting",metrics.get("documenting")+amount)
		3: metrics.set("reliability",metrics.get("reliability")+amount)
		4: metrics.set("stakeholderSatisfaction",metrics.get("stakeholderSatisfaction")+amount)
	statsChanged.emit()

func resetData():
	#resets Project stats to default values
	project = null
	metrics = {"frontEnd":0,"backEnd":0,"documenting":0,"reliability":0,"stakeholderSatisfaction":0}
	workers = []
	upgrades = []
	weekTime = 0
	projWeek = 0
	projSprint = 0
	pass

func resetProjectStats():
	projectRatedDifficulty = 0
	project = null
	metrics = {"frontEnd":0,"backEnd":0,"documenting":0,"reliability":0,"stakeholderSatisfaction":0}
	weekTime = 0
	projWeek = 0
	projSprint = 0
	FEBacklogStep = 0
	BEBacklogStep = 0
	docBacklogStep = 0
	pass

func _ready() -> void:
	var workerNode = Node2D.new()
	workerNode.name = "workerHoldover"
	add_child(workerNode)
	TimeTool.sprintPassed.connect(earnSprintMoney)

func newProject(newProject) -> void:
	project = newProject
	projWeek = 1
	projSprint = 1
	projectAmount += 1
	projectSelected.emit()
	pass

func newHire(worker) -> void:
	worker.name = worker.personName
	workers.append(worker)
	worker.reparent($workerHoldover)
	hireSelected.emit()
	pass
	
func newUpgrade(upgrade) -> void:
	pass

func earnSprintMoney():
	if project != null:
		currency += (30*project.projectDifficulty) + (5*projectAmount) + (50*(teamRank-1))
		pass

func earnProjectMoney():
		currency += (500*project.projectDifficulty) + (25*projectAmount) + (650*(teamRank-1)) 
		pass