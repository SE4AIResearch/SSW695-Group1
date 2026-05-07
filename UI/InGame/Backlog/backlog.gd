extends Node2D

var backlogItem = preload("res://UI/InGame/Backlog/BacklogItem/BacklogItem.tscn")
var backlogWorkerItem = preload("res://UI/InGame/Backlog/BacklogWorkerItem/BacklogWorkerItem.tscn")

var selectedWorker: Node
var draggedWorker: Node
var hoveredDropItem: Node
var status_message: String = ""

@onready var grabber: Node2D = $Grabber

func _ready() -> void:
	if $AdvanceWeekButton.material:
		$AdvanceWeekButton.material = $AdvanceWeekButton.material.duplicate()
	PlayerTool.backlogUpdated.connect(refreshBoard)
	PlayerTool.loopStateChanged.connect(updateHeader)
	refreshBoard()

func refreshBoard() -> void:
	selectedWorker = null
	draggedWorker = null
	hoveredDropItem = null
	if is_instance_valid(grabber) and grabber.has_method("clearGrab"):
		grabber.clearGrab()
	_refreshWorkers()
	_refreshItems()
	updateHeader()

func _refreshWorkers() -> void:
	for child in $WorkersScroll/Workers.get_children():
		child.queue_free()
	var readOnly: bool = PlayerTool.loopPhase != PlayerTool.LOOP_PLANNING_WEEK
	for worker in PlayerTool.workers:
		var newWorker = backlogWorkerItem.instantiate()
		newWorker.createWorkerItem(worker)
		newWorker.toggle_mode = false
		var is_resting := bool(worker.resting)
		newWorker.disabled = readOnly or is_resting
		newWorker.setWorkerStatus(PlayerTool.selectedAssignments.has(worker.workerId), is_resting)
		var assignmentId = PlayerTool.selectedAssignments.get(worker.workerId, null)
		if assignmentId != null:
			var item: Dictionary = PlayerTool.getBacklogItemById(int(assignmentId))
			if not item.is_empty():
				newWorker.setAssignmentLabel("Assigned: " + str(item.get("name", "")))
		newWorker.WorkerDragStarted.connect(workerDragStarted)
		_add_control_to_column($WorkersScroll/Workers, newWorker)

func _refreshItems() -> void:
	for child in $BacklogScroll/Backlog.get_children():
		child.queue_free()
	for child in $InProgressScroll/InProgress.get_children():
		child.queue_free()
	for child in $CompletedScroll/Completed.get_children():
		child.queue_free()

	for item in PlayerTool.backlogItems:
		var newItem = backlogItem.instantiate()
		newItem.prepItem(item)
		newItem.mouse_entered.connect(_on_item_mouse_entered.bind(newItem))
		newItem.mouse_exited.connect(_on_item_mouse_exited.bind(newItem))
		newItem.update_shader_opacity(selectedWorker != null)
		var readOnly: bool = PlayerTool.loopPhase != PlayerTool.LOOP_PLANNING_WEEK
		match str(item.get("status", "backlog")):
			"done":
				newItem.disabled = true
				_add_control_to_column($CompletedScroll/Completed, newItem)
			"in_progress":
				newItem.disabled = readOnly
				_add_control_to_column($InProgressScroll/InProgress, newItem)
			_:
				newItem.disabled = readOnly
				_add_control_to_column($BacklogScroll/Backlog, newItem)

func _add_control_to_column(column: VBoxContainer, newItem: Control) -> void:
	var itemWrapper: CenterContainer = CenterContainer.new()
	itemWrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	itemWrapper.add_child(newItem)
	column.add_child(itemWrapper)

func updateHeader() -> void:
	if PlayerTool.project == null:
		$CurrentSprintLabel.text = "No Active Project"
		$FeedbackLabel.text = _format_feedback_message("Open the PC to choose a new project.")
		$AdvanceWeekButton.disabled = true
		return
	var sprintTitle: String = str(PlayerTool.sprintGoal.get("title", "Sprint %d" % PlayerTool.projSprint))
	$CurrentSprintLabel.text = sprintTitle + " | Week %d/%d" % [PlayerTool.projWeek, PlayerTool.project.sprintLength]
	if PlayerTool.loopPhase == PlayerTool.LOOP_ACTIVE_WEEK:
		status_message = "Week in progress. Assignments are locked until the timer ends."
	elif status_message == "" or status_message == "Week in progress. Assignments are locked until the timer ends.":
		status_message = "Assign workers to backlog items, or advance the week when ready."
	$FeedbackLabel.text = _format_feedback_message(status_message)
	$AdvanceWeekButton.disabled = PlayerTool.loopPhase != PlayerTool.LOOP_PLANNING_WEEK or not PlayerTool.canAdvanceWeek()
	_update_advance_button_shader()

func _update_advance_button_shader():
	var all_dealt_with = true
	for worker in PlayerTool.workers:
		var is_assigned = PlayerTool.selectedAssignments.has(worker.workerId)
		var is_resting = bool(worker.resting)
		if not (is_assigned or is_resting):
			all_dealt_with = false
			break
	
	if $AdvanceWeekButton.material:
		$AdvanceWeekButton.material.set_shader_parameter("opacity", 1.0 if all_dealt_with else 0.0)

func _update_item_shader_opacities():
	var worker_selected = selectedWorker != null
	for column in [$BacklogScroll/Backlog, $InProgressScroll/InProgress, $CompletedScroll/Completed]:
		for wrapper in column.get_children():
			if wrapper is CenterContainer and wrapper.get_child_count() > 0:
				var item = wrapper.get_child(0)
				if item.has_method("update_shader_opacity"):
					item.update_shader_opacity(worker_selected)

func _update_worker_shader_opacities():
	var worker_selected = selectedWorker != null
	for wrapper in $WorkersScroll/Workers.get_children():
		if wrapper is CenterContainer and wrapper.get_child_count() > 0:
			var worker_item = wrapper.get_child(0)
			if worker_item.has_method("update_shader_opacity"):
				worker_item.update_shader_opacity(worker_selected, selectedWorker == worker_item)

func _update_all_shader_opacities():
	_update_item_shader_opacities()
	_update_worker_shader_opacities()

func backlogSelected(metricButton):
	if PlayerTool.loopPhase != PlayerTool.LOOP_PLANNING_WEEK:
		_set_status_message("Week in progress. Assignments are locked until the timer ends.")
		return
	if selectedWorker == null:
		_set_status_message("Drag a worker and release over a backlog or in-progress card to assign them.")
		return
	var workerButton = selectedWorker
	var result: Dictionary = PlayerTool.assignWorkerToItem(workerButton.heldWorker.workerId, int(metricButton.heldItem.get("id", -1)))
	_set_status_message(str(result.get("reason", "")))
	if result.get("ok", false):
		if workerButton != null and is_instance_valid(workerButton):
			workerButton.button_pressed = false
		selectedWorker = null
		_update_all_shader_opacities()
		return
	updateHeader()

func workerDragStarted(workerButton):
	if PlayerTool.loopPhase != PlayerTool.LOOP_PLANNING_WEEK:
		_set_status_message("Week in progress. Assignments are locked until the timer ends.")
		return
	if workerButton.isResting:
		_set_status_message("%s is resting until their stamina is full." % workerButton.heldWorker.personName)
		return
	draggedWorker = workerButton
	selectedWorker = workerButton
	hoveredDropItem = null
	if is_instance_valid(grabber) and grabber.has_method("beginGrab"):
		grabber.beginGrab(workerButton.heldWorker)
	_set_status_message("Dragging %s. Release over a backlog or in-progress card to assign them this week." % workerButton.heldWorker.personName)
	_update_all_shader_opacities()

func workerSelected(workerButton):
	workerDragStarted(workerButton)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_finishWorkerDrag()

func _on_item_mouse_entered(itemButton: Node) -> void:
	if draggedWorker == null:
		return
	hoveredDropItem = itemButton

func _on_item_mouse_exited(itemButton: Node) -> void:
	if hoveredDropItem == itemButton:
		hoveredDropItem = null

func _finishWorkerDrag() -> void:
	if draggedWorker == null:
		return
	var workerButton = draggedWorker
	var dropItem = _resolveDropItem()
	if dropItem != null:
		var result: Dictionary = PlayerTool.assignWorkerToItem(workerButton.heldWorker.workerId, dropItem.getItemId())
		_set_status_message(str(result.get("reason", "")))
		if not result.get("ok", false):
			updateHeader()
	else:
		if workerButton.isBusy:
			var workerName: String = workerButton.heldWorker.personName
			PlayerTool.unassignWorker(workerButton.heldWorker.workerId)
			_set_status_message("%s is now free." % workerName)
		else:
			_set_status_message("Released %s without assigning them." % workerButton.heldWorker.personName)
	_clearDragState()

func _resolveDropItem() -> Node:
	if hoveredDropItem != null and is_instance_valid(hoveredDropItem):
		if hoveredDropItem.has_method("isDropTarget") and hoveredDropItem.isDropTarget():
			return hoveredDropItem
	var hoveredControl: Control = get_viewport().gui_get_hovered_control()
	while hoveredControl != null:
		if hoveredControl.has_method("isDropTarget") and hoveredControl.has_method("getItemId"):
			if hoveredControl.isDropTarget():
				return hoveredControl
		hoveredControl = hoveredControl.get_parent() as Control
	return null

func _clearDragState() -> void:
	draggedWorker = null
	selectedWorker = null
	hoveredDropItem = null
	if is_instance_valid(grabber) and grabber.has_method("clearGrab"):
		grabber.clearGrab()
	_update_all_shader_opacities()

func _on_advance_week_button_pressed() -> void:
	if not PlayerTool.canAdvanceWeek():
		_set_status_message("You can only advance during sprint planning.")
		return
	if PlayerTool.startWeek():
		var ui = get_parent().get_parent()
		ui.endMenu()
		ui.call_deferred("show_kanban_exit_tutorial")

func _on_pc_back_pressed() -> void:
	get_parent().get_parent().endMenu()

func _set_status_message(message: String) -> void:
	status_message = message
	$FeedbackLabel.text = _format_feedback_message(status_message)

func _format_feedback_message(message: String) -> String:
	return "[center]%s[/center]" % message
