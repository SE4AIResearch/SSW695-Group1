extends Node2D

var projectList = load("res://Projects/projectList.json").new()
var projectItem = preload("res://Projects/projectBase.gd")
var projectChoiceItem = preload("res://UI/InGame/ProjectSetup/ProjectItem/ProjectItem.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_button_pressed() -> void:
	generateProjectChoices()
	pass

func generateProjectChoices() -> void:
	for i in range(3):
		var newProject = projectItem.instantiate()
		var newChoice = projectChoiceItem.instantiate()
		var randomProject = null
		
	
		pass