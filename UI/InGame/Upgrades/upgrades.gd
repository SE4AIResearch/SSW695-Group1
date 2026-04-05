extends Node2D

const PCWindowLayout = preload("res://UI/InGame/PCWindow/pc_window_layout.gd")
const UpgradeItemScene = preload("res://UI/InGame/Upgrades/UpgradeItem/UpgradeItem.tscn")

const COLUMN_GAP := 8.0
const COLUMN_ITEM_GAP := 12
const HEADER_HEIGHT := 56.0
const CONTENT_PADDING := 2.0

const UPGRADE_COLUMNS := [
	{
		"title": "Hardware",
		"color": Color("102550"),
		"items": [
			{"tier": 1, "name": "Desktop PC", "description": "+5% Frontend", "cost": 100, "locked": false},
			{"tier": 2, "name": "Dual Monitor Setup", "description": "+5% Frontend, +5% Documentation", "cost": 250, "locked": true},
			{"tier": 3, "name": "Database Upgrades", "description": "+10% Backend", "cost": 500, "locked": true},
			{"tier": 4, "name": "High-End Workstation", "description": "+10% Frontend, +10% Backend", "cost": 1000, "locked": true}
		]
	},
	{
		"title": "Software",
		"color": Color("27134a"),
		"items": [
			{"tier": 1, "name": "IDE Suite", "description": "+10% Frontend, +10% Backend", "cost": 150, "locked": false},
			{"tier": 2, "name": "Version Control Platform", "description": "+10% Reliability", "cost": 300, "locked": true},
			{"tier": 3, "name": "Automated Testing Suite", "description": "+15% Reliability", "cost": 500, "locked": true},
			{"tier": 4, "name": "CI/CD Pipeline", "description": "+10% Reliability, +5% Backend", "cost": 750, "locked": true},
			{"tier": 5, "name": "AI Assistant", "description": "+5% Frontend, +5% Backend, +10% Documentation", "cost": 1000, "locked": true},
			{"tier": 6, "name": "Enterprise Product Suite", "description": "+10% Frontend, +10% Backend, +10% Reliability, +10% Documentation, +10% Client Satisfaction", "cost": 1500, "locked": true}
		]
	},
	{
		"title": "Quality of Life",
		"color": Color("3a2618"),
		"items": [
			{"tier": 1, "name": "Coffee Machine", "description": "+5% Reliability", "cost": 75, "locked": false},
			{"tier": 2, "name": "Ergonomic Chairs", "description": "+5% Documentation, +5% Reliability", "cost": 200, "locked": true},
			{"tier": 3, "name": "Standing Desks", "description": "+5% Frontend, +5% Backend", "cost": 450, "locked": true},
			{"tier": 4, "name": "Air Conditioner", "description": "+10% Reliability", "cost": 900, "locked": true}
		]
	},
	{
		"title": "Office Space",
		"color": Color("062d34"),
		"items": [
			{"tier": 1, "name": "Downtown Loft Office", "description": "Office upgrade, 8 worker capacity", "cost": 300, "locked": false},
			{"tier": 2, "name": "Mid-Size Tech Office", "description": "Office upgrade, 10 worker capacity", "cost": 650, "locked": true},
			{"tier": 3, "name": "Corporate Headquarters", "description": "Office upgrade, 12 worker capacity", "cost": 1100, "locked": true},
			{"tier": 4, "name": "Innovation Campus", "description": "Office upgrade, 14 worker capacity", "cost": 1800, "locked": true}
		]
	}
]

func _ready() -> void:
	PCWindowLayout.apply(self)
	_apply_content_layout()
	_populate_columns()

func _apply_content_layout() -> void:
	var content_rect: Rect2 = PCWindowLayout.content_rect()

	$ScrollContainer.offset_left = content_rect.position.x + CONTENT_PADDING
	$ScrollContainer.offset_top = content_rect.position.y + CONTENT_PADDING
	$ScrollContainer.offset_right = content_rect.position.x + content_rect.size.x - CONTENT_PADDING
	$ScrollContainer.offset_bottom = content_rect.position.y + content_rect.size.y - CONTENT_PADDING

func _populate_columns() -> void:
	var columns: HBoxContainer = $ScrollContainer/UpgradeColumns
	var column_count: int = UPGRADE_COLUMNS.size()
	var vertical_scroll_width: float = 0.0
	var vertical_scroll_bar: VScrollBar = $ScrollContainer.get_v_scroll_bar()

	if vertical_scroll_bar != null:
		vertical_scroll_width = vertical_scroll_bar.get_combined_minimum_size().x

	var available_width: float = maxf(0.0, $ScrollContainer.size.x - vertical_scroll_width - 2.0)

	for child in columns.get_children():
		child.queue_free()

	columns.custom_minimum_size = Vector2(available_width, 0.0)
	columns.add_theme_constant_override("separation", COLUMN_GAP)

	for column_data in UPGRADE_COLUMNS:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_theme_constant_override("separation", COLUMN_ITEM_GAP)
		column.add_child(_create_category_header(column_data))

		for item_data in column_data["items"]:
			var upgrade_card = UpgradeItemScene.instantiate()
			column.add_child(upgrade_card)
			upgrade_card.setup_upgrade(item_data)

		columns.add_child(column)

func _create_category_header(column_data: Dictionary) -> PanelContainer:
	var header := PanelContainer.new()
	var style := StyleBoxFlat.new()
	var margin := MarginContainer.new()
	var label := Label.new()

	header.custom_minimum_size = Vector2(0.0, HEADER_HEIGHT)
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	style.bg_color = column_data.get("color", Color("13274d"))
	style.border_color = style.bg_color.lightened(0.18)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	header.add_theme_stylebox_override("panel", style)

	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 10)
	header.add_child(margin)

	label.text = str(column_data.get("title", "Upgrades"))
	label.add_theme_font_size_override("font_size", 18)
	label.modulate = Color(1, 1, 1)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	margin.add_child(label)

	return header

func _on_pc_back_pressed() -> void: get_parent().get_parent().endMenu()

func _on_close_button_pressed() -> void:
	get_parent().get_parent().endMenu()
