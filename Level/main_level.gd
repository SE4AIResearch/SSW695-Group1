extends Node2D



func _ready() -> void:
	PlayerTool.hireSelected.connect(setupDeskVisuals)
	initializeSave()
	pass

func _process(delta: float) -> void:
	pass

func initializeSave():
	pass

func setupDeskVisuals():

	pass