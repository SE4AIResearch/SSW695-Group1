extends Sprite2D

func _ready() -> void:
	PlayerTool.projectSelected.connect(setupProjData)
	PlayerTool.weekPassed.connect(setupProjData)
	PlayerTool.sprintComplete.connect(setupProjData)
	PlayerTool.deadlineReached.connect(setupProjData)
	PlayerTool.loopStateChanged.connect(setupProjData)
	setupProjData()

func setupProjData():
	if PlayerTool.currentProject == null:
		$TextParent/sprintData.text = "0/0"
		$TextParent/weekData.text = "0/0"
		$weekBar.max_value = 1
		$weekBar.value = 0
		return
	$TextParent/sprintData.text = str(PlayerTool.currentProjSprint) + "/" + str(PlayerTool.currentProject.sprintAmount)
	$TextParent/weekData.text = str(PlayerTool.currentProjWeek) + "/" + str(PlayerTool.currentProject.sprintLength)
	$weekBar.max_value = maxi(1, PlayerTool.currentProject.sprintLength)
	$weekBar.value = clampi(PlayerTool.currentProjWeek, 0, PlayerTool.currentProject.sprintLength)
