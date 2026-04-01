extends Button

signal WorkerSelected(button)

var heldWorker: Node

func createWorkerItem(worker):
	heldWorker = worker
	$Person.get_node("headSprite").texture = worker.get_node("headSprite").texture
	$Person.get_node("hairSprite").texture = worker.get_node("hairSprite").texture
	$Person.get_node("mouthSprite").texture = worker.get_node("mouthSprite").texture
	$Person.get_node("noseSprite").texture = worker.get_node("noseSprite").texture
	$Person.get_node("eyeSprite").texture = worker.get_node("eyeSprite").texture
	$Person.get_node("headSprite").modulate = worker.get_node("headSprite").modulate
	$Person.get_node("hairSprite").modulate = worker.get_node("hairSprite").modulate
	$Person.get_node("noseSprite").modulate = worker.get_node("noseSprite").modulate
	
	$textParent/nameLabel.text = worker.personName
	$textParent/statsLabel.text = "[color=#fc2403]Front End: " + str(worker.frontEndStat) + "[/color] \n [color=#30c4ff]Back End: " + str(worker.backEndStat) + "[/color] \n [color=#03fc41]Documenting: " + str(worker.documentingStat)
	pass


func _on_pressed() -> void:
	WorkerSelected.emit(self)
	
