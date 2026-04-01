extends Node

const WorkerStats = preload("res://Person/Worker/worker_stats.gd")

var nameList = load("res://Person/names.gd").new()
var textureList = load("res://Person/Textures/textures.gd").new()
var workerItem = preload("res://Person/Worker/Worker.tscn")

var skinColors: Array[Color]

func generateName() -> String:
	var fName: String
	match randi_range(0,1):
		0: fName = nameList.maleFirstNames[randi_range(0,nameList.maleFirstNames.size()-1)]
		1: fName = nameList.femaleFirstNames[randi_range(0,nameList.femaleFirstNames.size()-1)]
	return (fName +" "+nameList.lastNames[randi_range(0,nameList.lastNames.size()-1)])
	
func generateVisuals(person):
	person.headSpritePath = textureList.head[randi_range(0,textureList.head.size()-1)]
	person.hairSpritePath = textureList.hair[randi_range(0,textureList.hair.size()-1)]
	person.mouthSpritePath = textureList.mouth[randi_range(0,textureList.mouth.size()-1)]
	person.noseSpritePath = textureList.nose[randi_range(0,textureList.nose.size()-1)]
	person.eyeSpritePath = textureList.eyes[randi_range(0,textureList.eyes.size()-1)]
	person.get_node("hairSprite").texture = load(person.hairSpritePath)
	person.get_node("headSprite").texture = load(person.headSpritePath)
	person.get_node("noseSprite").texture = load(person.noseSpritePath)
	person.get_node("eyeSprite").texture = load(person.eyeSpritePath)
	person.get_node("mouthSprite").texture = load(person.mouthSpritePath)
	
	#Random Colors for now, Will replace later!
	person.get_node("headSprite").modulate = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))
	person.get_node("noseSprite").modulate = person.get_node("headSprite").modulate
	person.get_node("hairSprite").modulate = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))
	pass

func generateWorkerStats(worker): #CREATE SCALING FOR THIS!
	WorkerStats.apply_to_worker(worker)
	pass

func generateWorker(stats: Dictionary = {}):
	var newHire = workerItem.instantiate()
	newHire.personName = generateName()
	generateVisuals(newHire)
	WorkerStats.apply_to_worker(newHire, stats)
	return newHire
	pass

func generateBudgetWorker(budget: int):
	return generateWorker(WorkerStats.roll_hiring_worker_stats(budget))

func setBasicStats(worker):
	WorkerStats.apply_to_worker(worker)
	pass

func getStartingWorkerStats(workerIndex: int) -> Dictionary:
	return WorkerStats.get_starting_worker_stats(workerIndex)

func getHiringTierForBudget(budget: int) -> Dictionary:
	return WorkerStats.get_hiring_tier_for_budget(budget)

func setStartingWorkerStats(worker, workerIndex: int) -> void:
	WorkerStats.apply_to_worker(worker, getStartingWorkerStats(workerIndex))
	pass
