extends Node2D

signal close_requested

const BUTTON_TEXTURE_NORMAL = preload("res://UI/Theme/PCTheme/button/slimButton.png")
const BUTTON_TEXTURE_PRESSED = preload("res://UI/Theme/PCTheme/button/slimButtonPressed.png")
const BUTTON_TEXTURE_HOVER = preload("res://UI/Theme/PCTheme/button/slimButtonHeld.png")

const FONT_BOLD = preload("res://UI/Theme/Fonts/figtree-2.0.3/otf/Figtree-Bold.otf")
const FONT_LIGHT = preload("res://UI/Theme/Fonts/figtree-2.0.3/otf/Figtree-Light.otf")

const NAV_BUTTON_MAX_WIDTH := 240.0
const NAV_PANEL_SIDE_PADDING := 32.0
const TOPIC_INDENT := 40.0
const GROUP_BUTTON_HEIGHT := 66.0
const TOPIC_BUTTON_HEIGHT := 60.0
const NAV_BUTTON_GAP := 12
const GROUP_FONT_SIZE := 16
const TOPIC_FONT_SIZE := 14
const NAV_LABEL_TARGET_LINE_LENGTH := 22

var entries = load("res://UI/Learning Center/entries.gd").new()
var expanded_groups: Dictionary = {}
var current_topic_id: String = ""

var normal_button_style: StyleBoxTexture
var pressed_button_style: StyleBoxTexture
var hover_button_style: StyleBoxTexture

@onready var categories_panel: Sprite2D = $Categories/Sprite2D
@onready var categories_scroll: ScrollContainer = $Categories/ScrollContainer
@onready var categories_container: VBoxContainer = $Categories/ScrollContainer/VBoxContainer
@onready var entry_label: RichTextLabel = $Page/Entry

func _ready() -> void:
	normal_button_style = _make_stylebox(BUTTON_TEXTURE_NORMAL)
	pressed_button_style = _make_stylebox(BUTTON_TEXTURE_PRESSED)
	hover_button_style = _make_stylebox(BUTTON_TEXTURE_HOVER)
	_apply_scene_layout_defaults()

	entry_label.bbcode_enabled = true
	$Page.visible = true
	$Page/previousButton.visible = false
	$Page/nextButton.visible = false
	$Page/ReturnToLCMenu.visible = false

	if !visibility_changed.is_connected(_on_visibility_changed):
		visibility_changed.connect(_on_visibility_changed)

	reset_state()

func _apply_scene_layout_defaults() -> void:
	_layout_navigation_panel()
	categories_scroll.clip_contents = true
	if !categories_container.has_theme_constant_override("separation"):
		categories_container.add_theme_constant_override("separation", NAV_BUTTON_GAP)
	categories_container.custom_minimum_size = Vector2(_get_navigation_content_width(), 0.0)

func _layout_navigation_panel() -> void:
	var nav_button_width: float = _get_navigation_button_width()
	var panel_width: float = nav_button_width + (NAV_PANEL_SIDE_PADDING * 2.0)
	var panel_texture_width: float = 1.0
	if categories_panel.texture != null:
		panel_texture_width = float(categories_panel.texture.get_width())

	categories_panel.scale.x = panel_width / panel_texture_width

	var panel_left: float = categories_panel.position.x - (panel_width / 2.0)
	categories_scroll.offset_left = panel_left
	categories_scroll.offset_right = panel_left + panel_width

func _get_navigation_container_width() -> float:
	var scroll_width: float = categories_scroll.size.x
	if scroll_width <= 0.0:
		scroll_width = categories_scroll.offset_right - categories_scroll.offset_left
	return maxf(0.0, scroll_width)

func _get_navigation_content_width() -> float:
	var content_width: float = _get_navigation_container_width()
	var vertical_scrollbar: VScrollBar = categories_scroll.get_v_scroll_bar()
	if vertical_scrollbar != null:
		var scrollbar_width: float = vertical_scrollbar.size.x
		if scrollbar_width <= 0.0:
			scrollbar_width = vertical_scrollbar.custom_minimum_size.x
		content_width -= scrollbar_width
	return maxf(NAV_BUTTON_MAX_WIDTH + TOPIC_INDENT, content_width)

func _get_navigation_button_width() -> float:
	return NAV_BUTTON_MAX_WIDTH

func reset_state(default_topic_id: String = "") -> void:
	_initialize_group_state()
	var topic_id: String = default_topic_id if default_topic_id != "" else entries.get_default_topic_id()
	_select_topic(topic_id)

func select_topic(topic_id: String) -> void:
	_select_topic(topic_id)

func toggle_group(group_id: String) -> void:
	expanded_groups[group_id] = !bool(expanded_groups.get(group_id, true))
	_rebuild_navigation()

func _on_visibility_changed() -> void:
	if visible:
		reset_state()

func _initialize_group_state() -> void:
	expanded_groups.clear()
	for group in entries.get_learning_groups():
		expanded_groups[str(group.get("id", ""))] = true

func _select_topic(topic_id: String) -> void:
	if topic_id == "":
		return

	current_topic_id = topic_id
	_expand_group_for_topic(topic_id)
	_rebuild_navigation()
	_render_topic(topic_id)

func _expand_group_for_topic(topic_id: String) -> void:
	for group in entries.get_learning_groups():
		var group_id: String = str(group.get("id", ""))
		var topic_ids: Array = group.get("topics", [])
		if topic_ids.has(topic_id):
			expanded_groups[group_id] = true
			return

func _rebuild_navigation() -> void:
	for child in categories_container.get_children():
		child.queue_free()

	for group in entries.get_learning_groups():
		var group_id: String = str(group.get("id", ""))
		var group_title: String = str(group.get("title", ""))
		var nav_button_width: float = _get_navigation_button_width()
		var group_button: Button = Button.new()
		group_button.text = _format_nav_label("%s %s" % ["v" if bool(expanded_groups.get(group_id, true)) else ">", group_title])
		group_button.custom_minimum_size = Vector2(nav_button_width, GROUP_BUTTON_HEIGHT)
		group_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		group_button.focus_mode = Control.FOCUS_NONE
		group_button.mouse_filter = Control.MOUSE_FILTER_STOP
		group_button.pressed.connect(_on_group_button_pressed.bind(group_id))
		_apply_navigation_button_theme(group_button, true, false)
		categories_container.add_child(group_button)

		if !bool(expanded_groups.get(group_id, true)):
			continue

		var topic_ids: Array = group.get("topics", [])
		for topic_id_variant in topic_ids:
			var topic_id: String = str(topic_id_variant)
			var topic: Dictionary = entries.get_topic(topic_id)
			var topic_button: Button = Button.new()
			topic_button.text = _format_nav_label(str(topic.get("title", topic_id)))
			topic_button.custom_minimum_size = Vector2(nav_button_width, TOPIC_BUTTON_HEIGHT)
			topic_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			topic_button.focus_mode = Control.FOCUS_NONE
			topic_button.mouse_filter = Control.MOUSE_FILTER_STOP
			topic_button.pressed.connect(_on_topic_button_pressed.bind(topic_id))
			_apply_navigation_button_theme(topic_button, false, current_topic_id == topic_id)
			categories_container.add_child(_make_indented_topic_row(topic_button))

func _render_topic(topic_id: String) -> void:
	var topic: Dictionary = entries.get_topic(topic_id)
	if topic.is_empty():
		entry_label.text = "[b]Learning Center[/b]\n\nNo article is available for this topic yet."
		return

	var lines: Array = ["[center][b]%s[/b][/center]" % str(topic.get("title", ""))]
	for section in topic.get("sections", []):
		var heading: String = str(section.get("heading", ""))
		var body: String = str(section.get("body", ""))
		if heading != "":
			lines.append("")
			lines.append("[b]%s[/b]" % heading)
		if body != "":
			lines.append(body)

	entry_label.text = "\n".join(lines)
	entry_label.scroll_to_line(0)

func _apply_navigation_button_theme(button: Button, is_group_button: bool, is_selected: bool) -> void:
	button.disabled = false
	button.add_theme_stylebox_override("normal", hover_button_style if is_selected else normal_button_style)
	button.add_theme_stylebox_override("pressed", pressed_button_style)
	button.add_theme_stylebox_override("hover", hover_button_style)
	button.add_theme_stylebox_override("focus", pressed_button_style)
	button.add_theme_font_size_override("font_size", GROUP_FONT_SIZE if is_group_button else TOPIC_FONT_SIZE)
	button.add_theme_font_override("font", FONT_BOLD if is_group_button else FONT_LIGHT)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_focus_color", Color(1, 1, 1, 1))

func _format_nav_label(label: String) -> String:
	var cleaned_label: String = label.strip_edges()
	if cleaned_label.length() <= NAV_LABEL_TARGET_LINE_LENGTH:
		return cleaned_label

	var words: PackedStringArray = cleaned_label.split(" ", false)
	if words.size() < 2:
		return cleaned_label

	var best_wrap: String = cleaned_label
	var best_score: int = 1000000

	for split_index in range(1, words.size()):
		var first_line: String = _join_word_range(words, 0, split_index)
		var second_line: String = _join_word_range(words, split_index, words.size())
		var overflow_penalty: int = maxi(0, first_line.length() - NAV_LABEL_TARGET_LINE_LENGTH) + maxi(0, second_line.length() - NAV_LABEL_TARGET_LINE_LENGTH)
		var line_balance_penalty: int = absi(first_line.length() - second_line.length())
		var line_length_penalty: int = maxi(first_line.length(), second_line.length())
		var score: int = overflow_penalty * 100 + line_length_penalty + line_balance_penalty

		if score < best_score:
			best_score = score
			best_wrap = "%s\n%s" % [first_line, second_line]

	return best_wrap

func _join_word_range(words: PackedStringArray, start_index: int, end_index: int) -> String:
	var combined: String = ""
	for index in range(start_index, end_index):
		if combined != "":
			combined += " "
		combined += words[index]
	return combined

func _make_stylebox(texture: Texture2D) -> StyleBoxTexture:
	var stylebox: StyleBoxTexture = StyleBoxTexture.new()
	stylebox.texture = texture
	return stylebox

func _make_indented_topic_row(topic_button: Button) -> HBoxContainer:
	var topic_row := HBoxContainer.new()
	topic_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	topic_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	topic_row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var indent_spacer := Control.new()
	indent_spacer.custom_minimum_size = Vector2(TOPIC_INDENT, 0.0)
	indent_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	topic_row.add_child(indent_spacer)
	topic_row.add_child(topic_button)
	return topic_row

func _on_group_button_pressed(group_id: String) -> void:
	toggle_group(group_id)

func _on_topic_button_pressed(topic_id: String) -> void:
	_select_topic(topic_id)

func _on_sdlc_overview_pressed() -> void:
	_select_topic("sdlcOverview")

func _on_agile_pressed() -> void:
	_select_topic("agile")

func _on_waterfall_pressed() -> void:
	_select_topic("waterfall")

func _on_v_model_pressed() -> void:
	_select_topic("vModel")

func _on_spiral_pressed() -> void:
	_select_topic("spiral")

func _on_project_constraints_pressed() -> void:
	_select_topic("projectConstraints")

func _on_stakeholder_management_pressed() -> void:
	_select_topic("stakeholderManagement")

func _on_sprint_planning_basics_pressed() -> void:
	_select_topic("sprintPlanning")

func _on_risk_management_pressed() -> void:
	_select_topic("riskManagement")

func _on_previous_button_pressed() -> void:
	pass

func _on_next_button_pressed() -> void:
	pass

func _on_return_to_lc_menu_pressed() -> void:
	reset_state()

func _on_back_button_pressed() -> void:
	close_requested.emit()
