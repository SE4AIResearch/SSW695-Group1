extends Node2D

func _ready() -> void:
	PlayerTool.statsChanged.connect(updateCurrentStats)
	PlayerTool.projectSelected.connect(setupMetrics)
	PlayerTool.currencyChanged.connect(updateCurrency)
	PlayerTool.projectCompleted.connect(updateProjectSummary)
	updateCurrency()
	updateProjectSummary()

func setupMetrics():
	if PlayerTool.project == null:
		$frontEndBar.max_value = 1
		$backEndBar.max_value = 1
		$documentationBar.max_value = 1
		$reliabilityBar.max_value = 100
		updateCurrentStats()
		return
	$frontEndBar.max_value = PlayerTool.project.frontEndProjectMin
	$backEndBar.max_value = PlayerTool.project.backEndProjectMin
	$documentationBar.max_value = PlayerTool.project.documentingProjectMin
	$reliabilityBar.max_value = 100

func updateCurrentStats():
	if PlayerTool.project != null:
		$frontEndBar.value = PlayerTool.metrics.get("frontEnd")
		$backEndBar.value = PlayerTool.metrics.get("backEnd")
		$documentationBar.value = PlayerTool.metrics.get("documenting")
		$reliabilityBar.value = PlayerTool.metrics.get("reliability")
		return
	$frontEndBar.value = 0
	$backEndBar.value = 0
	$documentationBar.value = 0
	$reliabilityBar.value = 0

func updateCurrency() -> void:
	$Currency.text = "Currency: $%0.2f" % PlayerTool.currency

func updateProjectSummary() -> void:
	$Score.text = "Projects: %d" % PlayerTool.completed_project_count
