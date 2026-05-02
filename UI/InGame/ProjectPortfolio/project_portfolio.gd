extends Node2D

const PCWindowLayout = preload("res://UI/InGame/PCWindow/pc_window_layout.gd")

const METRIC_ROWS := [
	{
		"key": "frontEnd",
		"label": "Front End",
		"target_property": "frontEndProjectMin",
		"bar": "frontEndBar",
		"value": "frontEndValue",
		"max_default": 1,
	},
	{
		"key": "backEnd",
		"label": "Back End",
		"target_property": "backEndProjectMin",
		"bar": "backEndBar",
		"value": "backEndValue",
		"max_default": 1,
	},
	{
		"key": "documenting",
		"label": "Documentation",
		"target_property": "documentingProjectMin",
		"bar": "documentationBar",
		"value": "documentationValue",
		"max_default": 1,
	},
	{
		"key": "reliability",
		"label": "Reliability",
		"target_property": "",
		"bar": "reliabilityBar",
		"value": "reliabilityValue",
		"max_default": 100,
	},
	{
		"key": "stakeholderSatisfaction",
		"label": "Stakeholder Satisfaction",
		"target_property": "",
		"bar": "stakeholderBar",
		"value": "stakeholderValue",
		"max_default": 100,
	},
]

const SUMMARY_WIDTH := 380.0
const METRIC_LABEL_WIDTH := 210.0
const METRIC_VALUE_WIDTH := 96.0
const METRIC_BAR_WIDTH := 390.0
const METRIC_BAR_HEIGHT := 16.0
const METRIC_ROW_HEIGHT := 44.0

func _ready() -> void:
	PCWindowLayout.apply(self)
	_apply_content_layout()
	_connect_player_signals()
	_refresh()

func _apply_content_layout() -> void:
	var content_rect: Rect2 = PCWindowLayout.content_rect()
	var content_left := content_rect.position.x + 38.0
	var content_top := content_rect.position.y + 26.0
	var metrics_left := content_rect.position.x + 470.0
	var metrics_top := content_rect.position.y + 70.0

	_place_control($SummaryLabel, content_left, content_top, SUMMARY_WIDTH, 174.0)
	_place_control($CompletedProjectsLabel, content_left, content_top + 198.0, SUMMARY_WIDTH, 34.0)
	_place_control($NoActiveProjectLabel, content_left, content_top + 250.0, SUMMARY_WIDTH, 74.0)
	_place_control($MetricHeader, metrics_left, content_top, 440.0, 38.0)

	for i in range(METRIC_ROWS.size()):
		var row: Dictionary = METRIC_ROWS[i]
		var row_top := metrics_top + (METRIC_ROW_HEIGHT * i)
		_place_control(get_node(str(row.get("key", "")) + "Label") as Control, metrics_left, row_top, METRIC_LABEL_WIDTH, 28.0)
		_place_control(get_node(str(row.get("value", ""))) as Control, metrics_left + METRIC_LABEL_WIDTH, row_top, METRIC_VALUE_WIDTH, 28.0)
		_place_control(get_node(str(row.get("bar", ""))) as Control, metrics_left, row_top + 26.0, METRIC_BAR_WIDTH, METRIC_BAR_HEIGHT)

func _connect_player_signals() -> void:
	if not PlayerTool.statsChanged.is_connected(_refresh):
		PlayerTool.statsChanged.connect(_refresh)
	if not PlayerTool.projectSelected.is_connected(_refresh):
		PlayerTool.projectSelected.connect(_refresh)
	if not PlayerTool.deadlineReached.is_connected(_refresh):
		PlayerTool.deadlineReached.connect(_refresh)
	if not PlayerTool.scoreChanged.is_connected(_refresh):
		PlayerTool.scoreChanged.connect(_refresh)

func _refresh() -> void:
	var project = PlayerTool.project
	$CompletedProjectsLabel.text = "Completed Projects: %d" % int(PlayerTool.completed_project_count)
	$NoActiveProjectLabel.visible = project == null

	if project == null:
		$SummaryLabel.text = "No active project"
		$NoActiveProjectLabel.text = "Start a project from the PC menu to see its portfolio details here."
	else:
		$SummaryLabel.text = _build_project_summary(project)
		$NoActiveProjectLabel.text = ""

	_refresh_metrics(project)

func _build_project_summary(project) -> String:
	var methodology_name := str(project.methodology.get("name", "Not selected"))
	return "Project: %s\nClient: %s\nMethodology: %s\nSprint: %d / %d\nWeek: %d / %d" % [
		str(project.projectName),
		str(project.clientName),
		methodology_name,
		int(PlayerTool.projSprint),
		int(project.sprintAmount),
		int(PlayerTool.projWeek),
		int(project.sprintLength),
	]

func _refresh_metrics(project) -> void:
	for row in METRIC_ROWS:
		var metric_key := str(row.get("key", ""))
		var metric_value := int(PlayerTool.metrics.get(metric_key, 0))
		var metric_max := _get_metric_max(project, row)
		var bar := get_node(str(row.get("bar", ""))) as TextureProgressBar
		var value_label := get_node(str(row.get("value", ""))) as Label

		bar.max_value = metric_max
		bar.value = clampi(metric_value, 0, metric_max)
		value_label.text = "%d / %d" % [metric_value, metric_max]

func _get_metric_max(project, row: Dictionary) -> int:
	if project == null:
		return int(row.get("max_default", 1))

	var target_property := str(row.get("target_property", ""))
	if not target_property.is_empty():
		return maxi(1, int(project.get(target_property)))

	if str(row.get("key", "")) == "reliability" and PlayerTool.totalEvents > 0:
		return maxi(1, int(PlayerTool.totalEvents))

	return int(row.get("max_default", 100))

func _place_control(control: Control, left: float, top: float, width: float, height: float) -> void:
	control.offset_left = left
	control.offset_top = top
	control.offset_right = left + width
	control.offset_bottom = top + height

func _on_pc_back_pressed() -> void:
	get_parent().get_parent().endMenu()
