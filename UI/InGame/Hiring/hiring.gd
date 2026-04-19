extends Node2D

const PCWindowLayout = preload("res://UI/InGame/PCWindow/pc_window_layout.gd")

var hireItem = preload("res://UI/InGame/Hiring/HireItem/HireItem.tscn")
var insufficient_funds_message := ""

func _ready() -> void:
	PCWindowLayout.apply(self)
	_apply_content_layout()
	_hide_insufficient_funds_popup()
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

	_layout_insufficient_funds_popup()

func checkIfMaxHire() -> void:
	var current_workers := PlayerTool.workers.size()
	var max_workers := PlayerTool.max_worker_capacity
	var at_capacity := current_workers >= max_workers
	$SearchButton.disabled = at_capacity
	if at_capacity:
		$SearchButton.text = "Max Hired (%d/%d)" % [current_workers, max_workers]
	else:
		$SearchButton.text = "Search Hires (%d/%d)" % [current_workers, max_workers]


func _on_search_button_pressed() -> void:
	if _is_insufficient_funds_popup_visible():
		return

	var budget := maxi(1, int($BudgetSlider.value))
	for child in $Hires.get_children(): child.queue_free()
	for i in range(3):
		var newHireUI = hireItem.instantiate()
		var newHire = PersonConstructor.generateBudgetWorker(budget)
		newHireUI.fillInfo(newHire, budget)
		newHireUI.connect("selected",hireSelected)
		$Hires.add_child(newHireUI)

func hireSelected(worker, hire_cost: int) -> void:
	if _is_insufficient_funds_popup_visible():
		return

	var result: Dictionary = PlayerTool.purchase_hire(worker, hire_cost)
	var result_message := str(result.get("reason", ""))

	if not bool(result.get("ok", false)) and _is_insufficient_funds_message(result_message):
		_show_insufficient_funds_popup(result_message)
		return

	if not bool(result.get("ok", false)):
		checkIfMaxHire()
		return
	for child in $Hires.get_children(): 
		if worker != child.heldWorker: child.heldWorker.queue_free()
		child.queue_free()
	get_parent().get_parent().endMenu()

func _show_insufficient_funds_popup(message: String) -> void:
	insufficient_funds_message = message
	$InsufficientFundsModal/MessagePanel/Message.text = insufficient_funds_message
	$InsufficientFundsModal.visible = true
	$PCBack.disabled = true

func _hide_insufficient_funds_popup() -> void:
	$InsufficientFundsModal.visible = false
	$PCBack.disabled = false

func _is_insufficient_funds_popup_visible() -> bool:
	return $InsufficientFundsModal.visible

func _is_insufficient_funds_message(message: String) -> bool:
	return message.contains("enough money")

func _on_insufficient_funds_ok_pressed() -> void:
	_hide_insufficient_funds_popup()

func _on_pc_back_pressed() -> void:
	if _is_insufficient_funds_popup_visible():
		_hide_insufficient_funds_popup()
		return
	get_parent().get_parent().endMenu()

func _layout_insufficient_funds_popup() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var frame_left: float = $WindowFrame.offset_left
	var frame_top: float = $WindowFrame.offset_top
	var frame_width: float = $WindowFrame.offset_right - $WindowFrame.offset_left
	var frame_height: float = $WindowFrame.offset_bottom - $WindowFrame.offset_top
	var popup_width := 580.0
	var popup_height := 288.0

	$InsufficientFundsModal.offset_left = 0.0
	$InsufficientFundsModal.offset_top = 0.0
	$InsufficientFundsModal.offset_right = viewport_size.x
	$InsufficientFundsModal.offset_bottom = viewport_size.y

	$InsufficientFundsModal/InputBlocker.offset_left = 0.0
	$InsufficientFundsModal/InputBlocker.offset_top = 0.0
	$InsufficientFundsModal/InputBlocker.offset_right = viewport_size.x
	$InsufficientFundsModal/InputBlocker.offset_bottom = viewport_size.y

	$InsufficientFundsModal/Overlay.offset_left = 0.0
	$InsufficientFundsModal/Overlay.offset_top = 0.0
	$InsufficientFundsModal/Overlay.offset_right = viewport_size.x
	$InsufficientFundsModal/Overlay.offset_bottom = viewport_size.y

	$InsufficientFundsModal/MessagePanel.offset_left = frame_left + (frame_width - popup_width) / 2.0
	$InsufficientFundsModal/MessagePanel.offset_top = frame_top + (frame_height - popup_height) / 2.0
	$InsufficientFundsModal/MessagePanel.offset_right = $InsufficientFundsModal/MessagePanel.offset_left + popup_width
	$InsufficientFundsModal/MessagePanel.offset_bottom = $InsufficientFundsModal/MessagePanel.offset_top + popup_height
