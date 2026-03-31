extends Node2D

var hireItem = preload("res://UI/InGame/Hiring/HireItem/HireItem.tscn")

func _ready() -> void:
	checkIfMaxHire()

func _process(delta: float) -> void:
	$BudgetLabel.text = "Hiring Search Budget: $"+ str($BudgetSlider.value)
	pass

func checkIfMaxHire(): if PlayerTool.workers.size() >= 6:
		$SearchButton.disabled = true
		$SearchButton.text = "Max Hired"


func _on_search_button_pressed() -> void:
	for child in $Hires.get_children(): child.queue_free()
	for i in range(3):
		var newHireUI = hireItem.instantiate()
		var newHire = PersonConstructor.generateWorker()
		newHireUI.fillInfo(newHire)
		newHireUI.connect("selected",hireSelected)
		$Hires.add_child(newHireUI)
	pass

func hireSelected(worker):
	PlayerTool.newHire(worker)
	for child in $Hires.get_children(): 
		if worker != child.heldWorker: child.heldWorker.queue_free()
		child.queue_free()
	get_parent().get_parent().endMenu()
	pass
