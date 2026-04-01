extends Node

signal projectSelected
signal deadlineReached
signal sprintComplete
signal hireSelected
signal levelLoaded
signal weekPassed

var level

var currentProject: Node
var currentMetrics={
"frontEnd":0,
"backEnd":0,
"documenting":0,
"reliability":0,
"stakeholderSatisfaction":0
}
var currentWeekTime: int = 0
var currentProjWeek: int = 0
var currentProjSprint: int = 0
var workers: Array
var upgrades: Array
var passiveStats = {
"randomEventChance": .33
}

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

func resetData():
	#resets stats to default values
	currentProject = null
	currentMetrics = {"frontEnd":0,"backEnd":0,"documenting":0,"reliability":0,"stakeholderSatisfaction":0}
	workers = []
	upgrades = []
	passiveStats = {"randomEventChance": .33}
	pass

func _ready() -> void:
	var workerNode = Node2D.new()
	workerNode.name = "workerHoldover"
	add_child(workerNode)

func newProject(project) -> void:
	currentProject = project
	currentProjWeek = 1
	currentProjSprint = 1
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
