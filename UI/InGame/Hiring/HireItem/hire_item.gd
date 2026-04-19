extends Button

signal selected(heldWorker, hire_cost)

var heldWorker = Node2D
var hireCost: int = 0

func fillInfo(worker, cost: int) -> void:
	heldWorker = worker
	hireCost = cost
	$workerInfo.text = worker.personName + '\nFront End: ' + str(worker.frontEndStat) + "\nBack End: " + str(worker.backEndStat) + '\nDocumenting: ' + str(worker.documentingStat) + '\nSpeed: ' + str(worker.speedStat) + '\nStamina: ' + str(worker.staminaStat)
	$spriteMarker.add_child(heldWorker)
	heldWorker.set_progress_bars_visible(false)

func _on_pressed() -> void:
	selected.emit(heldWorker, hireCost)
