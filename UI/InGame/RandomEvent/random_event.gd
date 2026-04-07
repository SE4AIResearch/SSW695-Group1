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
	chosenEvent = eventList.events.pick_random()
	$eventText.text = chosenEvent.get("description")
	setButtonVisual(button1)
	setButtonVisual(button2)
	setButtonVisual(button3)
	setButtonVisual(button4)
	match chosenEvent.get("choices").size():
		1:
			button1.visible = true
			button2.visible = false
			button3.visible = false
			button4.visible = false
			button1.position = $single/Marker2D.position
			button1.get_child(0).text = chosenEvent.choices[0]
			choice1OBJ = chosenEvent.outcomes[0]
		2:
			button1.visible = true
			button2.visible = true
			button3.visible = false
			button4.visible = false		
			button1.position = $double/Marker2D.position
			button2.position = $double/Marker2D2.position
			button1.get_child(0).text = chosenEvent.choices[0]
			button2.get_child(0).text = chosenEvent.choices[1]
			choice1OBJ = chosenEvent.outcomes[0]
			choice2OBJ = chosenEvent.outcomes[1]
		3:
			button1.visible = true
			button3.visible = true
			button2.visible = true
			button4.visible = false
			button1.position = $tripple/Marker2D.position
			button2.position = $tripple/Marker2D2.position
			button3.position = $tripple/Marker2D3.position
			button1.get_child(0).text = chosenEvent.choices[0]
			button2.get_child(0).text = chosenEvent.choices[1]
			button3.get_child(0).text = chosenEvent.choices[2]
			choice1OBJ = chosenEvent.outcomes[0]
			choice2OBJ = chosenEvent.outcomes[1]
			choice3OBJ = chosenEvent.outcomes[2]
		4:
			button1.visible = true
			button2.visible = true
			button3.visible = true
			button4.visible = true
			button1.position = $quad/Marker2D.position
			button2.position = $quad/Marker2D2.position
			button3.position = $quad/Marker2D3.position
			button4.position = $quad/Marker2D4.position
			button1.get_child(0).text = chosenEvent.choices[0]
			button2.get_child(0).text = chosenEvent.choices[1]
			button3.get_child(0).text = chosenEvent.choices[2]
			button4.get_child(0).text = chosenEvent.choices[3]
			choice1OBJ = chosenEvent.outcomes[0]
			choice2OBJ = chosenEvent.outcomes[1]
			choice3OBJ = chosenEvent.outcomes[2]
			choice4OBJ = chosenEvent.outcomes[3]
			
func _on_choice_1_pressed() -> void: calculateOutcome(choice1OBJ)
func _on_choice_2_pressed() -> void: calculateOutcome(choice2OBJ)
func _on_choice_3_pressed() -> void: calculateOutcome(choice3OBJ)
func _on_choice_4_pressed() -> void: calculateOutcome(choice4OBJ)

func calculateOutcome(eventChoice):
	#Insert code here which determines whether the outcome of the event is a project stat change, or a backlog item.
	match chosenEvent.type:
		"FrontEnd": PlayerTool.currentMetrics.set("frontEnd",PlayerTool.currentMetrics.get("frontEnd") * eventChoice)
		"BackEnd": PlayerTool.currentMetrics.set("backEnd",PlayerTool.currentMetrics.get("backEnd") * eventChoice)
		"Documenting": PlayerTool.currentMetrics.set("documenting",PlayerTool.currentMetrics.get("documenting") * eventChoice)
		"Stakeholder": #DISALLOW STAKEHOLDER EVENTS FROM TAKING PLACE ON THE LAST SPRINT???????????
			if eventChoice is not Array:
				if eventChoice[0] != 0: PlayerTool.currentProject.sprintAmount += eventChoice[0]
				if eventChoice[1] != 0: PlayerTool.currentProject.sprintLength += eventChoice[1]
				if eventChoice[2] != 0: PlayerTool.currentProject.sprintMetricAmount += eventChoice[2]
			pass
		"Backlog":
				match eventChoice[0]:
					"frontEnd": PlayerTool.currentProject.frontEndMetrics[int(PlayerTool.currentProject.frontEndMetrics.size())] = eventChoice[1]
					"backEnd": PlayerTool.currentProject.backEndMetrics[int(PlayerTool.currentProject.backEndMetrics.size())] = eventChoice[1]
					"documenting": PlayerTool.currentProject.documentingMetrics[int(PlayerTool.currentProject.documentingMetrics.size())] = eventChoice[1]
	
	get_parent().get_parent().endMenu()
	pass
