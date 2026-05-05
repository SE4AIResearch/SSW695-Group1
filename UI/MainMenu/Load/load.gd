extends Node2D

var is_new_game_selection: bool = false
var tutorial_modal_scene: PackedScene = preload("res://UI/InGame/TutorialModal/TutorialModal.tscn")

const OVERWRITE_TITLE := "Overwrite Save?"
const OVERWRITE_MESSAGE := "Starting a new game in this slot will overwrite the existing save data with a new save. This cannot be undone."
const OVERWRITE_CONFIRM_TEXT := "Overwrite"
const OVERWRITE_CANCEL_TEXT := "Cancel"

var _overwrite_modal: TutorialModalPanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(SaveTool.get_save_list().size()):
		var button = get_node_or_null("saveButton" + str(i + 1))
		if button:
			button.self_modulate = Color(randf_range(0.4, 1.0), randf_range(0.4, 1.0), randf_range(0.4, 1.0))
	update_save_buttons()


func update_save_buttons() -> void:
	var saves = SaveTool.get_save_list()
	for i in range(saves.size()):
		var save_name = saves[i]
		var button = get_node_or_null("saveButton" + str(i + 1))
		var delete_button = get_node_or_null("delete" + str(i + 1))
		if button:
			var summary = SaveTool.get_save_summary(save_name)
			_set_button_info(button, save_name, summary)
			if delete_button:
				delete_button.disabled = not summary.exists


func _set_button_info(button: Button, save_name: String, summary: Dictionary) -> void:
	var save_info = button.get_node_or_null("saveInfo")
	if not save_info:
		return

	if summary.exists:
		button.disabled = false
		var info_text = "[center]Currency: " + str(summary.currency) + "\n"
		info_text += "Projects: " + str(summary.completed_project_count) + "\n"
		if summary.projectName != "":
			info_text += "Project: " + summary.projectName + "\n"
			info_text += "Client: " + summary.clientName + "\n"
			info_text += "Week: " + str(summary.projWeek) + "/" + str(summary.sprintLength) + " | "
			info_text += "Sprint: " + str(summary.projSprint) + "/" + str(summary.sprintAmount)
		else:
			info_text += "No Current Project"
		info_text += "[/center]"
		save_info.text = info_text
	else:
		button.disabled = not is_new_game_selection
		save_info.text = "[center]\n\nEmpty Slot\n\n[/center]"


func _handle_save_selection(slot_index: int) -> void:
	var saves = SaveTool.get_save_list()
	if slot_index < 0 or slot_index >= saves.size():
		return

	var save_name = saves[slot_index]
	if is_new_game_selection:
		var summary = SaveTool.get_save_summary(save_name)
		if summary.exists:
			_show_overwrite_confirmation(save_name)
			return
		_start_new_game(save_name)
	else:
		var summary = SaveTool.get_save_summary(save_name)
		if summary.exists:
			SaveTool.loadPlayerData(save_name)
			get_tree().change_scene_to_file("res://Level/mainLevel.tscn")


func _handle_delete(slot_index: int) -> void:
	var saves = SaveTool.get_save_list()
	if slot_index < 0 or slot_index >= saves.size():
		return

	SaveTool.delete_save(saves[slot_index])
	update_save_buttons()


func _show_overwrite_confirmation(save_name: String) -> void:
	if _overwrite_modal != null and is_instance_valid(_overwrite_modal):
		return

	var modal: TutorialModalPanel = tutorial_modal_scene.instantiate() as TutorialModalPanel
	_get_tutorial_modal_parent().add_child(modal)
	modal.setup(
		OVERWRITE_TITLE,
		OVERWRITE_MESSAGE,
		OVERWRITE_CONFIRM_TEXT,
		show_stamina_examples: false,
		secondary_button_text: OVERWRITE_CANCEL_TEXT
	)
	modal.confirmed.connect(_on_overwrite_confirmed.bind(save_name), CONNECT_ONE_SHOT)
	modal.dismissed.connect(_on_overwrite_modal_dismissed, CONNECT_ONE_SHOT)
	_overwrite_modal = modal


func _on_overwrite_confirmed(save_name: String) -> void:
	_start_new_game(save_name)


func _on_overwrite_modal_dismissed() -> void:
	_overwrite_modal = null


func _start_new_game(save_name: String) -> void:
	SaveTool.create_new_save(save_name)
	get_tree().change_scene_to_file("res://Level/mainLevel.tscn")


func _get_tutorial_modal_parent() -> Node:
	var scene_root: Node = get_tree().current_scene
	if scene_root != null:
		var ui_layer: Node = scene_root.get_node_or_null("UI")
		if ui_layer != null:
			return ui_layer
	return self


func _on_save_button_1_pressed() -> void:
	_handle_save_selection(0)


func _on_save_button_2_pressed() -> void:
	_handle_save_selection(1)


func _on_save_button_3_pressed() -> void:
	_handle_save_selection(2)


func _on_delete_1_pressed() -> void:
	_handle_delete(0)


func _on_delete_2_pressed() -> void:
	_handle_delete(1)


func _on_delete_3_pressed() -> void:
	_handle_delete(2)
