extends Node2D

var backlogItem = preload("res://UI/InGame/Backlog/BacklogItem/BacklogItem.tscn")
var backlogWorkerItem = preload("res://UI/InGame/Backlog/BacklogWorkerItem/BacklogWorkerItem.tscn")

var selectedWorker: Node
var status_message := ""

func _ready() -> void:
	PlayerTool.backlogUpdated.connect(refreshBoard)
	PlayerTool.loopStateChanged.connect(updateHeader)
	refreshBoard()

func refreshBoard() -> void:
	selectedWorker = null
	_refreshWorkers()
	_refreshItems()
	updateHeader()

func _refreshWorkers() -> void:
	for child in $WorkersScroll/Workers.get_children():
		child.queue_free()

	for worker in PlayerTool.workers:
		var newWorker = backlogWorkerItem.instantiate()
		newWorker.createWorkerItem(worker)
		var assignmentId = PlayerTool.selectedAssignments.get(worker.personName, null)
		if assignmentId != null:
			var item := PlayerTool.getBacklogItemById(int(assignmentId))
			if not item.is_empty():
				newWorker.setAssignmentLabel("Assigned: " + str(item.get("name", "")))
		newWorker.WorkerSelected.connect(workerSelected)
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
		newItem.MetricChosen.connect(backlogSelected)
		match str(item.get("status", "backlog")):
			"done":
				newItem.disabled = true
				_add_control_to_column($CompletedScroll/Completed, newItem)
			"in_progress":
				_add_control_to_column($InProgressScroll/InProgress, newItem)
			_:
				_add_control_to_column($BacklogScroll/Backlog, newItem)

func _add_control_to_column(column: VBoxContainer, newItem: Control) -> void:
	var itemWrapper := CenterContainer.new()
	itemWrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	itemWrapper.add_child(newItem)
	column.add_child(itemWrapper)

func updateHeader() -> void:
	if PlayerTool.currentProject == null:
		$CurrentSprintLabel.text = "No Active Project"
		$FeedbackLabel.text = _format_feedback_message("Open the PC to choose a new project.")
		$AdvanceWeekButton.disabled = true
		return

	var sprintTitle := str(PlayerTool.currentSprintGoal.get("title", "Sprint %d" % PlayerTool.currentProjSprint))
	$CurrentSprintLabel.text = sprintTitle + " | Week %d/%d" % [PlayerTool.currentProjWeek, PlayerTool.currentProject.sprintLength]
	if status_message == "":
		status_message = "Assign workers to backlog items, then advance the week."
	$FeedbackLabel.text = _format_feedback_message(status_message)
	$AdvanceWeekButton.disabled = not PlayerTool.canAdvanceWeek()

func backlogSelected(metricButton) -> void:
	if selectedWorker == null:
		_set_status_message("Select a worker first, then click a backlog card to assign them.")
		return
	var workerButton = selectedWorker
	var result := PlayerTool.assignWorkerToItem(workerButton.heldWorker.personName, int(metricButton.heldItem.get("id", -1)))
	_set_status_message(str(result.get("reason", "")))
	if result.get("ok", false):
		if workerButton != null and is_instance_valid(workerButton):
			workerButton.button_pressed = false
		selectedWorker = null
		return
	updateHeader()

func workerSelected(workerButton):
	if selectedWorker != null and selectedWorker != workerButton:
		selectedWorker.button_pressed = false
	if workerButton.button_pressed:
		selectedWorker = workerButton
		_set_status_message("Selected %s. Click a backlog or in-progress card to assign them this week." % workerButton.heldWorker.personName)
	else:
		selectedWorker = null
		_set_status_message("Assign workers to backlog items, then advance the week.")

func _on_advance_week_button_pressed() -> void:
	if not PlayerTool.canAdvanceWeek():
		_set_status_message("Assign at least one worker before advancing the week.")
		return
	if PlayerTool.advanceWeek():
		var ui_root = get_parent().get_parent()
		if PlayerTool.loopPhase == PlayerTool.LOOP_PROJECT_SUMMARY and not PlayerTool.pendingProjectSummary.is_empty():
			ui_root.showProjectSummary()
			return
		ui_root.endMenu()

func _on_pc_back_pressed() -> void:
	get_parent().get_parent().endMenu()

func _set_status_message(message: String) -> void:
	status_message = message
	$FeedbackLabel.text = _format_feedback_message(status_message)

func _format_feedback_message(message: String) -> String:
	return "[center]%s[/center]" % message
