extends Sprite2D


var newWeek: bool = false

func _ready() -> void:
	TimeTool.timer.timeout.connect(trackTime)
	PlayerTool.projectSelected.connect(setupProjData)


func setupProjData():
	$TextParent/sprintData.text = str(PlayerTool.currentProjSprint) + "/" + str(PlayerTool.currentProject.sprintAmount)
	$TextParent/weekData.text = str(PlayerTool.currentProjWeek) + "/" + str(PlayerTool.currentProject.sprintLength)	
	$weekBar.value = PlayerTool.currentWeekTime

func trackTime():
	if PlayerTool.currentProject != null:
		newWeek = false
		if PlayerTool.currentWeekTime == $weekBar.max_value:
			if PlayerTool.currentProjWeek == PlayerTool.currentProject.sprintLength:
				if PlayerTool.currentProjSprint == PlayerTool.currentProject.sprintAmount:
					PlayerTool.deadlineReached.emit()
				PlayerTool.sprintComplete.emit()
				PlayerTool.currentProjWeek = 0
				PlayerTool.currentProjSprint += 1
			newWeek = true
			PlayerTool.weekPassed.emit()
			PlayerTool.currentProjWeek += 1				
			PlayerTool.currentWeekTime = 0
		if !newWeek: PlayerTool.currentWeekTime += 1
		$weekBar.value = PlayerTool.currentWeekTime
		
		$TextParent/sprintData.text = str(PlayerTool.currentProjSprint) + "/" + str(PlayerTool.currentProject.sprintAmount)
		$TextParent/weekData.text = str(PlayerTool.currentProjWeek) + "/" + str(PlayerTool.currentProject.sprintLength)
		pass
		
