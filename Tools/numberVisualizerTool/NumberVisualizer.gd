extends Node

var number = preload("res://Tools/numberVisualizerTool/number.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#type 0 = Front End | 1 = Back End | 2 = Documenting
func createNumber(amount,type,position):
	var newNumb = number.instantiate()
	var color: String
	match type:
		0: color = "#fc2403"
		1: color = "#30c4ff"
		2: color = "#03fc41"
	newNumb.setupVisual(amount,color)
	get_tree().root.add_child(newNumb)
	newNumb.position = position
	pass
