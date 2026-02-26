extends Node2D

var hireItem = preload("res://UI/InGame/Hiring/HireItem/HireItem.tscn")
var workerItem = preload("res://Person/Worker/Worker.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$BudgetLabel.text = "Hiring Search Budget: $"+ str($BudgetSlider.value)
	pass


func _on_search_button_pressed() -> void:
	for i in range(3):
		var newHireUI = hireItem.instantiate()
		var newHire = workerItem.instantiate()
		PersonConstructor.generateName(newHire)
		PersonConstructor.generateVisuals(newHire)
		PersonConstructor.generateWorkerStats(newHire)
		newHireUI.fillInfo(newHire)
		newHireUI.connect("selectWorker",hireSelected)
		$Hires.add_child(newHireUI)
	pass

func hireSelected(worker):

	pass
