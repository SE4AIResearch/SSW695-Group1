extends Node2D

func _ready() -> void:
	PlayerTool.hireSelected.connect(setupDeskVisuals)
	initializeSave()
	PlayerTool.level = self
	pass

func _process(delta: float) -> void:
	pass

func initializeSave():
	pass

func setupDeskVisuals():
	for worker in PlayerTool.workers:
		if worker.get_parent().name == "workerHoldover":
			for i in range(1,7):
				var desk = $Level/workers.get_node(str(i)).get_node("worker")
				if desk.get_child_count() == 0:
					worker.reparent(desk)
					worker.position = Vector2(0,0)
		pass
	
