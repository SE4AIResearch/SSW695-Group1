extends Button

var save_name: String = ""
var currency: float = 0.0
var completed_projects: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)
	if save_name != "":
		var info_text = "[center]Currency: " + str(currency) + "\n"
		info_text += "Projects: " + str(completed_projects) + "[/center]"
		$saveInfo.text = info_text


func _on_pressed() -> void:
	if save_name != "":
		SaveTool.loadPlayerData(save_name)
		get_tree().change_scene_to_file("res://Level/mainLevel.tscn")
