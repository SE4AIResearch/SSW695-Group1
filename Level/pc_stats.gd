extends Node2D

func _ready() -> void:
	PlayerTool.statsChanged.connect(updateCurrentStats)
	PlayerTool.projectSelected.connect(setupMetrics)
	pass

func setupMetrics():
	$frontEndBar.max_value = PlayerTool.project.frontEndProjectMin
	$backEndBar.max_value = PlayerTool.project.backEndProjectMin
	$documentationBar.max_value = PlayerTool.project.documentingProjectMin
	$reliabilityBar.max_value = 100
	pass

func updateCurrentStats():
	if PlayerTool.project != null:
		$frontEndBar.value = PlayerTool.metrics.get("frontEnd")
		$backEndBar.value = PlayerTool.metrics.get("backEnd")
		$documentationBar.value = PlayerTool.metrics.get("documenting")
		$reliabilityBar.value = PlayerTool.metrics.get("reliability")	
		pass
