extends Node2D

var eventList = load("res://UI/InGame/RandomEvent/events.gd").new()

var chosenEvent: Dictionary

var choice1OBJ = "ChoiceOutcome"
var choice2OBJ = "ChoiceOutcome"
var choice3OBJ = "ChoiceOutcome"
var choice4OBJ = "ChoiceOutcome"

@onready var button1 = $choice1
@onready var button2 = $choice2
@onready var button3 = $choice3
@onready var button4 = $choice4

var postIt1Sprites = ["res://UI/Theme/MainMenu/postIt.png","res://UI/Theme/MainMenu/postItHover.png","res://UI/Theme/MainMenu/postItSelect.png"]
var postIt2Sprites = ["res://UI/Theme/MainMenu/postIt2.png","res://UI/Theme/MainMenu/postIt2Hover.png","res://UI/Theme/MainMenu/postIt2Select.png"]

func _ready() -> void:
	initializeEvent()
	pass

func setButtonVisual(menuButton: Button):
	var textureSet
	match randi_range(0,1):
		0: textureSet = postIt1Sprites
		1: textureSet = postIt2Sprites
	var normalStylebox = StyleBoxTexture.new()
	normalStylebox.texture = load(textureSet[0])
	var hoverStylebox = StyleBoxTexture.new()
	hoverStylebox.texture = load(textureSet[1])
	var pressedStylebox = StyleBoxTexture.new()
	pressedStylebox.texture = load(textureSet[2])
	
	hoverStylebox.texture = load(textureSet[1])
	menuButton.add_theme_stylebox_override("normal",normalStylebox)
	menuButton.add_theme_stylebox_override("hover",hoverStylebox)
	menuButton.add_theme_stylebox_override("pressed",pressedStylebox)
	menuButton.self_modulate = Color(randf_range(.5,1),randf_range(.5,1),randf_range(.5,1))
	pass

func initializeEvent():
	var project_name = ""
	if PlayerTool.currentProject != null:
		project_name = PlayerTool.currentProject.projectName

	var event_pool: Array = eventList.get_event_pool(project_name)
	if PlayerTool.currentProject == null:
		event_pool = _filter_project_only_events(event_pool)
	if event_pool.is_empty():
		return

	chosenEvent = event_pool.pick_random()
	$eventText.text = chosenEvent.get("description")
	var choices: Array = chosenEvent.get("choices", [])
	var outcomes: Array = chosenEvent.get("outcomes", [])
	setButtonVisual(button1)
	setButtonVisual(button2)
	setButtonVisual(button3)
	setButtonVisual(button4)
	match choices.size():
		1:
			button1.visible = true
			button2.visible = false
			button3.visible = false
			button4.visible = false
			button1.position = $single/Marker2D.position
			button1.get_child(0).text = str(choices[0])
			choice1OBJ = outcomes[0]
		2:
			button1.visible = true
			button2.visible = true
			button3.visible = false
			button4.visible = false		
			button1.position = $double/Marker2D.position
			button2.position = $double/Marker2D2.position
			button1.get_child(0).text = str(choices[0])
			button2.get_child(0).text = str(choices[1])
			choice1OBJ = outcomes[0]
			choice2OBJ = outcomes[1]
		3:
			button1.visible = true
			button3.visible = true
			button2.visible = true
			button4.visible = false
			button1.position = $tripple/Marker2D.position
			button2.position = $tripple/Marker2D2.position
			button3.position = $tripple/Marker2D3.position
			button1.get_child(0).text = str(choices[0])
			button2.get_child(0).text = str(choices[1])
			button3.get_child(0).text = str(choices[2])
			choice1OBJ = outcomes[0]
			choice2OBJ = outcomes[1]
			choice3OBJ = outcomes[2]
		4:
			button1.visible = true
			button2.visible = true
			button3.visible = true
			button4.visible = true
			button1.position = $quad/Marker2D.position
			button2.position = $quad/Marker2D2.position
			button3.position = $quad/Marker2D3.position
			button4.position = $quad/Marker2D4.position
			button1.get_child(0).text = str(choices[0])
			button2.get_child(0).text = str(choices[1])
			button3.get_child(0).text = str(choices[2])
			button4.get_child(0).text = str(choices[3])
			choice1OBJ = outcomes[0]
			choice2OBJ = outcomes[1]
			choice3OBJ = outcomes[2]
			choice4OBJ = outcomes[3]
			
func _on_choice_1_pressed() -> void: calculateOutcome(0, choice1OBJ)
func _on_choice_2_pressed() -> void: calculateOutcome(1, choice2OBJ)
func _on_choice_3_pressed() -> void: calculateOutcome(2, choice3OBJ)
func _on_choice_4_pressed() -> void: calculateOutcome(3, choice4OBJ)

func _filter_project_only_events(event_pool: Array) -> Array:
	var filtered: Array = []
	for event_data in event_pool:
		if event_data.get("type") in ["FrontEnd", "BackEnd", "Documenting"]:
			filtered.append(event_data)
	return filtered

func _apply_metric_changes(metric_changes: Dictionary) -> void:
	PlayerTool.applyMetricDeltas(metric_changes)

func _append_backlog_items(metric_key: String, backlog_label: String, amount: int) -> void:
	for i in range(max(amount, 1)):
		PlayerTool.addEventBacklogItem(metric_key, backlog_label)

func calculateOutcome(choiceIndex: int, eventChoice):
	var choiceText = ""
	var choices: Array = chosenEvent.get("choices", [])
	if choiceIndex >= 0 and choiceIndex < choices.size():
		choiceText = str(choices[choiceIndex])

	var metricDeltas: Dictionary = {}
	var outcomeSummary = ""
	var teachingMessage = str(chosenEvent.get("teaching_message", "Project decisions should teach cause and effect, not just correct versus incorrect answers."))
	var methodologyEffects = chosenEvent.get("methodology_effects", {})
	var methodologyName = ""
	if PlayerTool.currentProject != null:
		methodologyName = str(PlayerTool.currentProject.methodology.get("name", ""))

	if methodologyEffects.has(methodologyName):
		var effectData = methodologyEffects.get(methodologyName, {})
		metricDeltas.merge(effectData.get("metric_deltas", {}), true)
		if str(effectData.get("outcome_summary", "")) != "":
			outcomeSummary = str(effectData.get("outcome_summary"))
		if str(effectData.get("teaching_message", "")) != "":
			teachingMessage = str(effectData.get("teaching_message"))

	match chosenEvent.get("type", ""):
		"FrontEnd", "BackEnd", "Documenting":
			if eventChoice is Dictionary:
				metricDeltas.merge(eventChoice, true)
			elif eventChoice is float or eventChoice is int:
				var metricName = _normalize_metric_key(str(chosenEvent.get("type", "")))
				var scaledValue = int(round(float(PlayerTool.currentMetrics.get(metricName, 0)) * float(eventChoice))) - int(PlayerTool.currentMetrics.get(metricName, 0))
				metricDeltas.set(metricName, scaledValue)
			_apply_metric_changes(metricDeltas)
			if outcomeSummary == "":
				outcomeSummary = _format_metric_delta_sentence(metricDeltas)
		"Stakeholder":
			if PlayerTool.currentProject == null:
				return
			if eventChoice is Array:
				if eventChoice[0] != 0:
					PlayerTool.currentProject.sprintAmount += eventChoice[0]
				if eventChoice[1] != 0:
					PlayerTool.currentProject.sprintLength += eventChoice[1]
				if eventChoice[2] != 0:
					PlayerTool.currentProject.sprintMetricAmount += eventChoice[2]
				if outcomeSummary == "":
					outcomeSummary = "Project structure changed: sprint count %+d, sprint length %+d, sprint target %+d." % [eventChoice[0], eventChoice[1], eventChoice[2]]
		"Backlog":
			if PlayerTool.currentProject == null:
				return
			if eventChoice is Array and eventChoice.size() >= 3:
				_append_backlog_items(str(eventChoice[0]), str(eventChoice[1]), int(eventChoice[2]))
				if outcomeSummary == "":
					outcomeSummary = "Added %d backlog item(s): %s." % [int(eventChoice[2]), str(eventChoice[1])]

	var learnMoreTopic = str(chosenEvent.get("learn_more_topic", "stakeholderManagement"))
	PlayerTool.setTransientResults(
		"Decision Outcome",
		[{
			"player_action": choiceText,
			"outcome_summary": outcomeSummary,
			"teaching_message": teachingMessage,
		}],
		learnMoreTopic,
		"Use this outcome to decide how you plan the next sprint.",
		"",
		"Continue"
	)
	get_parent().get_parent().showWeekResults()

func _normalize_metric_key(metricName: String) -> String:
	match metricName:
		"FrontEnd", "frontend":
			return "frontEnd"
		"BackEnd", "backend":
			return "backEnd"
		"Documenting", "documenting":
			return "documenting"
	return metricName

func _format_metric_delta_sentence(metricDeltas: Dictionary) -> String:
	var parts: Array = []
	for metricName in metricDeltas.keys():
		var amount = int(metricDeltas.get(metricName, 0))
		var prefix = "+"
		if amount < 0:
			prefix = ""
		parts.append("%s%s %s" % [prefix, amount, _display_metric_name(str(metricName))])
	if parts.is_empty():
		return "No tracked metrics changed."
	return "Metrics changed: %s." % ", ".join(parts)

func _display_metric_name(metricName: String) -> String:
	match metricName:
		"frontEnd":
			return "Front End"
		"backEnd":
			return "Back End"
		"documenting":
			return "Documentation"
		"reliability":
			return "Reliability"
		"stakeholderSatisfaction":
			return "Stakeholder Satisfaction"
	return metricName
