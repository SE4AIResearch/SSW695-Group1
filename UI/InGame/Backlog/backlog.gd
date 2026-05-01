extends Node2D

var backlogItem = preload("res://UI/InGame/Backlog/BacklogItem/BacklogItem.tscn")
var backlogWorkerItem = preload("res://UI/InGame/Backlog/BacklogWorkerItem/BacklogWorkerItem.tscn")

var selectedWorker: Node
var status_message: String = ""

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
	var readOnly: bool = PlayerTool.loopPhase != PlayerTool.LOOP_PLANNING_WEEK
	for worker in PlayerTool.workers:
		var newWorker = backlogWorkerItem.instantiate()
		newWorker.createWorkerItem(worker)
		var is_resting := bool(worker.resting)
		newWorker.disabled = readOnly or is_resting
		newWorker.setWorkerStatus(PlayerTool.selectedAssignments.has(worker.workerId), is_resting)
		var assignmentId = PlayerTool.selectedAssignments.get(worker.workerId, null)
		if assignmentId != null:
			var item: Dictionary = PlayerTool.getBacklogItemById(int(assignmentId))
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

func backlogSelected(metricButton):
	if PlayerTool.loopPhase != PlayerTool.LOOP_PLANNING_WEEK:
		_set_status_message("Week in progress. Assignments are locked until the timer ends.")
		return
	if selectedWorker == null:
		_set_status_message("Select a worker first, then click a backlog card to assign them.")
		return
	var workerButton = selectedWorker
	var result: Dictionary = PlayerTool.assignWorkerToItem(workerButton.heldWorker.workerId, int(metricButton.heldItem.get("id", -1)))
	_set_status_message(str(result.get("reason", "")))
	if result.get("ok", false):
		if workerButton != null and is_instance_valid(workerButton):
			workerButton.button_pressed = false
		selectedWorker = null
		return
	updateHeader()

func workerSelected(workerButton):
	if PlayerTool.loopPhase != PlayerTool.LOOP_PLANNING_WEEK:
		workerButton.button_pressed = false
		selectedWorker = null
		_set_status_message("Week in progress. Assignments are locked until the timer ends.")
		return
	if workerButton.isResting:
		workerButton.button_pressed = false
		selectedWorker = null
		_set_status_message("%s is resting until their stamina is full." % workerButton.heldWorker.personName)
		return
	if workerButton.isBusy:
		var workerName: String = workerButton.heldWorker.personName
		PlayerTool.unassignWorker(workerButton.heldWorker.workerId)
		selectedWorker = null
		_set_status_message("%s is now free." % workerName)
		return
	if selectedWorker != null and selectedWorker != workerButton:
		selectedWorker.button_pressed = false
	if workerButton.button_pressed:
		selectedWorker = workerButton
		_set_status_message("Selected %s. Click a backlog or in-progress card to assign them this week." % workerButton.heldWorker.personName)
	else:
		selectedWorker = null
		_set_status_message("Assign workers to backlog items, or advance the week when ready.")

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
