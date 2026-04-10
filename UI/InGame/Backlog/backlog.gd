extends Node2D

var backlogItem = preload("res://UI/InGame/Backlog/BacklogItem/BacklogItem.tscn")
var backlogWorkerItem = preload("res://UI/InGame/Backlog/BacklogWorkerItem/BacklogWorkerItem.tscn")

var selectedWorker: Node
var brief_preview_open := false
var brief_pinned_open := false
var status_message := ""

func _ready() -> void:
	PlayerTool.backlogUpdated.connect(refreshBoard)
	PlayerTool.loopStateChanged.connect(updateHeader)
	$GoalLabel.visible = false
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
		$BriefButton.visible = false
		_set_brief_open_state(false, false)
		return

	var sprintTitle := str(PlayerTool.currentSprintGoal.get("title", "Sprint %d" % PlayerTool.currentProjSprint))
	$CurrentSprintLabel.text = sprintTitle + " | Week %d/%d" % [PlayerTool.currentProjWeek, PlayerTool.currentProject.sprintLength]
	$BriefButton.visible = true
	$BriefNote/BriefTitle.text = sprintTitle
	$BriefNote/BriefContent.text = _build_brief_text()
	if status_message == "":
		status_message = "Hover over the Sprint Brief note to review this sprint, then assign workers to backlog items."
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
		_set_status_message("Hover over the Sprint Brief note to review this sprint, then assign workers to backlog items.")

func _on_advance_week_button_pressed() -> void:
	if not PlayerTool.canAdvanceWeek():
		_set_status_message("Assign at least one worker before advancing the week.")
		return
	if PlayerTool.advanceWeek():
		get_parent().get_parent().showWeekResults()

func _on_pc_back_pressed() -> void:
	get_parent().get_parent().endMenu()

func _set_status_message(message: String) -> void:
	status_message = message
	$FeedbackLabel.text = _format_feedback_message(status_message)

func _format_feedback_message(message: String) -> String:
	return "[center]%s[/center]" % message

func _build_brief_text() -> String:
	if PlayerTool.currentProject == null:
		return ""

	var goalText = str(PlayerTool.currentSprintGoal.get("goal", "Complete the most valuable remaining work."))
	var lessonText = str(PlayerTool.currentSprintGoal.get("lesson", "Balance delivery with project-management tradeoffs."))
	var objectiveText = str(PlayerTool.currentProject.learningObjective)
	var successText = str(PlayerTool.currentProject.successCriteria)
	var methodologyText = str(PlayerTool.currentProject.recommendedMethodology)
	var sprintBrief = goalText
	if PlayerTool.currentProjSprint == 1:
		sprintBrief = "This opening sprint establishes the project direction and teaches the core decision loop.\n" + goalText

	var sections: Array = []
	sections.append("[b]Objective[/b]\n%s" % objectiveText)
	sections.append("[b]Success Criteria[/b]\n%s" % successText)
	sections.append("[b]Lesson Focus[/b]\n%s" % lessonText)
	sections.append("[b]Sprint Brief[/b]\n%s" % sprintBrief)
	if methodologyText != "":
		sections.append("[b]Recommended Methodology[/b]\n%s" % methodologyText)

	return "\n\n".join(sections)

func _set_brief_open_state(preview_open: bool, pinned_open: bool) -> void:
	brief_preview_open = preview_open
	brief_pinned_open = pinned_open
	if has_node("BriefButton"):
		$BriefButton.button_pressed = brief_pinned_open
	if has_node("BriefNote"):
		$BriefNote.visible = brief_preview_open or brief_pinned_open

func _on_brief_button_mouse_entered() -> void:
	if PlayerTool.currentProject == null or brief_pinned_open:
		return
	_set_brief_open_state(true, false)

func _on_brief_button_mouse_exited() -> void:
	if brief_pinned_open:
		return
	_set_brief_open_state(false, false)

func _on_brief_button_toggled(toggled_on: bool) -> void:
	if PlayerTool.currentProject == null:
		_set_brief_open_state(false, false)
		return
	_set_brief_open_state(toggled_on, toggled_on)

func _on_brief_close_button_pressed() -> void:
	_set_brief_open_state(false, false)
