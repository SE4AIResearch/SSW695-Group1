extends Node2D

const PCWindowLayout = preload("res://UI/InGame/PCWindow/pc_window_layout.gd")

var hireItem = preload("res://UI/InGame/Hiring/HireItem/HireItem.tscn")

func _ready() -> void:
	PCWindowLayout.apply(self)
	_apply_content_layout()
	checkIfMaxHire()

func _process(delta: float) -> void:
	var budget = int($BudgetSlider.value)
	var hiringTier = PersonConstructor.getHiringTierForBudget(budget)
	$BudgetLabel.text = "Budget: $" + str(budget) + " | T" + str(hiringTier["rank"])
	pass

func _apply_content_layout() -> void:
	var content_rect: Rect2 = PCWindowLayout.content_rect()
	var hires_width: float = 580.0
	var hires_height: float = 185.0
	var controls_width: float = 575.0

	$Hires.offset_left = content_rect.position.x + (content_rect.size.x - hires_width) / 2.0
	$Hires.offset_top = content_rect.position.y + 12.0
	$Hires.offset_right = $Hires.offset_left + hires_width
	$Hires.offset_bottom = $Hires.offset_top + hires_height

	$BudgetLabel.offset_left = content_rect.position.x + 110.0
	$BudgetLabel.offset_top = content_rect.position.y + 240.0
	$BudgetLabel.offset_right = $BudgetLabel.offset_left + 260.0
	$BudgetLabel.offset_bottom = $BudgetLabel.offset_top + 24.0

	$BudgetSlider.offset_left = content_rect.position.x + 40.0
	$BudgetSlider.offset_top = content_rect.position.y + 282.0
	$BudgetSlider.offset_right = $BudgetSlider.offset_left + controls_width
	$BudgetSlider.offset_bottom = $BudgetSlider.offset_top + 16.0

	$SearchButton.offset_left = content_rect.position.x + content_rect.size.x - 220.0
	$SearchButton.offset_top = content_rect.position.y + 236.0
	$SearchButton.offset_right = $SearchButton.offset_left + 180.0
	$SearchButton.offset_bottom = $SearchButton.offset_top + 56.0

func checkIfMaxHire(): if PlayerTool.workers.size() >= 6:
		$SearchButton.disabled = true
		$SearchButton.text = "Max Hired"


func _on_search_button_pressed() -> void:
	var budget = int($BudgetSlider.value)
	for child in $Hires.get_children(): child.queue_free()
	for i in range(3):
		var newHireUI = hireItem.instantiate()
		var newHire = PersonConstructor.generateBudgetWorker(budget)
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


func _on_pc_back_pressed() -> void: get_parent().get_parent().endMenu()
