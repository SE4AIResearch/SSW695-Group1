class_name PCWindowLayout
extends RefCounted

# shared PC window chrome.
const WINDOW_LEFT := 60.0
const WINDOW_TOP := 60.0
const WINDOW_WIDTH := 1035.0
const WINDOW_HEIGHT := 525.0

const TITLE_SIDE_PADDING := 180.0
const TITLE_TOP_PADDING := 30.0
const TITLE_HEIGHT := 38.0

const CLOSE_BUTTON_WIDTH := 80.0
const CLOSE_BUTTON_HEIGHT := 20.0
const CLOSE_BUTTON_TOP_PADDING := 35.0
const CLOSE_BUTTON_RIGHT_PADDING := 50.0
static func apply(root: Node) -> void:
	var frame: Control = root.get_node_or_null("WindowFrame") as Control
	var title: Control = root.get_node_or_null("Title") as Control
	var close_button: Control = root.get_node_or_null("PCBack") as Control

	if frame == null or title == null or close_button == null:
		return

	if root is Node2D:
		(root as Node2D).position = Vector2.ZERO

	var window_right: float = WINDOW_LEFT + WINDOW_WIDTH
	var window_bottom: float = WINDOW_TOP + WINDOW_HEIGHT
	var close_left: float = window_right - CLOSE_BUTTON_RIGHT_PADDING - CLOSE_BUTTON_WIDTH
	var close_top: float = WINDOW_TOP + CLOSE_BUTTON_TOP_PADDING

	frame.offset_left = WINDOW_LEFT
	frame.offset_top = WINDOW_TOP
	frame.offset_right = window_right
	frame.offset_bottom = window_bottom

	title.offset_left = WINDOW_LEFT + TITLE_SIDE_PADDING
	title.offset_top = WINDOW_TOP + TITLE_TOP_PADDING
	title.offset_right = WINDOW_LEFT + WINDOW_WIDTH - TITLE_SIDE_PADDING
	title.offset_bottom = title.offset_top + TITLE_HEIGHT

	close_button.offset_left = close_left
	close_button.offset_top = close_top
	close_button.offset_right = close_left + CLOSE_BUTTON_WIDTH
	close_button.offset_bottom = close_top + CLOSE_BUTTON_HEIGHT

static func content_rect() -> Rect2:
	return Rect2(
		WINDOW_LEFT + 32.0,
		WINDOW_TOP + 72.0,
		WINDOW_WIDTH - 64.0,
		WINDOW_HEIGHT - 104.0
	)
