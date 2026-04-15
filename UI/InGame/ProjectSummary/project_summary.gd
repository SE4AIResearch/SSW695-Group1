extends Node2D

func _ready() -> void:
	var summary: Dictionary = PlayerTool.pendingProjectSummary
	$Title.text = str(summary.get("title", "Project Summary"))
	$Summary.text = str(summary.get("summary", ""))
	$MethodologyFit.text = str(summary.get("methodology_fit", ""))
	$LearningObjective.text = "Learning Objective: " + str(summary.get("learning_objective", ""))
	$SuccessCriteria.text = "Success Criteria: " + str(summary.get("success_criteria", ""))
	$Rewards.text = "Score Earned: %d\nCurrency Earned: $%d" % [
		int(summary.get("score_earned", 0)),
		int(summary.get("currency_earned", 0)),
	]

func _on_continue_button_pressed() -> void:
	PlayerTool.pendingProjectSummary = {}
	get_parent().get_parent().endMenu()
