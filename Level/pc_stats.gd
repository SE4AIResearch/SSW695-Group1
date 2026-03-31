extends Node2D

func _ready() -> void:
	TimeTool.timer.timeout.connect(updateCurrentStats)
	PlayerTool.projectSelected.connect(setupMetrics)
	pass

func setupMetrics():
	$frontEndBar.max_value = PlayerTool.currentProject.frontEndProjectMin
	$backEndBar.max_value = PlayerTool.currentProject.backEndProjectMin
	$documentationBar.max_value = PlayerTool.currentProject.documentingProjectMin
	$reliabilityBar.max_value = 100
	pass

func updateCurrentStats():
	if PlayerTool.currentProject != null:
		$frontEndBar.value = PlayerTool.currentMetrics.get("frontEnd")
		$backEndBar.value = PlayerTool.currentMetrics.get("backEnd")
		$documentationBar.value = PlayerTool.currentMetrics.get("documenting")
		$reliabilityBar.value = PlayerTool.currentMetrics.get("reliability")	
		pass
