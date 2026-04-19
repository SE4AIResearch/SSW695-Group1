extends Node2D

const PCWindowLayout = preload("res://UI/InGame/PCWindow/pc_window_layout.gd")
const UpgradeItemScene = preload("res://UI/InGame/Upgrades/UpgradeItem/UpgradeItem.tscn")

const COLUMN_GAP := 8.0
const COLUMN_ITEM_GAP := 12
const HEADER_HEIGHT := 56.0
const CONTENT_PADDING := 2.0
const HEADER_TO_CONTENT_GAP := 8.0

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
	}
]

const OFFICE_SPACE_COLUMN := {
	"title": "Office Space",
	"color": Color("062d34"),
	"items": [
		{
			"category": "Office Space",
			"tier": 1,
			"name": "Downtown Loft Office",
			"description": "Office upgrade, 8 worker capacity",
			"capacity": 8,
			"required_projects": 2,
			"required_workers": 5,
			"cost": 300
		},
		{
			"category": "Office Space",
			"tier": 2,
			"name": "Mid-Size Tech Office",
			"description": "Office upgrade, 10 worker capacity",
			"capacity": 10,
			"required_projects": 4,
			"required_workers": 7,
			"cost": 650
		},
		{
			"category": "Office Space",
			"tier": 3,
			"name": "Corporate Headquarters",
			"description": "Office upgrade, 12 worker capacity",
			"capacity": 12,
			"required_projects": 6,
			"required_workers": 9,
			"cost": 1100
		},
		{
			"category": "Office Space",
			"tier": 4,
			"name": "Innovation Campus",
			"description": "Office upgrade, 14 worker capacity",
			"capacity": 14,
			"required_projects": 8,
			"required_workers": 11,
			"cost": 1800
		}
	]
}

var status_message := "Upgrades"

func _ready() -> void:
	PCWindowLayout.apply(self)
	_apply_content_layout()
	_populate_columns()
	if not PlayerTool.officeTierChanged.is_connected(_populate_columns):
		PlayerTool.officeTierChanged.connect(_populate_columns)

func _apply_content_layout() -> void:
	var content_rect: Rect2 = PCWindowLayout.content_rect()
	var header_top := content_rect.position.y + CONTENT_PADDING
	var header_bottom := header_top + HEADER_HEIGHT
	var content_top := header_bottom + HEADER_TO_CONTENT_GAP

	$HeaderColumns.offset_left = content_rect.position.x + CONTENT_PADDING
	$HeaderColumns.offset_top = header_top
	$HeaderColumns.offset_right = content_rect.position.x + content_rect.size.x - CONTENT_PADDING
	$HeaderColumns.offset_bottom = header_bottom

	$ScrollContainer.offset_left = content_rect.position.x + CONTENT_PADDING
	$ScrollContainer.offset_top = content_top
	$ScrollContainer.offset_right = content_rect.position.x + content_rect.size.x - CONTENT_PADDING
	$ScrollContainer.offset_bottom = content_rect.position.y + content_rect.size.y - CONTENT_PADDING

func _populate_columns() -> void:
	var header_columns: HBoxContainer = $HeaderColumns
	var columns: HBoxContainer = $ScrollContainer/UpgradeColumns
	var available_width := _get_available_content_width()
	var all_columns := _get_all_column_data()

	for child in header_columns.get_children():
		child.queue_free()

	for child in columns.get_children():
		child.queue_free()

	header_columns.offset_right = header_columns.offset_left + available_width
	header_columns.custom_minimum_size = Vector2(available_width, HEADER_HEIGHT)
	header_columns.add_theme_constant_override("separation", COLUMN_GAP)
	columns.custom_minimum_size = Vector2(available_width, 0.0)
	columns.add_theme_constant_override("separation", COLUMN_GAP)
	$Title.text = status_message

	for column_data in all_columns:
		_add_header_column(header_columns, column_data)
		_add_card_column(columns, column_data)

	_queue_header_sync()

func _get_available_content_width() -> float:
	var vertical_scroll_width: float = 0.0
	var vertical_scroll_bar: VScrollBar = $ScrollContainer.get_v_scroll_bar()

	if vertical_scroll_bar != null:
		vertical_scroll_width = vertical_scroll_bar.get_combined_minimum_size().x

	return maxf(0.0, $ScrollContainer.size.x - vertical_scroll_width - 2.0)

func _get_all_column_data() -> Array:
	var all_columns := UPGRADE_COLUMNS.duplicate(true)
	all_columns.append(_build_office_space_column())
	return all_columns

func _add_header_column(columns: HBoxContainer, column_data: Dictionary) -> void:
	var header := _create_category_header(column_data)
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(header)

func _add_card_column(columns: HBoxContainer, column_data: Dictionary) -> void:
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", COLUMN_ITEM_GAP)

	for item_data in column_data["items"]:
		var upgrade_card = UpgradeItemScene.instantiate()
		column.add_child(upgrade_card)
		upgrade_card.setup_upgrade(item_data)
		if str(item_data.get("category", "")) == "Office Space":
			upgrade_card.purchase_requested.connect(_on_upgrade_purchase_requested)

	columns.add_child(column)

func _queue_header_sync() -> void:
	call_deferred("_sync_header_widths")

func _sync_header_widths() -> void:
	var header_columns: HBoxContainer = $HeaderColumns
	var content_columns: HBoxContainer = $ScrollContainer/UpgradeColumns
	var headers := header_columns.get_children()
	var columns := content_columns.get_children()

	if headers.size() != columns.size():
		return

	var total_width := 0.0
	var missing_widths := false

	for i in range(headers.size()):
		var header := headers[i] as Control
		var column := columns[i] as Control

		if header == null or column == null:
			continue

		var column_width := column.size.x
		if is_zero_approx(column_width):
			column_width = column.get_combined_minimum_size().x
		if is_zero_approx(column_width):
			missing_widths = true
			continue

		header.size_flags_horizontal = 0
		header.custom_minimum_size = Vector2(column_width, HEADER_HEIGHT)
		total_width += column_width

	if missing_widths:
		call_deferred("_sync_header_widths")
		return

	total_width += COLUMN_GAP * maxf(0.0, float(headers.size() - 1))
	header_columns.offset_right = header_columns.offset_left + total_width
	header_columns.custom_minimum_size = Vector2(total_width, HEADER_HEIGHT)

func _build_office_space_column() -> Dictionary:
	var office_column := {
		"title": str(OFFICE_SPACE_COLUMN.get("title", "Office Space")),
		"color": OFFICE_SPACE_COLUMN.get("color", Color("062d34")),
		"items": []
	}

	for office_item in OFFICE_SPACE_COLUMN["items"]:
		office_column["items"].append(_build_office_upgrade_display_data(office_item))

	return office_column

func _build_office_upgrade_display_data(office_item: Dictionary) -> Dictionary:
	var upgrade_data := office_item.duplicate(true)
	var tier := int(upgrade_data.get("tier", 0))
	var required_projects := int(upgrade_data.get("required_projects", 0))
	var required_workers := int(upgrade_data.get("required_workers", 0))
	var current_projects := PlayerTool.completed_project_count
	var current_workers := PlayerTool.workers.size()
	var next_tier := PlayerTool.office_tier + 1
	var requirements_line := "Projects: %d/%d | Workers: %d/%d" % [
		current_projects,
		required_projects,
		current_workers,
		required_workers
	]
	var description := str(upgrade_data.get("description", ""))

	if tier <= PlayerTool.office_tier:
		description += "\nPurchased"
		upgrade_data["description"] = description
		upgrade_data["purchased"] = true
		upgrade_data["show_lock_label"] = true
		upgrade_data["lock_label"] = "PURCHASED"
		upgrade_data["action_text"] = "Purchased"
		upgrade_data["action_disabled"] = true
		return upgrade_data

	description += "\n" + requirements_line

	if tier != next_tier:
		description += "\nUnlock the previous office tier first."
		upgrade_data["description"] = description
		upgrade_data["locked"] = true
		upgrade_data["show_lock_label"] = true
		upgrade_data["lock_label"] = "LOCKED"
		upgrade_data["action_text"] = "Locked"
		upgrade_data["action_disabled"] = true
		return upgrade_data

	var requirements_met := current_projects >= required_projects and current_workers >= required_workers
	upgrade_data["description"] = description
	upgrade_data["locked"] = not requirements_met
	upgrade_data["show_lock_label"] = not requirements_met
	upgrade_data["lock_label"] = "LOCKED"
	upgrade_data["action_text"] = "Buy - $%d" % int(upgrade_data.get("cost", 0))
	upgrade_data["action_disabled"] = not requirements_met
	return upgrade_data

func _on_upgrade_purchase_requested(upgrade_data: Dictionary) -> void:
	var result := PlayerTool.purchase_office_upgrade(upgrade_data)
	status_message = str(result.get("reason", "Upgrades"))
	_populate_columns()

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
