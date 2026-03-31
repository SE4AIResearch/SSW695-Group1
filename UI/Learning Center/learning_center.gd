extends Node2D

var entries = load("res://UI/Learning Center/entries.gd").new()
var currentEntry: Dictionary
var currentPage: int = 0

func _on_sdlc_overview_pressed() -> void: prepPage("sdlc_overview")
func _on_agile_pressed() -> void: prepPage("agile")
func _on_waterfall_pressed() -> void: prepPage("waterfall")
func _on_project_constraints_pressed() -> void: prepPage("project_constraints")
func _on_stakeholder_management_pressed() -> void: prepPage("stakeholder_management")
func _on_sprint_planning_basics_pressed() -> void: prepPage("sprint_planning")
func _on_risk_management_pressed() -> void: prepPage("risk_management")

func prepPage(entry):
	$Categories.visible = false
	$Page.visible = true
	currentEntry = entries.get(entry)
	currentPage = 0
	displayPage()
	pass

func _on_previous_button_pressed() -> void:
	if currentPage > 0:
		currentPage -= 1
		displayPage()
		checkButtons()

func _on_next_button_pressed() -> void:
	if currentPage < currentEntry.size()-1:
		currentPage += 1
		displayPage()
		checkButtons()

func checkButtons():
	if currentPage == 0: $Page/previousButton.disabled = true
	if currentPage > 0: $Page/previousButton.disabled = false
	if currentPage == currentEntry.size()-1: $Page/nextButton.disabled = true
	if currentPage < currentEntry.size()-1: $Page/nextButton.disabled = false
	pass

func displayPage():
	$Page/Entry.text = currentEntry.get(currentPage)
	checkButtons()

func _on_return_to_lc_menu_pressed() -> void:
	$Categories.visible = true
	$Page/Entry.text = ""
	$Page.visible = false
