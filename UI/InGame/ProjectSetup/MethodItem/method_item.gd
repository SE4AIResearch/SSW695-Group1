extends Button

signal MethodChosen(heldMetric)

const CONTENT_PADDING_X := 8.0
const CONTENT_PADDING_TOP := 18.0
const CONTENT_PADDING_BOTTOM := 18.0

var method: Dictionary

func _ready() -> void:
	_refresh_layout()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_refresh_layout()

func _on_pressed() -> void:
	MethodChosen.emit(method)
	pass

func setupMetric(newMethod: Dictionary):
	method = newMethod
	$MetricInfo.bbcode_enabled = true
	$MetricInfo.text = _build_method_text()
	_refresh_layout()
	pass

func _refresh_layout() -> void:
	if !has_node("MetricInfo"):
		return

	$MetricInfo.offset_left = CONTENT_PADDING_X
	$MetricInfo.offset_top = CONTENT_PADDING_TOP
	$MetricInfo.offset_right = size.x - CONTENT_PADDING_X
	$MetricInfo.offset_bottom = size.y - CONTENT_PADDING_BOTTOM

func _build_method_text() -> String:
	var method_name := str(method.get("name", ""))
	var keywords: Array = method.get("keywords", [])
	var lines := ["[center]%s[/center]" % method_name]

	if keywords.is_empty():
		return "\n".join(lines)

	lines.append("")
	for keyword in keywords:
		lines.append("- %s" % str(keyword))

	return "\n".join(lines)
