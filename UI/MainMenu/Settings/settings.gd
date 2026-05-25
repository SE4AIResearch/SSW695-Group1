extends Node2D

signal close_requested

const BUTTON_TEXTURE_NORMAL = preload("res://UI/Theme/PCTheme/button/slimButton.png")
const BUTTON_TEXTURE_PRESSED = preload("res://UI/Theme/PCTheme/button/slimButtonPressed.png")
const BUTTON_TEXTURE_HOVER = preload("res://UI/Theme/PCTheme/button/slimButtonHeld.png")
const BACK_TEXTURE_NORMAL = preload("res://UI/Theme/PCTheme/arrow/next.png")
const BACK_TEXTURE_PRESSED = preload("res://UI/Theme/PCTheme/arrow/nextPressed.png")
const BACK_TEXTURE_HOVER = preload("res://UI/Theme/PCTheme/arrow/nextHover.png")
const BACK_TEXTURE_DISABLED = preload("res://UI/Theme/PCTheme/arrow/nextDisabled.png")
const OVERLAY_TEXTURE = preload("res://UI/Theme/PCTheme/Overlay.png")
const NAV_PANEL_TEXTURE = preload("res://UI/Theme/PCTheme/PanelSlim.png")
const CONTENT_PANEL_TEXTURE = preload("res://UI/Theme/PCTheme/Panel.png")
const FIGTREE_LIGHT = preload("res://UI/Theme/Fonts/figtree-2.0.3/otf/Figtree-Light.otf")
const FIGTREE_BOLD = preload("res://UI/Theme/Fonts/figtree-2.0.3/otf/Figtree-Bold.otf")

const AUDIO_CHANNELS := [
	{"id": "master", "label": "Master"},
	{"id": "music", "label": "Music"},
	{"id": "sfx", "label": "SFX"},
	{"id": "ambient", "label": "Ambient"},
]

var normal_button_style: StyleBoxTexture
var pressed_button_style: StyleBoxTexture
var hover_button_style: StyleBoxTexture
var selected_button_style: StyleBoxTexture
var nav_buttons: Dictionary = {}
var audio_sliders: Dictionary = {}
var audio_value_labels: Dictionary = {}
var current_page: String = "audio"

var page_container := Node2D.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	normal_button_style = _make_stylebox(BUTTON_TEXTURE_NORMAL)
	pressed_button_style = _make_stylebox(BUTTON_TEXTURE_PRESSED)
	hover_button_style = _make_stylebox(BUTTON_TEXTURE_HOVER)
	selected_button_style = _make_stylebox(BUTTON_TEXTURE_HOVER)

	_build_layout()
	_select_page("audio")

	if not visibility_changed.is_connected(_on_visibility_changed):
		visibility_changed.connect(_on_visibility_changed)
	if not AudioManager.volume_changed.is_connected(_on_audio_volume_changed):
		AudioManager.volume_changed.connect(_on_audio_volume_changed)


func _build_layout() -> void:
	var overlay := Sprite2D.new()
	overlay.name = "Overlay"
	overlay.position = Vector2(576.0, 324.0)
	overlay.scale = Vector2(4.5, 4.5)
	overlay.texture = OVERLAY_TEXTURE
	add_child(overlay)

	var title := Label.new()
	title.name = "Title"
	title.offset_left = 465.0
	title.offset_top = 34.0
	title.offset_right = 656.0
	title.offset_bottom = 96.0
	title.text = "Settings"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FIGTREE_BOLD)
	add_child(title)

	_build_back_button()
	_build_navigation()
	_build_audio_page()


func _build_back_button() -> void:
	var back_button := Button.new()
	back_button.name = "BackButton"
	back_button.offset_left = 1088.0
	back_button.offset_top = 82.0
	back_button.offset_right = 1136.0
	back_button.offset_bottom = 130.0
	back_button.rotation = PI
	back_button.add_theme_stylebox_override("normal", _make_stylebox(BACK_TEXTURE_NORMAL))
	back_button.add_theme_stylebox_override("pressed", _make_stylebox(BACK_TEXTURE_PRESSED))
	back_button.add_theme_stylebox_override("hover", _make_stylebox(BACK_TEXTURE_HOVER))
	back_button.add_theme_stylebox_override("disabled", _make_stylebox(BACK_TEXTURE_DISABLED))
	back_button.pressed.connect(_on_back_button_pressed)
	add_child(back_button)


func _build_navigation() -> void:
	var categories := Node2D.new()
	categories.name = "Categories"
	add_child(categories)

	var nav_panel := Sprite2D.new()
	nav_panel.name = "Panel"
	nav_panel.position = Vector2(221.1, 336.0)
	nav_panel.scale = Vector2(7.004167, 6.1)
	nav_panel.texture = NAV_PANEL_TEXTURE
	categories.add_child(nav_panel)

	var scroll := ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.offset_left = 69.0
	scroll.offset_top = 150.0
	scroll.offset_right = 413.0
	scroll.offset_bottom = 573.0
	scroll.clip_contents = true
	categories.add_child(scroll)

	var list := VBoxContainer.new()
	list.name = "SettingsList"
	list.layout_mode = 2
	list.add_theme_constant_override("separation", 12)
	scroll.add_child(list)

	var audio_button := Button.new()
	audio_button.name = "Audio"
	audio_button.custom_minimum_size = Vector2(240.0, 80.0)
	audio_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	audio_button.focus_mode = Control.FOCUS_NONE
	audio_button.text = "Audio"
	audio_button.pressed.connect(_select_page.bind("audio"))
	_apply_nav_button_theme(audio_button, true)
	list.add_child(audio_button)
	nav_buttons["audio"] = audio_button


func _build_audio_page() -> void:
	page_container.name = "Page"
	add_child(page_container)

	var content_panel := Sprite2D.new()
	content_panel.name = "Panel"
	content_panel.position = Vector2(759.5, 334.0)
	content_panel.scale = Vector2(5.601562, 6.05)
	content_panel.texture = CONTENT_PANEL_TEXTURE
	page_container.add_child(content_panel)

	var heading := Label.new()
	heading.name = "Heading"
	heading.offset_left = 460.0
	heading.offset_top = 145.0
	heading.offset_right = 1030.0
	heading.offset_bottom = 195.0
	heading.text = "Audio"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	heading.add_theme_font_override("font", FIGTREE_BOLD)
	page_container.add_child(heading)

	var sliders := VBoxContainer.new()
	sliders.name = "AudioSliders"
	sliders.offset_left = 475.0
	sliders.offset_top = 220.0
	sliders.offset_right = 1030.0
	sliders.offset_bottom = 500.0
	sliders.add_theme_constant_override("separation", 22)
	page_container.add_child(sliders)

	for channel_data in AUDIO_CHANNELS:
		var channel := str(channel_data["id"])
		var row := _make_audio_slider_row(channel, str(channel_data["label"]))
		sliders.add_child(row)


func _make_audio_slider_row(channel: String, label_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "%sRow" % label_text
	row.custom_minimum_size = Vector2(555.0, 46.0)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)

	var label := Label.new()
	label.custom_minimum_size = Vector2(115.0, 46.0)
	label.text = label_text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", FIGTREE_LIGHT)
	row.add_child(label)

	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(320.0, 32.0)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.value = roundf(AudioManager.get_volume(channel) * 100.0)
	row.add_child(slider)

	var value_label := Label.new()
	value_label.custom_minimum_size = Vector2(70.0, 46.0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_label.text = _format_percent(slider.value)
	value_label.add_theme_font_override("font", FIGTREE_LIGHT)
	row.add_child(value_label)

	slider.value_changed.connect(_on_volume_slider_changed.bind(channel, value_label))
	audio_sliders[channel] = slider
	audio_value_labels[channel] = value_label
	return row


func _select_page(page_id: String) -> void:
	current_page = page_id
	page_container.visible = page_id == "audio"
	for nav_id in nav_buttons.keys():
		_apply_nav_button_theme(nav_buttons[nav_id] as Button, nav_id == current_page)
	if current_page == "audio":
		_sync_audio_sliders()


func _sync_audio_sliders() -> void:
	for channel in audio_sliders.keys():
		var slider := audio_sliders[channel] as HSlider
		var value_label := audio_value_labels[channel] as Label
		var percent_value := roundf(AudioManager.get_volume(str(channel)) * 100.0)
		slider.set_value_no_signal(percent_value)
		value_label.text = _format_percent(percent_value)


func _on_volume_slider_changed(value: float, channel: String, value_label: Label) -> void:
	value_label.text = _format_percent(value)
	AudioManager.set_volume(channel, value / 100.0)


func _on_audio_volume_changed(channel: String, value: float) -> void:
	if not audio_sliders.has(channel):
		return
	var percent_value := roundf(value * 100.0)
	var slider := audio_sliders[channel] as HSlider
	var value_label := audio_value_labels[channel] as Label
	slider.set_value_no_signal(percent_value)
	value_label.text = _format_percent(percent_value)


func _on_visibility_changed() -> void:
	if visible:
		_select_page("audio")


func _on_back_button_pressed() -> void:
	close_requested.emit()


func _apply_nav_button_theme(button: Button, is_selected: bool) -> void:
	button.add_theme_stylebox_override("normal", selected_button_style if is_selected else normal_button_style)
	button.add_theme_stylebox_override("pressed", pressed_button_style)
	button.add_theme_stylebox_override("hover", hover_button_style)
	button.add_theme_stylebox_override("focus", pressed_button_style)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_focus_color", Color(1, 1, 1, 1))
	button.add_theme_font_override("font", FIGTREE_LIGHT)


func _make_stylebox(texture: Texture2D) -> StyleBoxTexture:
	var stylebox := StyleBoxTexture.new()
	stylebox.texture = texture
	return stylebox


func _format_percent(value: float) -> String:
	return "%d%%" % int(roundf(value))
