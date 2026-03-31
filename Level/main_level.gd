extends Node2D

func _ready() -> void:
	PlayerTool.hireSelected.connect(setupDeskVisuals)
	initializeSave()
	PlayerTool.level = self
	setupDeskVisuals()
	pass

func _process(delta: float) -> void:
	pass

func initializeSave():
	pass

func setupDeskVisuals():
	var workerCount = 1
	for worker in PlayerTool.workers:
		var desk = $Level/workers.get_node(str(workerCount)).get_node("worker")
		$Level/workers.get_node(str(workerCount)).get_node("computer").animation = "on"
		if desk.get_child_count() == 0:
			worker.reparent(desk)
			worker.position = Vector2(0,0)
		workerCount += 1
		pass
