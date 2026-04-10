extends Button

signal MetricChosen(button)

var heldItem: Dictionary = {}
const CARD_WIDTH := 192.0
const CARD_PADDING_X := 12.0
const CARD_TOP_PADDING := 12.0
const CARD_BOTTOM_PADDING := 12.0
const CARD_GAP := 6.0

func prepItem(item: Dictionary):
	heldItem = item
	var requiredSkill := str(item.get("required_skill", "frontEnd"))
	var skillColor := "#fc2403"
	var skillLabel := "Front End"
	match requiredSkill:
		"backEnd":
			skillColor = "#30c4ff"
			skillLabel = "Back End"
		"documenting":
			skillColor = "#03fc41"
			skillLabel = "Documentation"

	var tags: Array = []
	if bool(item.get("is_scope_change", false)):
		tags.append("Scope Change")
	if bool(item.get("is_reliability_critical", false)):
		tags.append("Reliability Critical")
	if item.get("status") == "done":
		tags.append("Complete")
	elif item.get("status") == "in_progress":
		tags.append("In Progress")

	$metricName.text = "[color=%s]%s" % [skillColor, str(item.get("name", "Backlog Item"))]
	var detailText := "[color=%s]%s | Effort %d/%d" % [
		skillColor,
		skillLabel,
		int(item.get("effort_remaining", 0)),
		int(item.get("total_effort", 0)),
	]
	if not tags.is_empty():
		detailText += " | " + " | ".join(tags)
	$metricDetails.text = detailText
	call_deferred("_refresh_card_layout")

func _refresh_card_layout() -> void:
	var textWidth = CARD_WIDTH - (CARD_PADDING_X * 2.0)
	$metricName.position = Vector2(CARD_PADDING_X, CARD_TOP_PADDING)
	$metricName.custom_minimum_size = Vector2(textWidth, 0)
	$metricName.size = Vector2(textWidth, $metricName.get_content_height())

	var detailsTop = CARD_TOP_PADDING + $metricName.size.y + CARD_GAP
	$metricDetails.position = Vector2(CARD_PADDING_X, detailsTop)
	$metricDetails.custom_minimum_size = Vector2(textWidth, 0)
	$metricDetails.size = Vector2(textWidth, $metricDetails.get_content_height())

	var totalHeight = detailsTop + $metricDetails.size.y + CARD_BOTTOM_PADDING
	custom_minimum_size = Vector2(CARD_WIDTH, max(totalHeight, 64.0))


func _on_pressed() -> void:
	MetricChosen.emit(self)
