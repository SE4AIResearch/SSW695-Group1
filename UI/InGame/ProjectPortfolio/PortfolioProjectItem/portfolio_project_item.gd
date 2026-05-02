extends Button

const ROW_HEIGHT := 124.0

const METRIC_ROWS := [
	{
		"key": "stakeholderSatisfaction",
		"label": "Stakeholder Satisfaction",
		"label_node": "StakeholderLabel",
		"bar_node": "StakeholderBar",
	},
	{
		"key": "frontEnd",
		"label": "Front End",
		"label_node": "FrontEndLabel",
		"bar_node": "FrontEndBar",
	},
	{
		"key": "backEnd",
		"label": "Back End",
		"label_node": "BackEndLabel",
		"bar_node": "BackEndBar",
	},
	{
		"key": "reliability",
		"label": "Reliability",
		"label_node": "ReliabilityLabel",
		"bar_node": "ReliabilityBar",
	},
	{
		"key": "documenting",
		"label": "Documentation",
		"label_node": "DocumentationLabel",
		"bar_node": "DocumentationBar",
	},
]

var _record: Dictionary = {}

func _ready() -> void:
	if not resized.is_connected(_apply_layout):
		resized.connect(_apply_layout)
	_refresh_content()
	call_deferred("_apply_layout")

func setup(record: Dictionary) -> void:
	_record = record.duplicate(true)
	if is_inside_tree():
		_refresh_content()
		_apply_layout()

func _refresh_content() -> void:
	var project_name := str(_record.get("project_name", "Project")).strip_edges()
	var client_name := str(_record.get("client_name", "Unknown Client")).strip_edges()

	$ProjectName.text = project_name.to_upper()
	$ClientLabel.text = "CLIENT:  " + client_name.to_upper()
	$CurrencyAmount.text = _format_currency(float(_record.get("currency_earned", 0.0)))
	$CompletedAtLabel.text = _format_completed_at(_record.get("completed_at", {}))

	var metrics := _get_record_dictionary("metrics")
	var metric_maxes := _get_record_dictionary("metric_maxes")
	for row in METRIC_ROWS:
		var metric_key := str(row.get("key", ""))
		var bar := get_node(str(row.get("bar_node", ""))) as TextureProgressBar
		bar.max_value = maxf(1.0, float(metric_maxes.get(metric_key, 1.0)))
		bar.value = clampf(float(metrics.get(metric_key, 0.0)), 0.0, float(bar.max_value))

func _apply_layout() -> void:
	var row_width := maxf(size.x, custom_minimum_size.x)
	var left := 18.0
	var right_panel_width := 214.0
	var divider_left := row_width - right_panel_width - 16.0
	var left_width := divider_left - left - 16.0

	_place_control($ProjectName, left, 10.0, left_width, 22.0)
	_place_control($ClientLabel, left, 34.0, left_width, 18.0)

	var metric_top := 73.0
	var metric_gap := 10.0
	var metric_width := maxf(64.0, (left_width - (metric_gap * float(METRIC_ROWS.size() - 1))) / float(METRIC_ROWS.size()))
	for index in range(METRIC_ROWS.size()):
		var row: Dictionary = METRIC_ROWS[index]
		var metric_left := left + (float(index) * (metric_width + metric_gap))
		_place_control(get_node(str(row.get("label_node", ""))) as Control, metric_left, metric_top, metric_width, 16.0)
		_place_control(get_node(str(row.get("bar_node", ""))) as Control, metric_left, metric_top + 18.0, metric_width, 12.0)

	_place_control($Divider, divider_left, 8.0, 1.0, ROW_HEIGHT - 16.0)

	var right_left := divider_left + 22.0
	_place_control($CurrencyTitle, right_left, 14.0, right_panel_width - 36.0, 16.0)
	_place_control($CurrencyAmount, right_left, 32.0, right_panel_width - 36.0, 28.0)
	_place_control($CompletedAtLabel, right_left, 78.0, right_panel_width - 36.0, 18.0)
	_place_control($CompletedLabel, right_left, 96.0, right_panel_width - 36.0, 16.0)

func _get_record_dictionary(key: String) -> Dictionary:
	var value = _record.get(key, {})
	if value is Dictionary:
		return value
	return {}

func _format_completed_at(raw_completed_at) -> String:
	if raw_completed_at is Dictionary:
		var completed_at: Dictionary = raw_completed_at
		if completed_at.has("year"):
			return "%02d/%02d/%04d %02d:%02d" % [
				int(completed_at.get("month", 0)),
				int(completed_at.get("day", 0)),
				int(completed_at.get("year", 0)),
				int(completed_at.get("hour", 0)),
				int(completed_at.get("minute", 0)),
			]

	var completed_at_text := str(_record.get("completed_at_text", "")).strip_edges()
	if !completed_at_text.is_empty():
		return completed_at_text
	return "--/--/---- --:--"

func _format_currency(amount: float) -> String:
	var is_negative := amount < 0.0
	var cents := int(round(absf(amount) * 100.0))
	var whole := int(floor(float(cents) / 100.0))
	var fraction := cents % 100
	var prefix := "-$" if is_negative else "$"
	return "%s%s.%02d" % [prefix, _format_integer_with_commas(whole), fraction]

func _format_integer_with_commas(value: int) -> String:
	var text := str(value)
	var result := ""
	var digits_since_comma := 0
	for index in range(text.length() - 1, -1, -1):
		if digits_since_comma > 0 and digits_since_comma % 3 == 0:
			result = "," + result
		result = text.substr(index, 1) + result
		digits_since_comma += 1
	return result

func _place_control(control: Control, left: float, top: float, width: float, height: float) -> void:
	control.offset_left = left
	control.offset_top = top
	control.offset_right = left + width
	control.offset_bottom = top + height
