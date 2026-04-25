extends Node2D

var eventList = load("res://UI/InGame/RandomEvent/events.gd").new()

var chosenEvent: Dictionary
var choiceOutcomes: Array = []

@onready var button1 = $choice1
@onready var button2 = $choice2
@onready var button3 = $choice3
@onready var button4 = $choice4
@onready var eventText = $eventText
@onready var eventLabel = $eventText

var feedbackContainer: Control
var continueBtn: Button

var postIt1Sprites = ["res://UI/Theme/MainMenu/postIt.png","res://UI/Theme/MainMenu/postItHover.png","res://UI/Theme/MainMenu/postItSelect.png"]
var postIt2Sprites = ["res://UI/Theme/MainMenu/postIt2.png","res://UI/Theme/MainMenu/postIt2Hover.png","res://UI/Theme/MainMenu/postIt2Select.png"]
var handwrittenFont = preload("res://UI/Theme/Fonts/jakes-writing-font/Jakeswriting-P2Zr.ttf")

func _ready() -> void:
	buildFeedbackUI()
	initializeEvent()

func buildFeedbackUI():
	feedbackContainer = Control.new()
	feedbackContainer.visible = false
	feedbackContainer.z_index = 10
	add_child(feedbackContainer)

	var iconLabel = RichTextLabel.new()
	iconLabel.name = "IconLabel"
	iconLabel.bbcode_enabled = true
	iconLabel.fit_content = true
	iconLabel.set_position(Vector2(250, 60))
	iconLabel.set_size(Vector2(652, 130))
	iconLabel.add_theme_font_override("normal_font", handwrittenFont)
	iconLabel.add_theme_font_size_override("normal_font_size", 80)
	iconLabel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedbackContainer.add_child(iconLabel)

	var metricsLabel = RichTextLabel.new()
	metricsLabel.name = "MetricsLabel"
	metricsLabel.bbcode_enabled = true
	metricsLabel.fit_content = true
	metricsLabel.set_position(Vector2(300, 200))
	metricsLabel.set_size(Vector2(552, 280))
	metricsLabel.add_theme_font_override("normal_font", handwrittenFont)
	metricsLabel.add_theme_font_size_override("normal_font_size", 40)
	metricsLabel.add_theme_color_override("default_color", Color.BLACK)
	metricsLabel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedbackContainer.add_child(metricsLabel)

	continueBtn = Button.new()
	continueBtn.set_position(Vector2(436, 480))
	continueBtn.set_size(Vector2(280, 100))
	continueBtn.connect("pressed", _on_continue_pressed)
	setButtonVisual(continueBtn)
	feedbackContainer.add_child(continueBtn)

	var btnLabel = RichTextLabel.new()
	btnLabel.bbcode_enabled = true
	btnLabel.z_index = 1
	btnLabel.set_position(Vector2(50, 20))
	btnLabel.set_size(Vector2(180, 60))
	btnLabel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btnLabel.add_theme_color_override("default_color", Color.BLACK)
	btnLabel.add_theme_font_override("normal_font", handwrittenFont)
	btnLabel.add_theme_font_size_override("normal_font_size", 28)
	btnLabel.text = "[center]Continue[/center]"
	btnLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btnLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	continueBtn.add_child(btnLabel)

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
	menuButton.add_theme_stylebox_override("normal", normalStylebox)
	menuButton.add_theme_stylebox_override("hover", hoverStylebox)
	menuButton.add_theme_stylebox_override("pressed", pressedStylebox)
	menuButton.self_modulate = Color(randf_range(.5,1), randf_range(.5,1), randf_range(.5,1))

func initializeEvent():
	PlayerTool.totalEvents += 1
	var eventPool: Array = []
	eventPool.append_array(eventList.general_events)
	if PlayerTool.project != null and eventList.project_events.has(PlayerTool.project.projectName):
		eventPool.append_array(eventList.project_events.get(PlayerTool.project.projectName, []))
	if eventPool.is_empty():
		$eventText.text = "No event available."
		button1.visible = false
		button2.visible = false
		button3.visible = false
		button4.visible = false
		return

	chosenEvent = eventPool.pick_random()
	var choices: Array = chosenEvent.get("choices", [])
	choiceOutcomes = chosenEvent.get("outcomes", [])
	$eventText.text = chosenEvent.get("description", "")

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
		2:
			button1.visible = true
			button2.visible = true
			button3.visible = false
			button4.visible = false
			button1.position = $double/Marker2D.position
			button2.position = $double/Marker2D2.position
			button1.get_child(0).text = str(choices[0])
			button2.get_child(0).text = str(choices[1])
		3:
			button1.visible = true
			button2.visible = true
			button3.visible = true
			button4.visible = false
			button1.position = $tripple/Marker2D.position
			button2.position = $tripple/Marker2D2.position
			button3.position = $tripple/Marker2D3.position
			button1.get_child(0).text = str(choices[0])
			button2.get_child(0).text = str(choices[1])
			button3.get_child(0).text = str(choices[2])
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

func _on_choice_1_pressed() -> void: processChoice(0)
func _on_choice_2_pressed() -> void: processChoice(1)
func _on_choice_3_pressed() -> void: processChoice(2)
func _on_choice_4_pressed() -> void: processChoice(3)

func processChoice(choiceIndex: int):
	var outcome = choiceOutcomes[choiceIndex]
	var eventType := str(chosenEvent.get("type", ""))

	match eventType:
		"FrontEnd", "BackEnd", "Documenting":
			_apply_metric_deltas(outcome)
		"Stakeholder":
			if PlayerTool.project == null:
				pass
			elif outcome is Array and outcome.size() >= 3:
				PlayerTool.project.sprintAmount += int(outcome[0])
				PlayerTool.project.sprintLength += int(outcome[1])
				PlayerTool.project.sprintMetricAmount += int(outcome[2])
			elif outcome is Dictionary:
				_apply_metric_deltas(outcome)
		"Backlog":
			if outcome is Array and outcome.size() >= 2:
				var requiredSkill := str(outcome[0])
				var backlogLabel := str(outcome[1])
				var effortAmount := 1
				if outcome.size() >= 3:
					effortAmount = max(1, int(outcome[2]))
				PlayerTool.addEventBacklogItem(requiredSkill, backlogLabel, effortAmount, effortAmount, true)

	var quality = evaluateChoice(choiceIndex)
	showFeedback(outcome, quality, eventType)

func _apply_metric_deltas(metricDeltas) -> void:
	if metricDeltas is not Dictionary:
		return
	for metricKey in metricDeltas.keys():
		PlayerTool.changeMetricByName(str(metricKey), int(metricDeltas.get(metricKey, 0)))

func evaluateChoice(choiceIndex: int) -> String:
	var chosenOutcome = choiceOutcomes[choiceIndex]
	if chosenOutcome is Dictionary and chosenOutcome.has("reliability"):
		var rel = int(chosenOutcome["reliability"])
		if rel == 1:
			return "good"
		elif rel == 0:
			return "bad"

	var scores = []
	for outcome in choiceOutcomes:
		if outcome is Dictionary:
			var net = 0
			for val in outcome.values():
				net += val
			scores.append(net)
		elif outcome is Array:
			scores.append(outcome.reduce(func(acc, v): return acc + int(v), 0))
		else:
			scores.append(0)

	if scores.size() == 0:
		return "ok"

	var chosen = scores[choiceIndex]
	var best = scores.max()
	var worst = scores.min()

	if best == worst:
		return "ok"
	if chosen >= best:
		return "good"
	if chosen <= worst:
		return "bad"
	return "ok"

func showFeedback(outcome, quality: String, eventType: String):
	button1.visible = false
	button2.visible = false
	button3.visible = false
	button4.visible = false
	eventText.visible = false
	eventLabel.visible = false

	var iconLabel = feedbackContainer.get_node("IconLabel")
	var metricsLabel = feedbackContainer.get_node("MetricsLabel")

	match quality:
		"good":
			iconLabel.text = "[center][color=green]✓ Good Choice![/color][/center]"
		"ok":
			iconLabel.text = "[center][color=orange]— Okay Choice[/color][/center]"
		"bad":
			iconLabel.text = "[center][color=red]✗ Poor Choice[/color][/center]"

	var text = "[center]"
	if outcome is Dictionary and outcome.size() > 0:
		for key in outcome.keys():
			if key != "reliability":
				var value = outcome[key]
				var displayName = formatMetricName(key)
				if value > 0:
					text += "[color=green]+" + str(value) + " " + displayName + "[/color]\n"
				elif value < 0:
					text += "[color=red]" + str(value) + " " + displayName + "[/color]\n"
				else:
					text += str(value) + " " + displayName + "\n"
	elif eventType == "Stakeholder" and outcome is Array and outcome.size() >= 3:
		var labels = ["Sprint Amount", "Sprint Length", "Sprint Metrics"]
		for i in range(3):
			var value = int(outcome[i])
			if value > 0:
				text += "[color=green]+" + str(value) + " " + labels[i] + "[/color]\n"
			elif value < 0:
				text += "[color=red]" + str(value) + " " + labels[i] + "[/color]\n"
	elif eventType == "Backlog" and outcome is Array and outcome.size() >= 2:
		text += "[color=yellow]New backlog item: " + str(outcome[1]) + "[/color]\n"
	elif outcome == 0 or outcome == null:
		text += "No effect"
	text += "[/center]"
	metricsLabel.text = text

	feedbackContainer.visible = true

func formatMetricName(key: String) -> String:
	match key:
		"frontEnd": return "Front End"
		"backEnd": return "Back End"
		"documenting": return "Documenting"
		"reliability": return "Reliability"
		"stakeholderSatisfaction": return "Stakeholder Satisfaction"
		_: return key.capitalize()

func _on_continue_pressed():
	get_parent().get_parent().endMenu()
