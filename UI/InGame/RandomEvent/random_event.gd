extends Node2D

var eventList = load("res://UI/InGame/RandomEvent/events.gd").new()

var choice1OBJ = ["ChoiceText","ChoiceOutcome"]
var choice2OBJ = ["ChoiceText","ChoiceOutcome"]
var choice3OBJ = ["ChoiceText","ChoiceOutcome"]
var choice4OBJ = ["ChoiceText","ChoiceOutcome"]

func _ready() -> void:
	initializeEvent()
	pass


func initializeEvent():
	var chosenEvent = eventList.events.pick_random()
	var associatedWorker
	match chosenEvent.get("type"):
		"FrontEnd":
			pass
		"BackEnd":
			pass
		"Documentation":
			pass
		"Stakeholder":
			pass
	pass

func _on_choice_1_pressed() -> void: calculateOutcome(choice1OBJ)
func _on_choice_2_pressed() -> void: calculateOutcome(choice2OBJ)
func _on_choice_3_pressed() -> void: calculateOutcome(choice3OBJ)
func _on_choice_4_pressed() -> void: calculateOutcome(choice4OBJ)

func calculateOutcome(eventChoice):
	#Insert code here which determines whether the outcome of the event is a project stat change, or a backlog item.
	var outcome = eventChoice[1]

	get_parent().get_parent().get_node("BackButton").visible = false
	get_tree().paused = false
	self.queue_free()
	pass

