extends Node2D

var loadItem = load("res://UI/MainMenu/Load/loadItem/loadItem.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate_save_list()


func populate_save_list() -> void:
	# Clear existing items if any
	for child in $VBoxContainer.get_children():
		child.queue_free()
	
	var saves = SaveTool.get_save_list()
	for save_name in saves:
		var item = loadItem.instantiate()
		item.save_name = save_name
		
		var summary = SaveTool.get_save_summary(save_name)
		item.currency = summary.currency
		item.completed_projects = summary.completed_project_count
		item.project_name = summary.projectName
		item.client_name = summary.clientName
		item.current_week = summary.projWeek
		item.total_weeks = summary.sprintLength
		item.current_sprint = summary.projSprint
		item.total_sprints = summary.sprintAmount
		
		$VBoxContainer.add_child(item)
