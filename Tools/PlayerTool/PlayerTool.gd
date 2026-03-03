extends Node

signal projectSelected
signal projectFinished
signal hireSelected

var currentProject: Node
var currentMetrics={
"frontEnd":5,
"backEnd":5,
"documenting":5,
"reliability":5,
"stakeholderSatisfaction":5
}
var workers: Array
var upgrades: Array


func newProject(project) -> void:
	currentProject = project
	projectSelected.emit()
	pass

func newHire(worker) -> void:
	workers.append(worker)
	hireSelected.emit()
	pass
	
func newUpgrade(upgrade) -> void:
	pass