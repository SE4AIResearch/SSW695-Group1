extends Button

signal WorkerSelected(button)

var heldWorker: Node
var isBusy: bool = false
var isResting: bool = false
const STATUS_BUSY_COLOR: Color = Color(0.96, 0.76, 0.18)
const STATUS_FREE_COLOR: Color = Color(0.2, 0.78, 0.36)
const STATUS_RESTING_COLOR: Color = Color(0.017259976, 0.4440687, 0.8440869)

func createWorkerItem(worker):
	heldWorker = worker
	if material:
		material = material.duplicate()
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

func setBusyStatus(is_busy: bool) -> void:
	setWorkerStatus(is_busy, false)

func setWorkerStatus(is_busy: bool, is_resting: bool) -> void:
	isBusy = is_busy
	isResting = is_resting
	update_shader_opacity()
	if is_resting:
		$StatusLabel.text = "RESTING"
		$StatusLabel.add_theme_color_override("font_color", _get_resting_status_color())
		return
	$StatusLabel.text = "BUSY" if is_busy else "FREE"
	$StatusLabel.add_theme_color_override("font_color", STATUS_BUSY_COLOR if is_busy else STATUS_FREE_COLOR)

func setAssignmentLabel(assignmentText: String) -> void:
	if assignmentText == "":
		$textParent/nameLabel.text = heldWorker.personName
	else:
		var shortenedAssignment = assignmentText
		if shortenedAssignment.begins_with("Assigned: "):
			shortenedAssignment = shortenedAssignment.trim_prefix("Assigned: ")
		if shortenedAssignment.length() > 22:
			shortenedAssignment = shortenedAssignment.substr(0, 19) + "..."
		$textParent/nameLabel.text = heldWorker.personName + "\nOn: " + shortenedAssignment

func _get_resting_status_color() -> Color:
	if heldWorker != null:
		var resting_color = heldWorker.get("restingColor")
		if resting_color is Color:
			return resting_color
	return STATUS_RESTING_COLOR

func update_shader_opacity(someone_selected: bool = false, is_this_selected: bool = false):
	var opacity = 0.0
	if someone_selected:
		if is_this_selected:
			opacity = 1.0
		else:
			opacity = 0.0
	elif not isBusy and not isResting:
		opacity = 1.0
		
	if material:
		material.set_shader_parameter("opacity", opacity)

func _on_pressed() -> void:
	WorkerSelected.emit(self)
	
