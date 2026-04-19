extends Sprite2D

func _ready() -> void:
	PlayerTool.projectSelected.connect(setupProjData)
	TimeTool.timer.timeout.connect(setupProjData)
	TimeTool.weekPassed.connect(setupProjData)
	PlayerTool.sprintComplete.connect(setupProjData)
	PlayerTool.deadlineReached.connect(setupProjData)
	setupProjData()

func setupProjData():
	if PlayerTool.project == null:
		$TextParent/sprintData.text = "0/0"
		$TextParent/weekData.text = "0/0"
		$weekBar.max_value = 1
		$weekBar.value = 0
		return
	$TextParent/sprintData.text = str(PlayerTool.projSprint) + "/" + str(PlayerTool.project.sprintAmount)
	$TextParent/weekData.text = str(PlayerTool.projWeek) + "/" + str(PlayerTool.project.sprintLength)
	$weekBar.max_value = TimeTool.WEEK_DURATION_SECONDS
	$weekBar.value = PlayerTool.weekTime
