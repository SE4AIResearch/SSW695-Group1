extends Sprite2D

signal weekPassed

func _ready() -> void:
	TimeTool.timer.timeout.connect(trackTime)
	PlayerTool.projectSelected.connect(setupProjData)


func setupProjData():
		
	pass

func trackTime():
	if PlayerTool.currentProject != null:
		PlayerTool.currentWeekTime += 1
		$weekBar.value = PlayerTool.currentWeekTime
		if PlayerTool.currentWeekTime == $weekBar.max_value:
			if PlayerTool.currentProjWeek == PlayerTool.currentProject.sprintLength:
				if PlayerTool.currentProjSprint == PlayerTool.currentProject.sprintAmount:
					PlayerTool.deadlineReached.emit()
				PlayerTool.sprintComplete.emit()
				PlayerTool.currentProjSprint += 1
			weekPassed.emit()
			PlayerTool.currentProjWeek += 1				
			PlayerTool.currentWeekTime = 0
		$TextParent/sprintData.text = str(PlayerTool.currentProjSprint) + "/" + str(PlayerTool.currentProject.sprintAmount)
		$TextParent/weekData.text = str(PlayerTool.currentProjWeek) + "/" + str(PlayerTool.currentProject.sprintLength)
		pass
		