extends Node2D

func getCurrentMetrics(_project, _metrics) -> void:
	setupMetrics()
	updateCurrentStats()

func _ready() -> void:
	PlayerTool.statsChanged.connect(updateCurrentStats)
	PlayerTool.projectSelected.connect(setupMetrics)
	pass


func setupMetrics():
	if PlayerTool.project == null:
		return
	$projectNameLabel.text = "Project: " + PlayerTool.project.projectName + " | Client: " + PlayerTool.project.clientName
	$methodologyLabel.text = "Methodology: " + PlayerTool.project.methodology.get("name")
	$frontEndBar.max_value = PlayerTool.project.frontEndProjectMin
	$backEndBar.max_value = PlayerTool.project.backEndProjectMin
	$documentationBar.max_value = PlayerTool.project.documentingProjectMin
	$reliabilityBar.value = PlayerTool.metrics.get("reliability")
	$reliabilityBar.max_value = 1
	pass

func updateCurrentStats():
	if PlayerTool.project != null:
		$frontEndBar.value = PlayerTool.metrics.get("frontEnd")
		$backEndBar.value = PlayerTool.metrics.get("backEnd")
		$documentationBar.value = PlayerTool.metrics.get("documenting")
		if PlayerTool.totalEvents != 0:
			$reliabilityBar.value = PlayerTool.metrics.get("reliability")
			$reliabilityBar.max_value = PlayerTool.totalEvents
	else:
		$frontEndBar.value = 0
		$backEndBar.value = 0
		$documentationBar.value = 0
		$reliabilityBar.value = 0
	pass
