extends Node

signal projectSelected
signal hireSelected

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

func newProject(project) -> void:
	currentProject = project
	#Insert Methodology chosen Manipulation here
	
	
	projectSelected.emit()
	pass

func newHire(worker) -> void:
	workers.append(worker)
	hireSelected.emit()
	pass
	
func newUpgrade(upgrade) -> void:
	pass