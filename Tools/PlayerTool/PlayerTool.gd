extends Node

signal projectSelected
signal hireSelected

var currentProject: Node
var currentProjectStats: Dictionary
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