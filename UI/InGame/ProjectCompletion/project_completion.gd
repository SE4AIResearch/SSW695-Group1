extends Node2D

const FE_COLOR := Color(0.82258534, 0.14166427, 0, 1)
const BE_COLOR := Color(0.0, 0.59539217, 0.76481044, 1)
const DOC_COLOR := Color(0.0, 0.7839653, 0.19948468, 1)
const REL_COLOR := Color(1.0, 1.0, 0.17254902, 1.0)
const SAT_COLOR := Color(0.95, 0.75, 0.15, 1.0)


func _ready() -> void:
	calculateCompletion()


func calculateCompletion() -> void:
	prepMenu()
	calculateStakeholderSatisfaction()
	calculateCurrencyEarned()


func prepMenu() -> void:
	var project_node = PlayerTool.project
	var fe_min: int = 1
	var be_min: int = 1
	var doc_min: int = 1

	if project_node != null:
		$ProjectInfo.text = "Project Name: %s\nClient: %s" % [
			str(project_node.projectName),
			str(project_node.clientName)
		]
		fe_min = maxi(1, int(project_node.frontEndProjectMin))
		be_min = maxi(1, int(project_node.backEndProjectMin))
		doc_min = maxi(1, int(project_node.documentingProjectMin))
	else:
		$ProjectInfo.text = "Project Name: -\nClient: -"

	_setup_bar($FERating, fe_min, int(PlayerTool.metrics.get("frontEnd", 0)), FE_COLOR)
	_setup_bar($BERating, be_min, int(PlayerTool.metrics.get("backEnd", 0)), BE_COLOR)
	_setup_bar($DocRating, doc_min, int(PlayerTool.metrics.get("documenting", 0)), DOC_COLOR)
	_setup_bar($ReliabilityRating, 100, int(PlayerTool.metrics.get("reliability", 0)), REL_COLOR)


func calculateStakeholderSatisfaction() -> void:
	var satisfaction_value: int = int(PlayerTool.metrics.get("stakeholderSatisfaction", 0))
	_setup_bar($"Stakeholder Satisfaction", 100, satisfaction_value, SAT_COLOR)


func calculateCurrencyEarned() -> void:
	var satisfaction_ratio: float = clampf(
		float(PlayerTool.metrics.get("stakeholderSatisfaction", 0)) / 100.0,
		0.0,
		1.0
	)
	var difficulty: float = float(PlayerTool.projectRatedDifficulty)
	var project_count: int = int(PlayerTool.projectAmount)
	var team_rank: int = int(PlayerTool.teamRank)
	var base_amount: float = (500.0 * difficulty) \
		+ (25.0 * float(project_count)) \
		+ (650.0 * float(team_rank - 1))
	var earned: int = maxi(0, int(round(base_amount * satisfaction_ratio)))

	if earned > 0:
		PlayerTool.addCurrency(earned)

	$CurrencyGained.text = "Currency Earned: $%d" % earned


func _setup_bar(bar: TextureProgressBar, max_value_amount: int, current_value: int, color: Color) -> void:
	if bar == null:
		return
	bar.max_value = max(1, max_value_amount)
	bar.value = clampi(current_value, 0, int(bar.max_value))
	bar.tint_progress = color


func _on_continue_pressed() -> void:
	get_parent().get_parent().endMenu()
