extends Control
class_name TutorialModalPanel

signal dismissed

const PANEL_WIDTH: float = 580.0
const PANEL_HEIGHT: float = 288.0

var _previous_pause_state: bool = false
var _is_dismissing: bool = false

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_previous_pause_state = get_tree().paused
	get_tree().paused = true
	_hide_worker_details()

func _ready() -> void:
	if not $MessagePanel/OkButton.pressed.is_connected(_on_ok_button_pressed):
		$MessagePanel/OkButton.pressed.connect(_on_ok_button_pressed)
	if not $MessagePanel/OkButton.gui_input.is_connected(_on_ok_button_gui_input):
		$MessagePanel/OkButton.gui_input.connect(_on_ok_button_gui_input)
	_layout_modal()

func setup(title: String, message: String, button_text: String = "OK") -> void:
	$MessagePanel/Title.text = title
	$MessagePanel/Message.text = message
	$MessagePanel/OkButton.text = button_text
	_layout_modal()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_modal()

func _layout_modal() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size

	offset_left = 0.0
	offset_top = 0.0
	offset_right = viewport_size.x
	offset_bottom = viewport_size.y

	$InputBlocker.offset_left = 0.0
	$InputBlocker.offset_top = 0.0
	$InputBlocker.offset_right = viewport_size.x
	$InputBlocker.offset_bottom = viewport_size.y

	$Overlay.offset_left = 0.0
	$Overlay.offset_top = 0.0
	$Overlay.offset_right = viewport_size.x
	$Overlay.offset_bottom = viewport_size.y

	$MessagePanel.offset_left = (viewport_size.x - PANEL_WIDTH) / 2.0
	$MessagePanel.offset_top = (viewport_size.y - PANEL_HEIGHT) / 2.0
	$MessagePanel.offset_right = $MessagePanel.offset_left + PANEL_WIDTH
	$MessagePanel.offset_bottom = $MessagePanel.offset_top + PANEL_HEIGHT

func _on_ok_button_pressed() -> void:
	_dismiss()

func _on_ok_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			accept_event()
			_dismiss()

func _dismiss() -> void:
	if _is_dismissing:
		return
	_is_dismissing = true
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().paused = _previous_pause_state
	queue_free()
	dismissed.emit()

func _hide_worker_details() -> void:
	var scene_root: Node = get_tree().current_scene
	if scene_root == null:
		return

	var worker_details: Node = scene_root.get_node_or_null("UI/WorkerDetails")
	if worker_details != null and worker_details.has_method("hide_worker"):
		worker_details.hide_worker()
