extends Button

signal selected(worker)
var heldWorker = Node2D

func fillInfo(worker):
	heldWorker = worker
	$workerInfo.text = worker.personName + '\nFront End: ' + str(worker.frontEndWorkerStat) + "\nBack End: " + str(worker.backEndWorkerStat) + '\nDocumenting: ' + str(worker.documentingWorkerStat) + '\nSpeed: ' + str(worker.speedWorkerStat) + '\nStamina: ' + str(worker.staminaWorkerStat)
	$spriteMarker.add_child(heldWorker)
	pass


func _on_pressed() -> void:
	selected.emit(heldWorker)
	pass
