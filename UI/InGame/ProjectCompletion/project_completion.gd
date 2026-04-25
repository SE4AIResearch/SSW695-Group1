extends Node2D

const FE_COLOR := Color(0.82258534, 0.14166427, 0, 1)
const BE_COLOR := Color(0.0, 0.59539217, 0.76481044, 1)
const DOC_COLOR := Color(0.0, 0.7839653, 0.19948468, 1)
const REL_COLOR := Color(1.0, 1.0, 0.17254902, 1.0)
const SAT_COLOR := Color(0.95, 0.75, 0.15, 1.0)


func _ready() -> void:
	calculateCompletion()


func calculateCompletion() -> void:
	if PlayerTool.project == null:
		$ProjectInfo.text = "No completed project available."
		$CurrencyAmount.text = "$0"
		return
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
	pass
