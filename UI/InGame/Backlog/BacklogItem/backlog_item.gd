extends Button

signal MetricChosen(button)
signal WorkerDragStarted(worker_id)

var heldItem: Dictionary = {}
const CARD_WIDTH: float = 192.0
const CARD_PADDING_X: float = 12.0
const CARD_MIN_HEIGHT: float = 64.0
const CARD_TOP_PADDING: float = 10.0
const ASSIGNED_CARD_TOP_PADDING: float = 16.0
const CARD_BOTTOM_PADDING: float = 10.0
const CARD_GAP: float = 4.0
const ASSIGNED_AVATAR_SLOT_WIDTH: float = 52.0
const TITLE_FONT_SIZE: int = 12
const DETAIL_FONT_SIZE: int = 10
const TITLE_LINE_HEIGHT: float = 15.0
const DETAIL_LINE_HEIGHT: float = 12.0

func prepItem(item, itemType: int = -1):
	if material:
		material = material.duplicate()
	if item is Dictionary:
		heldItem = item
	else:
		var requiredSkill: String = "frontEnd"
		match itemType:
			1:
				requiredSkill = "backEnd"
			2:
				requiredSkill = "documenting"
		heldItem = {
			"name": str(item),
			"required_skill": requiredSkill,
			"effort_remaining": 1,
			"total_effort": 1,
			"status": "todo",
		}

	var requiredSkill: String = str(heldItem.get("required_skill", "frontEnd"))
	var skillColor: String = "#fc2403"
	var skillLabel: String = "Front End"
	match requiredSkill:
		"backEnd":
			skillColor = "#30c4ff"
			skillLabel = "Back End"
		"documenting":
			skillColor = "#03fc41"
			skillLabel = "Documentation"

	var tags: Array = []
	if bool(heldItem.get("is_scope_change", false)):
		tags.append("Scope Change")
	if bool(heldItem.get("is_reliability_critical", false)):
		tags.append("Reliability Critical")
	if heldItem.get("status") == "done":
		tags.append("Complete")
	elif heldItem.get("status") == "in_progress":
		tags.append("In Progress")

	$metricName.text = "[color=%s]%s" % [skillColor, str(heldItem.get("name", "Backlog Item"))]
	var detailText: String = "[color=%s]%s | Effort %d/%d" % [
		skillColor,
		skillLabel,
		int(heldItem.get("effort_remaining", 0)),
		int(heldItem.get("total_effort", 0)),
	]
	if not tags.is_empty():
		detailText += " | " + " | ".join(tags)
	$metricDetails.text = detailText
	_refresh_assigned_worker_preview()
	call_deferred("_refresh_card_layout")

func _refresh_assigned_worker_preview() -> void:
	var assignedWorkerId: String = str(heldItem.get("assigned_worker_id", ""))
	var assignedWorker: Node = PlayerTool.getWorkerById(assignedWorkerId)
	$assignedWorkerPreview.visible = assignedWorker != null
	if assignedWorker == null:
		return

	_copy_worker_visual(assignedWorker, $assignedWorkerPreview)

func _copy_worker_visual(sourceWorker: Node, targetPerson: Node) -> void:
	targetPerson.get_node("headSprite").texture = sourceWorker.get_node("headSprite").texture
	targetPerson.get_node("hairSprite").texture = sourceWorker.get_node("hairSprite").texture
	targetPerson.get_node("mouthSprite").texture = sourceWorker.get_node("mouthSprite").texture
	targetPerson.get_node("noseSprite").texture = sourceWorker.get_node("noseSprite").texture
	targetPerson.get_node("eyeSprite").texture = sourceWorker.get_node("eyeSprite").texture
	targetPerson.get_node("headSprite").modulate = sourceWorker.get_node("headSprite").modulate
	targetPerson.get_node("hairSprite").modulate = sourceWorker.get_node("hairSprite").modulate
	targetPerson.get_node("noseSprite").modulate = sourceWorker.get_node("noseSprite").modulate

func _refresh_card_layout() -> void:
	_apply_card_layout()
	if not is_inside_tree():
		return
	await get_tree().process_frame
	if is_inside_tree():
		_apply_card_layout()

func _apply_card_layout() -> void:
	var hasAssignedWorker: bool = $assignedWorkerPreview.visible
	var topPadding: float = ASSIGNED_CARD_TOP_PADDING if hasAssignedWorker else CARD_TOP_PADDING
	var textLeft: float = CARD_PADDING_X + (ASSIGNED_AVATAR_SLOT_WIDTH if hasAssignedWorker else 0.0)
	var textWidth: float = CARD_WIDTH - textLeft - CARD_PADDING_X
	var nameHeight: float = _get_label_height($metricName, textWidth, TITLE_FONT_SIZE, TITLE_LINE_HEIGHT)
	var detailsHeight: float = _get_label_height($metricDetails, textWidth, DETAIL_FONT_SIZE, DETAIL_LINE_HEIGHT)

	$metricName.position = Vector2(textLeft, topPadding)
	$metricName.custom_minimum_size = Vector2(textWidth, nameHeight)
	$metricName.size = Vector2(textWidth, nameHeight)

	var detailsTop: float = topPadding + nameHeight + CARD_GAP
	$metricDetails.position = Vector2(textLeft, detailsTop)
	$metricDetails.custom_minimum_size = Vector2(textWidth, detailsHeight)
	$metricDetails.size = Vector2(textWidth, detailsHeight)

	var totalHeight: float = detailsTop + detailsHeight + CARD_BOTTOM_PADDING
	custom_minimum_size = Vector2(CARD_WIDTH, maxf(totalHeight, CARD_MIN_HEIGHT))
	size = custom_minimum_size

func _get_label_height(label: RichTextLabel, availableWidth: float, fontSize: int, lineHeight: float) -> float:
	var estimatedHeight: float = _estimate_wrapped_text_height(label.text, availableWidth, fontSize, lineHeight)
	var measuredHeight: float = label.get_content_height()
	if measuredHeight <= 0:
		return estimatedHeight
	return maxf(estimatedHeight, measuredHeight)

func _estimate_wrapped_text_height(bbcodeText: String, availableWidth: float, fontSize: int, lineHeight: float) -> float:
	var averageCharacterWidth: float = maxf(1.0, float(fontSize) * 0.55)
	var maxCharactersPerLine: int = maxi(1, int(floor(availableWidth / averageCharacterWidth)))
	return float(_estimate_wrapped_line_count(_strip_bbcode(bbcodeText), maxCharactersPerLine)) * lineHeight

func _estimate_wrapped_line_count(text: String, maxCharactersPerLine: int) -> int:
	var lineCount: int = 0
	for rawParagraph in text.split("\n"):
		var paragraph: String = str(rawParagraph).strip_edges()
		if paragraph == "":
			lineCount += 1
			continue

		var currentLineLength: int = 0
		for rawWord in paragraph.split(" ", false):
			var wordLength: int = str(rawWord).length()
			if wordLength == 0:
				continue
			if currentLineLength == 0:
				currentLineLength = wordLength
			elif currentLineLength + 1 + wordLength <= maxCharactersPerLine:
				currentLineLength += 1 + wordLength
			else:
				lineCount += 1
				currentLineLength = wordLength
			while currentLineLength > maxCharactersPerLine:
				lineCount += 1
				currentLineLength -= maxCharactersPerLine
		if currentLineLength > 0:
			lineCount += 1
	return maxi(lineCount, 1)

func _strip_bbcode(text: String) -> String:
	var plainText: String = ""
	var insideTag: bool = false
	for index in range(text.length()):
		var character: String = text.substr(index, 1)
		if character == "[":
			insideTag = true
		elif character == "]":
			insideTag = false
		elif not insideTag:
			plainText += character
	return plainText

func update_shader_opacity(worker_is_selected: bool):
	var is_completed = heldItem.get("status") == "done"
	
	var opacity = 0.0
	if worker_is_selected and not is_completed:
		opacity = 1.0
	
	if material:
		material.set_shader_parameter("opacity", opacity)

func isDropTarget() -> bool:
	return heldItem.get("status") != "done"

func getItemId() -> int:
	return int(heldItem.get("id", -1))

func _on_pressed() -> void:
	MetricChosen.emit(self)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if $assignedWorkerPreview.visible:
			var assignedWorkerId: String = str(heldItem.get("assigned_worker_id", ""))
			var avatarWidth := CARD_PADDING_X + ASSIGNED_AVATAR_SLOT_WIDTH
			if assignedWorkerId != "" and get_local_mouse_position().x < avatarWidth:
				WorkerDragStarted.emit(assignedWorkerId)
				accept_event()
