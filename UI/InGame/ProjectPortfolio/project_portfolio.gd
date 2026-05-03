extends Node2D

const PCWindowLayout = preload("res://UI/InGame/PCWindow/pc_window_layout.gd")
const PortfolioProjectItem = preload("res://UI/InGame/ProjectPortfolio/PortfolioProjectItem/PortfolioProjectItem.tscn")

const CONTENT_PADDING := 24.0
const HEADER_HEIGHT := 28.0
const HEADER_GAP := 10.0
const PORTFOLIO_ITEM_WIDTH := 884.0

func _ready() -> void:
	PCWindowLayout.apply(self)
	_apply_content_layout()
	_connect_player_signals()
	_refresh()

func _apply_content_layout() -> void:
	var content_rect: Rect2 = PCWindowLayout.content_rect()
	var content_left := content_rect.position.x + CONTENT_PADDING
	var content_top := content_rect.position.y + 10.0
	var content_width := content_rect.size.x - (CONTENT_PADDING * 2.0)
	var scroll_top := content_top + HEADER_HEIGHT + HEADER_GAP
	var scroll_height := content_rect.position.y + content_rect.size.y - scroll_top - CONTENT_PADDING

	_place_control($CompletedProjectsLabel, content_left, content_top, 360.0, HEADER_HEIGHT)
	_place_control($ScrollContainer, content_left, scroll_top, content_width, scroll_height)
	_place_control($EmptyStateLabel, content_left + 80.0, scroll_top + 112.0, content_width - 160.0, 96.0)

	var project_list: VBoxContainer = $ScrollContainer/ProjectList
	project_list.custom_minimum_size = Vector2(maxf(PORTFOLIO_ITEM_WIDTH, content_width - 20.0), 0.0)
	project_list.add_theme_constant_override("separation", 8)

func _connect_player_signals() -> void:
	if not PlayerTool.projectPortfolioChanged.is_connected(_refresh):
		PlayerTool.projectPortfolioChanged.connect(_refresh)
	if not PlayerTool.scoreChanged.is_connected(_refresh):
		PlayerTool.scoreChanged.connect(_refresh)

func _refresh() -> void:
	var project_list: VBoxContainer = $ScrollContainer/ProjectList
	for child in project_list.get_children():
		project_list.remove_child(child)
		child.queue_free()

	var portfolio: Array = PlayerTool.completed_project_portfolio
	$CompletedProjectsLabel.text = "Completed Projects: %d" % portfolio.size()
	$EmptyStateLabel.visible = portfolio.is_empty()

	for index in range(portfolio.size()):
		var record = portfolio[portfolio.size() - 1 - index]
		if record is not Dictionary:
			continue
		var project_item = PortfolioProjectItem.instantiate()
		project_item.setup(record)
		project_list.add_child(project_item)

func _place_control(control: Control, left: float, top: float, width: float, height: float) -> void:
	control.offset_left = left
	control.offset_top = top
	control.offset_right = left + width
	control.offset_bottom = top + height

func _on_pc_back_pressed() -> void:
	get_parent().get_parent().endMenu()
