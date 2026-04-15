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
	var outcomes: Array = chosenEvent.get("outcomes", [])
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
			
func _on_choice_1_pressed() -> void: calculateOutcome(choice1OBJ)
func _on_choice_2_pressed() -> void: calculateOutcome(choice2OBJ)
func _on_choice_3_pressed() -> void: calculateOutcome(choice3OBJ)
func _on_choice_4_pressed() -> void: calculateOutcome(choice4OBJ)

func calculateOutcome(eventChoice):
	var eventType := str(chosenEvent.get("type", ""))
	match eventType:
		"FrontEnd", "BackEnd", "Documenting":
			_apply_metric_deltas(eventChoice)
		"Stakeholder":
			if eventChoice is Array and eventChoice.size() >= 3:
				PlayerTool.project.sprintAmount += int(eventChoice[0])
				PlayerTool.project.sprintLength += int(eventChoice[1])
				PlayerTool.project.sprintMetricAmount += int(eventChoice[2])
			elif eventChoice is Dictionary:
				_apply_metric_deltas(eventChoice)
		"Backlog":
			if eventChoice is Array and eventChoice.size() >= 2:
				var requiredSkill := str(eventChoice[0])
				var backlogLabel := str(eventChoice[1])
				var effortAmount := 1
				if eventChoice.size() >= 3:
					effortAmount = max(1, int(eventChoice[2]))
				PlayerTool.addEventBacklogItem(requiredSkill, backlogLabel, effortAmount, effortAmount, true)
	
	get_parent().get_parent().endMenu()
	pass

func _apply_metric_deltas(metricDeltas) -> void:
	if metricDeltas is not Dictionary:
		return
	for metricKey in metricDeltas.keys():
		PlayerTool.changeMetricByName(str(metricKey), int(metricDeltas.get(metricKey, 0)))
