extends Button

var save_name: String = ""
var currency: float = 0.0
var completed_projects: int = 0
var project_name: String = ""
var client_name: String = ""
var current_week: int = 0
var total_weeks: int = 0
var current_sprint: int = 0
var total_sprints: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if save_name != "":
		var info_text = "[center]Currency: " + str(currency) + "\n"
		info_text += "Projects: " + str(completed_projects) + "\n"
		if project_name != "":
			info_text += "Project: " + project_name + "\n"
			info_text += "Client: " + client_name + "\n"
			info_text += "Week: " + str(current_week) + "/" + str(total_weeks) + " | "
			info_text += "Sprint: " + str(current_sprint) + "/" + str(total_sprints)
		else:
			info_text += "No Current Project"
		info_text += "[/center]"
		$saveInfo.text = info_text


func _on_pressed() -> void:
	if save_name != "":
		SaveTool.loadPlayerData(save_name)
		get_tree().change_scene_to_file("res://Level/mainLevel.tscn")
