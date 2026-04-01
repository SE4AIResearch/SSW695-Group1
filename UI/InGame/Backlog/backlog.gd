extends Node2D

var backlogItem = preload("res://UI/InGame/Backlog/BacklogItem/BacklogItem.tscn")
var backlogWorkerItem = preload("res://UI/InGame/Backlog/BacklogWorkerItem/BacklogWorkerItem.tscn")

var selectedWorker: Node
var selectedItem: Array

func _ready() -> void:
	populateWorkerBacklog()
	addBacklogItem()

func addBacklogItem():
	for i in range(PlayerTool.currentProject.frontEndMetrics.size()):
		newBEItem(PlayerTool.currentProject.frontEndMetrics.get(i),0)
	for i in range(PlayerTool.currentProject.backEndMetrics.size()):
		newBEItem(PlayerTool.currentProject.backEndMetrics.get(i),1)
	for i in range(PlayerTool.currentProject.documentingMetrics.size()):
		newBEItem(PlayerTool.currentProject.documentingMetrics.get(i),2)
		
	pass

# Types: 0 = FE, 1 = BE ,2 = Doc
func newBEItem(metric,type):
	var newItem = backlogItem.instantiate()
	newItem.prepItem(metric,type)
	newItem.MetricChosen.connect(backlogSelected)
	$BacklogScroll/Backlog.add_child(newItem)
	pass

func populateWorkerBacklog(): 
	for worker in PlayerTool.workers:
		var newWorker = backlogWorkerItem.instantiate()
		newWorker.createWorkerItem(worker)
		newWorker.WorkerSelected.connect(workerSelected)
		$WorkersScroll/Workers.add_child(newWorker)

func backlogSelected(metricName,metricType): 
	selectedItem = [metricName,metricType]

func workerSelected(worker):
	selectedWorker = worker