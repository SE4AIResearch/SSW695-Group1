extends Node

signal projectSelected
signal projectFinished
signal hireSelected

var level

var currentProject: Node
var currentMetrics={
"frontEnd":0,
"backEnd":0,
"documenting":0,
"reliability":0,
"stakeholderSatisfaction":0
}
var workers: Array
var upgrades: Array
var passiveStats = {
"randomEventChance": .33
}

func initializeNewSave():
	var freeWorker1 = PersonConstructor.generateWorker()
	var freeWorker2 = PersonConstructor.generateWorker()
	PersonConstructor.setBasicStats(freeWorker1)
	PersonConstructor.setBasicStats(freeWorker2)
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
	#Insert Methodology chosen Manipulation here
	
	
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
