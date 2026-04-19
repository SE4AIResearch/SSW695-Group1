extends Node2D

var learningEntries = load("res://UI/Learning Center/entries.gd").new()

func _ready() -> void:
	var results: Dictionary = PlayerTool.weekResults
	$Title.text = str(results.get("title", "Week Results"))
	$Subtitle.text = str(results.get("subtitle", ""))
	$Summary.text = str(results.get("summary_text", ""))
	$Reward.text = str(results.get("reward_summary", ""))
	$Details.text = _build_details(results.get("entries", []))
	$LearnMoreButton.visible = str(results.get("learn_more_topic", "")) != ""
	$LearnMoreText.visible = false
	$ContinueButton.text = str(results.get("continue_label", "Continue"))

func _build_details(entries: Array) -> String:
	var blocks: Array = []
	for entry in entries:
		var lines: Array = []
		var actionText: String = str(entry.get("player_action", ""))
		var outcomeText: String = str(entry.get("outcome_summary", ""))
		var teachingText: String = str(entry.get("teaching_message", ""))
		if actionText != "":
			lines.append("Action: " + actionText)
		if outcomeText != "":
			lines.append("Outcome: " + outcomeText)
		if teachingText != "":
			lines.append("Lesson: " + teachingText)
		if not lines.is_empty():
			blocks.append("\n".join(lines))
	return "\n\n".join(blocks)

func _on_continue_button_pressed() -> void:
	if PlayerTool.loopPhase == PlayerTool.LOOP_PROJECT_SUMMARY and not PlayerTool.pendingProjectSummary.is_empty():
		get_parent().get_parent().showProjectSummary()
		return
	get_parent().get_parent().endMenu()

func _on_learn_more_button_pressed() -> void:
	var topic: String = str(PlayerTool.weekResults.get("learn_more_topic", ""))
	if topic == "":
		return
	if $LearnMoreText.visible:
		$LearnMoreText.visible = false
		return
	var article_text: String = learningEntries.get_article_text(topic)
	if article_text == "":
		$LearnMoreText.text = "No learning-center entry is available for \"%s\" yet." % topic
		$LearnMoreText.visible = true
		return
	$LearnMoreText.text = article_text
	$LearnMoreText.visible = true
