extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void: calculateCompletion()

func calculateCompletion():
	prepMenu()
	calculateStakeholderSatisfaction()
		

func prepMenu():
	$ProjectInfo.text = "Project Name: "+PlayerTool.project.projectName + "\nClient: " + PlayerTool.project.clientName 
	pass

func calculateStakeholderSatisfaction():
	var frontEndRanking: float
	match PlayerTool.metrics.get("frontEnd") == 0:
		true: frontEndRanking = 0
		false: frontEndRanking = PlayerTool.metrics.get("frontEnd")/PlayerTool.project.frontEndProjectMin
	var backEndRanking: float
	match PlayerTool.metrics.get("backEnd") == 0:
		true: backEndRanking = 0
		false: backEndRanking = PlayerTool.metrics.get("backEnd")/PlayerTool.project.backEndProjectMin
	var documentationRanking: float
	match PlayerTool.metrics.get("documenting") == 0:
		true: documentationRanking = 0
		false: documentationRanking = PlayerTool.metrics.get("documenting")/PlayerTool.project.documentingProjectMin
	var reliabilityRanking: float
	match PlayerTool.metrics.get("reliability") == 0:
		true: reliabilityRanking = 0
		false: reliabilityRanking = PlayerTool.metrics.get("reliability")/ PlayerTool.totalEvents
	PlayerTool.metrics.set("stakeholderSatisfaction",frontEndRanking + backEndRanking + documentationRanking + reliabilityRanking)
	var stakeholderSatisfactionMax = 4
	$FERating.value = PlayerTool.metrics.get("frontEnd")
	$FERating.max_value = PlayerTool.project.frontEndProjectMin
	$BERating.value = PlayerTool.metrics.get("backEnd")
	$BERating.max_value = PlayerTool.project.backEndProjectMin
	$DocRating.value = PlayerTool.metrics.get("documenting")
	$DocRating.max_value = PlayerTool.project.documentingProjectMin
	$ReliabilityRating.value = PlayerTool.metrics.get("reliability")
	$ReliabilityRating.max_value = PlayerTool.totalEvents
	$SSRating.value = PlayerTool.metrics.get("stakeholderSatisfaction")
	$SSRating.max_value = stakeholderSatisfactionMax
	calculateCurrencyEarned(PlayerTool.metrics.get("stakeholderSatisfaction"))
	pass

func calculateCurrencyEarned(satisfactionAmount: float):
	var percentageEarned = satisfactionAmount/4
	PlayerTool.earnProjectMoney(percentageEarned)
	$CurrencyAmount.text = "$" + str(PlayerTool.returnSprintMoney(percentageEarned))
	PlayerTool.completed_project_count += 1
	PlayerTool.resetProjectStats()
	pass
