extends Node2D

func _ready() -> void:
	PlayerTool.statsChanged.connect(updateCurrentStats)
	PlayerTool.projectSelected.connect(setupMetrics)
	PlayerTool.currencyChanged.connect(updateCurrentStats)
	PlayerTool.scoreChanged.connect(updateCurrentStats)
	setupMetrics()
	pass

func setupMetrics():
	if PlayerTool.currentProject == null:
		$frontEndBar.max_value = 1
		$backEndBar.max_value = 1
		$documentationBar.max_value = 1
		$reliabilityBar.max_value = 100
		$Currency.text = "Currency: $" + str(PlayerTool.currency)
		$Score.text = "Score: " + str(PlayerTool.score)
		return
	$frontEndBar.max_value = PlayerTool.currentProject.frontEndProjectMin
	$backEndBar.max_value = PlayerTool.currentProject.backEndProjectMin
	$documentationBar.max_value = PlayerTool.currentProject.documentingProjectMin
	$reliabilityBar.max_value = 100
	$Currency.text = "Currency: $" + str(PlayerTool.currency)
	$Score.text = "Score: " + str(PlayerTool.score)
	pass

func updateCurrentStats():
	$Currency.text = "Currency: $" + str(PlayerTool.currency)
	$Score.text = "Score: " + str(PlayerTool.score)
	if PlayerTool.currentProject != null:
		$frontEndBar.value = PlayerTool.currentMetrics.get("frontEnd")
		$backEndBar.value = PlayerTool.currentMetrics.get("backEnd")
		$documentationBar.value = PlayerTool.currentMetrics.get("documenting")
		$reliabilityBar.value = PlayerTool.currentMetrics.get("reliability")
	else:
		$frontEndBar.value = 0
		$backEndBar.value = 0
		$documentationBar.value = 0
		$reliabilityBar.value = 0
		pass
