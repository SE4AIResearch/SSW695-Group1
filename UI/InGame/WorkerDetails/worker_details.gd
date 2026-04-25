extends Node2D

const PANEL_OFFSET := Vector2(28, -120)
const VIEWPORT_PADDING := 12.0
const UPGRADE_BONUS_COLOR := "#72e647"

@onready var panel: Panel = $Panel
@onready var worker_info: RichTextLabel = $Panel/WorkerInfo

func _ready() -> void:
	worker_info.bbcode_enabled = true
	visible = false

func show_worker(worker) -> void:
	worker_info.text = (
		worker.personName
		+ "\n" + _format_stat_line(worker, "Front End", "front_end", worker.frontEndStat)
		+ "\n" + _format_stat_line(worker, "Back End", "back_end", worker.backEndStat)
		+ "\n" + _format_stat_line(worker, "Documenting", "documenting", worker.documentingStat)
		+ "\n" + _format_stat_line(worker, "Speed", "speed", worker.speedStat)
		+ "\n" + _format_stat_line(worker, "Stamina", "stamina", worker.staminaStat)
	)
	global_position = worker.global_position + PANEL_OFFSET
	_clamp_to_viewport()
	visible = true

func hide_worker() -> void:
	visible = false

func _clamp_to_viewport() -> void:
	var viewport_size = get_viewport_rect().size
	global_position.x = clampf(global_position.x, VIEWPORT_PADDING, viewport_size.x - panel.size.x - VIEWPORT_PADDING)
	global_position.y = clampf(global_position.y, VIEWPORT_PADDING, viewport_size.y - panel.size.y - VIEWPORT_PADDING)

func _format_stat_line(worker, label: String, stat_key: String, current_value: int) -> String:
	var line := "%s: %d" % [label, current_value]
	var bonus := _get_worker_upgrade_bonus(worker, stat_key)
	if bonus <= 0.0:
		return line
	return "%s [color=%s](+%s)[/color]" % [line, UPGRADE_BONUS_COLOR, _format_bonus_value(bonus)]

func _get_worker_upgrade_bonus(worker, stat_key: String) -> float:
	if typeof(worker.get("upgradeStatBonuses")) != TYPE_DICTIONARY:
		return 0.0
	return float(worker.upgradeStatBonuses.get(stat_key, 0.0))

func _format_bonus_value(bonus: float) -> String:
	return str(int(floorf(bonus)))
