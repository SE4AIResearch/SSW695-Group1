extends Node2D

const FE_COLOR := Color(0.82258534, 0.14166427, 0, 1)
const BE_COLOR := Color(0.0, 0.59539217, 0.76481044, 1)
const DOC_COLOR := Color(0.0, 0.7839653, 0.19948468, 1)
const REL_COLOR := Color(1.0, 1.0, 0.17254902, 1.0)
const SAT_COLOR := Color(0.95, 0.75, 0.15, 1.0)

var _completion_snapshot: Dictionary = {}
var _currency_awarded: bool = false

func _ready() -> void:
	calculateCompletion()

func setup_from_snapshot(completion_snapshot: Dictionary) -> void:
	_completion_snapshot = completion_snapshot.duplicate(true)
	_currency_awarded = false
	if is_inside_tree():
		calculateCompletion()

func calculateCompletion() -> void:
	var completion_data := _get_completion_data()
	if completion_data.is_empty():
		$ProjectInfo.text = "No completed project available."
		$CurrencyAmount.text = "$0"
		return
	prepMenu(completion_data)
	calculateStakeholderSatisfaction(completion_data)
		

func prepMenu(completion_data: Dictionary) -> void:
	$ProjectInfo.text = "Project Name: %s\nClient: %s" % [
		str(completion_data.get("project_name", "")),
		str(completion_data.get("client_name", ""))
	]

func calculateStakeholderSatisfaction(completion_data: Dictionary) -> void:
	var metrics: Dictionary = completion_data.get("metrics", {})
	var front_end_target := maxi(1, int(completion_data.get("front_end_target", 0)))
	var back_end_target := maxi(1, int(completion_data.get("back_end_target", 0)))
	var documenting_target := maxi(1, int(completion_data.get("documenting_target", 0)))
	var total_events := int(completion_data.get("total_events", 0))
	var reliability_total := maxi(1, total_events)
	var frontEndRanking: float
	match int(metrics.get("frontEnd", 0)) <= 0:
		true: frontEndRanking = 0
		false: frontEndRanking = float(metrics.get("frontEnd", 0)) / front_end_target
	var backEndRanking: float
	match int(metrics.get("backEnd", 0)) <= 0:
		true: backEndRanking = 0
		false: backEndRanking = float(metrics.get("backEnd", 0)) / back_end_target
	var documentationRanking: float
	match int(metrics.get("documenting", 0)) <= 0:
		true: documentationRanking = 0
		false: documentationRanking = float(metrics.get("documenting", 0)) / documenting_target
	var reliabilityRanking: float
	match int(metrics.get("reliability", 0)) <= 0:
		true:
			match total_events == 0: # Change this if reliability becomes tied to more than just random events.
				true: reliabilityRanking = 1
				false: reliabilityRanking = 0
		false: reliabilityRanking = float(metrics.get("reliability", 0)) / reliability_total
	var stakeholder_satisfaction := frontEndRanking + backEndRanking + documentationRanking + reliabilityRanking
	var stakeholderSatisfactionMax = 4
	$FERating.value = int(metrics.get("frontEnd", 0))
	$FERating.max_value = front_end_target
	$BERating.value = int(metrics.get("backEnd", 0))
	$BERating.max_value = back_end_target
	$DocRating.value = int(metrics.get("documenting", 0))
	$DocRating.max_value = documenting_target
	$ReliabilityRating.value = int(metrics.get("reliability", 0))
	$ReliabilityRating.max_value = reliability_total
	$SSRating.value = stakeholder_satisfaction
	$SSRating.max_value = stakeholderSatisfactionMax
	calculateCurrencyEarned(stakeholder_satisfaction, completion_data)

func calculateCurrencyEarned(satisfactionAmount: float, completion_data: Dictionary) -> void:
	var currency_earned := _calculate_project_currency_earned(completion_data, satisfactionAmount / 4.0)
	if !_currency_awarded:
		PlayerTool.addCurrency(currency_earned)
		_currency_awarded = true
	$CurrencyAmount.text = "$" + str(currency_earned)

func _get_completion_data() -> Dictionary:
	if !_completion_snapshot.is_empty():
		return _completion_snapshot
	if PlayerTool.project == null:
		return {}
	return {
		"project_name": str(PlayerTool.project.projectName),
		"client_name": str(PlayerTool.project.clientName),
		"project_rated_difficulty": float(PlayerTool.projectRatedDifficulty),
		"project_amount": int(PlayerTool.projectAmount),
		"team_rank": int(PlayerTool.teamRank),
		"metrics": PlayerTool.metrics.duplicate(true),
		"front_end_target": int(PlayerTool.project.frontEndProjectMin),
		"back_end_target": int(PlayerTool.project.backEndProjectMin),
		"documenting_target": int(PlayerTool.project.documentingProjectMin),
		"total_events": int(PlayerTool.totalEvents),
	}

func _calculate_project_currency_earned(completion_data: Dictionary, satisfaction_amount: float) -> int:
	return int(floor(
		(
			(500.0 * float(completion_data.get("project_rated_difficulty", 0.0))) +
			(25.0 * int(completion_data.get("project_amount", 0))) +
			(650.0 * (int(completion_data.get("team_rank", 1)) - 1))
		) * satisfaction_amount
	))
