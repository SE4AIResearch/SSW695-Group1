extends Sprite2D

func _ready() -> void:
	PlayerTool.projectSelected.connect(setupProjData)
	TimeTool.timer.timeout.connect(setupProjData)
	TimeTool.weekPassed.connect(setupProjData)
	TimeTool.timer.timeout.connect(checkStatus)
	PlayerTool.sprintComplete.connect(setupProjData)
	PlayerTool.deadlineReached.connect(setupProjData)
	setupProjData()
	checkStatus()

func setupProjData():
	if PlayerTool.projectName == "":
		$TextParent/sprintData.text = "0/0"
		$TextParent/weekData.text = "0/0"
		$weekBar.max_value = 1
		$weekBar.value = 0
		return
	$TextParent/sprintData.text = str(PlayerTool.projSprint) + "/" + str(PlayerTool.sprintAmount)
	$TextParent/weekData.text = str(PlayerTool.projWeek) + "/" + str(PlayerTool.sprintLength)
	$weekBar.max_value = TimeTool.WEEK_DURATION_SECONDS
	$weekBar.value = PlayerTool.weekTime

func checkStatus():
	match PlayerTool.project != null:
		true: 
			match PlayerTool.isWeekActive():
				true: $TextParent/weekStatus.visible = false
				false: 
					$TextParent/weekStatus.visible = true
					$TextParent/weekStatus.text = "Assign Backlog Items!"
		false: 
			$TextParent/weekStatus.visible = true
			$TextParent/weekStatus.text = "Choose a Project!"
