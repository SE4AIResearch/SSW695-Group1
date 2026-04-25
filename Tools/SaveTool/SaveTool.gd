extends Node

const SaveListPath = "user://saves.cfg"
const SaveDirectory = "user://saves/"
const SaveSlots = ["Save Slot 1", "Save Slot 2", "Save Slot 3"]

var current_save_name: String = "Save Slot 1"
var save_list: Array = SaveSlots.duplicate()
var next_new_game_uses_tutorial: bool = false

func _ready():
	print(OS.get_data_dir())
	_ensure_save_directory_exists()
	var legacy_save_list = _load_legacy_save_list()
	legacy_save_list.append_array(_find_unlisted_legacy_saves(legacy_save_list))
	_migrate_legacy_saves(legacy_save_list)
	save_list = SaveSlots.duplicate()
	_save_save_list()
	next_new_game_uses_tutorial = not _has_any_existing_save()
	current_save_name = _first_existing_save_name()
	
	if not PlayerTool.weekResolved.is_connected(savePlayerData):
		PlayerTool.weekResolved.connect(savePlayerData)

func _ensure_save_directory_exists():
	if not DirAccess.dir_exists_absolute(SaveDirectory):
		DirAccess.make_dir_absolute(SaveDirectory)

func _load_legacy_save_list() -> Array:
	if not FileAccess.file_exists(SaveListPath):
		return []
	
	var listFile = ConfigFile.new()
	var err = listFile.load(SaveListPath)
	if err == OK:
		return listFile.get_value("Saves", "list", [])

	return []


func _find_unlisted_legacy_saves(legacy_save_list: Array) -> Array:
	var unlisted_saves = []
	var dir = DirAccess.open(SaveDirectory)
	if dir == null:
		return unlisted_saves

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.get_extension() == "cfg":
			var save_name = file_name.get_basename()
			if save_name not in SaveSlots and save_name not in legacy_save_list and save_name not in unlisted_saves:
				unlisted_saves.append(save_name)
		file_name = dir.get_next()

	unlisted_saves.sort()
	return unlisted_saves


func _migrate_legacy_saves(legacy_save_list: Array) -> void:
	var slot_index = 0
	for legacy_save_name in legacy_save_list:
		if legacy_save_name in SaveSlots:
			continue

		var legacy_path = get_save_path(legacy_save_name)
		if not FileAccess.file_exists(legacy_path):
			continue

		while slot_index < SaveSlots.size() and FileAccess.file_exists(get_save_path(SaveSlots[slot_index])):
			slot_index += 1

		if slot_index >= SaveSlots.size():
			return

		if _copy_save_file(legacy_path, get_save_path(SaveSlots[slot_index])):
			slot_index += 1


func _copy_save_file(source_path: String, target_path: String) -> bool:
	var source_file = FileAccess.open(source_path, FileAccess.READ)
	if source_file == null:
		return false

	var target_file = FileAccess.open(target_path, FileAccess.WRITE)
	if target_file == null:
		return false

	target_file.store_buffer(source_file.get_buffer(source_file.get_length()))
	return true

func _save_save_list():
	var listFile = ConfigFile.new()
	listFile.set_value("Saves", "list", SaveSlots)
	listFile.save(SaveListPath)

func get_save_list() -> Array:
	return SaveSlots.duplicate()

func should_reuse_default_new_game_slot() -> bool:
	return next_new_game_uses_tutorial

func create_new_save(saveName: String):
	if saveName not in SaveSlots:
		push_warning("Unknown save slot: " + saveName)
		return

	var use_tutorial: bool = next_new_game_uses_tutorial
	current_save_name = saveName
	initializeNewPlayerData(use_tutorial)
	next_new_game_uses_tutorial = false

func delete_save(saveName: String):
	if saveName not in SaveSlots:
		push_warning("Unknown save slot: " + saveName)
		return

	var path = get_save_path(saveName)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

	if current_save_name == saveName:
		current_save_name = _first_existing_save_name()

func get_save_path(saveName: String) -> String:
	return SaveDirectory + saveName + ".cfg"

func _has_any_existing_save() -> bool:
	for saveName in SaveSlots:
		if FileAccess.file_exists(get_save_path(saveName)):
			return true
	return false

func _first_existing_save_name() -> String:
	for saveName in SaveSlots:
		if FileAccess.file_exists(get_save_path(saveName)):
			return saveName
	return SaveSlots[0]
	
func get_save_summary(saveName: String) -> Dictionary:
	var path = get_save_path(saveName)
	var summary = {
		"currency": 0.0,
		"completed_project_count": 0,
		"projectName": "",
		"clientName": "",
		"projWeek": 0,
		"sprintLength": 0,
		"projSprint": 0,
		"sprintAmount": 0,
		"exists": false
	}
	
	if not FileAccess.file_exists(path):
		return summary
	
	var saveData = ConfigFile.new()
	var err = saveData.load(path)
	if err == OK:
		summary["exists"] = true
		summary["currency"] = saveData.get_value("Player", "currency", 0.0)
		summary["completed_project_count"] = saveData.get_value("Player", "completed_project_count", 0)
		summary["projectName"] = saveData.get_value("Project", "projectName", "")
		summary["clientName"] = saveData.get_value("Project", "clientName", "")
		summary["projWeek"] = saveData.get_value("Project", "projWeek", 0)
		summary["sprintLength"] = saveData.get_value("Project", "sprintLength", 0)
		summary["projSprint"] = saveData.get_value("Project", "projSprint", 0)
		summary["sprintAmount"] = saveData.get_value("Project", "sprintAmount", 0)
	
	return summary

func initializeNewPlayerData(use_tutorial: bool = false):
	PlayerTool.initializeNewSave()
	PlayerTool.set_new_player_tutorials_enabled(use_tutorial)
	PlayerTool.has_viewed_methodology_learning_center = !use_tutorial
	savePlayerData()

func loadPlayerData(saveName: String = current_save_name):
	current_save_name = saveName
	var path = get_save_path(saveName)
	
	if not FileAccess.file_exists(path):
		return
	
	var saveData = ConfigFile.new()
	var err = saveData.load(path)
	if err != OK:
		push_error("Failed to load save data")
		return
	
	# Load variables from lines 32 - 69 of PlayerTool.gd
	PlayerTool.projectRatedDifficulty = saveData.get_value("Project", "projectRatedDifficulty", 0.0)
	PlayerTool.projectName = saveData.get_value("Project", "projectName", "")
	PlayerTool.methodology = saveData.get_value("Project", "methodology", {})
	PlayerTool.clientName = saveData.get_value("Project", "clientName", "")
	PlayerTool.sprintLength = saveData.get_value("Project", "sprintLength", 0)
	PlayerTool.sprintAmount = saveData.get_value("Project", "sprintAmount", 0)
	PlayerTool.eventChance = saveData.get_value("Project", "eventChance", 0.45)
	PlayerTool.metrics = saveData.get_value("Project", "metrics", {
		"frontEnd": 0,
		"backEnd": 0,
		"documenting": 0,
		"reliability": 0,
		"stakeholderSatisfaction": 0
	})
	PlayerTool.MetricProgress = saveData.get_value("Project", "MetricProgress", {})
	PlayerTool.completedMetrics = saveData.get_value("Project", "completedMetrics", [])
	PlayerTool.weekTime = saveData.get_value("Project", "weekTime", 0)
	PlayerTool.projWeek = saveData.get_value("Project", "projWeek", 0)
	PlayerTool.projSprint = saveData.get_value("Project", "projSprint", 0)
	PlayerTool.FEBacklogStep = saveData.get_value("Project", "FEBacklogStep", 0)
	PlayerTool.BEBacklogStep = saveData.get_value("Project", "BEBacklogStep", 0)
	PlayerTool.docBacklogStep = saveData.get_value("Project", "docBacklogStep", 0)
	PlayerTool.totalEvents = saveData.get_value("Project", "totalEvents", 0)
	
	PlayerTool.teamRank = saveData.get_value("Player", "teamRank", 1)
	PlayerTool.currency = saveData.get_value("Player", "currency", 0.0)
	PlayerTool.score = saveData.get_value("Player", "score", 0)
	PlayerTool.projectAmount = saveData.get_value("Player", "projectAmount", 0)
	PlayerTool.completed_project_count = saveData.get_value("Player", "completed_project_count", 0)
	PlayerTool.has_viewed_methodology_learning_center = saveData.get_value("Player", "has_viewed_methodology_learning_center", false)
	PlayerTool.office_tier = saveData.get_value("Player", "office_tier", 0)
	PlayerTool.max_worker_capacity = saveData.get_value("Player", "max_worker_capacity", 6)
	PlayerTool.remaining_project_choice_names = saveData.get_value("Player", "remaining_project_choice_names", [])
	
	PlayerTool.loopPhase = saveData.get_value("GameState", "loopPhase", "no_project")
	PlayerTool.weekResults = saveData.get_value("GameState", "weekResults", {})
	PlayerTool.selectedAssignments = saveData.get_value("GameState", "selectedAssignments", {})
	PlayerTool.backlogItems = saveData.get_value("GameState", "backlogItems", [])
	PlayerTool.pendingProjectSummary = saveData.get_value("GameState", "pendingProjectSummary", {})
	PlayerTool.sprintGoal = saveData.get_value("GameState", "sprintGoal", {})
	PlayerTool.shouldShowWeekResultsModal = saveData.get_value("GameState", "shouldShowWeekResultsModal", false)
	if saveData.has_section_key("GameState", "tutorial_seen"):
		PlayerTool.tutorial_seen = saveData.get_value("GameState", "tutorial_seen", PlayerTool._default_tutorial_seen(true)) as Dictionary
	else:
		PlayerTool.set_new_player_tutorials_enabled(false)
	
	PlayerTool.upgrades = saveData.get_value("Lists", "upgrades", [])
	
	# Load workers
	var serialized_workers = saveData.get_value("Lists", "workers", [])
	deserializeWorkers(serialized_workers)

func savePlayerData():
	var saveData = ConfigFile.new()
	
	# Project variables
	saveData.set_value("Project", "projectRatedDifficulty", PlayerTool.projectRatedDifficulty)
	saveData.set_value("Project", "projectName", PlayerTool.projectName)
	saveData.set_value("Project", "methodology", PlayerTool.methodology)
	saveData.set_value("Project", "clientName", PlayerTool.clientName)
	saveData.set_value("Project", "sprintLength", PlayerTool.sprintLength)
	saveData.set_value("Project", "sprintAmount", PlayerTool.sprintAmount)
	saveData.set_value("Project", "eventChance", PlayerTool.eventChance)
	saveData.set_value("Project", "metrics", PlayerTool.metrics)
	saveData.set_value("Project", "MetricProgress", PlayerTool.MetricProgress)
	saveData.set_value("Project", "completedMetrics", PlayerTool.completedMetrics)
	saveData.set_value("Project", "weekTime", PlayerTool.weekTime)
	saveData.set_value("Project", "projWeek", PlayerTool.projWeek)
	saveData.set_value("Project", "projSprint", PlayerTool.projSprint)
	saveData.set_value("Project", "FEBacklogStep", PlayerTool.FEBacklogStep)
	saveData.set_value("Project", "BEBacklogStep", PlayerTool.BEBacklogStep)
	saveData.set_value("Project", "docBacklogStep", PlayerTool.docBacklogStep)
	saveData.set_value("Project", "totalEvents", PlayerTool.totalEvents)
	
	# Player variables
	saveData.set_value("Player", "teamRank", PlayerTool.teamRank)
	saveData.set_value("Player", "currency", PlayerTool.currency)
	saveData.set_value("Player", "score", PlayerTool.score)
	saveData.set_value("Player", "projectAmount", PlayerTool.projectAmount)
	saveData.set_value("Player", "completed_project_count", PlayerTool.completed_project_count)
	saveData.set_value("Player", "has_viewed_methodology_learning_center", PlayerTool.has_viewed_methodology_learning_center)
	saveData.set_value("Player", "office_tier", PlayerTool.office_tier)
	saveData.set_value("Player", "max_worker_capacity", PlayerTool.max_worker_capacity)
	saveData.set_value("Player", "remaining_project_choice_names", PlayerTool.remaining_project_choice_names)
	
	# GameState variables
	saveData.set_value("GameState", "loopPhase", PlayerTool.loopPhase)
	saveData.set_value("GameState", "weekResults", PlayerTool.weekResults)
	saveData.set_value("GameState", "selectedAssignments", PlayerTool.selectedAssignments)
	saveData.set_value("GameState", "backlogItems", PlayerTool.backlogItems)
	saveData.set_value("GameState", "pendingProjectSummary", PlayerTool.pendingProjectSummary)
	saveData.set_value("GameState", "sprintGoal", PlayerTool.sprintGoal)
	saveData.set_value("GameState", "shouldShowWeekResultsModal", PlayerTool.shouldShowWeekResultsModal)
	saveData.set_value("GameState", "tutorial_seen", PlayerTool.tutorial_seen)
	
	# Lists
	saveData.set_value("Lists", "upgrades", PlayerTool.upgrades)
	saveData.set_value("Lists", "workers", serializeWorkers())
	
	saveData.save(get_save_path(current_save_name))

func serializeWorkers() -> Array:
	var list = []
	for worker in PlayerTool.workers:
		var w_data = {
			"personName": worker.personName,
			"frontEndStat": worker.frontEndStat,
			"backEndStat": worker.backEndStat,
			"documentingStat": worker.documentingStat,
			"speedStat": worker.speedStat,
			"staminaStat": worker.staminaStat,
			"headSpritePath": worker.headSpritePath,
			"hairSpritePath": worker.hairSpritePath,
			"mouthSpritePath": worker.mouthSpritePath,
			"noseSpritePath": worker.noseSpritePath,
			"eyeSpritePath": worker.eyeSpritePath,
			"headModulate": worker.get_node("headSprite").modulate,
			"noseModulate": worker.get_node("noseSprite").modulate,
			"hairModulate": worker.get_node("hairSprite").modulate
		}
		list.append(w_data)
	return list

func deserializeWorkers(serialized_workers: Array):
	# Clear current workers
	for worker in PlayerTool.workers:
		worker.queue_free()
	PlayerTool.workers.clear()
	
	for w_data in serialized_workers:
		var stats = {
			"front_end": w_data.frontEndStat,
			"back_end": w_data.backEndStat,
			"documenting": w_data.documentingStat,
			"speed": w_data.speedStat,
			"stamina": w_data.staminaStat
		}
		var worker = PersonConstructor.generateWorker(stats)
		worker.personName = w_data.personName
		worker.headSpritePath = w_data.headSpritePath
		worker.hairSpritePath = w_data.hairSpritePath
		worker.mouthSpritePath = w_data.mouthSpritePath
		worker.noseSpritePath = w_data.noseSpritePath
		worker.eyeSpritePath = w_data.eyeSpritePath
		
		worker.get_node("headSprite").texture = load(worker.headSpritePath)
		worker.get_node("hairSprite").texture = load(worker.hairSpritePath)
		worker.get_node("mouthSprite").texture = load(worker.mouthSpritePath)
		worker.get_node("noseSprite").texture = load(worker.noseSpritePath)
		worker.get_node("eyeSprite").texture = load(worker.eyeSpritePath)
		
		worker.get_node("headSprite").modulate = w_data.headModulate
		worker.get_node("noseSprite").modulate = w_data.noseModulate
		worker.get_node("hairSprite").modulate = w_data.hairModulate
		
		PlayerTool.newHire(worker)
