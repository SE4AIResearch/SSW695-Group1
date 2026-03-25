extends Node2D

var eventList = load("res://UI/InGame/RandomEvent/events.gd").new()

var choice1OBJ = ["ChoiceText","ChoiceOutcome"]
var choice2OBJ = ["ChoiceText","ChoiceOutcome"]
var choice3OBJ = ["ChoiceText","ChoiceOutcome"]
var choice4OBJ = ["ChoiceText","ChoiceOutcome"]

@onready var button1 = $choice1
@onready var button2 = $choice2
@onready var button3 = $choice3
@onready var button4 = $choice4

func _ready() -> void:
	initializeEvent()
	pass


func initializeEvent():
	var chosenEvent = eventList.events.pick_random()
	$eventText.text = chosenEvent.get("description")
	match chosenEvent.get("choices").size():
		1:
			button1.visible = true
			button2.visible = false
			button3.visible = false
			button4.visible = false
			button1.position = $single/Marker2D.position
			button1.text = chosenEvent.choices[0]
		2:
			button1.visible = true
			button2.visible = true
			button3.visible = false
			button4.visible = false		
			button1.position = $double/Marker2D.position
			button2.position = $double/Marker2D2.position
			button1.text = chosenEvent.choices[0]
			button2.text = chosenEvent.choices[1]
		3:
			button1.visible = true
			button3.visible = true
			button2.visible = true
			button4.visible = false
			button1.position = $tripple/Marker2D.position
			button2.position = $tripple/Marker2D2.position
			button3.position = $tripple/Marker2D3.position
			button1.text = chosenEvent.choices[0]
			button2.text = chosenEvent.choices[1]
			button3.text = chosenEvent.choices[2]
		4:
			button1.visible = true
			button2.visible = true
			button3.visible = true
			button4.visible = true
			button1.position = $quad/Marker2D.position
			button2.position = $quad/Marker2D2.position
			button3.position = $quad/Marker2D3.position
			button4.position = $quad/Marker2D4.position
			button1.text = chosenEvent.choices[0]
			button2.text = chosenEvent.choices[1]
			button3.text = chosenEvent.choices[2]
			button4.text = chosenEvent.choices[3]
			
func _on_choice_1_pressed() -> void: calculateOutcome(choice1OBJ)
func _on_choice_2_pressed() -> void: calculateOutcome(choice2OBJ)
func _on_choice_3_pressed() -> void: calculateOutcome(choice3OBJ)
func _on_choice_4_pressed() -> void: calculateOutcome(choice4OBJ)

func calculateOutcome(eventChoice):
	#Insert code here which determines whether the outcome of the event is a project stat change, or a backlog item.
	var outcome = eventChoice[1]
	get_parent().get_parent().endMenu()
	pass
