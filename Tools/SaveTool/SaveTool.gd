extends Node

const SavePath = "user://playerSave.cfg"

func _ready():
	print(OS.get_data_dir())
	loadPlayerData()

func initializeNewPlayerData():
	PlayerTool.initializeNewSave()
	savePlayerData()

func loadPlayerData():
	if not FileAccess.file_exists(SavePath):
		initializeNewPlayerData()
		return
	
	var saveData = ConfigFile.new()
	var err = saveData.load(SavePath)
	if err != OK:
		push_error("Failed to load save data")
		return
	
	# Load variables from lines 32 - 69 of PlayerTool.gd
	PlayerTool.projectRatedDifficulty = saveData.get_value("Project", "projectRatedDifficulty", 0.0)
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
	
	PlayerTool.upgrades = saveData.get_value("Lists", "upgrades", [])
	
	# Load workers
	var serialized_workers = saveData.get_value("Lists", "workers", [])
	deserializeWorkers(serialized_workers)

func savePlayerData():
	var saveData = ConfigFile.new()
	
	# Project variables
	saveData.set_value("Project", "projectRatedDifficulty", PlayerTool.projectRatedDifficulty)
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
	
	# Lists
	saveData.set_value("Lists", "upgrades", PlayerTool.upgrades)
	saveData.set_value("Lists", "workers", serializeWorkers())
	
	saveData.save(SavePath)

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