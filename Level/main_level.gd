extends Node2D

@onready var worker_details = $UI/WorkerDetails


func _ready() -> void:
	TimeTool.weekPassed.connect(rollEvent)
	PlayerTool.hireSelected.connect(setupDeskVisuals)
	initializeSave()
	PlayerTool.level = self
	setupDeskVisuals()
	PlayerTool.levelLoaded.emit()

func initializeSave():
	pass

func setupDeskVisuals():
	var workerCount = 1
	for worker in PlayerTool.workers:
		worker.set_progress_bars_visible(true)
		if not worker.hover_started.is_connected(_on_worker_hover_started):
			worker.hover_started.connect(_on_worker_hover_started)
		if not worker.hover_ended.is_connected(_on_worker_hover_ended):
			worker.hover_ended.connect(_on_worker_hover_ended)
		var desk = $Level/workers.get_node(str(workerCount)).get_node("worker")
		$Level/workers.get_node(str(workerCount)).get_node("computer").animation = "on"
		if desk.get_child_count() == 0:
			worker.reparent(desk)
			worker.position = Vector2(0,0)
		workerCount += 1
		pass

func _on_worker_hover_started(worker) -> void:
	worker_details.show_worker(worker)

func _on_worker_hover_ended(worker) -> void:
	worker_details.hide_worker()

func rollEvent():
	var chance = randf_range(0,1)
	if chance <= PlayerTool.currentProject.eventChance: $UI.startEvent()
	pass
