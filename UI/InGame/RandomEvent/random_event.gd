extends Node2D

var eventList = load("res://UI/InGame/RandomEvent/events.gd").new()

func _ready() -> void:
	initializeEvent()
	pass


func initializeEvent():
	var chosenEvent = eventList.events.pick_random()
	pass
