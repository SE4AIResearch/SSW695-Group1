extends Node2D

const PANEL_OFFSET := Vector2(28, -120)
const VIEWPORT_PADDING := 12.0

@onready var panel: Panel = $Panel
@onready var worker_info: RichTextLabel = $Panel/WorkerInfo

func _ready() -> void:
	visible = false

func show_worker(worker) -> void:
	worker_info.text = (
		worker.personName
		+ "\nFront End: " + str(worker.frontEndStat)
		+ "\nBack End: " + str(worker.backEndStat)
		+ "\nDocumenting: " + str(worker.documentingStat)
		+ "\nSpeed: " + str(worker.speedStat)
		+ "\nStamina: " + str(worker.staminaStat)
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
