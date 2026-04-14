extends Sprite2D


var newWeek: bool = false

func _ready() -> void:
	TimeTool.timer.timeout.connect(trackTime)
	PlayerTool.projectSelected.connect(setupProjData)


func setupProjData():
	$TextParent/sprintData.text = str(PlayerTool.projSprint) + "/" + str(PlayerTool.project.sprintAmount)
	$TextParent/weekData.text = str(PlayerTool.projWeek) + "/" + str(PlayerTool.project.sprintLength)	
	$weekBar.value = PlayerTool.weekTime

func trackTime():
	if PlayerTool.project != null:
		newWeek = false
		if PlayerTool.weekTime == $weekBar.max_value:
			if PlayerTool.projWeek == PlayerTool.project.sprintLength:
				if PlayerTool.projSprint == PlayerTool.project.sprintAmount:
					PlayerTool.deadlineReached.emit()
				PlayerTool.sprintComplete.emit()
				PlayerTool.projWeek = 0
				PlayerTool.projSprint += 1
			newWeek = true
			TimeTool.weekPassed.emit()
			PlayerTool.projWeek += 1				
			PlayerTool.weekTime = 0
		if !newWeek: PlayerTool.weekTime += 1
		$weekBar.value = PlayerTool.weekTime
		
		$TextParent/sprintData.text = str(PlayerTool.projSprint) + "/" + str(PlayerTool.project.sprintAmount)
		$TextParent/weekData.text = str(PlayerTool.projWeek) + "/" + str(PlayerTool.project.sprintLength)
		pass
		