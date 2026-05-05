extends Control
class_name TutorialModalPanel

# Emitted when the modal is closed (after confirmed/cancelled, if emitted).
signal dismissed
# Emitted when the primary button is pressed.
signal confirmed
# Emitted when the secondary button is pressed.
signal cancelled

const PANEL_WIDTH: float = 580.0
const PANEL_HEIGHT: float = 288.0
const STAMINA_PANEL_HEIGHT: float = 404.0
const BUTTON_WIDTH: float = 240.0
const BUTTON_GAP: float = 20.0

var _previous_pause_state: bool = false
var _is_dismissing: bool = false
var _show_stamina_examples: bool = false
var _show_secondary_button: bool = false

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
	if not $MessagePanel/CancelButton.pressed.is_connected(_on_cancel_button_pressed):
		$MessagePanel/CancelButton.pressed.connect(_on_cancel_button_pressed)
	if not $MessagePanel/CancelButton.gui_input.is_connected(_on_cancel_button_gui_input):
		$MessagePanel/CancelButton.gui_input.connect(_on_cancel_button_gui_input)
	_layout_modal()

func setup(title: String, message: String, button_text: String = "OK", show_stamina_examples: bool = false, secondary_button_text: String = "") -> void:
	_show_stamina_examples = show_stamina_examples
	_show_secondary_button = secondary_button_text != ""
	$MessagePanel/Title.text = title
	$MessagePanel/Message.text = message
	$MessagePanel/OkButton.text = button_text
	$MessagePanel/CancelButton.text = secondary_button_text
	$MessagePanel/CancelButton.visible = _show_secondary_button
	$MessagePanel/StaminaExamples.visible = _show_stamina_examples
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

	var panel_height := STAMINA_PANEL_HEIGHT if _show_stamina_examples else PANEL_HEIGHT

	$MessagePanel.offset_left = (viewport_size.x - PANEL_WIDTH) / 2.0
	$MessagePanel.offset_top = (viewport_size.y - panel_height) / 2.0
	$MessagePanel.offset_right = $MessagePanel.offset_left + PANEL_WIDTH
	$MessagePanel.offset_bottom = $MessagePanel.offset_top + panel_height
	$MessagePanel/BackgroundFill.offset_bottom = panel_height - 18.0

	if _show_stamina_examples:
		$MessagePanel/Message.offset_top = 76.0
		$MessagePanel/Message.offset_bottom = 166.0
	else:
		$MessagePanel/Message.offset_top = 84.0
		$MessagePanel/Message.offset_bottom = 188.0
	var button_top := 312.0 if _show_stamina_examples else 196.0
	var button_bottom := 392.0 if _show_stamina_examples else 276.0
	_layout_buttons(button_top, button_bottom)

func _on_ok_button_pressed() -> void:
	_confirm()

func _on_ok_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			accept_event()
			_confirm()

func _on_cancel_button_pressed() -> void:
	_cancel()

func _on_cancel_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			accept_event()
			_cancel()

func _confirm() -> void:
	if _is_dismissing:
		return
	confirmed.emit()
	_dismiss()

func _cancel() -> void:
	if _is_dismissing:
		return
	cancelled.emit()
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

func _layout_buttons(button_top: float, button_bottom: float) -> void:
	if _show_secondary_button:
		var total_width := (BUTTON_WIDTH * 2.0) + BUTTON_GAP
		var start_left := (PANEL_WIDTH - total_width) / 2.0
		$MessagePanel/OkButton.offset_left = start_left
		$MessagePanel/OkButton.offset_right = start_left + BUTTON_WIDTH
		$MessagePanel/CancelButton.offset_left = start_left + BUTTON_WIDTH + BUTTON_GAP
		$MessagePanel/CancelButton.offset_right = $MessagePanel/CancelButton.offset_left + BUTTON_WIDTH
	else:
		var start_left := (PANEL_WIDTH - BUTTON_WIDTH) / 2.0
		$MessagePanel/OkButton.offset_left = start_left
		$MessagePanel/OkButton.offset_right = start_left + BUTTON_WIDTH

	$MessagePanel/OkButton.offset_top = button_top
	$MessagePanel/OkButton.offset_bottom = button_bottom
	$MessagePanel/CancelButton.offset_top = button_top
	$MessagePanel/CancelButton.offset_bottom = button_bottom
