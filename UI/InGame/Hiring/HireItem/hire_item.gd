extends Button

signal selected(heldWorker)
var heldWorker = Node2D

func fillInfo(worker):
	heldWorker = worker
	$workerInfo.text = worker.personName + '\nFront End: ' + str(worker.frontEndStat) + "\nBack End: " + str(worker.backEndStat) + '\nDocumenting: ' + str(worker.documentingStat) + '\nSpeed: ' + str(worker.speedStat) + '\nStamina: ' + str(worker.staminaStat)
	heldWorker.set_progress_bars_visible(false)
	$spriteMarker.add_child(heldWorker)
	pass


func _on_pressed() -> void:
	selected.emit(heldWorker)
	pass
